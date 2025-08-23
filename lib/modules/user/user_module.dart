import '../supabase/supabase_module.dart';
import 'repositories/user_repository.dart';
import 'services/user_service.dart';

/// 사용자 모듈
/// 사용자 관련 모든 기능을 관리합니다.
class UserModule {
  static UserModule? _instance;
  static UserModule get instance => _instance ??= UserModule._();

  UserModule._();

  late final UserRepository _userRepository;
  late final UserService _userService;

  /// 모듈 초기화
  Future<void> initialize() async {
    // Supabase 모듈이 초기화되었는지 확인
    if (!SupabaseModule.instance.isInitialized) {
      throw Exception('Supabase 모듈이 먼저 초기화되어야 합니다.');
    }

    _userRepository = UserRepository();
    _userService = UserService(SupabaseModule.instance.client);
  }

  /// 모듈 정리
  Future<void> dispose() async {
    // 필요한 정리 작업이 있다면 여기에 구현
  }

  /// 사용자 리포지토리 접근자
  UserRepository get repository => _userRepository;

  /// 사용자 서비스 접근자
  UserService get service => _userService;

  /// 현재 로그인된 사용자 이름
  String? get currentUsername => SupabaseModule.instance.auth.currentUsername;

  /// 사용자가 로그인되어 있는지 확인
  bool get isAuthenticated => SupabaseModule.instance.auth.isAuthenticated;
}
