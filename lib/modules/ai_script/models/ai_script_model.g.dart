// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_script_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiScript _$AiScriptFromJson(Map<String, dynamic> json) => AiScript(
  id: json['id'] as String,
  studySessionId: json['study_session_id'] as String,
  userId: json['user_id'] as String,
  koreanInput: json['korean_input'] as String,
  englishScript: json['english_script'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AiScriptToJson(AiScript instance) => <String, dynamic>{
  'id': instance.id,
  'study_session_id': instance.studySessionId,
  'user_id': instance.userId,
  'korean_input': instance.koreanInput,
  'english_script': instance.englishScript,
  'created_at': instance.createdAt.toIso8601String(),
};
