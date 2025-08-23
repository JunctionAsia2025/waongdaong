import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_script_model.dart';

/// AI API를 통해 한국어 텍스트를 영어 스크립트로 변환하는 서비스
/// Google Gemini 2.5 Flash 모델 사용 (직접 HTTP 요청)
class AiApiService {
  static const String _apiKey = 'AIzaSyD3daz8BpxjuwhjC8ZUz6ebLOQPfpBHpeo';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

  AiApiService();

  // Mock에서 사용할 수 있는 생성자
  AiApiService._mockConstructor();

  /// 한국어 입력을 영어 스크립트로 변환
  /// 실시간 보이스룸에서 사용할 수 있는 자연스러운 영어 표현으로 변환
  Future<AiScriptResponse> generateEnglishScript(String koreanInput) async {
    try {
      final prompt = _buildPrompt(koreanInput);

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 200},
          'systemInstruction': {
            'parts': [
              {'text': _getSystemPrompt()},
            ],
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final rawResponse =
              data['candidates'][0]['content']['parts'][0]['text']
                  .toString()
                  .trim();

          // JSON 마크다운 블록 제거 및 파싱
          final cleanedJson = _extractJsonFromResponse(rawResponse);
          return AiScriptResponse.success(cleanedJson);
        } else {
          return AiScriptResponse.error('Gemini API에서 빈 응답을 받았습니다.');
        }
      } else {
        final errorData = jsonDecode(response.body);
        return AiScriptResponse.error(
          'Gemini API 호출 실패: ${response.statusCode} - $errorData',
        );
      }
    } catch (e) {
      return AiScriptResponse.error('Gemini API 연동 중 오류 발생: $e');
    }
  }

  /// 시스템 프롬프트 - AI의 역할과 목적을 정의 (JSON 형식 응답)
  String _getSystemPrompt() {
    return '''
You are an expert Korean-to-English translator for real-time voice communication.

Your task: Provide exactly 3 different translation options in 3 distinct styles as JSON.

Response format (MUST be valid JSON only):
{
  "formal": "formal/polite English sentence",
  "casual": "casual/friendly English sentence", 
  "witty": "witty/clever English sentence"
}

Rules:
• Respond ONLY with valid JSON, no other text
• Each translation must be ONE complete sentence only
• Make each style clearly different in tone
• All translations should be natural and conversational
• Ensure proper JSON escaping for quotes and special characters
''';
  }

  /// 사용자 입력을 위한 프롬프트 구성 (JSON 형식 요청)
  String _buildPrompt(String koreanInput) {
    return '''
Korean text: "$koreanInput"

Translate to JSON format:
{
  "formal": "[formal English translation]",
  "casual": "[casual English translation]",
  "witty": "[witty English translation]"
}
''';
  }

  /// Gemini 응답에서 JSON 추출 및 정리
  String _extractJsonFromResponse(String rawResponse) {
    try {
      // 마크다운 코드 블록 제거
      String cleaned = rawResponse;

      // ```json 과 ``` 제거
      if (cleaned.contains('```json')) {
        cleaned = cleaned.replaceAll('```json', '').replaceAll('```', '');
      }

      // 앞뒤 공백 제거
      cleaned = cleaned.trim();

      // JSON 유효성 검사
      final parsed = jsonDecode(cleaned);

      // 다시 JSON 문자열로 변환 (정리된 형태)
      return jsonEncode(parsed);
    } catch (e) {
      // JSON 파싱 실패 시 원본 반환
      return rawResponse;
    }
  }
}

/// Mock AI API Service (개발/테스트용)
/// Gemini 2.5 Flash 스타일의 응답을 시뮬레이션
class MockAiApiService extends AiApiService {
  MockAiApiService() : super._mockConstructor();

  @override
  Future<AiScriptResponse> generateEnglishScript(String koreanInput) async {
    // Gemini API 호출 시뮬레이션 (약간 더 빠름)
    await Future.delayed(const Duration(milliseconds: 800));

    final mockTranslations = {
      // 인사 표현
      '안녕하세요': 'Hey there!',
      '안녕': 'Hi!',
      '만나서 반갑습니다': 'Great to meet you!',
      '반가워요': 'Nice to see you!',

      // 일상 대화
      '오늘 날씨가 좋네요': 'The weather\'s amazing today!',
      '어떻게 지내세요?': 'How\'s it going?',
      '어떻게 지내?': 'How are you?',
      '잘 지내고 있어요': 'I\'m doing great!',
      '잘 지내': 'I\'m good!',

      // 감사 및 사과
      '고마워요': 'Thanks so much!',
      '고마워': 'Thanks!',
      '감사합니다': 'Thank you!',
      '죄송해요': 'Sorry about that!',
      '미안해': 'My bad!',
      '괜찮아요': 'No worries!',
      '괜찮아': 'It\'s all good!',

      // 도움 요청
      '도움이 필요해요': 'I could use some help.',
      '도와주세요': 'Can you help me out?',
      '모르겠어요': 'I\'m not sure about this.',
      '알겠어요': 'Got it!',
      '이해했어요': 'I understand!',

      // 감정 표현
      '기뻐요': 'I\'m so happy!',
      '슬퍼요': 'I\'m feeling sad.',
      '화나요': 'I\'m frustrated.',
      '놀랐어요': 'That\'s surprising!',
      '재미있어요': 'This is fun!',

      // 동의/반대
      '맞아요': 'Exactly!',
      '그래요': 'Yeah, that\'s right.',
      '아니에요': 'Nope, that\'s not it.',
      '동의해요': 'I agree with that.',
      '반대해요': 'I disagree.',
    };

    // 정확히 일치하는 번역이 있으면 사용
    if (mockTranslations.containsKey(koreanInput.trim())) {
      return AiScriptResponse.success(mockTranslations[koreanInput.trim()]!);
    }

    // 부분 일치 검사 (더 자연스러운 Mock 응답)
    for (final entry in mockTranslations.entries) {
      if (koreanInput.contains(entry.key)) {
        return AiScriptResponse.success(entry.value);
      }
    }

    // 기본 응답 (Gemini 스타일)
    final defaultResponses = [
      'Could you help me with this translation?',
      'I\'d like to say something in English.',
      'Let me express this in English.',
      'How would you say this in English?',
    ];

    final randomIndex =
        DateTime.now().millisecondsSinceEpoch % defaultResponses.length;
    return AiScriptResponse.success(defaultResponses[randomIndex]);
  }
}
