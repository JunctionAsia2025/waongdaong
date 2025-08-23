/// 앱 전반에서 사용하는 상수들
class AppConstants {
  // 앱 정보
  static const String appName = 'WaongDaong';
  static const String appVersion = '1.0.0';
  
  // API 관련
  static const int apiTimeout = 30000; // 30초
  static const int maxRetryAttempts = 3;
  
  // 페이지네이션
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // 파일 업로드
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  
  // 캐시
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100;
  
  // 애니메이션
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  
  // 유효성 검사
  static const int minPasswordLength = 8;
  static const int maxNicknameLength = 20;
  static const int maxTitleLength = 100;
  static const int maxContentLength = 10000;
  
  // 포인트 시스템
  static const int defaultPoints = 0;
  static const int maxPoints = 999999;
  
  // 영어 레벨
  static const List<String> englishLevels = [
    'Beginner',
    'Elementary',
    'Pre-Intermediate',
    'Intermediate',
    'Upper-Intermediate',
    'Advanced',
    'Proficient'
  ];
  
  // 콘텐츠 타입
  static const List<String> contentTypes = [
    'news',
    'article',
    'column',
    'paper',
    'blog'
  ];
  
  // 스터디 그룹 상태 (단순화)
  static const List<String> studyGroupStatuses = [
    'active',        // 활성
    'paused',        // 일시 중단
    'closed',        // 종료
  ];
  
  // 짧은 토론 관련 상수
  static const List<int> discussionDurations = [10, 15, 20];
  static const int maxDiscussionTime = 20; // 최대 20분
  
  // 학습 세션 상태
  static const List<String> learningSessionStatuses = [
    'not_started',   // 시작 전
    'in_progress',   // 진행중
    'completed',     // 완료
    'paused'         // 일시정지
  ];
}
