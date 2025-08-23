import 'package:flutter/foundation.dart';
import '../models/ai_script_model.dart';
import '../services/ai_script_service.dart';
import '../ai_script_module.dart';

/// AI 스크립트 컨트롤러
/// UI와 서비스 레이어 사이의 상태 관리 및 비즈니스 로직 처리
class AiScriptController extends ChangeNotifier {
  final AiScriptService _aiScriptService;

  // 상태 관리
  bool _isLoading = false;
  String? _errorMessage;
  List<AiScript> _scripts = [];
  AiScript? _currentScript;

  AiScriptController()
    : _aiScriptService = AiScriptModule.instance.aiScriptService;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AiScript> get scripts => List.unmodifiable(_scripts);
  AiScript? get currentScript => _currentScript;
  bool get hasError => _errorMessage != null;

  /// 한국어 입력으로 영어 스크립트 생성
  Future<AiScript?> generateScript({
    required String studySessionId,
    required String userId,
    required String koreanInput,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _aiScriptService.generateEnglishScript(
        studySessionId: studySessionId,
        userId: userId,
        koreanInput: koreanInput,
      );

      if (result.success && result.script != null) {
        _currentScript = result.script;

        // 스크립트 목록에 추가 (중복 방지)
        final existingIndex = _scripts.indexWhere(
          (s) => s.id == result.script!.id,
        );
        if (existingIndex >= 0) {
          _scripts[existingIndex] = result.script!;
        } else {
          _scripts.insert(0, result.script!);
        }

        notifyListeners();
        return result.script;
      } else {
        _setError(result.errorMessage ?? '스크립트 생성에 실패했습니다.');
        return null;
      }
    } catch (e) {
      _setError('예상치 못한 오류가 발생했습니다: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 빠른 번역 (저장 없이)
  Future<String?> quickTranslate(String koreanInput) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _aiScriptService.quickTranslate(koreanInput);
      return result;
    } catch (e) {
      _setError('번역 중 오류가 발생했습니다: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 사용자의 스크립트 히스토리 로드
  Future<void> loadUserScripts(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final scripts = await _aiScriptService.getUserScriptHistory(userId);
      _scripts = scripts;
      notifyListeners();
    } catch (e) {
      _setError('스크립트 히스토리 로드 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 최근 스크립트 로드
  Future<void> loadRecentScripts(String userId, {int limit = 10}) async {
    _setLoading(true);
    _clearError();

    try {
      final scripts = await _aiScriptService.getRecentScripts(
        userId,
        limit: limit,
      );
      _scripts = scripts;
      notifyListeners();
    } catch (e) {
      _setError('최근 스크립트 로드 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 세션의 스크립트 로드
  Future<void> loadSessionScripts(String sessionId) async {
    _setLoading(true);
    _clearError();

    try {
      final scripts = await _aiScriptService.getSessionScripts(sessionId);
      _scripts = scripts;
      notifyListeners();
    } catch (e) {
      _setError('세션 스크립트 로드 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 스크립트 삭제
  Future<bool> deleteScript(String scriptId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _aiScriptService.deleteScript(scriptId);

      if (success) {
        _scripts.removeWhere((script) => script.id == scriptId);

        // 현재 스크립트가 삭제된 스크립트라면 클리어
        if (_currentScript?.id == scriptId) {
          _currentScript = null;
        }

        notifyListeners();
      } else {
        _setError('스크립트 삭제에 실패했습니다.');
      }

      return success;
    } catch (e) {
      _setError('스크립트 삭제 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 현재 스크립트 설정
  void setCurrentScript(AiScript? script) {
    _currentScript = script;
    notifyListeners();
  }

  /// 스크립트 목록 클리어
  void clearScripts() {
    _scripts.clear();
    _currentScript = null;
    notifyListeners();
  }

  /// 오류 메시지 클리어
  void clearError() {
    _clearError();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// AI 스크립트 상태를 나타내는 열거형
enum AiScriptState { idle, generating, success, error }

/// AI 스크립트 UI 상태
class AiScriptUiState {
  final AiScriptState state;
  final String? errorMessage;
  final AiScript? currentScript;
  final List<AiScript> scripts;

  const AiScriptUiState({
    required this.state,
    this.errorMessage,
    this.currentScript,
    this.scripts = const [],
  });

  AiScriptUiState copyWith({
    AiScriptState? state,
    String? errorMessage,
    AiScript? currentScript,
    List<AiScript>? scripts,
  }) {
    return AiScriptUiState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      currentScript: currentScript ?? this.currentScript,
      scripts: scripts ?? this.scripts,
    );
  }
}
