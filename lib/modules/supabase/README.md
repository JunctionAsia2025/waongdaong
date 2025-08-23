# Supabase 모듈

이 모듈은 Flutter 앱에서 Supabase를 사용하기 위한 **공통 기능**만 제공하는 핵심 모듈입니다.

## 구조

```
lib/modules/supabase/
├── supabase_module.dart          # 메인 모듈 클래스
├── config/
│   └── supabase_config.dart     # 설정 파일
├── services/
│   ├── auth_service.dart        # 인증 서비스
│   ├── database_service.dart    # 데이터베이스 서비스
│   └── storage_service.dart     # 스토리지 서비스
└── README.md                     # 이 파일
```

## 주요 특징

### 1. 공통 기능 제공
- **인증 (Authentication)**: 사용자 이름 기반 간단한 로그인/회원가입
- **데이터베이스 (Database)**: 기본 CRUD 작업, 쿼리 빌더
- **스토리지 (Storage)**: 파일 업로드, 다운로드, URL 생성

### 2. 다른 모듈의 기반
- 이 모듈은 다른 도메인별 모듈들이 사용하는 공통 인프라
- 직접적인 비즈니스 로직은 포함하지 않음
- Repository Pattern의 기본 서비스만 제공

### 3. 모듈 간 의존성
- 다른 모듈들이 이 모듈에 의존
- 이 모듈은 다른 모듈에 의존하지 않음

## 사용법

### 1. 모듈 초기화

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase 모듈 초기화 (다른 모듈보다 먼저)
  await SupabaseModule.instance.initialize();
  
  // 다른 모듈들 초기화
  await UserModule.instance.initialize();
  await PostModule.instance.initialize();
  
  runApp(const MyApp());
}
```

### 2. 인증 사용

```dart
// 사용자 이름으로 로그인 (자동 회원가입)
try {
  final success = await SupabaseModule.instance.auth.signInWithUsername('myusername');
  if (success) {
    print('로그인 성공!');
  }
} catch (e) {
  print('로그인 실패: $e');
}

// 현재 사용자 확인
if (SupabaseModule.instance.auth.isAuthenticated) {
  final username = SupabaseModule.instance.auth.currentUsername;
  print('로그인된 사용자: $username');
}
```

### 3. 데이터베이스 사용

```dart
// 기본 데이터 조회
try {
  final result = await SupabaseModule.instance.database.select(
    table: 'users',
    select: '*',
    limit: 10,
  );
  print('조회 결과: ${result.length}개');
} catch (e) {
  print('데이터 조회 실패: $e');
}
```

### 4. 파일 업로드

```dart
// 파일 업로드
try {
  final path = await SupabaseModule.instance.storage.uploadFile(
    bucket: 'avatars',
    path: 'user123/avatar.jpg',
    fileBytes: imageBytes,
    contentType: 'image/jpeg',
  );
  print('업로드 완료: $path');
} catch (e) {
  print('업로드 실패: $e');
}
```

### 5. 실시간 구독

```dart
// 실시간 구독
final channel = SupabaseModule.instance.database.subscribe(
  table: 'posts',
  event: 'INSERT',
  onData: (payload) {
    print('새 데이터: $payload');
  },
  onError: (error) {
    print('구독 에러: $error');
  },
);

// 구독 해제
channel.unsubscribe();
```

## 설정

`lib/modules/supabase/config/supabase_config.dart` 파일에서 다음을 설정하세요:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'your_project_url';
  static const String supabaseAnonKey = 'your_anon_key';
}
```

## 모듈 아키텍처

```
┌─────────────────┐
│   App Layer     │
└─────────┬───────┘
          │
┌─────────▼───────┐
│  Domain Modules │  ← UserModule, PostModule 등
│  (User, Post)   │
└─────────┬───────┘
          │
┌─────────▼───────┐
│ Supabase Module │  ← 이 모듈 (공통 인프라)
│  (Infrastructure)│
└─────────┬───────┘
          │
┌─────────▼───────┐
│   Supabase      │
│   (Backend)     │
└─────────────────┘
```

## 다른 모듈과의 관계

### 1. UserModule
```dart
// 사용자 모듈에서 Supabase 모듈 사용
class UserRepository {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  
  Future<UserModel?> getUserProfile(String userId) async {
    return await _databaseService.selectOne(
      table: 'users',
      select: '*',
      filters: {'id': userId},
    );
  }
}
```

### 2. PostModule
```dart
// 게시물 모듈에서 Supabase 모듈 사용
class PostRepository {
  final DatabaseService _databaseService = DatabaseService();
  
  Future<List<PostModel>> getPosts() async {
    return await _databaseService.select(
      table: 'posts',
      select: '*',
      orderBy: 'created_at',
      ascending: false,
    );
  }
}
```

## 에러 처리

모든 서비스는 적절한 예외를 발생시킵니다:

- `AuthException`: 인증 관련 에러
- `DatabaseException`: 데이터베이스 관련 에러
- `StorageException`: 스토리지 관련 에러

## 성능 최적화

1. **연결 풀링**: Supabase 클라이언트 재사용
2. **에러 처리**: 적절한 에러 처리로 앱 안정성 향상
3. **설정 중앙화**: 모든 Supabase 설정을 한 곳에서 관리

## 보안 고려사항

1. **환경 변수**: 민감한 정보는 환경 변수로 관리
2. **RLS 정책**: 데이터베이스 레벨에서 접근 제어
3. **인증 상태**: 모든 민감한 작업 전 인증 상태 확인

## 테스트

```dart
// 인증 서비스 테스트
test('로그인 테스트', () async {
  final authService = AuthService();
  // 테스트 로직
});

// 데이터베이스 서비스 테스트
test('데이터 조회 테스트', () async {
  final dbService = DatabaseService();
  // 테스트 로직
});
```

## 주의사항

1. **초기화 순서**: 이 모듈은 다른 모듈보다 먼저 초기화되어야 함
2. **의존성**: 다른 모듈들이 이 모듈에 의존하므로 안정성 중요
3. **확장성**: 새로운 공통 기능이 필요하면 이 모듈에 추가
