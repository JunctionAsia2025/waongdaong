import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/content_service.dart';

/// Content 모듈 - 콘텐츠 관리
class ContentModule {
  static const String name = 'Content';
  static const String version = '1.0.0';

  late final ContentService _contentService;

  ContentModule(SupabaseClient supabaseClient) {
    _contentService = ContentService(supabaseClient);
  }

  /// Content 서비스 가져오기
  ContentService get contentService => _contentService;

  /// 모듈 초기화
  Future<void> initialize() async {
    // Content 모듈 초기화 로직
    // 예: 캐시 초기화, 기본 콘텐츠 로드 등
  }

  /// 모듈 정리
  Future<void> dispose() async {
    // Content 모듈 정리 로직
  }
}
