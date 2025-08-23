import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_script.dart';
import '../models/three_style_script.dart';
import '../../core/utils/result.dart';
import '../../ai/ai_module.dart';

/// AI 스크립트 서비스 - AI Module을 활용하여 스크립트 관리
class AIScriptService {
  final SupabaseClient _supabase;
  final AIModule _aiModule;

  AIScriptService(this._supabase, this._aiModule);

  /// 세 가지 스타일의 영어 스크립트 생성 (격식있는, 편한, 재치있는)
  Future<Result<ThreeStyleScript>> generateThreeStyleScripts({
    required String koreanInput,
    String? basicPrompt,
  }) async {
    try {
      // AI Module을 통해 스크립트 생성
      final scriptResult = await _aiModule.aiApiService.sendPrompt(
        prompt: _buildPrompt(koreanInput, basicPrompt),
        maxTokens: 500, // JSON 형식이므로 토큰 수 증가
        temperature: 0.7,
      );

      if (scriptResult.isFailure) {
        return Result.failure(
          '세 가지 스타일 스크립트 생성 실패: ${scriptResult.errorMessageOrNull}',
          null,
        );
      }

      final responseText = scriptResult.dataOrNull!;

      // AI 응답(JSON 텍스트)을 객체로 파싱
      try {
        // JSON 문자열 정리 (```json, ``` 등 제거)
        String cleanJsonString = responseText.trim();
        if (cleanJsonString.startsWith('```json')) {
          cleanJsonString = cleanJsonString.substring(7);
        }
        if (cleanJsonString.startsWith('```')) {
          cleanJsonString = cleanJsonString.substring(3);
        }
        if (cleanJsonString.endsWith('```')) {
          cleanJsonString = cleanJsonString.substring(
            0,
            cleanJsonString.length - 3,
          );
        }
        cleanJsonString = cleanJsonString.trim();

        // JSON 파싱
        final jsonData = jsonDecode(cleanJsonString) as Map<String, dynamic>;
        final threeStyleScript = ThreeStyleScript.fromJson(jsonData);

        if (!threeStyleScript.isValid) {
          return Result.failure('생성된 스크립트가 완전하지 않습니다.', null);
        }

        return Result.success(threeStyleScript);
      } catch (e) {
        return Result.failure(
          'AI 응답을 JSON으로 파싱하는데 실패했습니다: $e\n응답: $responseText',
          e,
        );
      }
    } catch (e) {
      return Result.failure('세 가지 스타일 스크립트 생성 중 오류가 발생했습니다.', e);
    }
  }

  /// AI 스크립트 생성 (koreanInput + basicPrompt -> englishScript)
  Future<Result<AIScript>> generateScript({
    required String userId,
    required String koreanInput,
    String? basicPrompt,
    String? context,
    String? difficulty,
    String? topic,
    String? studyGroupId,
  }) async {
    try {
      // AI Module을 통해 스크립트 생성
      final scriptResult = await _aiModule.aiApiService.sendPrompt(
        prompt: _buildPrompt(koreanInput, basicPrompt),
        maxTokens: 200,
        temperature: 0.7,
      );

      if (scriptResult.isFailure) {
        return Result.failure(
          'AI 스크립트 생성 실패: ${scriptResult.errorMessageOrNull}',
          null,
        );
      }

      final englishScript = scriptResult.dataOrNull!;

      // AI 스크립트 데이터 생성
      final scriptData = {
        'user_id': userId,
        'korean_input': koreanInput,
        'english_script': englishScript,
        'basic_prompt': basicPrompt,
        'context': context ?? 'general',
        'difficulty': difficulty ?? 'intermediate',
        'topic': topic,
        'study_group_id': studyGroupId,
        'created_at': DateTime.now().toIso8601String(),
      };

      // 데이터베이스에 저장
      final response =
          await _supabase
              .from('ai_scripts')
              .insert(scriptData)
              .select()
              .single();

      return Result.success(AIScript.fromJson(response));
    } catch (e) {
      return Result.failure('AI 스크립트 생성 중 오류가 발생했습니다.', e);
    }
  }

  /// 프롬프트 생성 - 세 가지 스타일의 영어 스크립트 생성
  String _buildPrompt(String koreanInput, String? basicPrompt) {
    final buffer = StringBuffer();

    buffer.writeln('다음 한국어 입력을 바탕으로 세 가지 스타일의 영어 스크립트를 생성해주세요:');
    buffer.writeln();
    buffer.writeln('한국어 입력: "$koreanInput"');

    if (basicPrompt != null && basicPrompt.isNotEmpty) {
      buffer.writeln('추가 지시사항: $basicPrompt');
    }

    buffer.writeln();
    buffer.writeln('다음 JSON 형식으로 정확히 응답해주세요:');
    buffer.writeln('{');
    buffer.writeln('  "formal": "격식있고 정중한 영어 표현",');
    buffer.writeln('  "casual": "친근하고 편안한 영어 표현",');
    buffer.writeln('  "witty": "재치있고 유머러스한 영어 표현"');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('요구사항:');
    buffer.writeln('• 각 스타일은 명확하게 구분되어야 함');
    buffer.writeln('• 문법적으로 올바른 영어여야 함');
    buffer.writeln('• 자연스럽고 실용적인 표현이어야 함');
    buffer.writeln('• 반드시 JSON 형식으로만 응답해주세요 (다른 설명 없이)');

    return buffer.toString();
  }

  /// AI 스크립트 생성 (Create)
  Future<Result<AIScript>> createScript(AIScript script) async {
    try {
      final response =
          await _supabase
              .from('ai_scripts')
              .insert(script.toJson())
              .select()
              .single();

      return Result.success(AIScript.fromJson(response));
    } catch (e) {
      return Result.failure('AI 스크립트 생성 중 오류가 발생했습니다.', e);
    }
  }

  /// AI 스크립트 조회 (Read)
  Future<Result<AIScript>> getScript(String scriptId) async {
    try {
      final response =
          await _supabase
              .from('ai_scripts')
              .select()
              .eq('id', scriptId)
              .single();

      return Result.success(AIScript.fromJson(response));
    } catch (e) {
      return Result.failure('AI 스크립트 조회 중 오류가 발생했습니다.', e);
    }
  }

  /// AI 스크립트 목록 조회 (Read)
  Future<Result<List<AIScript>>> getScripts({
    String? userId,
    String? context,
    String? studyGroupId,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase.from('ai_scripts').select();

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      if (context != null) {
        query = query.eq('context', context);
      }

      if (studyGroupId != null) {
        query = query.eq('study_group_id', studyGroupId);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final scripts =
          (response as List).map((json) => AIScript.fromJson(json)).toList();

      return Result.success(scripts);
    } catch (e) {
      return Result.failure('AI 스크립트 목록 조회 중 오류가 발생했습니다.', e);
    }
  }

  /// AI 스크립트 업데이트 (Update)
  Future<Result<AIScript>> updateScript({
    required String scriptId,
    String? koreanInput,
    String? englishScript,
    String? basicPrompt,
    String? context,
    String? difficulty,
    String? topic,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (koreanInput != null) updateData['korean_input'] = koreanInput;
      if (englishScript != null) updateData['english_script'] = englishScript;
      if (basicPrompt != null) updateData['basic_prompt'] = basicPrompt;
      if (context != null) updateData['context'] = context;
      if (difficulty != null) updateData['difficulty'] = difficulty;
      if (topic != null) updateData['topic'] = topic;

      final response =
          await _supabase
              .from('ai_scripts')
              .update(updateData)
              .eq('id', scriptId)
              .select()
              .single();

      return Result.success(AIScript.fromJson(response));
    } catch (e) {
      return Result.failure('AI 스크립트 업데이트 중 오류가 발생했습니다.', e);
    }
  }

  /// AI 스크립트 삭제 (Delete)
  Future<Result<void>> deleteScript(String scriptId) async {
    try {
      await _supabase.from('ai_scripts').delete().eq('id', scriptId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('AI 스크립트 삭제 중 오류가 발생했습니다.', e);
    }
  }
}
