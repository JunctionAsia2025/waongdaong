class UserProfile {
  final String id;
  final String userId;
  final String nickname;
  final String currentLevel;
  final String? targetLevel;
  final String? bio;
  final String? avatarUrl;
  final List<String> interests;
  final Map<String, int> testScores;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.currentLevel,
    this.targetLevel,
    this.bio,
    this.avatarUrl,
    this.interests = const [],
    this.testScores = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      currentLevel: json['current_level'] as String,
      targetLevel: json['target_level'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      interests: (json['interests'] as List?)?.cast<String>() ?? [],
      testScores: Map<String, int>.from(
        (json['test_scores'] as Map<String, dynamic>?) ?? {},
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nickname': nickname,
      'current_level': currentLevel,
      'target_level': targetLevel,
      'bio': bio,
      'avatar_url': avatarUrl,
      'interests': interests,
      'test_scores': testScores,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? nickname,
    String? currentLevel,
    String? targetLevel,
    String? bio,
    String? avatarUrl,
    List<String>? interests,
    Map<String, int>? testScores,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      interests: interests ?? this.interests,
      testScores: testScores ?? this.testScores,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, userId: $userId, nickname: $nickname, currentLevel: $currentLevel, targetLevel: $targetLevel, bio: $bio, avatarUrl: $avatarUrl, interests: $interests, testScores: $testScores, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.userId == userId &&
        other.nickname == nickname &&
        other.currentLevel == currentLevel &&
        other.targetLevel == targetLevel &&
        other.bio == bio &&
        other.avatarUrl == avatarUrl &&
        other.interests == interests &&
        other.testScores == testScores &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        nickname.hashCode ^
        currentLevel.hashCode ^
        targetLevel.hashCode ^
        bio.hashCode ^
        avatarUrl.hashCode ^
        interests.hashCode ^
        testScores.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
