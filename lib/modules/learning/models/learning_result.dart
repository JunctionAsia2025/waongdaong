/// 학습 결과 모델
class LearningResult {
  final String id;
  final String learningSessionId;
  final int quizScore;
  final String summary;
  final String translation;
  final int earnedPoints;
  final DateTime createdAt;

  const LearningResult({
    required this.id,
    required this.learningSessionId,
    required this.quizScore,
    required this.summary,
    required this.translation,
    required this.earnedPoints,
    required this.createdAt,
  });

  /// JSON에서 LearningResult 생성
  factory LearningResult.fromJson(Map<String, dynamic> json) {
    return LearningResult(
      id: json['id'] as String,
      learningSessionId: json['learning_session_id'] as String,
      quizScore: json['quiz_score'] as int,
      summary: json['summary'] as String,
      translation: json['translation'] as String,
      earnedPoints: json['earned_points'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// LearningResult를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'learning_session_id': learningSessionId,
      'quiz_score': quizScore,
      'summary': summary,
      'translation': translation,
      'earned_points': earnedPoints,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 학습 결과 정보 복사 및 수정
  LearningResult copyWith({
    String? id,
    String? learningSessionId,
    int? quizScore,
    String? summary,
    String? translation,
    int? earnedPoints,
    DateTime? createdAt,
  }) {
    return LearningResult(
      id: id ?? this.id,
      learningSessionId: learningSessionId ?? this.learningSessionId,
      quizScore: quizScore ?? this.quizScore,
      summary: summary ?? this.summary,
      translation: translation ?? this.translation,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 퀴즈 점수가 우수한지 확인 (80점 이상)
  bool get isExcellentScore => quizScore >= 80;
  
  /// 퀴즈 점수가 양호한지 확인 (60점 이상)
  bool get isGoodScore => quizScore >= 60;
  
  /// 퀴즈 점수가 부족한지 확인 (60점 미만)
  bool get isPoorScore => quizScore < 60;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearningResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LearningResult(id: $id, quizScore: $quizScore, earnedPoints: $earnedPoints)';
  }
}
