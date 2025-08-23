import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'models/auth_user.dart';

/// Auth 모듈 - 인증 및 사용자 관리
class AuthModule {
  static const String name = 'Auth';
  static const String version = '1.0.0';

  late final AuthService _authService;

  AuthModule(SupabaseClient supabaseClient) {
    _authService = AuthService(supabaseClient);
  }

  /// Auth 서비스 가져오기
  AuthService get authService => _authService;

  /// 현재 인증된 사용자 가져오기
  AppUser? get currentUser => _authService.currentUser;

  /// 로그인 상태 확인
  bool get isAuthenticated => _authService.isAuthenticated;

  /// 모듈 초기화
  Future<void> initialize() async {
    // Auth 모듈 초기화 로직
    // 예: 자동 로그인, 토큰 갱신 등
  }

  /// 모듈 정리
  Future<void> dispose() async {
    // Auth 모듈 정리 로직
  }
}
