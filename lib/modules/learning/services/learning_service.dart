import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/result.dart';
import '../models/learning_session.dart';
import '../models/learning_result.dart';

class LearningService {
  final SupabaseClient _supabase;

  LearningService(this._supabase);

  /// 학습 세션 시작
  Future<Result<LearningSession>> startLearningSession({
    required String contentId,
    required String userId,
    String? studyGroupId,
  }) async {
    try {
      final sessionData = {
        'user_id': userId,
        'content_id': contentId,
        'study_group_id': studyGroupId,
        'started_at': DateTime.now().toIso8601String(),
        'status': 'in_progress',
      };

      final response =
          await _supabase
              .from('learning_sessions')
              .insert(sessionData)
              .select()
              .single();

      final session = LearningSession.fromJson(response);
      return Result.success(session);
    } catch (e) {
      return Result.failure('학습 세션을 시작하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 학습 세션 완료
  Future<Result<LearningSession>> completeLearningSession({
    required String sessionId,
    required int studyTime,
    required int comprehensionScore,
    String? notes,
  }) async {
    try {
      final updateData = {
        'ended_at': DateTime.now().toIso8601String(),
        'study_time': studyTime,
        'comprehension_score': comprehensionScore,
        'notes': notes,
        'status': 'completed',
      };

      final response =
          await _supabase
              .from('learning_sessions')
              .update(updateData)
              .eq('id', sessionId)
              .select()
              .single();

      final session = LearningSession.fromJson(response);
      return Result.success(session);
    } catch (e) {
      return Result.failure('학습 세션을 완료하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 학습 세션 일시정지
  Future<Result<LearningSession>> pauseLearningSession(String sessionId) async {
    try {
      final updateData = {
        'paused_at': DateTime.now().toIso8601String(),
        'status': 'paused',
      };

      final response =
          await _supabase
              .from('learning_sessions')
              .update(updateData)
              .eq('id', sessionId)
              .select()
              .single();

      final session = LearningSession.fromJson(response);
      return Result.success(session);
    } catch (e) {
      return Result.failure('학습 세션을 일시정지하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 학습 세션 재개
  Future<Result<LearningSession>> resumeLearningSession(
    String sessionId,
  ) async {
    try {
      final updateData = {
        'resumed_at': DateTime.now().toIso8601String(),
        'status': 'in_progress',
      };

      final response =
          await _supabase
              .from('learning_sessions')
              .update(updateData)
              .eq('id', sessionId)
              .select()
              .single();

      final session = LearningSession.fromJson(response);
      return Result.success(session);
    } catch (e) {
      return Result.failure('학습 세션을 재개하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자의 학습 세션 목록 조회
  Future<Result<List<LearningSession>>> getUserLearningSessions({
    required String userId,
    String? status,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase
          .from('learning_sessions')
          .select()
          .eq('user_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('started_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final sessions =
          (response as List)
              .map((json) => LearningSession.fromJson(json))
              .toList();

      return Result.success(sessions);
    } catch (e) {
      return Result.failure('학습 세션을 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 학습 세션 상세 조회
  Future<Result<LearningSession>> getLearningSession(String sessionId) async {
    try {
      final response =
          await _supabase
              .from('learning_sessions')
              .select()
              .eq('id', sessionId)
              .single();

      final session = LearningSession.fromJson(response);
      return Result.success(session);
    } catch (e) {
      return Result.failure('학습 세션을 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 학습 결과 저장
  Future<Result<LearningResult>> saveLearningResult({
    required String sessionId,
    required int vocabularyScore,
    required int grammarScore,
    required int readingScore,
    required int listeningScore,
    required int totalScore,
    String? feedback,
  }) async {
    try {
      final resultData = {
        'session_id': sessionId,
        'vocabulary_score': vocabularyScore,
        'grammar_score': grammarScore,
        'reading_score': readingScore,
        'listening_score': listeningScore,
        'total_score': totalScore,
        'feedback': feedback,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from('learning_results')
              .insert(resultData)
              .select()
              .single();

      final result = LearningResult.fromJson(response);
      return Result.success(result);
    } catch (e) {
      return Result.failure('학습 결과를 저장하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 학습 결과 조회
  Future<Result<LearningResult>> getLearningResult(String sessionId) async {
    try {
      final response =
          await _supabase
              .from('learning_results')
              .select()
              .eq('session_id', sessionId)
              .single();

      final result = LearningResult.fromJson(response);
      return Result.success(result);
    } catch (e) {
      return Result.failure('학습 결과를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자의 학습 통계 조회
  Future<Result<Map<String, dynamic>>> getUserLearningStats(
    String userId,
  ) async {
    try {
      // 총 학습 시간
      final totalTimeResponse = await _supabase
          .from('learning_sessions')
          .select('study_time')
          .eq('user_id', userId)
          .eq('status', 'completed');

      int totalStudyTime = 0;
      for (final item in totalTimeResponse as List) {
        totalStudyTime += (item['study_time'] as int?) ?? 0;
      }

      // 완료된 세션 수
      final completedSessionsResponse = await _supabase
          .from('learning_sessions')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'completed');

      final completedCount = (completedSessionsResponse as List).length;

      // 평균 이해도 점수
      final comprehensionResponse = await _supabase
          .from('learning_sessions')
          .select('comprehension_score')
          .eq('user_id', userId)
          .eq('status', 'completed');

      double avgComprehension = 0;
      if (comprehensionResponse.isNotEmpty) {
        int totalScore = 0;
        for (final item in comprehensionResponse as List) {
          totalScore += (item['comprehension_score'] as int?) ?? 0;
        }
        avgComprehension = totalScore / comprehensionResponse.length;
      }

      final stats = {
        'totalStudyTime': totalStudyTime,
        'completedSessions': completedCount,
        'averageComprehension': avgComprehension,
        'totalContents': completedCount, // 완료된 세션 수와 동일
      };

      return Result.success(stats);
    } catch (e) {
      return Result.failure('학습 통계를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디 그룹의 학습 세션 조회
  Future<Result<List<LearningSession>>> getStudyGroupLearningSessions({
    required String studyGroupId,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final response = await _supabase
          .from('learning_sessions')
          .select()
          .eq('study_group_id', studyGroupId)
          .order('started_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final sessions =
          (response as List)
              .map((json) => LearningSession.fromJson(json))
              .toList();

      return Result.success(sessions);
    } catch (e) {
      return Result.failure('스터디 그룹 학습 세션을 조회하는 중 오류가 발생했습니다.', e);
    }
  }
}
