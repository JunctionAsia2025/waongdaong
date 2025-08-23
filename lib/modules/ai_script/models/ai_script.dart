/// AI 스크립트 모델 - 스터디그룹 발언 지원 전용
class AIScript {
  final String id;
  final String userId;
  final String studyGroupId; // 스터디그룹 필수 참조
  final String koreanInput; // 사용자가 입력한 한국어
  final String englishScript; // AI가 생성한 영어 스크립트
  final String? basicPrompt; // 추가 지시사항
  final String context; // 사용 컨텍스트 (기본값: 'speaking_support')
  final String difficulty; // 난이도 (beginner, intermediate, advanced)
  final String? topic; // 발언 주제
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AIScript({
    required this.id,
    required this.userId,
    required this.studyGroupId,
    required this.koreanInput,
    required this.englishScript,
    this.basicPrompt,
    this.context = 'speaking_support',
    this.difficulty = 'intermediate',
    this.topic,
    required this.createdAt,
    this.updatedAt,
  });

  /// JSON에서 AIScript 객체 생성
  factory AIScript.fromJson(Map<String, dynamic> json) {
    return AIScript(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      studyGroupId: json['study_group_id'] as String,
      koreanInput: json['korean_input'] as String,
      englishScript: json['english_script'] as String,
      basicPrompt: json['basic_prompt'] as String?,
      context: json['context'] as String? ?? 'speaking_support',
      difficulty: json['difficulty'] as String? ?? 'intermediate',
      topic: json['topic'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  /// AIScript 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'study_group_id': studyGroupId,
      'korean_input': koreanInput,
      'english_script': englishScript,
      'basic_prompt': basicPrompt,
      'context': context,
      'difficulty': difficulty,
      'topic': topic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// AIScript 객체 복사 및 수정
  AIScript copyWith({
    String? id,
    String? userId,
    String? studyGroupId,
    String? koreanInput,
    String? englishScript,
    String? basicPrompt,
    String? context,
    String? difficulty,
    String? topic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AIScript(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studyGroupId: studyGroupId ?? this.studyGroupId,
      koreanInput: koreanInput ?? this.koreanInput,
      englishScript: englishScript ?? this.englishScript,
      basicPrompt: basicPrompt ?? this.basicPrompt,
      context: context ?? this.context,
      difficulty: difficulty ?? this.difficulty,
      topic: topic ?? this.topic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 스터디그룹 발언 지원용인지 확인
  bool get isSpeakingSupport => context == 'speaking_support';

  /// 초급 난이도인지 확인
  bool get isBeginner => difficulty == 'beginner';

  /// 중급 난이도인지 확인
  bool get isIntermediate => difficulty == 'intermediate';

  /// 고급 난이도인지 확인
  bool get isAdvanced => difficulty == 'advanced';

  @override
  String toString() {
    return 'AIScript(id: $id, userId: $userId, studyGroupId: $studyGroupId, koreanInput: $koreanInput, englishScript: $englishScript, context: $context, difficulty: $difficulty, topic: $topic, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIScript &&
        other.id == id &&
        other.userId == userId &&
        other.studyGroupId == studyGroupId &&
        other.koreanInput == koreanInput &&
        other.englishScript == englishScript &&
        other.basicPrompt == basicPrompt &&
        other.context == context &&
        other.difficulty == difficulty &&
        other.topic == topic &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        studyGroupId.hashCode ^
        koreanInput.hashCode ^
        englishScript.hashCode ^
        basicPrompt.hashCode ^
        context.hashCode ^
        difficulty.hashCode ^
        topic.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
