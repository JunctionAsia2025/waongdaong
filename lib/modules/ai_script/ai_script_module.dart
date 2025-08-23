import '../supabase/supabase_module.dart';
import 'services/ai_api_service.dart';
import 'services/ai_script_database_service.dart';
import 'services/ai_script_service.dart';

/// AI 스크립트 모듈
/// 의존성 주입 및 서비스 인스턴스 관리를 담당
class AiScriptModule {
  static AiScriptModule? _instance;

  late final AiApiService _aiApiService;
  late final AiScriptDatabaseService _databaseService;
  late final AiScriptService _aiScriptService;

  AiScriptModule._();

  /// 싱글톤 인스턴스
  static AiScriptModule get instance {
    _instance ??= AiScriptModule._();
    return _instance!;
  }

  /// 모듈 초기화
  /// Supabase 모듈이 먼저 초기화되어야 함
  void initialize({bool useMockApi = false}) {
    final supabaseClient = SupabaseModule.instance.client;

    // 서비스 인스턴스 생성
    _aiApiService = useMockApi ? MockAiApiService() : AiApiService();
    _databaseService = AiScriptDatabaseService(supabaseClient);
    _aiScriptService = AiScriptService(
      aiApiService: _aiApiService,
      databaseService: _databaseService,
    );
  }

  /// AI API 서비스 접근자
  AiApiService get aiApiService {
    _ensureInitialized();
    return _aiApiService;
  }

  /// 데이터베이스 서비스 접근자
  AiScriptDatabaseService get databaseService {
    _ensureInitialized();
    return _databaseService;
  }

  /// AI 스크립트 서비스 접근자
  AiScriptService get aiScriptService {
    _ensureInitialized();
    return _aiScriptService;
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
