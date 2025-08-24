import 'dart:convert';

class QuizAttempt {
  final String id;
  final String quizId;
  final String userId;
  final String userAnswer;
  final bool isCorrect;
  final int score;
  final int timeSpent;
  final Map<String, dynamic>? aiEvaluation; // AI 평가 결과 (요약/번역 퀴즈만)
  final DateTime createdAt;

  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.userAnswer,
    required this.isCorrect,
    required this.score,
    required this.timeSpent,
    this.aiEvaluation,
    required this.createdAt,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      userId: json['user_id'] as String,
      userAnswer: json['user_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      score: json['score'] as int,
      timeSpent: json['time_spent'] as int,
      aiEvaluation:
          json['ai_evaluation'] != null
              ? jsonDecode(json['ai_evaluation'] as String)
                  as Map<String, dynamic>
              : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'user_id': userId,
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'score': score,
      'time_spent': timeSpent,
      'ai_evaluation': aiEvaluation != null ? jsonEncode(aiEvaluation) : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  QuizAttempt copyWith({
    String? id,
    String? quizId,
    String? userId,
    String? userAnswer,
    bool? isCorrect,
    int? score,
    int? timeSpent,
    Map<String, dynamic>? aiEvaluation,
    DateTime? createdAt,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      timeSpent: timeSpent ?? this.timeSpent,
      aiEvaluation: aiEvaluation ?? this.aiEvaluation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'QuizAttempt(id: $id, quizId: $quizId, userId: $userId, isCorrect: $isCorrect, score: $score, timeSpent: $timeSpent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizAttempt &&
        other.id == id &&
        other.quizId == quizId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ quizId.hashCode ^ userId.hashCode;
  }
}
