/// 사용자 프로필 정보
class UserProfile {
  final String id;
  final String userId;
  final String nickname;
  final String? currentLevel;
  final String? targetLevel;
  final int? toeicScore;
  final int? toeicSpeakingScore;
  final int? toeicWritingScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.nickname,
    this.currentLevel,
    this.targetLevel,
    this.toeicScore,
    this.toeicSpeakingScore,
    this.toeicWritingScore,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 UserProfile 생성
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      currentLevel: json['current_level'] as String?,
      targetLevel: json['target_level'] as String?,
      toeicScore: json['toeic_score'] as int?,
      toeicSpeakingScore: json['toeic_speaking_score'] as int?,
      toeicWritingScore: json['toeic_writing_score'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// UserProfile을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nickname': nickname,
      'current_level': currentLevel,
      'target_level': targetLevel,
      'toeic_score': toeicScore,
      'toeic_speaking_score': toeicSpeakingScore,
      'toeic_writing_score': toeicWritingScore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 프로필 정보 복사 및 수정
  UserProfile copyWith({
    String? id,
    String? userId,
    String? nickname,
    String? currentLevel,
    String? targetLevel,
    int? toeicScore,
    int? toeicSpeakingScore,
    int? toeicWritingScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      toeicScore: toeicScore ?? this.toeicScore,
      toeicSpeakingScore: toeicSpeakingScore ?? this.toeicSpeakingScore,
      toeicWritingScore: toeicWritingScore ?? this.toeicWritingScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 영어 레벨이 설정되었는지 확인
  bool get hasLevelSet => currentLevel != null && targetLevel != null;

  /// 토익 점수가 설정되었는지 확인
  bool get hasToeicScore =>
      toeicScore != null ||
      toeicSpeakingScore != null ||
      toeicWritingScore != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserProfile(id: $id, userId: $userId, nickname: $nickname)';
  }
}
