import '../ai/services/ai_api_service.dart';
import 'controllers/ai_trans_controller.dart';
import 'services/ai_trans_service.dart';

/// AI 번역 모듈
class AiTransModule {
  static AiTransModule? _instance;
  static AiTransModule get instance => _instance ??= AiTransModule._();

  AiTransModule._();

  late AiTransService _aiTransService;
  late AiTransController _aiTransController;

  /// 모듈 초기화
  void initialize(AIApiService aiApiService) {
    print('🔧 AiTransModule 초기화 시작');

    _aiTransService = AiTransService(aiApiService);
    _aiTransController = AiTransController(_aiTransService);

    print('✅ AiTransModule 초기화 완료');
  }

  /// AI 번역 서비스 인스턴스
  AiTransService get aiTransService => _aiTransService;

  /// AI 번역 컨트롤러 인스턴스
  AiTransController get aiTransController => _aiTransController;
}
