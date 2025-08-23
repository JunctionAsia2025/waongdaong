import '../ai/ai_module.dart';
import 'services/ai_topic_service.dart';

/// AI 토론 주제 모듈
/// 의존성 주입 및 서비스 인스턴스 관리를 담당
class AiTopicModule {
  static AiTopicModule? _instance;

  late final AIModule _aiModule;
  late final AITopicService _aiTopicService;

  AiTopicModule._();

  /// 싱글톤 인스턴스
  static AiTopicModule get instance {
    _instance ??= AiTopicModule._();
    return _instance!;
  }

  /// 모듈 초기화
  /// AI 모듈이 먼저 초기화되어야 함
  Future<void> initialize(AIModule aiModule) async {
    _aiModule = aiModule;

    // AI 토론 주제 서비스 인스턴스 생성
    _aiTopicService = AITopicService(_aiModule);
  }

  /// AI 모듈 접근자
  AIModule get aiModule {
    _ensureInitialized();
    return _aiModule;
  }

  /// AI 토론 주제 서비스 접근자
  AITopicService get aiTopicService {
    _ensureInitialized();
    return _aiTopicService;
  }

  /// 초기화 여부 확인
  void _ensureInitialized() {
    // late final 필드는 초기화되지 않으면 자동으로 에러를 발생시킴
    // 따라서 별도의 null 체크가 필요하지 않음
  }

  /// 모듈 리셋 (테스트용)
  void reset() {
    _instance = null;
  }
}
