# AI 스크립트 모듈

실시간 보이스룸에서 사용할 수 있는 AI 기반 한국어-영어 번역 서비스를 제공하는 모듈입니다.

## 개요

이 모듈은 사용자가 한국어로 입력한 텍스트를 AI를 통해 자연스러운 영어 표현으로 변환해주어, 영어로만 소통해야 하는 사용자의 부담을 줄여주는 기능을 제공합니다.

## 주요 기능

- **한국어 → 영어 번역**: AI API를 통한 자연스러운 영어 표현 생성
- **스크립트 저장**: 생성된 번역 결과를 데이터베이스에 저장
- **히스토리 관리**: 사용자별/세션별 번역 히스토리 조회
- **빠른 번역**: 저장 없이 즉석 번역 기능
- **캐시 기능**: 동일한 입력에 대한 중복 요청 방지

## 아키텍처

### 데이터 모델
- `AiScript`: AI 스크립트 데이터 모델 (ERD의 ai_scripts 테이블 기반)
- `AiScriptRequest`: AI 스크립트 생성 요청 모델
- `AiScriptResponse`: AI 스크립트 응답 모델

### 서비스 레이어
- `AiApiService`: AI API 연동 서비스 (Google Gemini 2.5 Flash 사용)
- `AiScriptDatabaseService`: 데이터베이스 CRUD 서비스
- `AiScriptService`: 메인 비즈니스 로직 서비스

### 컨트롤러
- `AiScriptController`: UI 상태 관리 및 비즈니스 로직 처리

### 모듈
- `AiScriptModule`: 의존성 주입 및 서비스 인스턴스 관리

## 사용법

### 1. 모듈 초기화

```dart
// main.dart에서
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase 모듈 먼저 초기화
  await SupabaseModule.instance.initialize();
  
  // AI 스크립트 모듈 초기화
  AiScriptModule.instance.initialize(useMockApi: true); // 개발환경
  // AiScriptModule.instance.initialize(useMockApi: false); // 실제 API 사용
  
  runApp(const MyApp());
}
```

### 2. 기본 사용 예제

```dart
// 컨트롤러 생성
final controller = AiScriptController();

// 한국어 입력을 영어로 번역
final script = await controller.generateScript(
  studySessionId: 'session_123',
  userId: 'user_456',
  koreanInput: '안녕하세요, 만나서 반갑습니다!',
);

if (script != null) {
  print('번역 결과: ${script.englishScript}');
  // 결과: "Hello there! Nice to meet you!"
}
```

### 3. 빠른 번역 (저장 없이)

```dart
final englishText = await controller.quickTranslate('오늘 날씨가 좋네요');
print(englishText); // "The weather is really nice today!"
```

### 4. 히스토리 조회

```dart
// 사용자의 번역 히스토리 로드
await controller.loadUserScripts('user_456');
final scripts = controller.scripts;

// 최근 10개 번역 결과만 로드
await controller.loadRecentScripts('user_456', limit: 10);

// 특정 세션의 번역 결과 로드
await controller.loadSessionScripts('session_123');
```

### 5. 직접 서비스 사용

```dart
// 서비스 직접 접근
final aiScriptService = AiScriptModule.instance.aiScriptService;

// 번역 생성
final result = await aiScriptService.generateEnglishScript(
  studySessionId: 'session_123',
  userId: 'user_456',
  koreanInput: '도움이 필요해요',
);

if (result.success) {
  print('번역 결과: ${result.script?.englishScript}');
  print('캐시에서 가져옴: ${result.isFromCache}');
}
```

## 환경 설정

### 1. 의존성 추가

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.9.1
  http: ^1.1.0
  uuid: ^4.0.0
  json_annotation: ^4.8.1
  google_generative_ai: ^0.4.6
```

### 2. Gemini API 키 설정

실제 Google Gemini API를 사용하려면 `AiApiService`에서 API 키를 설정해야 합니다:

```dart
// lib/modules/ai_script/services/ai_api_service.dart
static const String _apiKey = 'your-gemini-api-key-here';
```

또는 환경변수나 설정 파일을 통해 관리하는 것을 권장합니다.

**Gemini API 키 발급 방법:**
1. [Google AI Studio](https://aistudio.google.com/app/apikey)에 접속
2. Google 계정으로 로그인
3. "Create API Key" 버튼 클릭
4. 생성된 API 키를 복사하여 사용

### 3. 데이터베이스 테이블

Supabase에 다음 테이블이 필요합니다:

```sql
CREATE TABLE ai_scripts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    study_session_id UUID NOT NULL,
    user_id UUID NOT NULL,
    korean_input TEXT NOT NULL,
    english_script TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_ai_scripts_user_id ON ai_scripts(user_id);
CREATE INDEX idx_ai_scripts_session_id ON ai_scripts(study_session_id);
CREATE INDEX idx_ai_scripts_created_at ON ai_scripts(created_at);
```

## Mock API

개발 환경에서는 `MockAiApiService`를 사용하여 실제 Gemini API 호출 없이 테스트할 수 있습니다. 다양한 한국어 표현들에 대한 자연스러운 영어 번역을 시뮬레이션하며, Gemini 2.5 Flash의 응답 스타일을 모방합니다.

**Mock API 특징:**
- 40개 이상의 일반적인 한국어 표현 지원
- 인사, 일상 대화, 감정 표현, 동의/반대 등 다양한 카테고리
- 부분 일치 검색으로 더 유연한 응답
- 실제 Gemini API보다 빠른 응답 시간 (800ms)

## 에러 처리

모든 서비스와 컨트롤러는 적절한 에러 처리를 포함하고 있습니다:

```dart
// 컨트롤러에서 에러 확인
if (controller.hasError) {
  print('오류 발생: ${controller.errorMessage}');
}

// 서비스에서 에러 처리
final result = await aiScriptService.generateEnglishScript(...);
if (!result.success) {
  print('에러: ${result.errorMessage}');
}
```

## 성능 최적화

- **캐시 기능**: 동일한 한국어 입력에 대해 기존 번역 결과 재사용
- **비동기 처리**: 모든 API 호출과 데이터베이스 작업은 비동기로 처리
- **상태 관리**: ChangeNotifier를 통한 효율적인 UI 상태 업데이트

## 확장 가능성

- 다른 AI 모델 지원 (Claude, OpenAI GPT 등)
- 다양한 언어 쌍 지원 (한국어↔중국어, 한국어↔일본어 등)
- 음성 인식과의 연동
- 실시간 번역 스트리밍
- Gemini Pro 모델로 업그레이드 (더 정확한 번역)
- 컨텍스트 기반 번역 (이전 대화 내용 고려)

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
