import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/study_service.dart';
import '../content/services/content_service.dart';

/// Study 모듈 - 스터디 그룹 관리
class StudyModule {
  static const String name = 'Study';
  static const String version = '1.0.0';

  late final StudyService _studyService;

  StudyModule(SupabaseClient supabaseClient, ContentService contentService) {
    _studyService = StudyService(supabaseClient, contentService);
  }

  /// Study 서비스 가져오기
  StudyService get studyService => _studyService;

  /// 모듈 초기화
  Future<void> initialize() async {
    // Study 모듈 초기화 로직
    // 예: 스터디 그룹 상태 동기화, 참여자 관리 등
  }

  /// 모듈 정리
  Future<void> dispose() async {
    // Study 모듈 정리 로직
  }
}
