import 'package:json_annotation/json_annotation.dart';

part 'ai_script_model.g.dart';

@JsonSerializable()
class AiScript {
  final String id;
  @JsonKey(name: 'study_session_id')
  final String studySessionId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'korean_input')
  final String koreanInput;
  @JsonKey(name: 'english_script')
  final String englishScript;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  AiScript({
    required this.id,
    required this.studySessionId,
    required this.userId,
    required this.koreanInput,
    required this.englishScript,
    required this.createdAt,
  });

  factory AiScript.fromJson(Map<String, dynamic> json) =>
      _$AiScriptFromJson(json);

  Map<String, dynamic> toJson() => _$AiScriptToJson(this);

  AiScript copyWith({
    String? id,
    String? studySessionId,
    String? userId,
    String? koreanInput,
    String? englishScript,
    DateTime? createdAt,
  }) {
    return AiScript(
      id: id ?? this.id,
      studySessionId: studySessionId ?? this.studySessionId,
      userId: userId ?? this.userId,
      koreanInput: koreanInput ?? this.koreanInput,
      englishScript: englishScript ?? this.englishScript,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AiScript(id: $id, studySessionId: $studySessionId, userId: $userId, koreanInput: $koreanInput, englishScript: $englishScript, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AiScript &&
        other.id == id &&
        other.studySessionId == studySessionId &&
        other.userId == userId &&
        other.koreanInput == koreanInput &&
        other.englishScript == englishScript &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        studySessionId.hashCode ^
        userId.hashCode ^
        koreanInput.hashCode ^
        englishScript.hashCode ^
        createdAt.hashCode;
  }
}

/// AI 스크립트 생성 요청 모델
class AiScriptRequest {
  final String studySessionId;
  final String userId;
  final String koreanInput;

  AiScriptRequest({
    required this.studySessionId,
    required this.userId,
    required this.koreanInput,
  });

  Map<String, dynamic> toJson() => {
    'study_session_id': studySessionId,
    'user_id': userId,
    'korean_input': koreanInput,
  };
}

/// AI 스크립트 응답 모델
class AiScriptResponse {
  final String englishScript;
  final String? errorMessage;
  final bool success;

  AiScriptResponse({
    required this.englishScript,
    this.errorMessage,
    required this.success,
  });

  factory AiScriptResponse.success(String englishScript) {
    return AiScriptResponse(englishScript: englishScript, success: true);
  }

  factory AiScriptResponse.error(String errorMessage) {
    return AiScriptResponse(
      englishScript: '',
      errorMessage: errorMessage,
      success: false,
    );
  }
}
