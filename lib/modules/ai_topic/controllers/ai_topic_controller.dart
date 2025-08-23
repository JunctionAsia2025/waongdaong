import 'package:flutter/foundation.dart';
import '../models/discussion_topics.dart';
import '../services/ai_topic_service.dart';
import '../ai_topic_module.dart';

/// AI 토론 주제 컨트롤러
/// UI와 서비스 레이어 사이의 상태 관리 및 비즈니스 로직 처리
class AiTopicController extends ChangeNotifier {
  final AITopicService _aiTopicService;

  // 상태 관리
  bool _isLoading = false;
  String? _errorMessage;
  DiscussionTopics? _currentTopics;

  AiTopicController() : _aiTopicService = AiTopicModule.instance.aiTopicService;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DiscussionTopics? get currentTopics => _currentTopics;
  bool get hasError => _errorMessage != null;

  /// 콘텐츠 기반 토론 주제 3개 생성
  Future<DiscussionTopics?> generateDiscussionTopics({
    required String contentText,
    required String contentType,
    String? additionalContext,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _aiTopicService.generateDiscussionTopics(
        contentText: contentText,
        contentType: contentType,
        additionalContext: additionalContext,
      );

      if (result.isSuccess && result.dataOrNull != null) {
        _currentTopics = result.dataOrNull!;
        notifyListeners();
        return result.dataOrNull;
      } else {
        _setError(result.errorMessageOrNull ?? '토론 주제 생성에 실패했습니다.');
        return null;
      }
    } catch (e) {
      _setError('예상치 못한 오류가 발생했습니다: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 현재 토론 주제 설정
  void setCurrentTopics(DiscussionTopics? topics) {
    _currentTopics = topics;
    notifyListeners();
  }

  /// 토론 주제 클리어
  void clearTopics() {
    _currentTopics = null;
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
