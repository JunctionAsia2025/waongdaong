/// 학습 세션 모델
class LearningSession {
  final String id;
  final String userId;
  final String contentId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status;
  final DateTime createdAt;

  const LearningSession({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.createdAt,
  });

  /// JSON에서 LearningSession 생성
  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      contentId: json['content_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// LearningSession을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content_id': contentId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 학습 세션 정보 복사 및 수정
  LearningSession copyWith({
    String? id,
    String? userId,
    String? contentId,
    DateTime? startedAt,
    DateTime? completedAt,
    String? status,
    DateTime? createdAt,
  }) {
    return LearningSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 학습 세션이 진행 중인지 확인
  bool get isInProgress => status == 'in_progress';
  
  /// 학습 세션이 완료되었는지 확인
  bool get isCompleted => status == 'completed';
  
  /// 학습 세션이 일시정지되었는지 확인
  bool get isPaused => status == 'paused';
  
  /// 학습 시간 계산 (분 단위)
  int get learningDurationMinutes {
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt).inMinutes;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearningSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LearningSession(id: $id, status: $status, contentId: $contentId)';
  }
}
