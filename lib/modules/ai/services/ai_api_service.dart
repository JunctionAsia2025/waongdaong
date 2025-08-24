import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/result.dart';

/// AI API 호출을 전담하는 서비스
class AIApiService {
  // Google Gemini 2.0 Flash 모델 사용
  //static const String _apiKey = 'AIzaSyD3daz8BpxjuwhjC8ZUz6ebLOQPfpBHpeo';
  //static const String _apiKey = 'AIzaSyDxBUw5RM5T1kgUN964APCeZKlc3CHO424';
  static const String _apiKey = 'AIzaSyCx_jlm7e-kq5aUtqnNxzzJU4gcKOM2nZ0';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

  /// 일반적인 AI 요청 - 프롬프트를 보내면 결과를 반환
  Future<Result<String>> sendPrompt({
    required String prompt,
    int maxTokens = 200,
    double temperature = 0.7,
  }) async {
    try {
      // Gemini API 호출
      final response = await _callGemini(
        prompt: prompt,
        maxTokens: maxTokens,
        temperature: temperature,
      );

      return response;
    } catch (e) {
      return Result.failure('AI 요청 중 오류가 발생했습니다.', e);
    }
  }

  /// Gemini API 호출 (공통 로직)
  Future<Result<String>> _callGemini({
    required String prompt,
    int maxTokens = 200,
    double temperature = 0.7,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      final headers = {'Content-Type': 'application/json'};

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': temperature,
          'maxOutputTokens': maxTokens,
        },
        'systemInstruction': {
          'parts': [
            {'text': _getSystemPrompt()},
          ],
        },
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final content =
              data['candidates'][0]['content']['parts'][0]['text']
                  .toString()
                  .trim();
          return Result.success(content);
        } else {
          return Result.failure('Gemini API에서 빈 응답을 받았습니다.', null);
        }
      } else {
        final errorData = jsonDecode(response.body);
        return Result.failure(
          'Gemini API 호출 실패: ${response.statusCode} - $errorData',
          null,
        );
      }
    } catch (e) {
      return Result.failure('Gemini API 호출 중 오류: $e', null);
    }
  }

  /// 시스템 프롬프트 - AI의 역할과 목적을 정의
  String _getSystemPrompt() {
    return '''
You are an expert English learning assistant.

Your task: Provide helpful, accurate, and natural English responses based on the given prompt.

Rules:
• Respond in clear, natural English
• Provide practical and useful information
• Keep responses concise and focused
• Use appropriate tone for the context
• Ensure grammatical correctness
''';
  }
}
