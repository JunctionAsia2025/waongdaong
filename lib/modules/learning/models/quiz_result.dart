/// 퀴즈 결과 모델
class QuizResult {
  final String id;
  final String learningSessionId;
  final QuizType quizType;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int score;
  final List<String> incorrectWords; // 틀린 단어들 (단어퀴즈의 경우)
  final DateTime createdAt;

  const QuizResult({
    required this.id,
    required this.learningSessionId,
    required this.quizType,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.score,
    this.incorrectWords = const [],
    required this.createdAt,
  });

  /// JSON에서 QuizResult 생성
  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      learningSessionId: json['learning_session_id'] as String,
      quizType: QuizType.values.firstWhere(
        (e) => e.name == json['quiz_type'],
        orElse: () => QuizType.vocabulary,
      ),
      question: json['question'] as String,
      userAnswer: json['user_answer'] as String,
      correctAnswer: json['correct_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      score: json['score'] as int,
      incorrectWords:
          json['incorrect_words'] != null
              ? List<String>.from(json['incorrect_words'] as List)
              : [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// QuizResult를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'learning_session_id': learningSessionId,
      'quiz_type': quizType.name,
      'question': question,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'score': score,
      'incorrect_words': incorrectWords,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 퀴즈 결과 정보 복사 및 수정
  QuizResult copyWith({
    String? id,
    String? learningSessionId,
    QuizType? quizType,
    String? question,
    String? userAnswer,
    String? correctAnswer,
    bool? isCorrect,
    int? score,
    List<String>? incorrectWords,
    DateTime? createdAt,
  }) {
    return QuizResult(
      id: id ?? this.id,
      learningSessionId: learningSessionId ?? this.learningSessionId,
      quizType: quizType ?? this.quizType,
      question: question ?? this.question,
      userAnswer: userAnswer ?? this.userAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      incorrectWords: incorrectWords ?? this.incorrectWords,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 단어퀴즈인지 확인
  bool get isVocabularyQuiz => quizType == QuizType.vocabulary;

  /// 영어요약 퀴즈인지 확인
  bool get isSummaryQuiz => quizType == QuizType.summary;

  /// 한글번역 퀴즈인지 확인
  bool get isTranslationQuiz => quizType == QuizType.translation;

  /// 틀린 단어가 있는지 확인
  bool get hasIncorrectWords => incorrectWords.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizResult &&
        other.id == id &&
        other.learningSessionId == learningSessionId &&
        other.quizType == quizType &&
        other.isCorrect == isCorrect;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        learningSessionId.hashCode ^
        quizType.hashCode ^
        isCorrect.hashCode;
  }

  @override
  String toString() {
    return 'QuizResult(id: $id, type: $quizType, isCorrect: $isCorrect, score: $score)';
  }
}

/// 퀴즈 유형 열거형
enum QuizType {
  vocabulary, // 단어퀴즈
  summary, // 영어요약
  translation, // 한글번역
}

/// 퀴즈 유형별 설명
extension QuizTypeExtension on QuizType {
  String get displayName {
    switch (this) {
      case QuizType.vocabulary:
        return '단어퀴즈';
      case QuizType.summary:
        return '영어요약';
      case QuizType.translation:
        return '한글번역';
    }
  }

  String get description {
    switch (this) {
      case QuizType.vocabulary:
        return '학습한 콘텐츠에서 나온 단어들의 의미를 맞춰보세요';
      case QuizType.summary:
        return '콘텐츠의 내용을 영어로 요약해보세요';
      case QuizType.translation:
        return '주어진 영어 문장을 한글로 번역해보세요';
    }
  }
}
