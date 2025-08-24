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
                      _buildScoreItem(
                        '점수',
                        '${results['totalScore'] ?? 0}/$maxScore',
                      ),
                      _buildScoreItem(
                        '정답률',
                        '${_calculateAccuracy().toStringAsFixed(1)}%',
                      ),
                      _buildScoreItem(
                        '맞힌 문제',
                        '${_calculateCorrectAnswers()}/${quizzes.length}',
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
    // AI 채점 결과를 그대로 사용
    final calculatedResults = Map<String, dynamic>.from(results);

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
    // AI 채점 결과에서 실제 점수와 정답 여부 가져오기
    final quizResult =
        results['quiz_${questionNumber - 1}'] as Map<String, dynamic>?;
    final score = quizResult?['score'] ?? 0;
    final isCorrect = quizResult?['isCorrect'] ?? false;
    final aiFeedback = quizResult?['aiFeedback'] as String?;

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

          // AI 피드백 표시
          if (aiFeedback != null && aiFeedback.isNotEmpty) ...[
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
                    aiFeedback,
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

  // AI 채점 결과에서 정답률 계산
  double _calculateAccuracy() {
    int correctCount = 0;
    for (int i = 0; i < quizzes.length; i++) {
      final quizResult = results['quiz_$i'] as Map<String, dynamic>?;
      if (quizResult?['isCorrect'] == true) {
        correctCount++;
      }
    }
    return quizzes.isEmpty ? 0.0 : (correctCount / quizzes.length) * 100;
  }

  // AI 채점 결과에서 맞힌 문제 수 계산
  int _calculateCorrectAnswers() {
    int correctCount = 0;
    for (int i = 0; i < quizzes.length; i++) {
      final quizResult = results['quiz_$i'] as Map<String, dynamic>?;
      if (quizResult?['isCorrect'] == true) {
        correctCount++;
      }
    }
    return correctCount;
  }
}
