import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/result.dart';
import '../models/user_scrap.dart';
import '../models/content.dart';

/// 콘텐츠 스크랩 관련 서비스
class ScrapService {
  final SupabaseClient _supabase;

  ScrapService(this._supabase);

  /// 콘텐츠 스크랩하기
  Future<Result<UserScrap>> scrapContent({
    required String userId,
    required String contentId,
  }) async {
    try {
      final scrapData = {
        'user_id': userId,
        'content_id': contentId,
        'scrapped_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from('user_scraps')
              .insert(scrapData)
              .select()
              .single();

      final scrap = UserScrap.fromJson(response);
      return Result.success(scrap);
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        return Result.failure('이미 스크랩된 콘텐츠입니다.', e);
      }
      return Result.failure('콘텐츠를 스크랩하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 콘텐츠 언스크랩하기
  Future<Result<void>> unscrapContent({
    required String userId,
    required String contentId,
  }) async {
    try {
      await _supabase
          .from('user_scraps')
          .delete()
          .eq('user_id', userId)
          .eq('content_id', contentId);

      return const Result.success(null);
    } catch (e) {
      return Result.failure('스크랩을 해제하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자의 스크랩 목록 가져오기 (페이지네이션)
  Future<Result<List<Content>>> getUserScraps({
    required String userId,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final response = await _supabase
          .from('user_scraps')
          .select('''
            *,
            content:content_id(*)
          ''')
          .eq('user_id', userId)
          .order('scrapped_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final scraps =
          (response as List).map((json) {
            final contentJson = json['content'] as Map<String, dynamic>;
            return Content.fromJson(contentJson);
          }).toList();

      return Result.success(scraps);
    } catch (e) {
      return Result.failure('스크랩 목록을 가져오는 중 오류가 발생했습니다.', e);
    }
  }

  /// 콘텐츠가 스크랩되었는지 확인
  Future<Result<bool>> isContentScrapped({
    required String userId,
    required String contentId,
  }) async {
    try {
      final response =
          await _supabase
              .from('user_scraps')
              .select('id')
              .eq('user_id', userId)
              .eq('content_id', contentId)
              .maybeSingle();

      return Result.success(response != null);
    } catch (e) {
      return Result.failure('스크랩 상태를 확인하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자의 스크랩 수 가져오기
  Future<Result<int>> getUserScrapCount(String userId) async {
    try {
      final response = await _supabase
          .from('user_scraps')
          .select('id')
          .eq('user_id', userId);

      return Result.success(response.length);
    } catch (e) {
      return Result.failure('스크랩 수를 가져오는 중 오류가 발생했습니다.', e);
    }
  }

  /// 콘텐츠별 스크랩 수 가져오기
  Future<Result<int>> getContentScrapCount(String contentId) async {
    try {
      final response = await _supabase
          .from('user_scraps')
          .select('id')
          .eq('content_id', contentId);

      return Result.success(response.length);
    } catch (e) {
      return Result.failure('콘텐츠 스크랩 수를 가져오는 중 오류가 발생했습니다.', e);
    }
  }

  /// 스크랩 기반 콘텐츠 추천 (페이지네이션)
  Future<Result<List<Content>>> getRecommendedByScraps({
    required String userId,
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      // 사용자가 스크랩한 콘텐츠의 카테고리를 기반으로 추천
      final response = await _supabase
          .from('user_scraps')
          .select('''
            content:content_id(
              id, title, content, content_type, source_url, 
              difficulty_level, created_at, updated_at, categories
            )
          ''')
          .eq('user_id', userId)
          .order('scrapped_at', ascending: false)
          .limit(5); // 최근 스크랩 5개

      if (response.isEmpty) {
        return Result.success([]);
      }

      // 스크랩한 콘텐츠의 카테고리 추출
      final categories = <String>{};
      for (final scrap in response) {
        final content = scrap['content'] as Map<String, dynamic>;
        final contentCategories = content['categories'] as List<dynamic>?;
        if (contentCategories != null) {
          categories.addAll(contentCategories.cast<String>());
        }
      }

      if (categories.isEmpty) {
        return Result.success([]);
      }

      // 카테고리 기반 추천 콘텐츠 조회
      final recommendedResponse = await _supabase
          .from('content')
          .select()
          .overlaps('categories', categories.toList())
          .not('id', 'in', response.map((s) => s['content']['id']).toList())
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final contents =
          (recommendedResponse as List)
              .map((json) => Content.fromJson(json))
              .toList();

      return Result.success(contents);
    } catch (e) {
      return Result.failure('스크랩 기반 추천을 가져오는 중 오류가 발생했습니다.', e);
    }
  }
}
