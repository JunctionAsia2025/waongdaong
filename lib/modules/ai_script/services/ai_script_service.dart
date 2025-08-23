import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_script.dart';
import '../../core/utils/result.dart';
import '../../ai/ai_module.dart';

/// AI 스크립트 서비스 - AI Module을 활용하여 스크립트 관리
class AIScriptService {
  final SupabaseClient _supabase;
  final AIModule _aiModule;

  AIScriptService(this._supabase, this._aiModule);

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

  /// 프롬프트 생성
  String _buildPrompt(String koreanInput, String? basicPrompt) {
    final buffer = StringBuffer();

    buffer.writeln(
      'Create an English script based on the following Korean input:',
    );
    buffer.writeln('Korean Input: $koreanInput');

    if (basicPrompt != null && basicPrompt.isNotEmpty) {
      buffer.writeln('Additional Instructions: $basicPrompt');
    }

    buffer.writeln(
      '\nPlease provide a natural, conversational English script that matches the Korean input.',
    );

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
