/// 사용자 스크랩 모델
class UserScrap {
  final String id;
  final String userId;
  final String contentId;
  final DateTime scrappedAt;

  const UserScrap({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.scrappedAt,
  });

  /// JSON에서 UserScrap 생성
  factory UserScrap.fromJson(Map<String, dynamic> json) {
    return UserScrap(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      contentId: json['content_id'] as String,
      scrappedAt: DateTime.parse(json['scrapped_at'] as String),
    );
  }

  /// UserScrap을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content_id': contentId,
      'scrapped_at': scrappedAt.toIso8601String(),
    };
  }

  /// 스크랩 정보 복사 및 수정
  UserScrap copyWith({
    String? id,
    String? userId,
    String? contentId,
    DateTime? scrappedAt,
  }) {
    return UserScrap(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      scrappedAt: scrappedAt ?? this.scrappedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserScrap && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserScrap(id: $id, userId: $userId, contentId: $contentId)';
  }
}
