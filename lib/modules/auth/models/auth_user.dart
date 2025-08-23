/// 인증된 사용자 정보
class AppUser {
  final String id;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final String? currentLevel;
  final String? targetLevel;

  const AppUser({
    required this.id,
    required this.email,
    this.nickname,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isEmailVerified,
    this.currentLevel,
    this.targetLevel,
  });

  /// JSON에서 AppUser 생성
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isEmailVerified: json['email_confirmed_at'] != null,
      currentLevel: json['current_level'] as String?,
      targetLevel: json['target_level'] as String?,
    );
  }

  /// AppUser를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'email_confirmed_at':
          isEmailVerified ? updatedAt.toIso8601String() : null,
      'current_level': currentLevel,
      'target_level': targetLevel,
    };
  }

  /// 사용자 정보 복사 및 수정
  AppUser copyWith({
    String? id,
    String? email,
    String? nickname,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    String? currentLevel,
    String? targetLevel,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, nickname: $nickname)';
  }
}
