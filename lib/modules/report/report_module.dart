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
    required String title,
    required String content,
  }) async {
    return await _reportService.createLearningReport(
      userId: userId,
      learningSessionId: learningSessionId,
      title: title,
      content: content,
    );
  }

  /// 스터디그룹 리포트 생성
  Future<Result<Report>> createStudyGroupReport({
    required String userId,
    required String studyGroupId,
    required String title,
    required String content,
  }) async {
    return await _reportService.createStudyGroupReport(
      userId: userId,
      studyGroupId: studyGroupId,
      title: title,
      content: content,
    );
  }

  /// 사용자 리포트 조회
  Future<Result<List<Report>>> getUserReports(String userId) async {
    return await _reportService.getUserReports(userId);
  }

  /// 스터디그룹 리포트 조회
  Future<Result<List<Report>>> getStudyGroupReports(String studyGroupId) async {
    return await _reportService.getStudyGroupReports(studyGroupId);
  }

  /// 리포트 업데이트
  Future<Result<Report>> updateReport({
    required String reportId,
    String? title,
    String? content,
  }) async {
    return await _reportService.updateReport(
      reportId: reportId,
      title: title,
      content: content,
    );
  }

  /// 리포트 삭제
  Future<Result<void>> deleteReport(String reportId) async {
    return await _reportService.deleteReport(reportId);
  }
}
