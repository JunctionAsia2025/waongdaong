import 'dart:convert';

/// 퀴즈 유형 열거형
enum QuizType {
  vocabulary('vocabulary'),
  summary('summary'),
  translation('translation');

  const QuizType(this.value);
  final String value;

  static QuizType fromString(String value) {
    return QuizType.values.firstWhere((type) => type.value == value);
  }
}

/// 퀴즈 문제 모델
class Quiz {
  final String id;
  final String contentId;
  final QuizType quizType;
  final String question;
  final String correctAnswer;
  final List<String>? options; // 단어 퀴즈용 선택지
  final String? excerpt; // 요약/번역용 발췌 텍스트
  final String difficultyLevel;
  final int points;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Quiz({
    required this.id,
    required this.contentId,
    required this.quizType,
    required this.question,
    required this.correctAnswer,
    this.options,
    this.excerpt,
    required this.difficultyLevel,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 Quiz 생성
  factory Quiz.fromJson(Map<String, dynamic> json) {
    List<String>? optionsList;
    if (json['options'] != null) {
      if (json['options'] is String) {
        final decoded = jsonDecode(json['options'] as String);
        optionsList = List<String>.from(decoded as List);
      } else if (json['options'] is List) {
        optionsList = List<String>.from(json['options'] as List);
      }
    }

    return Quiz(
      id: json['id'] as String,
      contentId: json['content_id'] as String,
      quizType: QuizType.fromString(json['quiz_type'] as String),
      question: json['question'] as String,
      correctAnswer: json['correct_answer'] as String,
      options: optionsList,
      excerpt: json['excerpt'] as String?,
      difficultyLevel: json['difficulty_level'] as String,
      points: json['points'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Quiz를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'quiz_type': quizType.value,
      'question': question,
      'correct_answer': correctAnswer,
      'options': options,
      'excerpt': excerpt,
      'difficulty_level': difficultyLevel,
      'points': points,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 단어 퀴즈인지 확인
  bool get isVocabulary => quizType == QuizType.vocabulary;

  /// 요약 퀴즈인지 확인
  bool get isSummary => quizType == QuizType.summary;

  /// 번역 퀴즈인지 확인
  bool get isTranslation => quizType == QuizType.translation;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quiz && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Quiz(id: $id, type: ${quizType.value}, question: $question)';
  }
}

/// 콘텐츠 퀴즈 진행 상황 모델
class ContentQuizProgress {
  final String id;
  final String userId;
  final String contentId;
  final int totalQuizzes;
  final int completedQuizzes;
  final double averageScore;
  final DateTime? lastAttemptAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContentQuizProgress({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.averageScore,
    this.lastAttemptAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 ContentQuizProgress 생성
  factory ContentQuizProgress.fromJson(Map<String, dynamic> json) {
    return ContentQuizProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      contentId: json['content_id'] as String,
      totalQuizzes: json['total_quizzes'] as int,
      completedQuizzes: json['completed_quizzes'] as int,
      averageScore: (json['average_score'] as num).toDouble(),
      lastAttemptAt:
          json['last_attempt_at'] != null
              ? DateTime.parse(json['last_attempt_at'] as String)
              : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progressRate {
    if (totalQuizzes == 0) return 0.0;
    return completedQuizzes / totalQuizzes;
  }

  /// 완료 여부
  bool get isCompleted => completedQuizzes >= totalQuizzes;

  @override
  String toString() {
    return 'ContentQuizProgress(progress: $completedQuizzes/$totalQuizzes, avg: $averageScore)';
  }
}
