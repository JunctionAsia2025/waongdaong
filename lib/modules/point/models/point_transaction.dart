/// 포인트 거래 모델
class PointTransaction {
  final String id;
  final String userId;
  final int points;
  final String transactionType; // 'earn', 'spend', 'refund'
  final String
  source; // 'learning_session', 'study_group', 'content', 'referral'
  final String description;
  final String? referenceType; // 'study_group', 'content', 'referral'
  final String? referenceId;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.transactionType,
    required this.source,
    required this.description,
    this.referenceType,
    this.referenceId,
    required this.createdAt,
    this.expiresAt,
  });

  /// JSON에서 PointTransaction 객체 생성
  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      points: json['points'] as int,
      transactionType: json['transaction_type'] as String,
      source: json['source'] as String,
      description: json['description'] as String,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt:
          json['expires_at'] != null
              ? DateTime.parse(json['expires_at'] as String)
              : null,
    );
  }

  /// PointTransaction 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'points': points,
      'transaction_type': transactionType,
      'source': source,
      'description': description,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// PointTransaction 객체 복사 및 수정
  PointTransaction copyWith({
    String? id,
    String? userId,
    int? points,
    String? transactionType,
    String? source,
    String? description,
    String? referenceType,
    String? referenceId,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return PointTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      transactionType: transactionType ?? this.transactionType,
      source: source ?? this.source,
      description: description ?? this.description,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// 포인트 적립인지 확인
  bool get isEarn => transactionType == 'earn';

  /// 포인트 사용인지 확인
  bool get isSpend => transactionType == 'spend';

  /// 포인트 환불인지 확인
  bool get isRefund => transactionType == 'refund';

  /// 스터디그룹 관련인지 확인
  bool get isStudyGroupRelated => referenceType == 'study_group';

  /// 콘텐츠 관련인지 확인
  bool get isContentRelated => referenceType == 'content';

  /// 추천인 관련인지 확인
  bool get isReferralRelated => referenceType == 'referral';

  @override
  String toString() {
    return 'PointTransaction(id: $id, userId: $userId, points: $points, transactionType: $transactionType, source: $source, description: $description, referenceType: $referenceType, referenceId: $referenceId, createdAt: $createdAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PointTransaction &&
        other.id == id &&
        other.userId == userId &&
        other.points == points &&
        other.transactionType == transactionType &&
        other.source == source &&
        other.description == description &&
        other.referenceType == referenceType &&
        other.referenceId == referenceId &&
        other.createdAt == createdAt &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        points.hashCode ^
        transactionType.hashCode ^
        source.hashCode ^
        description.hashCode ^
        referenceType.hashCode ^
        referenceId.hashCode ^
        createdAt.hashCode ^
        expiresAt.hashCode;
  }
}
