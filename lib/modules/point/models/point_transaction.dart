class PointTransaction {
  final String id;
  final String userId;
  final String type; // 'earn', 'spend', 'refund', 'bonus'
  final int amount;
  final int balanceAfter;
  final String description;
  final String? referenceType; // 'learning_session', 'study_group', 'content', 'referral'
  final String? referenceId;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    this.referenceType,
    this.referenceId,
    required this.createdAt,
    this.expiresAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      amount: json['amount'] as int,
      balanceAfter: json['balance_after'] as int,
      description: json['description'] as String,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'amount': amount,
      'balance_after': balanceAfter,
      'description': description,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  PointTransaction copyWith({
    String? id,
    String? userId,
    String? type,
    int? amount,
    int? balanceAfter,
    String? description,
    String? referenceType,
    String? referenceId,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return PointTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      description: description ?? this.description,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'PointTransaction(id: $id, userId: $userId, type: $type, amount: $amount, balanceAfter: $balanceAfter, description: $description, referenceType: $referenceType, referenceId: $referenceId, createdAt: $createdAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PointTransaction &&
        other.id == id &&
        other.userId == userId &&
        other.type == type &&
        other.amount == amount &&
        other.balanceAfter == balanceAfter &&
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
        type.hashCode ^
        amount.hashCode ^
        balanceAfter.hashCode ^
        description.hashCode ^
        referenceType.hashCode ^
        referenceId.hashCode ^
        createdAt.hashCode ^
        expiresAt.hashCode;
  }
}
