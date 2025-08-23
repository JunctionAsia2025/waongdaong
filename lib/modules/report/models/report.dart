/// 학습 활동 리포트 모델
class Report {
  final String id;
  final String userId;
  final String reportType; // 'individual_learning' 또는 'study_group'
  final String? studyGroupId; // 스터디그룹 리포트인 경우
  final String? learningSessionId; // 개인학습 리포트인 경우
  final String period; // 리포트 기간 (예: 'daily', 'weekly', 'monthly')
  final int totalStudyTime; // 총 학습 시간 (분)
  final int completedContents; // 완료한 콘텐츠 수
  final int earnedPoints; // 획득한 포인트
  final double participationRate; // 참여도 (0.0 ~ 1.0)
  final String weakAreas; // 취약한 영역
  final String recommendations; // 개선 권장사항
  final String reflection; // 학습 소감/일기
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Report({
    required this.id,
    required this.userId,
    required this.reportType,
    this.studyGroupId,
    this.learningSessionId,
    required this.period,
    required this.totalStudyTime,
    required this.completedContents,
    required this.earnedPoints,
    required this.participationRate,
    required this.weakAreas,
    required this.recommendations,
    required this.reflection,
    required this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reportType: json['report_type'] as String,
      studyGroupId: json['study_group_id'] as String?,
      learningSessionId: json['learning_session_id'] as String?,
      period: json['period'] as String,
      totalStudyTime: json['total_study_time'] as int,
      completedContents: json['completed_contents'] as int,
      earnedPoints: json['earned_points'] as int,
      participationRate: (json['participation_rate'] as num).toDouble(),
      weakAreas: json['weak_areas'] as String,
      recommendations: json['recommendations'] as String,
      reflection: json['reflection'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'report_type': reportType,
      'study_group_id': studyGroupId,
      'learning_session_id': learningSessionId,
      'period': period,
      'total_study_time': totalStudyTime,
      'completed_contents': completedContents,
      'earned_points': earnedPoints,
      'participation_rate': participationRate,
      'weak_areas': weakAreas,
      'recommendations': recommendations,
      'reflection': reflection,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? userId,
    String? reportType,
    String? studyGroupId,
    String? learningSessionId,
    String? period,
    int? totalStudyTime,
    int? completedContents,
    int? earnedPoints,
    double? participationRate,
    String? weakAreas,
    String? recommendations,
    String? reflection,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reportType: reportType ?? this.reportType,
      studyGroupId: studyGroupId ?? this.studyGroupId,
      learningSessionId: learningSessionId ?? this.learningSessionId,
      period: period ?? this.period,
      totalStudyTime: totalStudyTime ?? this.totalStudyTime,
      completedContents: completedContents ?? this.completedContents,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      participationRate: participationRate ?? this.participationRate,
      weakAreas: weakAreas ?? this.weakAreas,
      recommendations: recommendations ?? this.recommendations,
      reflection: reflection ?? this.reflection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 개인학습 리포트인지 확인
  bool get isIndividualLearning => reportType == 'individual_learning';

  /// 스터디그룹 리포트인지 확인
  bool get isStudyGroup => reportType == 'study_group';

  /// 일일 리포트인지 확인
  bool get isDaily => period == 'daily';

  /// 주간 리포트인지 확인
  bool get isWeekly => period == 'weekly';

  /// 월간 리포트인지 확인
  bool get isMonthly => period == 'monthly';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Report(id: $id, type: $reportType, period: $period)';
  }
}
