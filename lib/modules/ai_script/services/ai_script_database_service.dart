import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_script_model.dart';

/// AI 스크립트 데이터베이스 서비스
/// Supabase를 사용하여 ai_scripts 테이블과 상호작용
class AiScriptDatabaseService {
  final SupabaseClient _client;

  AiScriptDatabaseService(this._client);

  /// AI 스크립트 저장
  Future<AiScript?> saveAiScript({
    required String studySessionId,
    required String userId,
    required String koreanInput,
    required String englishScript,
  }) async {
    try {
      final data =
          await _client
              .from('ai_scripts')
              .insert({
                'study_session_id': studySessionId,
                'user_id': userId,
                'korean_input': koreanInput,
                'english_script': englishScript,
              })
              .select()
              .single();

      return AiScript.fromJson(data);
    } catch (e) {
      print('AI 스크립트 저장 중 오류: $e');
      return null;
    }
  }

  /// 특정 사용자의 AI 스크립트 목록 조회
  Future<List<AiScript>> getAiScriptsByUserId(String userId) async {
    try {
      final data = await _client
          .from('ai_scripts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return data.map((item) => AiScript.fromJson(item)).toList();
    } catch (e) {
      print('사용자 AI 스크립트 조회 중 오류: $e');
      return [];
    }
  }

  /// 특정 스터디 세션의 AI 스크립트 목록 조회
  Future<List<AiScript>> getAiScriptsBySessionId(String sessionId) async {
    try {
      final data = await _client
          .from('ai_scripts')
          .select()
          .eq('study_session_id', sessionId)
          .order('created_at', ascending: false);

      return data.map((item) => AiScript.fromJson(item)).toList();
    } catch (e) {
      print('세션 AI 스크립트 조회 중 오류: $e');
      return [];
    }
  }

  /// 특정 AI 스크립트 조회
  Future<AiScript?> getAiScriptById(String id) async {
    try {
      final data =
          await _client.from('ai_scripts').select().eq('id', id).single();

      return AiScript.fromJson(data);
    } catch (e) {
      print('AI 스크립트 조회 중 오류: $e');
      return null;
    }
  }

  /// AI 스크립트 삭제
  Future<bool> deleteAiScript(String id) async {
    try {
      await _client.from('ai_scripts').delete().eq('id', id);

      return true;
    } catch (e) {
      print('AI 스크립트 삭제 중 오류: $e');
      return false;
    }
  }

  /// 사용자의 최근 AI 스크립트 조회 (제한된 개수)
  Future<List<AiScript>> getRecentAiScripts(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final data = await _client
          .from('ai_scripts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return data.map((item) => AiScript.fromJson(item)).toList();
    } catch (e) {
      print('최근 AI 스크립트 조회 중 오류: $e');
      return [];
    }
  }

  /// 특정 한국어 입력에 대한 기존 스크립트 검색
  /// 중복된 요청을 방지하기 위해 사용
  Future<AiScript?> findExistingScript({
    required String userId,
    required String koreanInput,
  }) async {
    try {
      final data = await _client
          .from('ai_scripts')
          .select()
          .eq('user_id', userId)
          .eq('korean_input', koreanInput)
          .order('created_at', ascending: false)
          .limit(1);

      if (data.isNotEmpty) {
        return AiScript.fromJson(data.first);
      }
      return null;
    } catch (e) {
      print('기존 스크립트 검색 중 오류: $e');
      return null;
    }
  }
}
