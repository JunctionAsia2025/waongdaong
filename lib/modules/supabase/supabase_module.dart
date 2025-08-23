import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/storage_service.dart';

/// Supabase 모듈의 메인 클래스
/// 공통적인 Supabase 기능만 제공합니다.
class SupabaseModule {
  static SupabaseModule? _instance;
  static SupabaseModule get instance => _instance ??= SupabaseModule._();

  SupabaseModule._();

  late final AuthService _authService;
  late final DatabaseService _databaseService;
  late final StorageService _storageService;

  /// 모듈 초기화
  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );

    _authService = AuthService();
    _databaseService = DatabaseService();
    _storageService = StorageService();
  }

  /// 인증 서비스 접근자
  AuthService get auth => _authService;

  /// 데이터베이스 서비스 접근자
  DatabaseService get database => _databaseService;

  /// 스토리지 서비스 접근자
  StorageService get storage => _storageService;

  /// Supabase 클라이언트 직접 접근
  SupabaseClient get client => Supabase.instance.client;

  /// 모듈이 초기화되었는지 확인
  bool get isInitialized => true;
}
