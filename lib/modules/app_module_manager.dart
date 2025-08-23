import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/core_module.dart';
import 'auth/auth_module.dart';
import 'content/content_module.dart';
import 'learning/learning_module.dart';
import 'study/study_module.dart';
import 'user/user_module.dart';
import 'report/report_module.dart';
import 'point/point_module.dart';
import 'ai/ai_module.dart';

/// 앱 전체 모듈을 관리하는 매니저
class AppModuleManager {
  static AppModuleManager? _instance;
  static AppModuleManager get instance => _instance ??= AppModuleManager._();

  AppModuleManager._();

  late final SupabaseClient _supabaseClient;
  late final CoreModule _coreModule;
  late final AuthModule _authModule;
  late final ContentModule _contentModule;
  late final LearningModule _learningModule;
  late final StudyModule _studyModule;
  late final UserModule _userModule;
  late final ReportModule _reportModule;
  late final PointModule _pointModule;
  late final AIModule _aiModule;

  bool _isInitialized = false;

  /// Supabase 클라이언트 가져오기
  SupabaseClient get supabaseClient => _supabaseClient;

  /// Core 모듈 가져오기
  CoreModule get coreModule => _coreModule;

  /// Auth 모듈 가져오기
  AuthModule get authModule => _authModule;

  /// Content 모듈 가져오기
  ContentModule get contentModule => _contentModule;

  /// Learning 모듈 가져오기
  LearningModule get learningModule => _learningModule;

  /// Study 모듈 가져오기
  StudyModule get studyModule => _studyModule;

  /// User 모듈 가져오기
  UserModule get userModule => _userModule;

  /// Report 모듈 가져오기
  ReportModule get reportModule => _reportModule;

  /// Point 모듈 가져오기
  PointModule get pointModule => _pointModule;

  /// AI 모듈 가져오기
  AIModule get aiModule => _aiModule;

  /// 초기화 상태 확인
  bool get isInitialized => _isInitialized;

  /// 모듈 매니저 초기화
  Future<void> initialize(SupabaseClient supabaseClient) async {
    if (_isInitialized) return;

    try {
      _supabaseClient = supabaseClient;

      // Core 모듈 초기화
      await CoreModule.initialize();

      // 각 모듈 인스턴스 생성
      _coreModule = CoreModule();
      _authModule = AuthModule(_supabaseClient);
      _contentModule = ContentModule(_supabaseClient);
      _learningModule = LearningModule(_supabaseClient);
      _studyModule = StudyModule(_supabaseClient);
      _userModule = UserModule.instance;
      _reportModule = ReportModule(_supabaseClient);
      _pointModule = PointModule(_supabaseClient);
      _aiModule = AIModule();

      // 각 모듈 초기화
      await Future.wait([
        _authModule.initialize(),
        _contentModule.initialize(),
        _learningModule.initialize(),
        _studyModule.initialize(),
        _userModule.initialize(),
        _reportModule.initialize(),
        _pointModule.initialize(),
        _aiModule.initialize(),
      ]);

      _isInitialized = true;

      // print('✅ 모든 모듈이 성공적으로 초기화되었습니다.');
    } catch (e) {
      // print('❌ 모듈 초기화 중 오류가 발생했습니다: $e');
      rethrow;
    }
  }

  /// 모듈 매니저 정리
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      // 각 모듈 정리
      await Future.wait([
        _authModule.dispose(),
        _contentModule.dispose(),
        _learningModule.dispose(),
        _studyModule.dispose(),
        _userModule.dispose(),
        _reportModule.dispose(),
        _pointModule.dispose(),
        _aiModule.dispose(),
      ]);

      // Core 모듈 정리
      await CoreModule.dispose();

      _isInitialized = false;

      // print('✅ 모든 모듈이 성공적으로 정리되었습니다.');
    } catch (e) {
      // print('❌ 모듈 정리 중 오류가 발생했습니다: $e');
      rethrow;
    }
  }

  /// 특정 모듈 상태 확인
  bool isModuleReady(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'core':
        return _isInitialized;
      case 'auth':
        return _isInitialized;
      case 'content':
        return _isInitialized;
      case 'learning':
        return _isInitialized;
      case 'study':
        return _isInitialized;
      default:
        return false;
    }
  }

  /// 모듈 상태 요약
  Map<String, bool> getModuleStatus() {
    return {
      'core': isModuleReady('core'),
      'auth': isModuleReady('auth'),
      'content': isModuleReady('content'),
      'learning': isModuleReady('learning'),
      'study': isModuleReady('study'),
    };
  }
}
