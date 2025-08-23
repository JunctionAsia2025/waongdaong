# User Module

사용자 관리 기능을 담당하는 모듈입니다. 간단한 사용자 이름 기반 인증 시스템을 제공합니다.

## 🚀 주요 기능

### 인증 시스템
- **사용자 이름 기반 로그인**: 이메일/비밀번호 없이 사용자 이름만으로 로그인
- **자동 회원가입**: 새 사용자 이름 입력 시 자동으로 계정 생성
- **중복 방지**: 사용자 이름 중복 확인 및 제한
- **세션 관리**: 메모리 기반 간단한 세션 관리

### 사용자 관리
- **프로필 관리**: 사용자 정보 조회 및 업데이트
- **아바타 관리**: 프로필 이미지 업로드 및 관리
- **사용자 검색**: 다른 사용자 검색 및 팔로우 기능

## 📁 모듈 구조

```
lib/modules/user/
├── models/
│   └── user_model.dart          # 사용자 데이터 모델
├── repositories/
│   └── user_repository.dart     # 데이터 접근 계층
├── services/
│   └── user_service.dart        # 비즈니스 로직 계층
├── user_module.dart             # 모듈 진입점
└── README.md                    # 이 파일
```

## 🔧 사용법

### 1. 모듈 초기화

```dart
import 'package:waongdaong/modules/user/user_module.dart';

// UserModule은 SupabaseModule에 의존합니다
final userModule = UserModule.instance;
```

### 2. 사용자 이름으로 로그인

```dart
import 'package:waongdaong/modules/supabase/supabase_module.dart';

final authService = SupabaseModule.instance.auth;

try {
  // 사용자 이름으로 로그인 (자동 회원가입)
  final success = await authService.signInWithUsername('myusername');
  
  if (success) {
    print('로그인 성공!');
    print('현재 사용자: ${authService.currentUsername}');
  }
} catch (e) {
  print('로그인 실패: $e');
}
```

### 3. 사용자 정보 조회

```dart
// 현재 로그인된 사용자 정보
final currentUser = await authService.getCurrentUser();
if (currentUser != null) {
  print('사용자 ID: ${currentUser['id']}');
  print('사용자 이름: ${currentUser['username']}');
  print('가입일: ${currentUser['created_at']}');
}

// 사용자 이름 중복 확인
final isAvailable = await authService.isUsernameAvailable('newusername');
if (isAvailable) {
  print('사용 가능한 사용자 이름입니다.');
}
```

### 4. 사용자 서비스 활용

```dart
final userService = UserModule.instance.userService;

// 현재 사용자 프로필 조회
final profile = await userService.getCurrentUserProfile();

// 사용자 검색 (현재 사용자 제외)
final searchResults = await userService.searchUsers('john');

// 팔로우 상태 토글
final isFollowing = await userService.toggleFollowStatus(userId);

// 사용자 통계 조회
final stats = await userService.getUserStatistics(userId);
```

### 5. 로그아웃

```dart
await authService.signOut();
print('로그아웃 완료');
```

## 🗄️ 데이터베이스 스키마

### users 테이블
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 주요 필드
- `id`: 자동 증가하는 고유 식별자
- `username`: 고유한 사용자 이름 (로그인에 사용)
- `created_at`: 계정 생성 시간
- `updated_at`: 마지막 업데이트 시간

## 🔐 보안 정책

- **RLS (Row Level Security)** 활성화
- 모든 사용자가 읽기/쓰기 가능
- 사용자 이름의 고유성 보장

## 📱 UI 연동

### 로그인 페이지 예시
```dart
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  
  Future<void> _signIn() async {
    try {
      final success = await SupabaseModule.instance.auth
          .signInWithUsername(_usernameController.text.trim());
      
      if (success) {
        // 로그인 성공 시 홈페이지로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: '사용자 이름',
              hintText: '중복되지 않는 사용자 이름을 입력하세요',
            ),
          ),
          ElevatedButton(
            onPressed: _signIn,
            child: Text('로그인'),
          ),
        ],
      ),
    );
  }
}
```

## 🚨 예외 처리

### AuthException
```dart
try {
  await authService.signInWithUsername('username');
} on AuthException catch (e) {
  print('인증 오류: ${e.message}');
} catch (e) {
  print('기타 오류: $e');
}
```

### RepositoryException
```dart
try {
  final users = await userRepository.searchUsers('query');
} on RepositoryException catch (e) {
  print('데이터 접근 오류: ${e.message}');
}
```

## 🔄 상태 관리

### 인증 상태 확인
```dart
final authService = SupabaseModule.instance.auth;

// 로그인 상태 확인
if (authService.isAuthenticated) {
  print('로그인됨: ${authService.currentUsername}');
} else {
  print('로그인되지 않음');
}

// 사용자 ID 및 이메일 (사용자 이름과 동일)
print('사용자 ID: ${authService.userId}');
print('사용자 이메일: ${authService.userEmail}');
```

## 📋 의존성

- `supabase_flutter`: Supabase 클라이언트
- `SupabaseModule`: 공통 Supabase 기능

## 🎯 향후 계획

- [ ] 사용자 프로필 확장 (이름, 생년월일, 자기소개 등)
- [ ] 소셜 로그인 연동 (Google, Apple)
- [ ] 이메일 인증 시스템
- [ ] 비밀번호 관리
- [ ] 사용자 권한 시스템

## 📞 지원

문제가 발생하거나 질문이 있으시면 개발팀에 문의해주세요.
