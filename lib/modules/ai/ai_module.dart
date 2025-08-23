import 'services/ai_api_service.dart';

/// AI Module - AI 관련 기능을 제공
class AIModule {
  late final AIApiService _aiApiService;

  AIModule();

  /// 모듈 초기화
  Future<void> initialize() async {
    _aiApiService = AIApiService();
  }

  /// 모듈 정리
  Future<void> dispose() async {
    // 필요한 정리 작업이 있다면 여기에 구현
  }

  /// AIApiService 가져오기
  AIApiService get aiApiService => _aiApiService;
}
