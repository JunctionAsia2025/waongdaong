import 'package:uuid/uuid.dart';
import '../models/quiz.dart';
import '../models/quiz_attempt.dart';
import '../../report/models/report.dart';
import '../../supabase/services/database_service.dart';
import '../../ai/services/ai_api_service.dart';
import '../../core/utils/result.dart';

class QuizReportService {
  final DatabaseService _databaseService;
  final AIApiService _aiService;
  final _uuid = const Uuid();

  QuizReportService({
    required DatabaseService databaseService,
    required AIApiService aiService,
  }) : _databaseService = databaseService,
       _aiService = aiService;

  /// 퀴즈 결과를 바탕으로 즉석 리포트 생성
  Future<Result<Report>> generateQuizReport({
    required String userId,
    required String contentId,
    required String? learningSessionId,
    required List<Quiz> quizzes,
    required List<QuizAttempt> attempts,
    required String contentTitle,
  }) async {
    try {
      // 1. 퀴즈 결과 분석
      final quizAnalysis = _analyzeQuizResults(quizzes, attempts);

      // 2. AI 피드백 생성
      final aiFeedbackResult = await _generateAIFeedback(
        contentTitle: contentTitle,
        quizAnalysis: quizAnalysis,
        attempts: attempts,
      );

      if (aiFeedbackResult.isFailure) {
        return Result.failure(
          'AI 피드백 생성 실패: ${aiFeedbackResult.errorMessageOrNull}',
        );
      }

      // 3. 리포트 내용 구성
      final reportContent = _generateReportContent(quizAnalysis);

      // 4. 리포트 제목 생성
      final reportTitle = _generateReportTitle(quizAnalysis, contentTitle);

      // 5. Report 객체 생성 (실제 사용자 ID 사용)
      final report = Report(
        id: _uuid.v4(),
        userId: userId, // 실제 사용자 ID 사용
        reportType: ReportType.individualLearning,
        learningSessionId: null, // learning_sessions 테이블 의존성 제거
        studyGroupId: null,
        title: reportTitle,
        content: reportContent,
        aiFeedback: aiFeedbackResult.dataOrNull ?? '',
        userReflection: '', // 사용자가 나중에 입력할 수 있음
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      // 6. 데이터베이스에 저장
      final saveResult = await _saveReport(report);
      if (saveResult.isFailure) {
        return Result.failure('리포트 저장 실패: ${saveResult.errorMessageOrNull}');
      }

      return Result.success(report);
    } catch (e) {
      return Result.failure('퀴즈 리포트 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 퀴즈 결과 분석
  Map<String, dynamic> _analyzeQuizResults(
    List<Quiz> quizzes,
    List<QuizAttempt> attempts,
  ) {
    if (quizzes.isEmpty || attempts.isEmpty) {
      return {
        'totalQuizzes': 0,
        'correctAnswers': 0,
        'accuracyRate': 0.0,
        'totalScore': 0,
        'maxPossibleScore': 0,
        'averageTimePerQuiz': 0,
        'quizTypePerformance': {},
      };
    }

    final totalQuizzes = quizzes.length;
    final correctAnswers = attempts.where((a) => a.isCorrect).length;
    final accuracyRate = (correctAnswers / totalQuizzes) * 100;

    final totalScore = attempts.fold<int>(0, (sum, a) => sum + a.score);
    final maxPossibleScore = quizzes.fold<int>(0, (sum, q) => sum + q.points);

    final totalTime = attempts.fold<int>(0, (sum, a) => sum + a.timeSpent);
    final averageTimePerQuiz = totalTime / totalQuizzes;

    // 퀴즈 타입별 성과 분석
    final quizTypePerformance = <String, Map<String, dynamic>>{};
    for (final quizType in QuizType.values) {
      final typeQuizzes = quizzes.where((q) => q.quizType == quizType).toList();
      final typeAttempts =
          attempts.where((a) {
            final quiz = quizzes.firstWhere((q) => q.id == a.quizId);
            return quiz.quizType == quizType;
          }).toList();

      if (typeQuizzes.isNotEmpty) {
        final typeCorrect = typeAttempts.where((a) => a.isCorrect).length;
        final typeAccuracy = (typeCorrect / typeQuizzes.length) * 100;
        final typeScore = typeAttempts.fold<int>(0, (sum, a) => sum + a.score);
        final typeMaxScore = typeQuizzes.fold<int>(
          0,
          (sum, q) => sum + q.points,
        );

        quizTypePerformance[quizType.value] = {
          'count': typeQuizzes.length,
          'correct': typeCorrect,
          'accuracy': typeAccuracy,
          'score': typeScore,
          'maxScore': typeMaxScore,
        };
      }
    }

    return {
      'totalQuizzes': totalQuizzes,
      'correctAnswers': correctAnswers,
      'accuracyRate': accuracyRate,
      'totalScore': totalScore,
      'maxPossibleScore': maxPossibleScore,
      'averageTimePerQuiz': averageTimePerQuiz.round(),
      'quizTypePerformance': quizTypePerformance,
    };
  }

  /// AI 피드백 생성
  Future<Result<String>> _generateAIFeedback({
    required String contentTitle,
    required Map<String, dynamic> quizAnalysis,
    required List<QuizAttempt> attempts,
  }) async {
    final prompt = '''
다음 퀴즈 결과를 바탕으로 학습 리포트의 AI 피드백을 생성해주세요.

[콘텐츠 정보]
제목: $contentTitle

[퀴즈 결과 요약]
- 총 퀴즈 수: ${quizAnalysis['totalQuizzes']}개
- 정답 수: ${quizAnalysis['correctAnswers']}개
- 정확률: ${quizAnalysis['accuracyRate'].toStringAsFixed(1)}%
- 총점: ${quizAnalysis['totalScore']}/${quizAnalysis['maxPossibleScore']}점
- 평균 소요 시간: ${quizAnalysis['averageTimePerQuiz']}초

[퀴즈 타입별 성과]
${_formatQuizTypePerformance(quizAnalysis['quizTypePerformance'])}

[AI 평가 상세 분석]
${_formatAIEvaluationDetails(attempts)}

[요청사항]
다음 3가지 영역에 대해 한국어로 구체적이고 도움이 되는 피드백을 제공해주세요:

1. **성과 요약**: 전반적인 학습 성과와 주요 성취점
2. **개선 방향**: 취약한 영역과 구체적인 개선 방법
3. **학습 조언**: 향후 학습을 위한 실용적인 팁과 전략

응답은 다음 형식으로 작성해주세요:
- 간결하고 명확한 문장 사용
- 구체적인 예시와 방법 제시
- 긍정적이고 격려하는 톤 유지
- 실행 가능한 조언 위주로 구성
''';

    return await _aiService.sendPrompt(
      prompt: prompt,
      maxTokens: 2000, // 토큰 수 증가
      temperature: 0.7,
    );
  }

  /// 퀴즈 타입별 성과 포맷팅
  String _formatQuizTypePerformance(Map<String, dynamic> performance) {
    final buffer = StringBuffer();

    for (final entry in performance.entries) {
      final type = entry.key;
      final data = entry.value as Map<String, dynamic>;

      buffer.writeln(
        '• $type: ${data['count']}개 중 ${data['correct']}개 정답 (${data['accuracy'].toStringAsFixed(1)}%)',
      );
    }

    return buffer.toString();
  }

  /// AI 평가 상세 정보 포맷팅
  String _formatAIEvaluationDetails(List<QuizAttempt> attempts) {
    final buffer = StringBuffer();

    for (final attempt in attempts) {
      if (attempt.aiEvaluation != null) {
        final evaluation = attempt.aiEvaluation!;
        buffer.writeln('• 퀴즈 ${attempt.quizId}:');

        if (evaluation.containsKey('accuracyScore')) {
          buffer.writeln('  - 정확성: ${evaluation['accuracyScore']}점');
        }
        if (evaluation.containsKey('completenessScore')) {
          buffer.writeln('  - 완성도: ${evaluation['completenessScore']}점');
        }
        if (evaluation.containsKey('fluencyScore')) {
          buffer.writeln('  - 자연스러움: ${evaluation['fluencyScore']}점');
        }
        if (evaluation.containsKey('naturalnessScore')) {
          buffer.writeln('  - 자연스러움: ${evaluation['naturalnessScore']}점');
        }
        if (evaluation.containsKey('contextScore')) {
          buffer.writeln('  - 문맥 이해: ${evaluation['contextScore']}점');
        }
        buffer.writeln('  - 전체 점수: ${evaluation['overallScore']}점');
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }

  /// 리포트 내용 생성
  String _generateReportContent(Map<String, dynamic> analysis) {
    final accuracyRate = analysis['accuracyRate'] as double;
    final totalScore = analysis['totalScore'] as int;
    final maxScore = analysis['maxPossibleScore'] as int;
    final totalQuizzes = analysis['totalQuizzes'] as int;
    final correctAnswers = analysis['correctAnswers'] as int;

    String performanceLevel;
    if (accuracyRate >= 90) {
      performanceLevel = '우수';
    } else if (accuracyRate >= 70) {
      performanceLevel = '양호';
    } else if (accuracyRate >= 50) {
      performanceLevel = '보통';
    } else {
      performanceLevel = '개선 필요';
    }

    return '''
## 📊 퀴즈 결과 요약

**전체 성과**: $performanceLevel
**총 퀴즈 수**: $totalQuizzes개
**정답 수**: $correctAnswers개
**정확률**: ${accuracyRate.toStringAsFixed(1)}%
**총점**: $totalScore/$maxScore점
**평균 소요 시간**: ${analysis['averageTimePerQuiz']}초

## 🎯 퀴즈 타입별 성과

${_formatQuizTypePerformanceForContent(analysis['quizTypePerformance'])}

## 💡 학습 포인트

이번 퀴즈를 통해 학습한 내용을 정리하고, 다음 학습에 활용해보세요.
''';
  }

  /// 리포트 내용용 퀴즈 타입별 성과 포맷팅
  String _formatQuizTypePerformanceForContent(
    Map<String, dynamic> performance,
  ) {
    final buffer = StringBuffer();

    for (final entry in performance.entries) {
      final type = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final count = data['count'] as int;
      final correct = data['correct'] as int;
      final accuracy = data['accuracy'] as double;
      final score = data['score'] as int;
      final maxScore = data['maxScore'] as int;

      String typeDisplay;
      switch (type) {
        case 'vocabulary':
          typeDisplay = '🔤 단어 퀴즈';
          break;
        case 'summary':
          typeDisplay = '📝 요약 퀴즈';
          break;
        case 'translation':
          typeDisplay = '🌐 번역 퀴즈';
          break;
        default:
          typeDisplay = type;
      }

      buffer.writeln('**$typeDisplay**');
      buffer.writeln('- 문제 수: $count개');
      buffer.writeln('- 정답: $correct개');
      buffer.writeln('- 정확률: ${accuracy.toStringAsFixed(1)}%');
      buffer.writeln('- 점수: $score/$maxScore점');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  /// 리포트 제목 생성
  String _generateReportTitle(
    Map<String, dynamic> analysis,
    String contentTitle,
  ) {
    final accuracyRate = analysis['accuracyRate'] as double;

    String performance;
    if (accuracyRate >= 90) {
      performance = '우수한';
    } else if (accuracyRate >= 70) {
      performance = '양호한';
    } else if (accuracyRate >= 50) {
      performance = '보통의';
    } else {
      performance = '개선이 필요한';
    }

    return '$contentTitle - $performance 학습 결과 리포트';
  }

  /// 리포트를 데이터베이스에 저장
  Future<Result<void>> _saveReport(Report report) async {
    try {
      await _databaseService.insert(table: 'reports', data: report.toJson());
      return const Result.success(null);
    } catch (e) {
      return Result.failure('리포트 저장 중 오류: $e');
    }
  }

  /// 사용자의 퀴즈 리포트 조회
  Future<Result<List<Report>>> getUserQuizReports(String userId) async {
    try {
      final result = await _databaseService.select(
        table: 'reports',
        filters: {
          'user_id': userId,
          'report_type': ReportType.individualLearning.name,
        },
        orderBy: 'created_at',
        ascending: false,
      );

      final reports = result.map((json) => Report.fromJson(json)).toList();
      return Result.success(reports);
    } catch (e) {
      return Result.failure('퀴즈 리포트 조회 중 오류: $e');
    }
  }

  /// 특정 콘텐츠의 퀴즈 리포트 조회
  Future<Result<List<Report>>> getContentQuizReports(String contentId) async {
    try {
      final result = await _databaseService.select(
        table: 'reports',
        filters: {
          'content_id': contentId,
          'report_type': ReportType.individualLearning.name,
        },
        orderBy: 'created_at',
        ascending: false,
      );

      final reports = result.map((json) => Report.fromJson(json)).toList();
      return Result.success(reports);
    } catch (e) {
      return Result.failure('콘텐츠 퀴즈 리포트 조회 중 오류: $e');
    }
  }
}
