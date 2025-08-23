import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/result.dart';
import '../models/user_profile.dart';

class UserService {
  final SupabaseClient _supabase;

  UserService(this._supabase);

  /// 사용자 프로필 생성
  Future<Result<UserProfile>> createUserProfile({
    required String userId,
    required String nickname,
    required String currentLevel,
    String? targetLevel,
    String? bio,
    String? avatarUrl,
    Map<String, int>? testScores,
  }) async {
    try {
      final profileData = {
        'user_id': userId,
        'nickname': nickname,
        'current_level': currentLevel,
        'target_level': targetLevel,
        'bio': bio,
        'avatar_url': avatarUrl,
        'test_scores': testScores,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from('user_profiles')
              .insert(profileData)
              .select()
              .single();

      final profile = UserProfile.fromJson(response);
      return Result.success(profile);
    } catch (e) {
      return Result.failure('사용자 프로필을 생성하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 프로필 조회
  Future<Result<UserProfile>> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase
              .from('user_profiles')
              .select()
              .eq('user_id', userId)
              .single();

      final profile = UserProfile.fromJson(response);
      return Result.success(profile);
    } catch (e) {
      return Result.failure('사용자 프로필을 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 프로필 업데이트
  Future<Result<UserProfile>> updateUserProfile({
    required String userId,
    String? nickname,
    String? currentLevel,
    String? targetLevel,
    String? bio,
    String? avatarUrl,
    Map<String, int>? testScores,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nickname != null) updateData['nickname'] = nickname;
      if (currentLevel != null) updateData['current_level'] = currentLevel;
      if (targetLevel != null) updateData['target_level'] = targetLevel;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (testScores != null) updateData['test_scores'] = testScores;

      final response =
          await _supabase
              .from('user_profiles')
              .update(updateData)
              .eq('user_id', userId)
              .select()
              .single();

      final profile = UserProfile.fromJson(response);
      return Result.success(profile);
    } catch (e) {
      return Result.failure('사용자 프로필을 업데이트하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 프로필 삭제
  Future<Result<void>> deleteUserProfile(String userId) async {
    try {
      await _supabase.from('user_profiles').delete().eq('user_id', userId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('사용자 프로필을 삭제하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 검색 (닉네임 기반)
  Future<Result<List<UserProfile>>> searchUsers({
    required String query,
    String? currentLevel,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var searchQuery = _supabase
          .from('user_profiles')
          .select()
          .or('nickname.ilike.%$query%,bio.ilike.%$query%');

      if (currentLevel != null) {
        searchQuery = searchQuery.eq('current_level', currentLevel);
      }

      final response = await searchQuery
          .order('updated_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final profiles =
          (response as List).map((json) => UserProfile.fromJson(json)).toList();

      return Result.success(profiles);
    } catch (e) {
      return Result.failure('사용자를 검색하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 관심사 업데이트
  Future<Result<void>> updateUserInterests({
    required String userId,
    required List<String> interests,
  }) async {
    try {
      final updateData = {
        'interests': interests,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('user_id', userId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('사용자 관심사를 업데이트하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 관심사 조회
  Future<Result<List<String>>> getUserInterests(String userId) async {
    try {
      final response =
          await _supabase
              .from('user_profiles')
              .select('interests')
              .eq('user_id', userId)
              .single();

      final interests = (response['interests'] as List?)?.cast<String>() ?? [];
      return Result.success(interests);
    } catch (e) {
      return Result.failure('사용자 관심사를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 테스트 점수 업데이트
  Future<Result<void>> updateUserTestScores({
    required String userId,
    required Map<String, int> testScores,
  }) async {
    try {
      // 기존 점수 조회
      final existingResponse =
          await _supabase
              .from('user_profiles')
              .select('test_scores')
              .eq('user_id', userId)
              .single();

      final existingScores = Map<String, int>.from(
        (existingResponse['test_scores'] as Map<String, dynamic>?) ?? {},
      );

      // 새 점수로 업데이트
      existingScores.addAll(testScores);

      final updateData = {
        'test_scores': existingScores,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('user_id', userId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('사용자 테스트 점수를 업데이트하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 테스트 점수 조회
  Future<Result<Map<String, int>>> getUserTestScores(String userId) async {
    try {
      final response =
          await _supabase
              .from('user_profiles')
              .select('test_scores')
              .eq('user_id', userId)
              .single();

      final testScores = Map<String, int>.from(
        (response['test_scores'] as Map<String, dynamic>?) ?? {},
      );

      return Result.success(testScores);
    } catch (e) {
      return Result.failure('사용자 테스트 점수를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 레벨 업데이트
  Future<Result<void>> updateUserLevel({
    required String userId,
    required String newLevel,
  }) async {
    try {
      final updateData = {
        'current_level': newLevel,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('user_id', userId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('사용자 레벨을 업데이트하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 통계 조회
  Future<Result<Map<String, dynamic>>> getUserStats(String userId) async {
    try {
      // 학습 세션 통계
      final sessionsResponse = await _supabase
          .from('learning_sessions')
          .select('study_time, comprehension_score, status')
          .eq('user_id', userId);

      int totalStudyTime = 0;
      int completedSessions = 0;
      double avgComprehension = 0;
      int totalScore = 0;

      for (final session in sessionsResponse as List) {
        if (session['status'] == 'completed') {
          completedSessions++;
          totalStudyTime += (session['study_time'] as int?) ?? 0;
          totalScore += (session['comprehension_score'] as int?) ?? 0;
        }
      }

      if (completedSessions > 0) {
        avgComprehension = totalScore / completedSessions;
      }

      // 스터디 그룹 통계
      final groupsResponse = await _supabase
          .from('study_group_members')
          .select('status')
          .eq('user_id', userId);

      int activeGroups = 0;
      int pendingGroups = 0;

      for (final group in groupsResponse as List) {
        if (group['status'] == 'active') {
          activeGroups++;
        } else if (group['status'] == 'pending') {
          pendingGroups++;
        }
      }

      final stats = {
        'totalStudyTime': totalStudyTime,
        'completedSessions': completedSessions,
        'averageComprehension': avgComprehension,
        'activeGroups': activeGroups,
        'pendingGroups': pendingGroups,
      };

      return Result.success(stats);
    } catch (e) {
      return Result.failure('사용자 통계를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 아바타 업로드
  Future<Result<String>> uploadUserAvatar({
    required String userId,
    required Uint8List imageBytes,
    required String fileExtension,
  }) async {
    try {
      final fileName =
          'avatar_$userId.${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = 'avatars/$fileName';

      await _supabase.storage
          .from('user-avatars')
          .uploadBinary(filePath, imageBytes);

      final avatarUrl = _supabase.storage
          .from('user-avatars')
          .getPublicUrl(filePath);

      // 프로필에 아바타 URL 업데이트
      await updateUserProfile(userId: userId, avatarUrl: avatarUrl);

      return Result.success(avatarUrl);
    } catch (e) {
      return Result.failure('아바타를 업로드하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 아바타 삭제
  Future<Result<void>> deleteUserAvatar(String userId) async {
    try {
      // 프로필에서 아바타 URL 제거
      await updateUserProfile(userId: userId, avatarUrl: null);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('아바타를 삭제하는 중 오류가 발생했습니다.', e);
    }
  }
}
