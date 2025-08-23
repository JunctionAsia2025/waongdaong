import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/result.dart';
import 'services/report_service.dart';
import 'models/report.dart';

class ReportModule {
  final SupabaseClient _supabase;
  late final ReportService _reportService;

  ReportModule(this._supabase);

  /// 모듈 초기화
  Future<void> initialize() async {
    _reportService = ReportService(_supabase);
  }

  /// 모듈 정리
  Future<void> dispose() async {
    // 필요한 정리 작업이 있다면 여기에 구현
  }

  /// ReportService 가져오기
  ReportService get reportService => _reportService;

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
    return await _reportService.createIndividualLearningReport(
      userId: userId,
      learningSessionId: learningSessionId,
      period: period,
      totalStudyTime: totalStudyTime,
      completedContents: completedContents,
      earnedPoints: earnedPoints,
      weakAreas: weakAreas,
      recommendations: recommendations,
      reflection: reflection,
    );
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
    return await _reportService.createStudyGroupReport(
      userId: userId,
      studyGroupId: studyGroupId,
      period: period,
      totalStudyTime: totalStudyTime,
      completedContents: completedContents,
      earnedPoints: earnedPoints,
      participationRate: participationRate,
      weakAreas: weakAreas,
      recommendations: recommendations,
      reflection: reflection,
    );
  }

  /// 사용자 리포트 조회
  Future<Result<List<Report>>> getUserReports({
    required String userId,
    String? reportType,
    String? period,
    int page = 0,
    int pageSize = 20,
  }) async {
    return await _reportService.getUserReports(
      userId: userId,
      reportType: reportType,
      period: period,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 리포트 통계 조회
  Future<Result<Map<String, dynamic>>> getReportStats({
    String? userId,
    String? reportType,
    String? period,
  }) async {
    return await _reportService.getReportStats(
      userId: userId,
      reportType: reportType,
      period: period,
    );
  }

  /// 리포트 타입별 통계 조회
  Future<Result<Map<String, dynamic>>> getReportTypeStats({
    String? userId,
    String? period,
  }) async {
    return await _reportService.getReportTypeStats(
      userId: userId,
      period: period,
    );
  }
}
