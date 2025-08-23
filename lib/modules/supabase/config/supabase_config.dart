/// Supabase 프로젝트 설정
class SupabaseConfig {
  static const String supabaseUrl = 'https://gfgqzdefkewbubtmjdjk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmZ3F6ZGVma2V3YnVidG1qZGprIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU4OTkxNjcsImV4cCI6MjA3MTQ3NTE2N30.rKVsjT3UPrgKjy5C1po0oPBdjQlu-vWn8C-U2DiUO_8';

  /// 개발 환경 설정
  static const bool isDevelopment = true;

  /// 프로덕션 환경 설정
  static const bool isProduction = false;

  /// 데이터베이스 스키마
  static const String schema = 'public';

  /// 기본 페이지 크기
  static const int defaultPageSize = 20;

  /// 최대 페이지 크기
  static const int maxPageSize = 100;

  /// OAuth2 설정
  static const String googleClientId = 'your_google_client_id_here';
  static const String googleClientSecret = 'your_google_client_secret_here';
  static const String googleRedirectUrl = 'your_google_redirect_url_here';
}
