import '../../ai/services/ai_api_service.dart';
import '../../core/utils/result.dart';
import '../models/translation_result.dart';

/// AI 번역 서비스
class AiTransService {
  final AIApiService _aiApiService;

  AiTransService(this._aiApiService);

  /// 텍스트 번역
  Future<Result<TranslationResult>> translateText({
    required String text,
    String sourceLang = 'en',
    String targetLang = 'ko',
  }) async {
    try {
      print('🔄 번역 시작: "$text" ($sourceLang → $targetLang)');

      // AI API 호출 (ai_trans 파라미터 사용)
      final prompt = '''
다음 ${sourceLang == 'en' ? '영어' : sourceLang} 텍스트를 자연스러운 ${targetLang == 'ko' ? '한국어' : targetLang}로 번역해주세요.

원문: "$text"

번역:''';

      final result = await _aiApiService.sendPrompt(
        prompt: prompt,
        maxTokens: 300, // 번역에 충분한 토큰
        temperature: 0.3, // 번역은 일관성이 중요하므로 낮은 temperature
      );

      if (result.isSuccess) {
        final translatedText = result.dataOrNull?.trim() ?? '';
        print('✅ 번역 완료: "$translatedText"');

        final translationResult = TranslationResult(
          originalText: text,
          translatedText: translatedText,
          sourceLang: sourceLang,
          targetLang: targetLang,
          timestamp: DateTime.now(),
        );

        return Result.success(translationResult);
      } else {
        print('❌ 번역 실패: ${result.errorMessageOrNull}');
        return Result.failure('번역에 실패했습니다.', result.errorMessageOrNull);
      }
    } catch (e) {
      print('💥 번역 오류: $e');
      return Result.failure('번역 중 오류가 발생했습니다: $e', e);
    }
  }

  /// 언어 감지 (향후 확장용)
  Future<Result<String>> detectLanguage(String text) async {
    try {
      // 간단한 언어 감지 로직 (영어/한국어)
      final hasKorean = RegExp(r'[ㄱ-ㅎ가-힣]').hasMatch(text);
      final hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);

      if (hasKorean && !hasEnglish) {
        return Result.success('ko');
      } else if (hasEnglish && !hasKorean) {
        return Result.success('en');
      } else {
        return Result.success('en'); // 기본값
      }
    } catch (e) {
      return Result.failure('언어 감지에 실패했습니다: $e', e);
    }
  }
}
