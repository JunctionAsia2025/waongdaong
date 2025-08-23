import 'package:flutter/foundation.dart';
import '../models/ai_script.dart';
import '../services/ai_script_service.dart';
import '../ai_script_module.dart';

/// AI 스크립트 컨트롤러
/// UI와 서비스 레이어 사이의 상태 관리 및 비즈니스 로직 처리
class AiScriptController extends ChangeNotifier {
  final AIScriptService _aiScriptService;

  // 상태 관리
  bool _isLoading = false;
  String? _errorMessage;
  List<AIScript> _scripts = [];
  AIScript? _currentScript;

  AiScriptController()
    : _aiScriptService = AiScriptModule.instance.aiScriptService;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AIScript> get scripts => List.unmodifiable(_scripts);
  AIScript? get currentScript => _currentScript;
  bool get hasError => _errorMessage != null;

  /// 한국어 입력으로 영어 스크립트 생성
  Future<AIScript?> generateScript({
    required String userId,
    required String koreanInput,
    String? basicPrompt,
    String? context,
    String? difficulty,
    String? topic,
    String? studyGroupId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _aiScriptService.generateScript(
        userId: userId,
        koreanInput: koreanInput,
        basicPrompt: basicPrompt,
        context: context,
        difficulty: difficulty,
        topic: topic,
        studyGroupId: studyGroupId,
      );

      if (result.isSuccess && result.dataOrNull != null) {
        _currentScript = result.dataOrNull!;

        // 스크립트 목록에 추가 (중복 방지)
        final existingIndex = _scripts.indexWhere(
          (s) => s.id == result.dataOrNull!.id,
        );
        if (existingIndex >= 0) {
          _scripts[existingIndex] = result.dataOrNull!;
        } else {
          _scripts.insert(0, result.dataOrNull!);
        }

        notifyListeners();
        return result.dataOrNull;
      } else {
        _setError(result.errorMessageOrNull ?? '스크립트 생성에 실패했습니다.');
        return null;
      }
    } catch (e) {
      _setError('예상치 못한 오류가 발생했습니다: $e');
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
      final result = await _aiScriptService.getScripts(userId: userId);
      if (result.isSuccess) {
        _scripts = result.dataOrNull ?? [];
        notifyListeners();
      } else {
        _setError(result.errorMessageOrNull ?? '스크립트 히스토리 로드에 실패했습니다.');
      }
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
      final result = await _aiScriptService.getScripts(
        userId: userId,
        pageSize: limit,
      );
      if (result.isSuccess) {
        _scripts = result.dataOrNull ?? [];
        notifyListeners();
      } else {
        _setError(result.errorMessageOrNull ?? '최근 스크립트 로드에 실패했습니다.');
      }
    } catch (e) {
      _setError('최근 스크립트 로드 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 스터디그룹의 스크립트 로드
  Future<void> loadStudyGroupScripts(String studyGroupId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _aiScriptService.getScripts(
        studyGroupId: studyGroupId,
      );
      if (result.isSuccess) {
        _scripts = result.dataOrNull ?? [];
        notifyListeners();
      } else {
        _setError(result.errorMessageOrNull ?? '스터디그룹 스크립트 로드에 실패했습니다.');
      }
    } catch (e) {
      _setError('스터디그룹 스크립트 로드 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 스크립트 삭제
  Future<bool> deleteScript(String scriptId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _aiScriptService.deleteScript(scriptId);

      if (result.isSuccess) {
        _scripts.removeWhere((script) => script.id == scriptId);

        // 현재 스크립트가 삭제된 스크립트라면 클리어
        if (_currentScript?.id == scriptId) {
          _currentScript = null;
        }

        notifyListeners();
        return true;
      } else {
        _setError(result.errorMessageOrNull ?? '스크립트 삭제에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('스크립트 삭제 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 스크립트 업데이트
  Future<bool> updateScript({
    required String scriptId,
    String? koreanInput,
    String? englishScript,
    String? basicPrompt,
    String? context,
    String? difficulty,
    String? topic,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _aiScriptService.updateScript(
        scriptId: scriptId,
        koreanInput: koreanInput,
        englishScript: englishScript,
        basicPrompt: basicPrompt,
        context: context,
        difficulty: difficulty,
        topic: topic,
      );

      if (result.isSuccess && result.dataOrNull != null) {
        // 스크립트 목록에서 업데이트
        final index = _scripts.indexWhere((s) => s.id == scriptId);
        if (index >= 0) {
          _scripts[index] = result.dataOrNull!;
        }

        // 현재 스크립트가 업데이트된 스크립트라면 업데이트
        if (_currentScript?.id == scriptId) {
          _currentScript = result.dataOrNull!;
        }

        notifyListeners();
        return true;
      } else {
        _setError(result.errorMessageOrNull ?? '스크립트 업데이트에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('스크립트 업데이트 중 오류가 발생했습니다: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 현재 스크립트 설정
  void setCurrentScript(AIScript? script) {
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
  final AIScript? currentScript;
  final List<AIScript> scripts;

  const AiScriptUiState({
    required this.state,
    this.errorMessage,
    this.currentScript,
    this.scripts = const [],
  });

  AiScriptUiState copyWith({
    AiScriptState? state,
    String? errorMessage,
    AIScript? currentScript,
    List<AIScript>? scripts,
  }) {
    return AiScriptUiState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      currentScript: currentScript ?? this.currentScript,
      scripts: scripts ?? this.scripts,
    );
  }
}
