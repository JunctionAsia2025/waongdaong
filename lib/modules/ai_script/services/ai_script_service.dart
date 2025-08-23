import 'package:uuid/uuid.dart';
import '../models/ai_script_model.dart';
import 'ai_api_service.dart';
import 'ai_script_database_service.dart';

/// AI 스크립트 생성 및 관리를 담당하는 메인 서비스
/// 사용자 입력을 받아 AI API를 통해 영어 스크립트를 생성하고 데이터베이스에 저장
class AiScriptService {
  final AiApiService _aiApiService;
  final AiScriptDatabaseService _databaseService;
  final Uuid _uuid = const Uuid();

  AiScriptService({
    required AiApiService aiApiService,
    required AiScriptDatabaseService databaseService,
  }) : _aiApiService = aiApiService,
       _databaseService = databaseService;

  /// 한국어 입력을 받아 영어 스크립트 생성
  /// 1. AI API를 통해 번역 수행
  /// 2. 결과를 데이터베이스에 저장
  /// 3. AiScript 객체 반환
  Future<AiScriptGenerationResult> generateEnglishScript({
    required String studySessionId,
    required String userId,
    required String koreanInput,
    bool saveToDatabase = true,
    bool checkExisting = true,
  }) async {
    try {
      // 입력값 검증
      if (koreanInput.trim().isEmpty) {
        return AiScriptGenerationResult.error('한국어 입력이 비어있습니다.');
      }

      // 기존 스크립트 확인 (선택적)
      if (checkExisting) {
        final existingScript = await _databaseService.findExistingScript(
          userId: userId,
          koreanInput: koreanInput.trim(),
        );

        if (existingScript != null) {
          return AiScriptGenerationResult.success(
            existingScript,
            isFromCache: true,
          );
        }
      }

      // AI API를 통한 영어 스크립트 생성
      final aiResponse = await _aiApiService.generateEnglishScript(
        koreanInput.trim(),
      );

      if (!aiResponse.success) {
        return AiScriptGenerationResult.error(
          aiResponse.errorMessage ?? 'AI 스크립트 생성에 실패했습니다.',
        );
      }

      // 데이터베이스에 저장 (선택적)
      AiScript? savedScript;
      if (saveToDatabase) {
        savedScript = await _databaseService.saveAiScript(
          studySessionId: studySessionId,
          userId: userId,
          koreanInput: koreanInput.trim(),
          englishScript: aiResponse.englishScript,
        );

        if (savedScript == null) {
          // 저장에 실패했지만 AI 응답은 성공한 경우
          // 임시 AiScript 객체 생성
          savedScript = AiScript(
            id: _uuid.v4(),
            studySessionId: studySessionId,
            userId: userId,
            koreanInput: koreanInput.trim(),
            englishScript: aiResponse.englishScript,
            createdAt: DateTime.now(),
          );
        }
      } else {
        // 저장하지 않는 경우 임시 객체 생성
        savedScript = AiScript(
          id: _uuid.v4(),
          studySessionId: studySessionId,
          userId: userId,
          koreanInput: koreanInput.trim(),
          englishScript: aiResponse.englishScript,
          createdAt: DateTime.now(),
        );
      }

      return AiScriptGenerationResult.success(savedScript);
    } catch (e) {
      return AiScriptGenerationResult.error('예상치 못한 오류가 발생했습니다: $e');
    }
  }

  /// 사용자의 AI 스크립트 히스토리 조회
  Future<List<AiScript>> getUserScriptHistory(String userId) async {
    return await _databaseService.getAiScriptsByUserId(userId);
  }

  /// 특정 스터디 세션의 AI 스크립트 목록 조회
  Future<List<AiScript>> getSessionScripts(String sessionId) async {
    return await _databaseService.getAiScriptsBySessionId(sessionId);
  }

  /// 최근 AI 스크립트 조회
  Future<List<AiScript>> getRecentScripts(
    String userId, {
    int limit = 10,
  }) async {
    return await _databaseService.getRecentAiScripts(userId, limit: limit);
  }

  /// AI 스크립트 삭제
  Future<bool> deleteScript(String scriptId) async {
    return await _databaseService.deleteAiScript(scriptId);
  }

  /// 특정 AI 스크립트 조회
  Future<AiScript?> getScript(String scriptId) async {
    return await _databaseService.getAiScriptById(scriptId);
  }

  /// 빠른 번역 (데이터베이스 저장 없이)
  /// 실시간 대화 중 즉석에서 사용할 때 유용
  Future<String?> quickTranslate(String koreanInput) async {
    if (koreanInput.trim().isEmpty) return null;

    final response = await _aiApiService.generateEnglishScript(
      koreanInput.trim(),
    );
    return response.success ? response.englishScript : null;
  }
}

/// AI 스크립트 생성 결과를 담는 클래스
class AiScriptGenerationResult {
  final AiScript? script;
  final String? errorMessage;
  final bool success;
  final bool isFromCache;

  AiScriptGenerationResult._({
    this.script,
    this.errorMessage,
    required this.success,
    this.isFromCache = false,
  });

  factory AiScriptGenerationResult.success(
    AiScript script, {
    bool isFromCache = false,
  }) {
    return AiScriptGenerationResult._(
      script: script,
      success: true,
      isFromCache: isFromCache,
    );
  }

  factory AiScriptGenerationResult.error(String errorMessage) {
    return AiScriptGenerationResult._(
      errorMessage: errorMessage,
      success: false,
    );
  }
}
