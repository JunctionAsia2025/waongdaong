/// 리포트 모델 - 개인학습과 그룹학습 2가지 유형만 지원
class Report {
  final String id;
  final String userId;
  final ReportType reportType; // 개인학습 또는 그룹학습
  final String? learningSessionId; // 학습 세션 ID
  final String? studyGroupId; // 그룹학습 리포트인 경우
  final String title;
  final String content;
  final String aiFeedback; // AI가 생성한 피드백
  final String userReflection; // 사용자가 입력한 후기/소감
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Report({
    required this.id,
    required this.userId,
    required this.reportType,
    this.learningSessionId,
    this.studyGroupId,
    required this.title,
    required this.content,
    required this.aiFeedback,
    required this.userReflection,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON에서 Report 객체 생성
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      learningSessionId: json['learning_session_id'] as String?,
      reportType: _parseReportType(json['report_type'] as String),
      studyGroupId: json['study_group_id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      aiFeedback: json['ai_feedback'] as String,
      userReflection: json['user_reflection'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  /// 데이터베이스 문자열을 ReportType으로 파싱
  static ReportType _parseReportType(String typeString) {
    switch (typeString) {
      case 'individual_learning':
        return ReportType.individualLearning;
      case 'study_group':
        return ReportType.studyGroup;
      default:
        return ReportType.individualLearning;
    }
  }

  /// Report 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'report_type': _getReportTypeString(reportType),
      'learning_session_id': learningSessionId,
      'study_group_id': studyGroupId,
      'title': title,
      'content': content,
      'ai_feedback': aiFeedback,
      'user_reflection': userReflection,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 데이터베이스 제약 조건에 맞는 report_type 문자열 반환
  String _getReportTypeString(ReportType type) {
    switch (type) {
      case ReportType.individualLearning:
        return 'individual_learning';
      case ReportType.studyGroup:
        return 'study_group';
    }
  }

  /// Report 객체 복사 및 수정
  Report copyWith({
    String? id,
    String? userId,
    ReportType? reportType,
    String? learningSessionId,
    String? studyGroupId,
    String? title,
    String? content,
    String? aiFeedback,
    String? userReflection,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reportType: reportType ?? this.reportType,
      learningSessionId: learningSessionId ?? this.learningSessionId,
      studyGroupId: studyGroupId ?? this.studyGroupId,
      title: title ?? this.title,
      content: content ?? this.content,
      aiFeedback: aiFeedback ?? this.aiFeedback,
      userReflection: userReflection ?? this.userReflection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 개인학습 리포트인지 확인
  bool get isIndividualLearning => reportType == ReportType.individualLearning;

  /// 그룹학습 리포트인지 확인
  bool get isStudyGroup => reportType == ReportType.studyGroup;

  /// AI 피드백이 있는지 확인
  bool get hasAiFeedback => aiFeedback.isNotEmpty;

  /// 사용자 후기가 있는지 확인
  bool get hasUserReflection => userReflection.isNotEmpty;

  @override
  String toString() {
    return 'Report(id: $id, userId: $userId, type: $reportType, title: $title, hasAiFeedback: $hasAiFeedback, hasUserReflection: $hasUserReflection)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report &&
        other.id == id &&
        other.userId == userId &&
        other.reportType == reportType &&
        other.studyGroupId == studyGroupId &&
        other.title == title &&
        other.content == content &&
        other.aiFeedback == aiFeedback &&
        other.userReflection == userReflection &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        reportType.hashCode ^
        studyGroupId.hashCode ^
        title.hashCode ^
        content.hashCode ^
        aiFeedback.hashCode ^
        userReflection.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

/// 리포트 유형 열거형 - 2가지만 지원
enum ReportType {
  individualLearning, // 개인학습
  studyGroup, // 그룹학습
}

/// 리포트 유형별 설명
extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.individualLearning:
        return '개인학습 리포트';
      case ReportType.studyGroup:
        return '그룹학습 리포트';
    }
  }

  String get description {
    switch (this) {
      case ReportType.individualLearning:
        return '개인적으로 진행한 학습에 대한 AI 분석 리포트';
      case ReportType.studyGroup:
        return '스터디 그룹 참여를 통한 학습에 대한 AI 분석 리포트';
    }
  }
}
