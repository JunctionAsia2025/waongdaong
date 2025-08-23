/// 스터디 그룹 참가자 모델 - 역할 단순화
class StudyGroupParticipant {
  final String id;
  final String studyGroupId;
  final String userId;
  final bool isCreator; // 그룹 생성자 여부
  final DateTime joinedAt;
  final DateTime? leftAt; // 중간 퇴장 시간 (null이면 아직 참여 중)
  final String status; // 참가 상태 (active, left, removed)

  const StudyGroupParticipant({
    required this.id,
    required this.studyGroupId,
    required this.userId,
    required this.isCreator,
    required this.joinedAt,
    this.leftAt,
    this.status = 'active',
  });

  /// JSON에서 StudyGroupParticipant 생성
  factory StudyGroupParticipant.fromJson(Map<String, dynamic> json) {
    return StudyGroupParticipant(
      id: json['id'] as String,
      studyGroupId: json['study_group_id'] as String,
      userId: json['user_id'] as String,
      isCreator: json['is_creator'] as bool,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      leftAt:
          json['left_at'] != null
              ? DateTime.parse(json['left_at'] as String)
              : null,
      status: json['status'] as String? ?? 'active',
    );
  }

  /// StudyGroupParticipant를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'study_group_id': studyGroupId,
      'user_id': userId,
      'is_creator': isCreator,
      'joined_at': joinedAt.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
      'status': status,
    };
  }

  /// 참가자 정보 복사 및 수정
  StudyGroupParticipant copyWith({
    String? id,
    String? studyGroupId,
    String? userId,
    bool? isCreator,
    DateTime? joinedAt,
    DateTime? leftAt,
    String? status,
  }) {
    return StudyGroupParticipant(
      id: id ?? this.id,
      studyGroupId: studyGroupId ?? this.studyGroupId,
      userId: userId ?? this.userId,
      isCreator: isCreator ?? this.isCreator,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      status: status ?? this.status,
    );
  }

  /// 현재 참여 중인지 확인
  bool get isActive => status == 'active' && leftAt == null;

  /// 중간에 나간 참가자인지 확인
  bool get hasLeft => leftAt != null;

  /// 그룹 생성자인지 확인
  bool get isGroupCreator => isCreator;

  /// 일반 참가자인지 확인
  bool get isRegularParticipant => !isCreator;

  /// 참여 시간 계산 (분 단위)
  int get participationDuration {
    final endTime = leftAt ?? DateTime.now();
    return endTime.difference(joinedAt).inMinutes;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyGroupParticipant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StudyGroupParticipant(id: $id, userId: $userId, isCreator: $isCreator, status: $status)';
  }
}
