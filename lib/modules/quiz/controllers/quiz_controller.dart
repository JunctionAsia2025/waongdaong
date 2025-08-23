import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/quiz_attempt.dart';
import '../services/quiz_service.dart';
import '../../report/models/report.dart';

/// 퀴즈 상태 관리 컨트롤러
class QuizController extends ChangeNotifier {
  final QuizService _quizService;

  // 퀴즈 관련 상태
  List<Quiz> _quizzes = [];
  int _currentQuizIndex = 0;
  Quiz? _currentQuiz;
  bool _isLoading = false;
  String? _error;

  // 리포트 관련 상태
  Report? _quizReport;
  Map<String, dynamic>? _sessionSummary;
  List<QuizAttempt>? _quizAttempts;

  QuizController({required QuizService quizService})
    : _quizService = quizService;

  // Getters
  List<Quiz> get quizzes => _quizzes;
  Quiz? get currentQuiz => _currentQuiz;
  int get currentQuizIndex => _currentQuizIndex;
  List<QuizAttempt> get attempts => _quizAttempts ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNextQuiz => _currentQuizIndex < _quizzes.length - 1;
  bool get hasPreviousQuiz => _currentQuizIndex > 0;

  /// 콘텐츠에 대한 퀴즈 생성
  Future<void> generateQuizzesForContent({
    required String contentId,
    required String contentText,
    required String difficultyLevel,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _quizService.generateQuizzesForContent(
        contentId: contentId,
        contentText: contentText,
        difficultyLevel: difficultyLevel,
      );

      if (result.isSuccess) {
        _quizzes = result.dataOrNull ?? [];
        _currentQuizIndex = 0;
        _currentQuiz = _quizzes.isNotEmpty ? _quizzes[0] : null;
        _setError(null);
      } else {
        _setError(result.errorMessageOrNull ?? '알 수 없는 오류가 발생했습니다');
      }
    } catch (e) {
      _setError('퀴즈 생성 중 예상치 못한 오류가 발생했습니다');
    } finally {
      _setLoading(false);
    }
  }

  /// 콘텐츠별 퀴즈 로드
  Future<void> loadQuizzesByContent(String contentId) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _quizService.getQuizzesByContent(contentId);

      if (result.isSuccess) {
        _quizzes = result.dataOrNull ?? [];
        _currentQuizIndex = 0;
        _currentQuiz = _quizzes.isNotEmpty ? _quizzes[0] : null;
        _setError(null);
      } else {
        _setError(result.errorMessageOrNull ?? '알 수 없는 오류가 발생했습니다');
      }
    } catch (e) {
      _setError('퀴즈 로드 중 오류가 발생했습니다');
    } finally {
      _setLoading(false);
    }
  }

  /// 다음 퀴즈로 이동
  void nextQuiz() {
    if (hasNextQuiz) {
      _currentQuizIndex++;
      _currentQuiz = _quizzes[_currentQuizIndex];
      notifyListeners();
    }
  }

  /// 이전 퀴즈로 이동
  void previousQuiz() {
    if (hasPreviousQuiz) {
      _currentQuizIndex--;
      _currentQuiz = _quizzes[_currentQuizIndex];
      notifyListeners();
    }
  }

  /// 특정 퀴즈로 이동
  void goToQuiz(int index) {
    if (index >= 0 && index < _quizzes.length) {
      _currentQuizIndex = index;
      _currentQuiz = _quizzes[index];
      notifyListeners();
    }
  }

  /// 퀴즈 답안 제출
  Future<void> submitAnswer(String answer, int timeSpent) async {
    if (_currentQuiz == null) return;

    final attempt = QuizAttempt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      quizId: _currentQuiz!.id,
      userId: 'current-user-id', // 실제 사용자 ID로 교체 필요
      userAnswer: answer,
      isCorrect: _evaluateAnswer(_currentQuiz!, answer),
      score: _calculateScore(_currentQuiz!, answer, timeSpent),
      timeSpent: timeSpent,
      aiEvaluation: null, // 단어 퀴즈는 AI 평가 불필요
      createdAt: DateTime.now(),
    );

    _quizAttempts = [...(_quizAttempts ?? []), attempt];

    // 다음 퀴즈로 이동
    if (_currentQuizIndex < _quizzes.length - 1) {
      _currentQuizIndex++;
      _currentQuiz = _quizzes[_currentQuizIndex];
    } else {
      // 모든 퀴즈 완료
      _currentQuiz = null;
    }

    notifyListeners();
  }

  /// 답안 평가 (단순 정답/오답)
  bool _evaluateAnswer(Quiz quiz, String answer) {
    return quiz.correctAnswer.toLowerCase().trim() ==
        answer.toLowerCase().trim();
  }

  /// 점수 계산
  int _calculateScore(Quiz quiz, String answer, int timeSpent) {
    final isCorrect = _evaluateAnswer(quiz, answer);
    if (!isCorrect) return 0;

    int score = quiz.points;

    // 시간 보너스/페널티
    if (timeSpent <= 30) {
      score = (score * 1.2).round(); // 20% 보너스
    } else if (timeSpent >= 120) {
      score = (score * 0.8).round(); // 20% 페널티
    }

    return score;
  }

  /// 퀴즈 진행 상황 조회
  ContentQuizProgress? get progress {
    if (_quizzes.isEmpty || _quizAttempts == null) return null;

    final totalQuizzes = _quizzes.length;
    final completedQuizzes = _quizAttempts!.length;
    final totalScore = _quizAttempts!.fold<int>(0, (sum, a) => sum + (a.score));
    final averageScore = totalScore / completedQuizzes;

    return ContentQuizProgress(
      id: 'temp-progress-id',
      userId: 'current-user-id',
      contentId: _quizzes.first.contentId,
      totalQuizzes: totalQuizzes,
      completedQuizzes: completedQuizzes,
      averageScore: averageScore,
      lastAttemptAt:
          _quizAttempts!.isNotEmpty ? _quizAttempts!.last.createdAt : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 퀴즈 유형별 필터링
  List<Quiz> getQuizzesByType(QuizType type) {
    return _quizzes.where((quiz) => quiz.quizType == type).toList();
  }

  /// 단어 퀴즈만 가져오기
  List<Quiz> get vocabularyQuizzes => getQuizzesByType(QuizType.vocabulary);

  /// 요약 퀴즈만 가져오기
  List<Quiz> get summaryQuizzes => getQuizzesByType(QuizType.summary);

  /// 번역 퀴즈만 가져오기
  List<Quiz> get translationQuizzes => getQuizzesByType(QuizType.translation);

  /// 퀴즈 통계 조회
  Map<String, dynamic> get quizStats {
    final total = _quizzes.length;
    final attempted = _quizAttempts?.length ?? 0;
    final correct = _quizAttempts?.where((a) => a.isCorrect).length ?? 0;
    final averageScore =
        attempted > 0
            ? (_quizAttempts?.map((a) => a.score).reduce((a, b) => a + b) ??
                    0) /
                attempted
            : 0.0;

    return {
      'total': total,
      'attempted': attempted,
      'correct': correct,
      'accuracy': attempted > 0 ? (correct / attempted) * 100 : 0.0,
      'averageScore': averageScore,
    };
  }

  /// 퀴즈 상태 초기화
  void reset() {
    _quizzes = [];
    _currentQuiz = null;
    _currentQuizIndex = 0;
    _quizAttempts = [];
    _isLoading = false;
    _error = null;
    _quizReport = null;
    _sessionSummary = null;
    notifyListeners();
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 상태 설정
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// 퀴즈 완료 및 리포트 생성
  Future<void> completeQuizSession({
    required String userId,
    required String contentId,
    required String? learningSessionId,
    required String contentTitle,
    required List<Map<String, dynamic>> userAnswers,
  }) async {
    if (_quizzes.isEmpty) {
      _setError('퀴즈가 없습니다.');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _quizService.completeQuizSession(
        userId: userId,
        contentId: contentId,
        learningSessionId: learningSessionId,
        quizzes: _quizzes,
        userAnswers: userAnswers,
        contentTitle: contentTitle,
      );

      if (result.isSuccess) {
        final data = result.dataOrNull!;
        _quizReport = data['report'];
        _sessionSummary = data['summary'];
        _quizAttempts = data['attempts'];

        _setError(null);
        notifyListeners();
      } else {
        _setError(result.errorMessageOrNull ?? '퀴즈 세션 완료 중 오류가 발생했습니다');
      }
    } catch (e) {
      _setError('퀴즈 세션 완료 중 예상치 못한 오류가 발생했습니다');
    } finally {
      _setLoading(false);
    }
  }

  /// 퀴즈 리포트 조회
  Report? get quizReport => _quizReport;

  /// 세션 요약 조회
  Map<String, dynamic>? get sessionSummary => _sessionSummary;

  /// 퀴즈 답안 조회
  List<QuizAttempt>? get quizAttempts => _quizAttempts;
}
