import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/result.dart';
import '../models/auth_user.dart';
import '../models/user_profile.dart';

/// 인증 관련 서비스
class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  /// 현재 인증된 사용자 가져오기
  AppUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      nickname: user.userMetadata?['nickname'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(user.lastSignInAt ?? user.createdAt),
      isEmailVerified: user.emailConfirmedAt != null,
      currentLevel: user.userMetadata?['current_level'] as String?,
      targetLevel: user.userMetadata?['target_level'] as String?,
    );
  }

  /// 로그인 상태 확인
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// 이메일/비밀번호로 로그인
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Result.failure('로그인에 실패했습니다.');
      }

      final authUser = AppUser(
        id: response.user!.id,
        email: response.user!.email ?? '',
        nickname: response.user!.userMetadata?['nickname'] as String?,
        avatarUrl: response.user!.userMetadata?['avatar_url'] as String?,
        createdAt: DateTime.parse(response.user!.createdAt),
        updatedAt: DateTime.parse(
          response.user!.lastSignInAt ?? response.user!.createdAt,
        ),
        isEmailVerified: response.user!.emailConfirmedAt != null,
        currentLevel: response.user!.userMetadata?['current_level'] as String?,
        targetLevel: response.user!.userMetadata?['target_level'] as String?,
      );

      return Result.success(authUser);
    } on AuthException catch (e) {
      return Result.failure(_getAuthErrorMessage(e.message), e);
    } catch (e) {
      return Result.failure('로그인 중 오류가 발생했습니다.', e);
    }
  }

  /// 이메일/비밀번호로 회원가입
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'nickname': nickname},
      );

      if (response.user == null) {
        return const Result.failure('회원가입에 실패했습니다.');
      }

      final authUser = AppUser(
        id: response.user!.id,
        email: response.user!.email ?? '',
        nickname: nickname,
        avatarUrl: null,
        createdAt: DateTime.parse(response.user!.createdAt),
        updatedAt: DateTime.parse(response.user!.createdAt),
        isEmailVerified: false,
        currentLevel: null,
        targetLevel: null,
      );

      return Result.success(authUser);
    } on AuthException catch (e) {
      return Result.failure(_getAuthErrorMessage(e.message), e);
    } catch (e) {
      return Result.failure('회원가입 중 오류가 발생했습니다.', e);
    }
  }

  /// 로그아웃
  Future<Result<void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure('로그아웃 중 오류가 발생했습니다.', e);
    }
  }

  /// 비밀번호 재설정 이메일 발송
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(_getAuthErrorMessage(e.message), e);
    } catch (e) {
      return Result.failure('비밀번호 재설정 이메일 발송 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 프로필 업데이트
  Future<Result<void>> updateProfile({
    String? nickname,
    String? currentLevel,
    String? targetLevel,
    int? toeicScore,
    int? toeicSpeakingScore,
    int? toeicWritingScore,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return const Result.failure('로그인이 필요합니다.');
      }

      // 사용자 메타데이터 업데이트
      final metadata = <String, dynamic>{};
      if (nickname != null) {
        metadata['nickname'] = nickname;
      }
      if (currentLevel != null) {
        metadata['current_level'] = currentLevel;
      }
      if (targetLevel != null) {
        metadata['target_level'] = targetLevel;
      }

      if (metadata.isNotEmpty) {
        await _supabase.auth.updateUser(UserAttributes(data: metadata));
      }

      // 프로필 테이블 업데이트
      final profileData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nickname != null) {
        profileData['nickname'] = nickname;
      }
      if (currentLevel != null) {
        profileData['current_level'] = currentLevel;
      }
      if (targetLevel != null) {
        profileData['target_level'] = targetLevel;
      }
      if (toeicScore != null) {
        profileData['toeic_score'] = toeicScore;
      }
      if (toeicSpeakingScore != null) {
        profileData['toeic_speaking_score'] = toeicSpeakingScore;
      }
      if (toeicWritingScore != null) {
        profileData['toeic_writing_score'] = toeicWritingScore;
      }

      await _supabase.from('user_profiles').upsert({
        'user_id': user.id,
        ...profileData,
      });

      return const Result.success(null);
    } catch (e) {
      return Result.failure('프로필 업데이트 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 프로필 가져오기
  Future<Result<UserProfile>> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return const Result.failure('로그인이 필요합니다.');
      }

      final response =
          await _supabase
              .from('user_profiles')
              .select()
              .eq('user_id', user.id)
              .single();

      final profile = UserProfile.fromJson(response);
      return Result.success(profile);
    } catch (e) {
      return Result.failure('프로필을 가져오는 중 오류가 발생했습니다.', e);
    }
  }

  /// 인증 에러 메시지 변환
  String _getAuthErrorMessage(String message) {
    switch (message) {
      case 'Invalid login credentials':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'Email not confirmed':
        return '이메일 인증이 필요합니다.';
      case 'User already registered':
        return '이미 등록된 사용자입니다.';
      case 'Password should be at least 6 characters':
        return '비밀번호는 최소 6자 이상이어야 합니다.';
      default:
        return message;
    }
  }
}
