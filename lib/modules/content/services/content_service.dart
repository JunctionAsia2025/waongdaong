import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/result.dart';
import '../models/content.dart';

/// 콘텐츠 관련 서비스
class ContentService {
  final SupabaseClient _supabase;

  ContentService(this._supabase);

  /// 콘텐츠 목록 가져오기 (페이지네이션 + 필터링)
  Future<Result<List<Content>>> getContents({
    String? contentType,
    String? difficultyLevel,
    List<String>? categories,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      // 기본 쿼리 시작
      var query = _supabase.from('content').select();

      // 필터링 적용
      if (contentType != null) {
        query = query.eq('content_type', contentType);
      }

      if (difficultyLevel != null) {
        query = query.eq('difficulty_level', difficultyLevel);
      }

      if (categories != null && categories.isNotEmpty) {
        // 배열 필터링: categories 컬럼에 categories 배열이 포함되는지 확인
        query = query.overlaps('categories', categories);
      }

      // 정렬 및 페이지네이션 적용
      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final contents =
          (response as List).map((json) => Content.fromJson(json)).toList();

      return Result.success(contents);
    } catch (e) {
      return Result.failure('콘텐츠를 가져오는 중 오류가 발생했습니다.', e);
    }
  }

  /// 콘텐츠 상세 정보 가져오기
  Future<Result<Content>> getContentById(String id) async {
    try {
      final response =
          await _supabase.from('content').select().eq('id', id).single();

      final content = Content.fromJson(response);
      return Result.success(content);
    } catch (e) {
      return Result.failure('콘텐츠를 가져오는 중 오류가 발생했습니다.', e);
    }
  }

  /// 사용자 관심사 기반 콘텐츠 추천 (페이지네이션 지원)
  Future<Result<List<Content>>> getRecommendedContents({
    required List<String> userInterests,
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final response = await _supabase
          .from('content')
          .select()
          .overlaps('categories', userInterests)
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final contents =
          (response as List).map((json) => Content.fromJson(json)).toList();

      return Result.success(contents);
    } catch (e) {
      return Result.failure('추천 콘텐츠를 가져오는 중 오류가 발생했습니다.', e);
    }
  }

  /// 콘텐츠 검색 (페이지네이션 + 필터링)
  Future<Result<List<Content>>> searchContents({
    required String query,
    String? contentType,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      // 기본 검색 쿼리 시작
      var searchQuery = _supabase
          .from('content')
          .select()
          .or('title.ilike.%$query%,content.ilike.%$query%');

      // 추가 필터링 적용
      if (contentType != null) {
        searchQuery = searchQuery.eq('content_type', contentType);
      }

      // 정렬 및 페이지네이션 적용
      final response = await searchQuery
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final contents =
          (response as List).map((json) => Content.fromJson(json)).toList();

      return Result.success(contents);
    } catch (e) {
      return Result.failure('콘텐츠 검색 중 오류가 발생했습니다.', e);
    }
  }

  /// 콘텐츠 카테고리 목록 가져오기
  Future<Result<List<String>>> getContentCategories() async {
    try {
      final response = await _supabase
          .from('content_categories')
          .select('category')
          .order('category');

      final categories =
          (response as List)
              .map((json) => json['category'] as String)
              .toSet()
              .toList();

      return Result.success(categories);
    } catch (e) {
      return Result.failure('카테고리를 가져오는 중 오류가 발생했습니다.', e);
    }
  }

  /// 콘텐츠 난이도별 통계
  Future<Result<Map<String, int>>> getContentDifficultyStats() async {
    try {
      final response = await _supabase
          .from('content')
          .select('difficulty_level');

      final stats = <String, int>{};
      for (final item in response as List) {
        final level = item['difficulty_level'] as String;
        stats[level] = (stats[level] ?? 0) + 1;
      }

      return Result.success(stats);
    } catch (e) {
      return Result.failure('통계를 가져오는 중 오류가 발생했습니다.', e);
    }
  }

  /// 필터링된 콘텐츠 총 개수 조회 (페이지네이션을 위한)
  Future<Result<int>> getFilteredContentsCount({
    String? contentType,
    String? difficultyLevel,
    List<String>? categories,
  }) async {
    try {
      // 간단한 방법: 모든 데이터를 가져와서 클라이언트에서 카운트
      // 실제 프로덕션에서는 RPC 함수나 다른 방법 사용 권장
      var query = _supabase.from('content').select('id');

      // 필터링 적용
      if (contentType != null) {
        query = query.eq('content_type', contentType);
      }

      if (difficultyLevel != null) {
        query = query.eq('difficulty_level', difficultyLevel);
      }

      if (categories != null && categories.isNotEmpty) {
        query = query.overlaps('categories', categories);
      }

      final response = await query;
      return Result.success((response as List).length);
    } catch (e) {
      return Result.failure('콘텐츠 개수를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 콘텐츠 타입별 통계
  Future<Result<Map<String, int>>> getContentTypeStats() async {
    try {
      final response = await _supabase.from('content').select('content_type');

      final stats = <String, int>{};
      for (final item in response as List) {
        final type = item['content_type'] as String;
        stats[type] = (stats[type] ?? 0) + 1;
      }

      return Result.success(stats);
    } catch (e) {
      return Result.failure('콘텐츠 타입 통계를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 인기 콘텐츠 조회 (학습 세션 수 기준)
  Future<Result<List<Content>>> getPopularContents({
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      // 학습 세션이 많은 순으로 정렬 (실제로는 RPC 함수나 조인 필요)
      final response = await _supabase
          .from('content')
          .select()
          .order('created_at', ascending: false) // 임시로 생성일 기준
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final contents =
          (response as List).map((json) => Content.fromJson(json)).toList();

      return Result.success(contents);
    } catch (e) {
      return Result.failure('인기 콘텐츠를 조회하는 중 오류가 발생했습니다.', e);
    }
  }
}
