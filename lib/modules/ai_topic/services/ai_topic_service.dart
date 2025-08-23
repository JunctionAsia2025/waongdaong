import 'dart:convert';
import '../../core/utils/result.dart';
import '../../ai/ai_module.dart';
import '../models/discussion_topics.dart';

/// AI 토론 주제 서비스 - AI Module을 활용하여 토론 주제 생성
class AITopicService {
  final AIModule _aiModule;

  AITopicService(this._aiModule);

  /// 콘텐츠 기반 토론 주제 3개 생성
  Future<Result<DiscussionTopics>> generateDiscussionTopics({
    required String contentText,
    required String contentType,
    String? additionalContext,
  }) async {
    try {
      final prompt = _buildDiscussionTopicsPrompt(
        contentText,
        contentType,
        additionalContext,
      );

      // JSON 형식으로 응답받기 위해 maxTokens를 늘림
      final response = await _aiModule.aiApiService.sendPrompt(
        prompt: prompt,
        maxTokens: 400,
        temperature: 0.8, // 창의성을 위해 temperature 약간 높임
      );

      if (response.isFailure) {
        return Result.failure(
          '토론 주제 생성 실패: ${response.errorMessageOrNull}',
          null,
        );
      }

      final responseText = response.dataOrNull!;

      // JSON 파싱 시도
      try {
        // JSON 문자열 정리 (```json과 ``` 제거)
        String cleanJsonString = responseText.trim();
        if (cleanJsonString.startsWith('```json')) {
          cleanJsonString = cleanJsonString.substring(7);
        }
        if (cleanJsonString.startsWith('```')) {
          cleanJsonString = cleanJsonString.substring(3);
        }
        if (cleanJsonString.endsWith('```')) {
          cleanJsonString = cleanJsonString.substring(
            0,
            cleanJsonString.length - 3,
          );
        }
        cleanJsonString = cleanJsonString.trim();

        final jsonData = jsonDecode(cleanJsonString) as Map<String, dynamic>;
        final discussionTopics = DiscussionTopics.fromJson(jsonData);

        if (!discussionTopics.isValid) {
          return Result.failure('생성된 토론 주제가 완전하지 않습니다.', null);
        }

        return Result.success(discussionTopics);
      } catch (e) {
        return Result.failure(
          'AI 응답을 JSON으로 파싱하는데 실패했습니다: $e\n응답: $responseText',
          e,
        );
      }
    } catch (e) {
      return Result.failure('토론 주제 생성 중 오류가 발생했습니다: $e', e);
    }
  }

  /// 토론 주제 생성을 위한 프롬프트 생성
  String _buildDiscussionTopicsPrompt(
    String contentText,
    String contentType,
    String? additionalContext,
  ) {
    final buffer = StringBuffer();

    buffer.writeln(
      '다음 ${_getContentTypeKorean(contentType)} 내용을 읽고 토론할 만한 주제 3개를 생성해주세요:',
    );
    buffer.writeln();
    buffer.writeln('콘텐츠 내용:');
    buffer.writeln('"""');
    buffer.writeln(contentText);
    buffer.writeln('"""');

    if (additionalContext != null && additionalContext.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('추가 맥락: $additionalContext');
    }

    buffer.writeln();
    buffer.writeln('다음 JSON 형식으로 정확히 응답해주세요:');
    buffer.writeln('{');
    buffer.writeln('  "topic1": "첫 번째 토론 주제 (한국어)",');
    buffer.writeln('  "topic2": "두 번째 토론 주제 (한국어)",');
    buffer.writeln('  "topic3": "세 번째 토론 주제 (한국어)"');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('요구사항:');
    buffer.writeln('• 각 주제는 토론하기에 적합하고 흥미로워야 함');
    buffer.writeln('• 콘텐츠의 핵심 내용과 관련이 있어야 함');
    buffer.writeln('• 서로 다른 관점이나 측면을 다뤄야 함');
    buffer.writeln('• 찬반 의견이 나올 수 있는 주제여야 함');
    buffer.writeln('• 반드시 JSON 형식으로만 응답해주세요 (다른 설명 없이)');

    return buffer.toString();
  }

  /// 콘텐츠 타입을 한국어로 변환
  String _getContentTypeKorean(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'news':
        return '뉴스';
      case 'paper':
        return '논문';
      case 'column':
        return '칼럼';
      case 'blog':
        return '블로그';
      default:
        return '콘텐츠';
    }
  }
}
