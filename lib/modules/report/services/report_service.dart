import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report.dart';
import '../../core/utils/result.dart';

/// 학습 활동 리포트 서비스
class ReportService {
  final SupabaseClient _supabase;

  ReportService(this._supabase);

  /// 개인학습 리포트 생성
  Future<Result<Report>> createIndividualLearningReport({
    required String userId,
    required String learningSessionId,
    required String period,
    required int totalStudyTime,
    required int completedContents,
    required int earnedPoints,
    required String weakAreas,
    required String recommendations,
    required String reflection,
  }) async {
    try {
      final reportData = {
        'user_id': userId,
        'report_type': 'individual_learning',
        'learning_session_id': learningSessionId,
        'period': period,
        'total_study_time': totalStudyTime,
        'completed_contents': completedContents,
        'earned_points': earnedPoints,
        'participation_rate': 1.0, // 개인학습은 항상 100% 참여
        'weak_areas': weakAreas,
        'recommendations': recommendations,
        'reflection': reflection,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase.from('reports').insert(reportData).select().single();

      return Result.success(Report.fromJson(response));
    } catch (e) {
      return Result.failure('개인학습 리포트 생성 중 오류가 발생했습니다.', e);
    }
  }

  /// 스터디그룹 리포트 생성
  Future<Result<Report>> createStudyGroupReport({
    required String userId,
    required String studyGroupId,
    required String period,
    required int totalStudyTime,
    required int completedContents,
    required int earnedPoints,
    required double participationRate,
    required String weakAreas,
    required String recommendations,
    required String reflection,
  }) async {
    try {
      final reportData = {
        'user_id': userId,
        'report_type': 'study_group',
        'study_group_id': studyGroupId,
        'period': period,
        'total_study_time': totalStudyTime,
        'completed_contents': completedContents,
        'earned_points': earnedPoints,
        'participation_rate': participationRate,
        'weak_areas': weakAreas,
        'recommendations': recommendations,
        'reflection': reflection,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase.from('reports').insert(reportData).select().single();

      return Result.success(Report.fromJson(response));
    } catch (e) {
      return Result.failure('스터디그룹 리포트 생성 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 리포트 조회
  Future<Result<List<Report>>> getUserReports({
    required String userId,
    String? reportType,
    String? period,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase.from('reports').select().eq('user_id', userId);

      if (reportType != null) {
        query = query.eq('report_type', reportType);
      }

      if (period != null) {
        query = query.eq('period', period);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      final reports =
          (response as List).map((json) => Report.fromJson(json)).toList();

      return Result.success(reports);
    } catch (e) {
      return Result.failure('사용자 리포트 조회 중 오류가 발생했습니다.', e);
    }
  }

  /// 특정 리포트 조회
  Future<Result<Report>> getReport(String reportId) async {
    try {
      final response =
          await _supabase.from('reports').select().eq('id', reportId).single();

      return Result.success(Report.fromJson(response));
    } catch (e) {
      return Result.failure('리포트 조회 중 오류가 발생했습니다.', e);
    }
  }

  /// 모든 리포트 조회 (관리자용)
  Future<Result<List<Report>>> getAllReports({
    String? reportType,
    String? period,
    int page = 0,
    int pageSize = 50,
  }) async {
    try {
      var query = _supabase.from('reports').select();

      if (reportType != null) {
        query = query.eq('report_type', reportType);
      }

      if (period != null) {
        query = query.eq('period', period);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      final reports =
          (response as List).map((json) => Report.fromJson(json)).toList();

      return Result.success(reports);
    } catch (e) {
      return Result.failure('모든 리포트 조회 중 오류가 발생했습니다.', e);
    }
  }

  /// 리포트 업데이트
  Future<Result<Report>> updateReport({
    required String reportId,
    String? weakAreas,
    String? recommendations,
    String? reflection,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (weakAreas != null) updateData['weak_areas'] = weakAreas;
      if (recommendations != null)
        updateData['recommendations'] = recommendations;
      if (reflection != null) updateData['reflection'] = reflection;

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

  /// 리포트 통계 조회
  Future<Result<Map<String, dynamic>>> getReportStats({
    String? userId,
    String? reportType,
    String? period,
  }) async {
    try {
      var query = _supabase.from('reports').select();

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      if (reportType != null) {
        query = query.eq('report_type', reportType);
      }

      if (period != null) {
        query = query.eq('period', period);
      }

      final response = await query;
      final reports = response as List;

      if (reports.isEmpty) {
        return Result.success({
          'totalReports': 0,
          'totalStudyTime': 0,
          'totalCompletedContents': 0,
          'totalEarnedPoints': 0,
          'averageParticipationRate': 0.0,
        });
      }

      final totalStudyTime = reports
          .map((r) => r['total_study_time'] as int)
          .reduce((a, b) => a + b);

      final totalCompletedContents = reports
          .map((r) => r['completed_contents'] as int)
          .reduce((a, b) => a + b);

      final totalEarnedPoints = reports
          .map((r) => r['earned_points'] as int)
          .reduce((a, b) => a + b);

      final averageParticipationRate =
          reports
              .map((r) => (r['participation_rate'] as num).toDouble())
              .reduce((a, b) => a + b) /
          reports.length;

      return Result.success({
        'totalReports': reports.length,
        'totalStudyTime': totalStudyTime,
        'totalCompletedContents': totalCompletedContents,
        'totalEarnedPoints': totalEarnedPoints,
        'averageParticipationRate': averageParticipationRate,
      });
    } catch (e) {
      return Result.failure('리포트 통계 조회 중 오류가 발생했습니다.', e);
    }
  }

  /// 리포트 타입별 통계
  Future<Result<Map<String, dynamic>>> getReportTypeStats({
    String? userId,
    String? period,
  }) async {
    try {
      final individualResult = await getReportStats(
        userId: userId,
        reportType: 'individual_learning',
        period: period,
      );

      final studyGroupResult = await getReportStats(
        userId: userId,
        reportType: 'study_group',
        period: period,
      );

      if (individualResult.isFailure || studyGroupResult.isFailure) {
        return Result.failure('리포트 타입별 통계 조회 중 오류가 발생했습니다.', null);
      }

      return Result.success({
        'individualLearning': individualResult.dataOrNull,
        'studyGroup': studyGroupResult.dataOrNull,
      });
    } catch (e) {
      return Result.failure('리포트 타입별 통계 조회 중 오류가 발생했습니다.', e);
    }
  }

  /// 기간별 리포트 생성
  Future<Result<Report>> generatePeriodReport({
    required String userId,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 해당 기간의 학습 데이터를 수집하여 리포트 생성
      // 이 부분은 LearningService와 StudyService와 연동하여 구현

      // 임시로 기본 리포트 생성
      final reportData = {
        'user_id': userId,
        'report_type': 'individual_learning',
        'period': period,
        'total_study_time': 0,
        'completed_contents': 0,
        'earned_points': 0,
        'participation_rate': 1.0,
        'weak_areas': '분석 중',
        'recommendations': '분석 중',
        'reflection': '분석 중',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase.from('reports').insert(reportData).select().single();

      return Result.success(Report.fromJson(response));
    } catch (e) {
      return Result.failure('기간별 리포트 생성 중 오류가 발생했습니다.', e);
    }
  }
}
