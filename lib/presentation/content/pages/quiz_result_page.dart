import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../modules/quiz/models/quiz.dart';
import '../../../modules/content/models/content.dart';
import 'content_report_page.dart';

class QuizResultPage extends StatelessWidget {
  final List<Quiz> quizzes;
  final Map<int, String> userAnswers;
  final Map<String, dynamic> results;
  final Content content;

  const QuizResultPage({
    super.key,
    required this.quizzes,
    required this.userAnswers,
    required this.results,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final totalScore = results['totalScore'] ?? 0;
    final maxScore = results['maxPossibleScore'] ?? 0;
    final accuracy = results['accuracyRate'] ?? 0.0;
    final correctAnswers = results['correctAnswers'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Quiz Results',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 전체 결과 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.YBMPurple,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.YBMPurple.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '🎉 퀴즈 완료!',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreItem('점수', '$totalScore/$maxScore'),
                      _buildScoreItem('정답률', '${accuracy.toStringAsFixed(1)}%'),
                      _buildScoreItem(
                        '맞힌 문제',
                        '$correctAnswers/${quizzes.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 각 문제별 결과
            Text(
              '문제별 결과',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            ...List.generate(quizzes.length, (index) {
              final quiz = quizzes[index];
              final userAnswer = userAnswers[index] ?? '';
              return _buildQuizResultCard(quiz, userAnswer, index + 1);
            }),

            const SizedBox(height: 32),

            // Generate Report 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _generateReport(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Generate Report',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateReport(BuildContext context) async {
    // 실제 퀴즈 점수 데이터 계산
    final calculatedResults = <String, dynamic>{};
    int totalScore = 0;
    int correctAnswers = 0;

    for (int i = 0; i < quizzes.length; i++) {
      final quiz = quizzes[i];
      final userAnswer = userAnswers[i] ?? '';
      final isCorrect = _evaluateAnswer(quiz, userAnswer);
      final score = isCorrect ? quiz.points : 0;

      if (isCorrect) {
        totalScore += score;
        correctAnswers++;
      }

      calculatedResults['quiz_$i'] = {
        'isCorrect': isCorrect,
        'score': score,
        'maxScore': quiz.points,
        'userAnswer': userAnswer,
        'correctAnswer': quiz.correctAnswer,
      };
    }

    calculatedResults['totalScore'] = totalScore;
    calculatedResults['correctAnswers'] = correctAnswers;
    calculatedResults['totalQuizzes'] = quizzes.length;

    // Content Report 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ContentReportPage(
              content: content,
              quizzes: quizzes,
              userAnswers: userAnswers,
              results: calculatedResults, // 실제 계산된 결과 전달
            ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizResultCard(
    Quiz quiz,
    String userAnswer,
    int questionNumber,
  ) {
    // 임시로 간단한 채점 (실제로는 AI 채점 결과 사용)
    final isCorrect = _evaluateAnswer(quiz, userAnswer);
    final score = isCorrect ? quiz.points : 0;

    String quizTypeName = '';
    Color cardColor = AppColors.YBMlightPurple;

    switch (quiz.quizType) {
      case QuizType.vocabulary:
        quizTypeName = 'Word Quiz';
        cardColor = AppColors.YBMlightPurple;
        break;
      case QuizType.translation:
        quizTypeName = 'Translation';
        cardColor = AppColors.YBMlightPurple;
        break;
      case QuizType.summary:
        quizTypeName = 'Summary';
        cardColor = AppColors.YBMlightPurple;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Q$questionNumber: $quizTypeName',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$score/${quiz.points}점',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 문제
          if (quiz.excerpt != null) ...[
            Text(
              '원문:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              quiz.excerpt!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
          ],

          Text(
            '문제: ${quiz.question}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // 답안 비교 (위아래 배치)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 내 답안
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내 답안:',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      userAnswer.isEmpty ? '(답안 없음)' : userAnswer,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            userAnswer.isEmpty
                                ? Colors.grey
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 정답
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '정답:',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Text(
                      quiz.correctAnswer,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // AI 피드백 (추후 구현)
          if (!isCorrect && quiz.quizType != QuizType.vocabulary) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Colors.blue.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI 피드백',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '더 자연스러운 표현을 사용해보세요. 문맥을 고려한 번역이 필요합니다.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _evaluateAnswer(Quiz quiz, String userAnswer) {
    if (userAnswer.trim().isEmpty) return false;

    print('🔍 채점 시작 - 퀴즈 타입: ${quiz.quizType}');
    print('📝 사용자 답안: "$userAnswer"');
    print('✅ 정답: "${quiz.correctAnswer}"');

    switch (quiz.quizType) {
      case QuizType.vocabulary:
        // 단어 퀴즈: 정확한 단어 매칭
        final userWord = userAnswer.trim().toLowerCase();
        final correctWord = quiz.correctAnswer.trim().toLowerCase();
        final isCorrect = userWord == correctWord;
        print(
          '📚 단어 퀴즈 - 사용자: "$userWord", 정답: "$correctWord", 결과: $isCorrect',
        );
        return isCorrect;

      case QuizType.translation:
        // 번역 퀴즈: 키워드 기반 평가
        final userText = userAnswer.trim().toLowerCase();
        final correctText = quiz.correctAnswer.trim().toLowerCase();

        // 키워드 추출 (간단한 방법)
        final userKeywords = _extractKeywords(userText);
        final correctKeywords = _extractKeywords(correctText);

        // 키워드 매칭 비율 계산
        final matchCount =
            userKeywords
                .where((keyword) => correctKeywords.contains(keyword))
                .length;
        final matchRatio =
            correctKeywords.isNotEmpty
                ? matchCount / correctKeywords.length
                : 0.0;

        final isCorrect =
            matchRatio >= 0.6 && userText.length >= 5; // 60% 이상 매칭 + 최소 길이
        print(
          '🌐 번역 퀴즈 - 매칭 비율: ${(matchRatio * 100).toStringAsFixed(1)}%, 결과: $isCorrect',
        );
        return isCorrect;

      case QuizType.summary:
        // 요약 퀴즈: 내용 기반 평가
        final userText = userAnswer.trim();
        final correctText = quiz.correctAnswer.trim();

        // 키워드 기반 평가
        final userKeywords = _extractKeywords(userText.toLowerCase());
        final correctKeywords = _extractKeywords(correctText.toLowerCase());

        final matchCount =
            userKeywords
                .where((keyword) => correctKeywords.contains(keyword))
                .length;
        final matchRatio =
            correctKeywords.isNotEmpty
                ? matchCount / correctKeywords.length
                : 0.0;

        final isCorrect =
            matchRatio >= 0.5 && userText.length >= 20; // 50% 이상 매칭 + 최소 길이
        print(
          '📖 요약 퀴즈 - 매칭 비율: ${(matchRatio * 100).toStringAsFixed(1)}%, 결과: $isCorrect',
        );
        return isCorrect;
    }
  }

  List<String> _extractKeywords(String text) {
    // 간단한 키워드 추출 (한글, 영어 단어)
    final words =
        text
            .split(RegExp(r'[^\w가-힣]'))
            .where((word) => word.length > 1)
            .toList();
    return words.take(10).toList(); // 상위 10개 단어만 사용
  }
}
