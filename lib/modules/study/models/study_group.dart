/// 자유롭고 단순한 스터디 그룹 모델
class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String category;
  final int maxMembers;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.category,
    required this.maxMembers,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON에서 StudyGroup 생성
  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      creatorId: json['creator_id'] as String,
      category: json['category'] as String,
      maxMembers: json['max_members'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  /// StudyGroup을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creator_id': creatorId,
      'category': category,
      'max_members': maxMembers,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 스터디 그룹 정보 복사 및 수정
  StudyGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    String? category,
    int? maxMembers,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      category: category ?? this.category,
      maxMembers: maxMembers ?? this.maxMembers,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 활성 상태인지 확인
  bool get isActive => status == 'active';
  
  /// 일시 중단 상태인지 확인
  bool get isPaused => status == 'paused';
  
  /// 종료된 상태인지 확인
  bool get isClosed => status == 'closed';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StudyGroup(id: $id, name: $name, status: $status)';
  }
}
