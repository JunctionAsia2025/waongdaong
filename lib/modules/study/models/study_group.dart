/// 자유롭고 단순한 스터디 그룹 모델
class StudyGroup {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String category;
  final int maxParticipants;
  final int currentParticipants;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String topic;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StudyGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.category,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.topic,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON에서 StudyGroup 생성
  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      creatorId: json['creator_id'] as String,
      category: json['category'] as String,
      maxParticipants: json['max_participants'] as int,
      currentParticipants: json['current_participants'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
      topic: json['topic'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  /// StudyGroup을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creator_id': creatorId,
      'category': category,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'topic': topic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 스터디 그룹 정보 복사 및 수정
  StudyGroup copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    String? category,
    int? maxParticipants,
    int? currentParticipants,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? topic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      category: category ?? this.category,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      topic: topic ?? this.topic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 활성 상태인지 확인
  bool get isActive => status == 'active';

  /// 진행 중인지 확인
  bool get isInProgress => status == 'in_progress';

  /// 일시 중단 상태인지 확인
  bool get isPaused => status == 'paused';

  /// 완료된 상태인지 확인
  bool get isCompleted => status == 'completed';

  /// 종료된 상태인지 확인
  bool get isClosed => status == 'closed';

  /// 참가자 모집 가능한지 확인
  bool get canJoin => isActive && currentParticipants < maxParticipants;

  /// 그룹이 가득 찼는지 확인
  bool get isFull => currentParticipants >= maxParticipants;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StudyGroup(id: $id, title: $title, status: $status, participants: $currentParticipants/$maxParticipants)';
  }
}
