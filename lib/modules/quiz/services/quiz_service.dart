import 'dart:convert';
import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import '../models/quiz.dart';
import '../models/quiz_attempt.dart';
import '../../supabase/services/database_service.dart';
import '../../ai/services/ai_api_service.dart';
import '../../core/utils/result.dart';
import 'quiz_report_service.dart';

/// 퀴즈 관련 서비스
class QuizService {
  final DatabaseService _databaseService;
  final AIApiService _aiService;
  late final QuizReportService _reportService;
  final Uuid _uuid = const Uuid();

  /// QuizReportService 가져오기
  QuizReportService get reportService => _reportService;

  QuizService({
    required DatabaseService databaseService,
    required AIApiService aiService,
  }) : _databaseService = databaseService,
       _aiService = aiService {
    _reportService = QuizReportService(
      databaseService: databaseService,
      aiService: aiService,
    );
  }

  /// 콘텐츠에 대한 퀴즈 생성 (AI 사용)
  Future<Result<List<Quiz>>> generateQuizzesForContent({
    required String contentId,
    required String contentText,
    required String difficultyLevel,
    int vocabularyCount = 5,
    int summaryCount = 3,
    int translationCount = 3,
  }) async {
    try {
      final List<Quiz> allQuizzes = [];

      // 1. 단어 퀴즈 생성
      final vocabResult = await _generateVocabularyQuizzes(
        contentId: contentId,
        contentText: contentText,
        difficultyLevel: difficultyLevel,
        count: vocabularyCount,
      );
      if (vocabResult.isSuccess) {
        allQuizzes.addAll(vocabResult.dataOrNull ?? []);
      }

      // 2. 요약 퀴즈 생성
      final summaryResult = await _generateSummaryQuizzes(
        contentId: contentId,
        contentText: contentText,
        difficultyLevel: difficultyLevel,
        count: summaryCount,
      );
      if (summaryResult.isSuccess) {
        allQuizzes.addAll(summaryResult.dataOrNull ?? []);
      }

      // 3. 번역 퀴즈 생성
      final translationResult = await _generateTranslationQuizzes(
        contentId: contentId,
        contentText: contentText,
        difficultyLevel: difficultyLevel,
        count: translationCount,
      );
      if (translationResult.isSuccess) {
        allQuizzes.addAll(translationResult.dataOrNull ?? []);
      }

      // 데이터베이스에 저장
      for (final quiz in allQuizzes) {
        await _saveQuizToDatabase(quiz);
      }

      // 진행 상황 업데이트
      await _updateContentQuizProgress(contentId, allQuizzes.length);

      return Result.success(allQuizzes);
    } catch (e) {
      return Result.failure('퀴즈 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 퀴즈 완료 후 리포트 생성
  Future<Result<Map<String, dynamic>>> completeQuizSession({
    required String userId,
    required String contentId,
    required String? learningSessionId,
    required List<Quiz> quizzes,
    required List<Map<String, dynamic>> userAnswers,
    required String contentTitle,
  }) async {
    try {
      // 1. 사용자 답안을 QuizAttempt로 변환
      final attempts = await _processUserAnswers(userId, quizzes, userAnswers);

      // 2. 학습 리포트 생성
      final reportResult = await _reportService.generateQuizReport(
        userId: userId,
        contentId: contentId,
        learningSessionId: learningSessionId,
        quizzes: quizzes,
        attempts: attempts,
        contentTitle: contentTitle,
      );

      if (reportResult.isFailure) {
        return Result.failure('리포트 생성 실패: ${reportResult.errorMessageOrNull}');
      }

      // 3. 결과 요약 반환
      final summary = _generateSessionSummary(quizzes, attempts);

      return Result.success({
        'report': reportResult.dataOrNull,
        'summary': summary,
        'attempts': attempts,
      });
    } catch (e) {
      return Result.failure('퀴즈 세션 완료 중 오류가 발생했습니다: $e');
    }
  }

  /// 단어 퀴즈 생성
  Future<Result<List<Quiz>>> _generateVocabularyQuizzes({
    required String contentId,
    required String contentText,
    required String difficultyLevel,
    required int count,
  }) async {
    try {
      final prompt = '''
다음 영어 텍스트에서 $count개의 단어 퀴즈를 생성해주세요.
난이도: $difficultyLevel
형식: JSON 배열

각 퀴즈는 다음 형식이어야 합니다:
{
  "word": "단어",
  "question": "What does '[단어]' mean in this context?",
  "correct_answer": "정답",
  "options": ["정답", "오답1", "오답2", "오답3"]
}

텍스트:
$contentText

응답은 순수 JSON 배열만 제공해주세요.
''';

      print('🤖 [단어퀴즈] AI 프롬프트 전송...');
      print('📝 콘텐츠 길이: ${contentText.length}자');

      final response = await _aiService.sendPrompt(
        prompt: prompt,
        maxTokens: 2000, // 퀴즈 3개 완전 생성을 위한 충분한 토큰 수
      );
      print('📡 AI 응답 상태: ${response.isSuccess}');

      if (response.isFailure) {
        print('❌ AI 응답 실패: ${response.errorMessageOrNull}');

        // API 할당량 초과 시는 에러로 처리 (샘플 퀴즈는 ContentSessionPage에서 처리)
        return Result.failure('AI 응답 오류: ${response.errorMessageOrNull}');
      }

      final rawResponse = response.dataOrNull ?? '';
      print('📄 [단어퀴즈] AI 원본 응답:');
      print('=== 응답 시작 ===');
      print(rawResponse);
      print('=== 응답 끝 ===');
      print('응답 길이: ${rawResponse.length}자');

      try {
        final quizData = _parseAIResponse(rawResponse);
        print('✅ [단어퀴즈] 파싱 성공! ${quizData.length}개 퀴즈 데이터 추출');
      } catch (parseError) {
        print('❌ [단어퀴즈] 파싱 실패: $parseError');
        print('🔧 파싱 시도한 응답:');
        print(rawResponse);
        return Result.failure('단어퀴즈 AI 응답 파싱 실패: $parseError');
      }

      final quizData = _parseAIResponse(rawResponse);
      final List<Quiz> quizzes = [];

      for (final data in quizData) {
        final quiz = Quiz(
          id: _uuid.v4(),
          contentId: contentId,
          quizType: QuizType.vocabulary,
          question: data['question'] as String,
          correctAnswer: data['correct_answer'] as String,
          options: List<String>.from(data['options'] as List),
          difficultyLevel: difficultyLevel,
          points: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        quizzes.add(quiz);
      }

      return Result.success(quizzes);
    } catch (e) {
      return Result.failure('단어 퀴즈 생성 실패: $e');
    }
  }

  /// 요약 퀴즈 생성
  Future<Result<List<Quiz>>> _generateSummaryQuizzes({
    required String contentId,
    required String contentText,
    required String difficultyLevel,
    required int count,
  }) async {
    try {
      final prompt = '''
다음 영어 텍스트 전체에 대한 1개의 요약 퀴즈를 생성해주세요.
난이도: $difficultyLevel

퀴즈 형식:
{
  "excerpt": "전체 텍스트 내용 (원문 그대로)",
  "question": "Summarize the entire article in 3-4 sentences in English. Your summary should capture the main points and key information.",
  "correct_answer": "전체 내용을 포괄하는 3-4문장의 모범 요약 답안"
}

텍스트:
$contentText

응답은 순수 JSON 배열 형태로 1개 객체만 제공해주세요.
''';

      final response = await _aiService.sendPrompt(
        prompt: prompt,
        maxTokens: 2000, // 퀴즈 완전 생성을 위한 충분한 토큰 수
      );
      if (response.isFailure) {
        return Result.failure('AI 응답 오류: ${response.errorMessageOrNull}');
      }

      final quizData = _parseAIResponse(response.dataOrNull ?? '');
      final List<Quiz> quizzes = [];

      for (final data in quizData) {
        final quiz = Quiz(
          id: _uuid.v4(),
          contentId: contentId,
          quizType: QuizType.summary,
          question: data['question'] as String,
          correctAnswer: data['correct_answer'] as String,
          excerpt: data['excerpt'] as String,
          difficultyLevel: difficultyLevel,
          points: 20,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        quizzes.add(quiz);
      }

      return Result.success(quizzes);
    } catch (e) {
      return Result.failure('요약 퀴즈 생성 실패: $e');
    }
  }

  /// 번역 퀴즈 생성
  Future<Result<List<Quiz>>> _generateTranslationQuizzes({
    required String contentId,
    required String contentText,
    required String difficultyLevel,
    required int count,
  }) async {
    try {
      final prompt = '''
다음 영어 텍스트에서 $count개의 번역 퀴즈를 생성해주세요.
난이도: $difficultyLevel

각 퀴즈는 다음 형식이어야 합니다:
{
  "excerpt": "번역할 영어 문장",
  "question": "Translate the following sentence into Korean:",
  "correct_answer": "정확한 한국어 번역"
}

텍스트:
$contentText

응답은 순수 JSON 배열만 제공해주세요.
''';

      final response = await _aiService.sendPrompt(
        prompt: prompt,
        maxTokens: 2000, // 퀴즈 완전 생성을 위한 충분한 토큰 수
      );
      if (response.isFailure) {
        return Result.failure('AI 응답 오류: ${response.errorMessageOrNull}');
      }

      final quizData = _parseAIResponse(response.dataOrNull ?? '');
      final List<Quiz> quizzes = [];

      for (final data in quizData) {
        final quiz = Quiz(
          id: _uuid.v4(),
          contentId: contentId,
          quizType: QuizType.translation,
          question: data['question'] as String,
          correctAnswer: data['correct_answer'] as String,
          excerpt: data['excerpt'] as String,
          difficultyLevel: difficultyLevel,
          points: 15,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        quizzes.add(quiz);
      }

      return Result.success(quizzes);
    } catch (e) {
      return Result.failure('번역 퀴즈 생성 실패: $e');
    }
  }

  /// 콘텐츠별 퀴즈 조회
  Future<Result<List<Quiz>>> getQuizzesByContent(String contentId) async {
    try {
      final result = await _databaseService.select(
        table: 'quizzes',
        filters: {'content_id': contentId},
        orderBy: 'created_at',
      );

      final quizzes = result.map((json) => Quiz.fromJson(json)).toList();

      return Result.success(quizzes);
    } catch (e) {
      return Result.failure('퀴즈 조회 중 오류: $e');
    }
  }

  /// 퀴즈 답안 제출
  Future<Result<QuizAttempt>> submitQuizAnswer({
    required String quizId,
    required String userId,
    required String userAnswer,
    required int timeSpent,
  }) async {
    try {
      // 퀴즈 정보 조회
      final quizResult = await _databaseService.selectOne(
        table: 'quizzes',
        filters: {'id': quizId},
      );
      if (quizResult == null) {
        return Result.failure('퀴즈를 찾을 수 없습니다');
      }

      final quiz = Quiz.fromJson(quizResult);

      // 정답 확인 및 점수 계산
      final (isCorrect, score, feedback) = await _evaluateAnswer(
        quiz: quiz,
        userAnswer: userAnswer,
      );

      // 답안 기록 저장
      final attemptData = {
        'quiz_id': quizId,
        'user_id': userId,
        'user_answer': userAnswer,
        'is_correct': isCorrect,
        'score': score,
        'time_spent': timeSpent,
        'ai_feedback': feedback,
      };

      final result = await _databaseService.insert(
        table: 'quiz_attempts',
        data: attemptData,
      );

      final attempt = QuizAttempt.fromJson(result.first);

      // 진행 상황 업데이트
      await _updateUserQuizProgress(userId, quiz.contentId);

      return Result.success(attempt);
    } catch (e) {
      return Result.failure('답안 제출 중 오류: $e');
    }
  }

  /// 답안 평가 (AI 사용)
  Future<(bool, int, String?)> _evaluateAnswer({
    required Quiz quiz,
    required String userAnswer,
  }) async {
    if (quiz.isVocabulary) {
      // 단어 퀴즈는 정확한 매칭
      final isCorrect =
          userAnswer.trim().toLowerCase() ==
          quiz.correctAnswer.trim().toLowerCase();
      return (isCorrect, isCorrect ? quiz.points : 0, null);
    }

    // 요약/번역 퀴즈는 AI 평가
    final prompt = '''
다음 ${quiz.isSummary ? '요약' : '번역'} 답안을 평가해주세요.

문제: ${quiz.question}
${quiz.excerpt != null ? '원문: ${quiz.excerpt}' : ''}
모범답안: ${quiz.correctAnswer}
사용자답안: $userAnswer

평가 기준:
- 정확성 (50%)
- 완성도 (30%)
- 언어적 자연스러움 (20%)

응답 형식:
{
  "score": 0-${quiz.points} 사이의 점수,
  "feedback": "구체적인 피드백"
}
''';

    try {
      final response = await _aiService.sendPrompt(prompt: prompt);
      if (response.isFailure) {
        // AI 평가 실패 시 기본 평가
        return (false, 0, '평가 중 오류가 발생했습니다');
      }

      final evaluation = _parseAIResponse(response.dataOrNull ?? '').first;
      final score = evaluation['score'] as int;
      final feedback = evaluation['feedback'] as String;
      final isCorrect = score >= (quiz.points * 0.7); // 70% 이상이면 정답

      return (isCorrect, score, feedback);
    } catch (e) {
      return (false, 0, '평가 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자 답안 처리 및 QuizAttempt 생성
  Future<List<QuizAttempt>> _processUserAnswers(
    String userId,
    List<Quiz> quizzes,
    List<Map<String, dynamic>> userAnswers,
  ) async {
    final attempts = <QuizAttempt>[];

    for (int i = 0; i < quizzes.length && i < userAnswers.length; i++) {
      final quiz = quizzes[i];
      final answer = userAnswers[i];

      // 퀴즈 타입별로 다른 평가 방식 적용
      final (isCorrect, score, aiEvaluation) = await _evaluateQuizAnswer(
        quiz,
        answer['answer'],
        answer['timeSpent'] ?? 0,
      );

      final attempt = QuizAttempt(
        id: _generateId(),
        quizId: quiz.id,
        userId: userId,
        userAnswer: answer['answer'],
        isCorrect: isCorrect,
        score: score,
        timeSpent: answer['timeSpent'] ?? 0,
        aiEvaluation: aiEvaluation,
        createdAt: DateTime.now(),
      );

      attempts.add(attempt);
      await _saveQuizAttempt(attempt);
    }

    return attempts;
  }

  /// AI 응답 파싱
  List<Map<String, dynamic>> _parseAIResponse(String response) {
    try {
      print('🔍 파싱 시작...');
      print('원본 응답 길이: ${response.length}');

      // 1. 코드 블록 제거 (```json ... ```)
      String cleanedResponse = response;

      // ```json 블록 제거
      if (response.contains('```json')) {
        cleanedResponse =
            response.replaceAll('```json', '').replaceAll('```', '').trim();
        print('✅ ```json 코드 블록 제거 완료');
      }
      // 일반 ``` 블록 제거
      else if (response.contains('```')) {
        cleanedResponse = response.replaceAll('```', '').trim();
        print('✅ ``` 코드 블록 제거 완료');
      }

      // 추가 정리: 앞뒤 공백 및 특수문자 제거
      cleanedResponse = cleanedResponse.trim();
      if (cleanedResponse.startsWith('json')) {
        cleanedResponse = cleanedResponse.substring(4).trim();
      }

      print('정리된 응답 길이: ${cleanedResponse.length}');

      // 2. JSON 배열 찾기
      final jsonStart = cleanedResponse.indexOf('[');
      final jsonEnd = cleanedResponse.lastIndexOf(']') + 1;

      print('JSON 시작 위치: $jsonStart');
      print('JSON 끝 위치: $jsonEnd');

      if (jsonStart == -1 || jsonEnd == 0) {
        print('❌ JSON 배열을 찾을 수 없습니다');

        // 3. JSON 객체들이 개별적으로 있는지 확인
        final objects = <Map<String, dynamic>>[];
        final lines = cleanedResponse.split('\n');

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
            try {
              final obj = jsonDecode(trimmed) as Map<String, dynamic>;
              objects.add(obj);
              print('✅ 개별 JSON 객체 파싱 성공');
            } catch (e) {
              print('⚠️ JSON 객체 파싱 실패: $e');
            }
          }
        }

        if (objects.isNotEmpty) {
          print('✅ 개별 객체 파싱으로 ${objects.length}개 발견');
          return objects;
        }

        throw Exception(
          'JSON 형식을 찾을 수 없습니다. 응답: ${cleanedResponse.substring(0, math.min(200, cleanedResponse.length))}...',
        );
      }

      String jsonString = cleanedResponse.substring(jsonStart, jsonEnd);
      print('추출된 JSON 길이: ${jsonString.length}자');

      // JSON이 불완전한 경우 수정 시도
      if (!jsonString.endsWith(']')) {
        print('⚠️ JSON이 불완전함. 수정 시도...');

        // 마지막 완전한 객체를 찾아서 배열을 닫기
        final lastCompleteObject = jsonString.lastIndexOf('}');
        if (lastCompleteObject != -1) {
          jsonString = jsonString.substring(0, lastCompleteObject + 1) + '\n]';
          print('✅ JSON 수정 완료');
        }
      }

      final List<dynamic> parsed = (jsonDecode(jsonString) as List);
      print('✅ JSON 배열 파싱 성공: ${parsed.length}개 항목');

      return parsed.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('💥 파싱 최종 실패: $e');
      throw Exception('AI 응답 파싱 실패: $e');
    }
  }

  /// 퀴즈 타입별 답안 평가
  Future<(bool, int, Map<String, dynamic>?)> _evaluateQuizAnswer(
    Quiz quiz,
    String userAnswer,
    int timeSpent,
  ) async {
    switch (quiz.quizType) {
      case QuizType.vocabulary:
        // 단어 퀴즈: 정답 여부만 확인
        final isCorrect =
            quiz.correctAnswer.toLowerCase().trim() ==
            userAnswer.toLowerCase().trim();
        final score = _calculateScore(quiz, isCorrect, timeSpent);
        return (isCorrect, score, null);

      case QuizType.summary:
      case QuizType.translation:
        // 요약/번역 퀴즈: AI 평가 수행
        final aiEvaluation = await _evaluateWithAI(quiz, userAnswer);
        final overallScore = aiEvaluation['overallScore'] as int;
        final isCorrect = overallScore >= 70; // 70점 이상을 정답으로 간주
        final score = _calculateScore(quiz, isCorrect, timeSpent);
        return (isCorrect, score, aiEvaluation);
    }
  }

  /// AI를 사용한 요약/번역 퀴즈 평가
  Future<Map<String, dynamic>> _evaluateWithAI(
    Quiz quiz,
    String userAnswer,
  ) async {
    try {
      String prompt;
      if (quiz.quizType == QuizType.summary) {
        prompt = '''
다음 요약 퀴즈에 대한 사용자 답안을 평가해주세요.

[문제]
원문: ${quiz.excerpt}
모범답안: ${quiz.correctAnswer}
사용자답안: $userAnswer

[평가 기준]
- 정확성 (40%): 핵심 내용을 정확하게 파악했는가
- 완성도 (30%): 요약이 충분히 완성되었는가
- 자연스러움 (30%): 영어 표현이 자연스러운가

[응답 형식]
JSON 형태로 다음 정보를 제공해주세요:
{
  "accuracyScore": 0-100,
  "completenessScore": 0-100,
  "fluencyScore": 0-100,
  "overallScore": 0-100,
  "detailedFeedback": "구체적인 피드백",
  "improvementTips": "개선을 위한 팁"
}

응답은 순수 JSON만 제공해주세요.
''';
      } else {
        // QuizType.translation
        prompt = '''
다음 번역 퀴즈에 대한 사용자 답안을 평가해주세요.

[문제]
원문: ${quiz.excerpt}
모범답안: ${quiz.correctAnswer}
사용자답안: $userAnswer

[평가 기준]
- 정확성 (50%): 의미를 정확하게 번역했는가
- 자연스러움 (30%): 한국어 표현이 자연스러운가
- 문맥 이해 (20%): 문맥을 올바르게 이해했는가

[응답 형식]
JSON 형태로 다음 정보를 제공해주세요:
{
  "accuracyScore": 0-100,
  "naturalnessScore": 0-100,
  "contextScore": 0-100,
  "overallScore": 0-100,
  "detailedFeedback": "구체적인 피드백",
  "improvementTips": "개선을 위한 팁"
}

응답은 순수 JSON만 제공해주세요.
''';
      }

      final result = await _aiService.sendPrompt(
        prompt: prompt,
        maxTokens: 300,
        temperature: 0.7,
      );

      if (result.isSuccess) {
        try {
          // JSON 응답 파싱
          final jsonStart = result.dataOrNull!.indexOf('{');
          final jsonEnd = result.dataOrNull!.lastIndexOf('}') + 1;

          if (jsonStart != -1 && jsonEnd > jsonStart) {
            final jsonString = result.dataOrNull!.substring(jsonStart, jsonEnd);
            final evaluation = jsonDecode(jsonString) as Map<String, dynamic>;
            return evaluation;
          }
        } catch (e) {
          // JSON 파싱 실패 시 기본 평가 제공
        }
      }
    } catch (e) {
      // AI 서비스 실패 시 기본 평가 제공
    }

    // 기본 평가 결과 반환
    return {
      'accuracyScore': 50,
      'completenessScore': 50,
      'fluencyScore': 50,
      'overallScore': 50,
      'detailedFeedback': 'AI 평가를 수행할 수 없어 기본 점수를 부여했습니다.',
      'improvementTips': '답안을 다시 한번 검토해보세요.',
    };
  }

  /// 점수 계산
  int _calculateScore(Quiz quiz, bool isCorrect, int timeSpent) {
    if (!isCorrect) return 0;

    int baseScore = quiz.points;

    // 시간 보너스/페널티 (빠를수록 높은 점수)
    if (timeSpent <= 30) {
      baseScore = (baseScore * 1.2).round(); // 20% 보너스
    } else if (timeSpent >= 120) {
      baseScore = (baseScore * 0.8).round(); // 20% 페널티
    }

    return baseScore;
  }

  /// 세션 요약 생성
  Map<String, dynamic> _generateSessionSummary(
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
      };
    }

    final totalQuizzes = quizzes.length;
    final correctAnswers = attempts.where((a) => a.isCorrect).length;
    final accuracyRate = (correctAnswers / totalQuizzes) * 100;

    final totalScore = attempts.fold<int>(0, (sum, a) => sum + a.score);
    final maxPossibleScore = quizzes.fold<int>(0, (sum, q) => sum + q.points);

    final totalTime = attempts.fold<int>(0, (sum, a) => sum + a.timeSpent);
    final averageTimePerQuiz = totalTime / totalQuizzes;

    return {
      'totalQuizzes': totalQuizzes,
      'correctAnswers': correctAnswers,
      'accuracyRate': accuracyRate,
      'totalScore': totalScore,
      'maxPossibleScore': maxPossibleScore,
      'averageTimePerQuiz': averageTimePerQuiz.round(),
    };
  }

  /// ID 생성
  String _generateId() {
    return _uuid.v4();
  }

  /// 퀴즈를 데이터베이스에 저장
  Future<void> _saveQuizToDatabase(Quiz quiz) async {
    await _databaseService.insert(table: 'quizzes', data: quiz.toJson());
  }

  /// 퀴즈 답안 저장
  Future<void> _saveQuizAttempt(QuizAttempt attempt) async {
    await _databaseService.insert(
      table: 'quiz_attempts',
      data: attempt.toJson(),
    );
  }

  /// 콘텐츠 퀴즈 진행 상황 업데이트
  Future<void> _updateContentQuizProgress(
    String contentId,
    int totalCount,
  ) async {
    // 구현 로직
  }

  /// 사용자 퀴즈 진행 상황 업데이트
  Future<void> _updateUserQuizProgress(String userId, String contentId) async {
    // 구현 로직
  }
}
