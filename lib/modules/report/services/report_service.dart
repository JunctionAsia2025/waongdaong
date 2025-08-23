import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report.dart';
import '../../core/utils/result.dart';

/// 리포트 서비스
class ReportService {
  final SupabaseClient _supabase;

  ReportService(this._supabase);

  /// 스터디그룹 리포트 생성
  Future<Result<Report>> createStudyGroupReport({
    required String userId,
    required String studyGroupId,
    required String title,
    required String content,
    String reportType = 'study_group',
  }) async {
    try {
      final reportData = {
        'user_id': userId,
        'study_group_id': studyGroupId,
        'title': title,
        'content': content,
        'report_type': reportType,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase.from('reports').insert(reportData).select().single();

      return Result.success(Report.fromJson(response));
    } catch (e) {
      return Result.failure('스터디그룹 리포트 생성 중 오류가 발생했습니다.', e);
    }
  }

  /// 개인학습 리포트 생성
  Future<Result<Report>> createLearningReport({
    required String userId,
    required String learningSessionId,
    required String title,
    required String content,
    String reportType = 'learning',
  }) async {
    try {
      final reportData = {
        'user_id': userId,
        'learning_session_id': learningSessionId,
        'title': title,
        'content': content,
        'report_type': reportType,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase.from('reports').insert(reportData).select().single();

      return Result.success(Report.fromJson(response));
    } catch (e) {
      return Result.failure('개인학습 리포트 생성 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 리포트 조회
  Future<Result<List<Report>>> getUserReports(String userId) async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final reports =
          (response as List).map((json) => Report.fromJson(json)).toList();

      return Result.success(reports);
    } catch (e) {
      return Result.failure('사용자 리포트 조회 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디그룹 리포트 조회
  Future<Result<List<Report>>> getStudyGroupReports(String studyGroupId) async {
    try {
      final response = await _supabase
          .from('reports')
          .select()
          .eq('study_group_id', studyGroupId)
          .order('created_at', ascending: false);

      final reports =
          (response as List).map((json) => Report.fromJson(json)).toList();

      return Result.success(reports);
    } catch (e) {
      return Result.failure('스터디그룹 리포트 조회 중 오류가 발생했습니다.', e);
    }
  }

  /// 리포트 업데이트
  Future<Result<Report>> updateReport({
    required String reportId,
    String? title,
    String? content,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;

      final response =
          await _supabase
              .from('reports')
              .update(updateData)
              .eq('id', reportId)
              .select()
              .single();

      return Result.success(Report.fromJson(response));
    } catch (e) {
      return Result.failure('리포트 업데이트 중 오류가 발생했습니다.', e);
    }
  }

  /// 리포트 삭제
  Future<Result<void>> deleteReport(String reportId) async {
    try {
      await _supabase.from('reports').delete().eq('id', reportId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('리포트 삭제 중 오류가 발생했습니다.', e);
    }
  }
}
