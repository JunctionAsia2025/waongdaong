import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../modules/content/models/content.dart';
import '../../../modules/quiz/models/quiz.dart';
import '../../../modules/quiz/models/quiz_attempt.dart';
import '../../../modules/report/models/report.dart';
import '../../../modules/quiz/services/quiz_report_service.dart';
import '../../../modules/quiz/quiz_module.dart';
import '../../../modules/supabase/supabase_module.dart';
import '../../../modules/ai/ai_module.dart';
import '../../../modules/app_module_manager.dart';
import '../../shared/widgets/loading_indicator.dart';

class ContentReportPage extends StatefulWidget {
  final Content content;
  final List<Quiz> quizzes;
  final Map<int, String> userAnswers;
  final Map<String, dynamic> results;

  const ContentReportPage({
    super.key,
    required this.content,
    required this.quizzes,
    required this.userAnswers,
    required this.results,
  });

  @override
  State<ContentReportPage> createState() => _ContentReportPageState();
}

class _ContentReportPageState extends State<ContentReportPage> {
  bool _isLoading = true;
  String? _error;
  Report? _report;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔥 리포트 생성 시작');

      // 틀린 문제들 찾기
      final incorrectQuizzes = <Quiz>[];
      final incorrectAnswers = <String>[];

      for (int i = 0; i < widget.quizzes.length; i++) {
        final quiz = widget.quizzes[i];
        final userAnswer = widget.userAnswers[i] ?? '';
        final isCorrect = _evaluateAnswer(quiz, userAnswer);

        if (!isCorrect && userAnswer.isNotEmpty) {
          incorrectQuizzes.add(quiz);
          incorrectAnswers.add(userAnswer);
        }
      }

      // 실제 사용자 ID 가져오기 (Supabase에서)
      final databaseService = SupabaseModule.instance.database;
      String actualUserId = '00000000-0000-0000-0000-000000000000';

      try {
        final usersResult = await databaseService.select(
          table: 'users',
          limit: 1,
        );

        if (usersResult.isNotEmpty) {
          actualUserId = usersResult.first['id'] as String;
        } else {
          // 사용자 테이블이 비어있으면 임시 사용자 생성
          final tempUserId = DateTime.now().millisecondsSinceEpoch.toString();
          await databaseService.insert(
            table: 'users',
            data: {
              'id': tempUserId,
              'email': 'temp@example.com',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            },
          );
          actualUserId = tempUserId;
        }
      } catch (e) {
        // 에러 발생 시 기본 UUID 사용
        print('⚠️ 사용자 ID 가져오기 실패: $e');
        actualUserId = '00000000-0000-0000-0000-000000000000';
      }

      // QuizModule의 QuizReportService 사용
      final reportService = QuizModule.instance.quizService.reportService;

      // QuizAttempt 객체들 생성
      final attempts = <QuizAttempt>[];
      for (int i = 0; i < widget.quizzes.length; i++) {
        final quiz = widget.quizzes[i];
        final userAnswer = widget.userAnswers[i] ?? '';
        final isCorrect = _evaluateAnswer(quiz, userAnswer);

        attempts.add(
          QuizAttempt(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
            quizId: quiz.id,
            userId: actualUserId, // 실제 존재하는 사용자 ID
            userAnswer: userAnswer,
            isCorrect: isCorrect,
            score: isCorrect ? quiz.points : 0,
            timeSpent: 30, // 임시 값
            createdAt: DateTime.now(),
          ),
        );
      }

      final reportResult = await reportService.generateQuizReport(
        userId: actualUserId, // 실제 존재하는 사용자 ID
        contentId: widget.content.id,
        learningSessionId: null, // learning_sessions 테이블에 없으므로 null로 설정
        quizzes: widget.quizzes,
        attempts: attempts,
        contentTitle: widget.content.title,
      );

      if (reportResult.isSuccess) {
        _report = reportResult.dataOrNull!;
        print('✅ 리포트 생성 성공');
      } else {
        throw Exception(reportResult.errorMessageOrNull ?? '리포트 생성 실패');
      }
    } catch (e) {
      print('💥 리포트 생성 실패: $e');
      setState(() {
        _error = '리포트 생성 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveReportToDatabase() async {
    if (_report == null) return;

    try {
      final databaseService = SupabaseModule.instance.database;

      await databaseService.insert(table: 'reports', data: _report!.toJson());

      print('✅ 리포트 데이터베이스 저장 완료');
    } catch (e) {
      print('⚠️ 리포트 저장 실패: $e');
    }
  }

  bool _evaluateAnswer(Quiz quiz, String userAnswer) {
    if (userAnswer.isEmpty) return false;

    switch (quiz.quizType) {
      case QuizType.vocabulary:
        return userAnswer.toLowerCase().trim() ==
            quiz.correctAnswer.toLowerCase().trim();
      case QuizType.translation:
      case QuizType.summary:
        final userWords = userAnswer.toLowerCase().split(' ');
        final correctWords = quiz.correctAnswer.toLowerCase().split(' ');
        final matchCount =
            userWords
                .where(
                  (word) => correctWords.any(
                    (correct) =>
                        correct.contains(word) || word.contains(correct),
                  ),
                )
                .length;
        return matchCount >= (correctWords.length * 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Learning Report',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.YBMPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorView()
              : _buildReportView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              '리포트 생성 실패',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _generateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.YBMPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportView() {
    if (_report == null) return const Center(child: Text('리포트 데이터가 없습니다.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildContentCard(),
          const SizedBox(height: 16),
          _buildAIFeedbackCard(),
          const SizedBox(height: 16),
          _buildQuizDetailsCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.YBMPurple, AppColors.YBMBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _report!.title,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '생성일: ${_formatDate(_report!.createdAt)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return _buildCard(
      title: '📊 학습 요약',
      child: MarkdownBody(
        data: '''
# 🎯 학습 완료!

**퀴즈 세션이 성공적으로 완료되었습니다.**

## 📈 주요 성과
- ✅ **퀴즈 참여**: ${widget.quizzes.length}문제 풀이
- 🎯 **학습 목표**: 영어 실력 향상
- 📚 **학습 내용**: ${widget.content.title}

---
        ''',
        styleSheet: MarkdownStyleSheet(
          h1: AppTextStyles.h2.copyWith(
            color: AppColors.YBMPurple,
            fontWeight: FontWeight.bold,
          ),
          h2: AppTextStyles.h3.copyWith(
            color: AppColors.YBMBlue,
            fontWeight: FontWeight.bold,
          ),
          p: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          strong: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.YBMPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return _buildCard(
      title: '📝 학습 내용',
      child: MarkdownBody(
        data: '''
# 📖 학습한 내용

${_report!.content}

## 🔍 핵심 포인트
- **주제**: ${widget.content.title}
- **난이도**: ${widget.content.contentType}
- **학습 시간**: ${_formatDate(_report!.createdAt)}

---
        ''',
        styleSheet: MarkdownStyleSheet(
          h1: AppTextStyles.h3.copyWith(
            color: AppColors.YBMPurple,
            fontWeight: FontWeight.bold,
          ),
          h2: AppTextStyles.h4.copyWith(
            color: AppColors.YBMBlue,
            fontWeight: FontWeight.bold,
          ),
          p: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          strong: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.YBMPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAIFeedbackCard() {
    return _buildCard(
      title: '🤖 AI 피드백',
      child: MarkdownBody(
        data: '''
# 💡 AI 학습 분석

${_report!.aiFeedback}

## 🎯 개선 제안
- **다음 학습**: 더 많은 퀴즈 풀기
- **복습**: 틀린 문제 다시 확인
- **연습**: 유사한 내용으로 추가 학습

---
        ''',
        styleSheet: MarkdownStyleSheet(
          h1: AppTextStyles.h3.copyWith(
            color: AppColors.YBMPurple,
            fontWeight: FontWeight.bold,
          ),
          h2: AppTextStyles.h4.copyWith(
            color: AppColors.YBMBlue,
            fontWeight: FontWeight.bold,
          ),
          p: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          strong: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.YBMPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizDetailsCard() {
    final totalScore = widget.results['totalScore'] ?? 0;
    final maxScore = widget.results['maxPossibleScore'] ?? 0;
    final accuracy = widget.results['accuracy'] ?? 0.0;
    final correctAnswers = widget.results['correctAnswers'] ?? 0;

    return _buildCard(
      title: '📋 퀴즈 결과 상세',
      child: MarkdownBody(
        data: '''
# 📊 퀴즈 성과 분석

## 🎯 **전체 성과**
| 항목 | 결과 |
|------|------|
| **총 점수** | **$totalScore/$maxScore** |
| **정답률** | **${accuracy.toStringAsFixed(1)}%** |
| **맞힌 문제** | **$correctAnswers/${widget.quizzes.length}** |

## 📈 **성과 등급**
${_getPerformanceGrade(accuracy)}

## 🎉 **축하합니다!**
퀴즈를 성공적으로 완료하셨습니다!

---
        ''',
        styleSheet: MarkdownStyleSheet(
          h1: AppTextStyles.h3.copyWith(
            color: AppColors.YBMPurple,
            fontWeight: FontWeight.bold,
          ),
          h2: AppTextStyles.h4.copyWith(
            color: AppColors.YBMBlue,
            fontWeight: FontWeight.bold,
          ),
          p: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          strong: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.YBMPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getPerformanceGrade(double accuracy) {
    if (accuracy >= 90) {
      return '**🏆 A+ 등급** - 탁월한 성과입니다!';
    } else if (accuracy >= 80) {
      return '**🥇 A 등급** - 매우 좋은 성과입니다!';
    } else if (accuracy >= 70) {
      return '**🥈 B 등급** - 좋은 성과입니다!';
    } else if (accuracy >= 60) {
      return '**🥉 C 등급** - 보통 성과입니다!';
    } else {
      return '**📚 D 등급** - 더 많은 연습이 필요합니다!';
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.YBMPurple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
