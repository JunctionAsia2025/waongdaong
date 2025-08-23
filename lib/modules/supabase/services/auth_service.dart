import 'package:supabase_flutter/supabase_flutter.dart';

/// 간단한 사용자 이름 기반 인증 서비스
class AuthService {
  AuthService();

  // 현재 로그인된 사용자 정보 (메모리에 저장)
  String? _currentUsername;

  /// 현재 사용자 이름
  String? get currentUsername => _currentUsername;

  /// 로그인 상태 확인
  bool get isAuthenticated => _currentUsername != null;

  /// 사용자 ID (사용자 이름을 ID로 사용)
  String? get userId => _currentUsername;

  /// 사용자 이메일 (사용자 이름을 이메일로 사용)
  String? get userEmail => _currentUsername;

  /// 사용자 이름으로 로그인
  Future<bool> signInWithUsername(String username) async {
    try {
      // 사용자 이름 중복 확인
      final existingUser =
          await Supabase.instance.client
              .from('users')
              .select('username')
              .eq('username', username)
              .maybeSingle();

      if (existingUser != null) {
        // 기존 사용자: 로그인 성공
        _currentUsername = username;
        return true;
      } else {
        // 새 사용자: 회원가입 후 로그인
        await Supabase.instance.client.from('users').insert({
          'username': username,
          'created_at': DateTime.now().toIso8601String(),
        });

        _currentUsername = username;
        return true;
      }
    } catch (e) {
      throw AuthException('사용자 이름 로그인 실패: $e');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      _currentUsername = null;
    } catch (e) {
      throw AuthException('로그아웃 실패: $e');
    }
  }

  /// 현재 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_currentUsername == null) return null;

    try {
      final user =
          await Supabase.instance.client
              .from('users')
              .select('*')
              .eq('username', _currentUsername!)
              .maybeSingle();

      return user;
    } catch (e) {
      throw AuthException('사용자 정보 조회 실패: $e');
    }
  }

  /// 사용자 이름 중복 확인
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final existingUser =
          await Supabase.instance.client
              .from('users')
              .select('username')
              .eq('username', username)
              .maybeSingle();

      return existingUser == null;
    } catch (e) {
      throw AuthException('사용자 이름 중복 확인 실패: $e');
    }
  }
}

/// 인증 예외 클래스
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
