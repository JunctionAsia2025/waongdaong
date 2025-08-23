import 'package:supabase_flutter/supabase_flutter.dart';

/// 데이터베이스 기본 서비스
class DatabaseService {
  DatabaseService();

  /// Supabase 클라이언트
  SupabaseClient get _client => Supabase.instance.client;

  /// 데이터 조회
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String? select,
    Map<String, dynamic>? filters,
    int? limit,
    int? offset,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      // 기본 쿼리 빌더 생성
      var queryBuilder = _client.from(table).select(select ?? '*');

      // 필터 적용
      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value != null) {
            queryBuilder = queryBuilder.eq(entry.key, entry.value);
          }
        }
      }

      // 정렬, 페이지네이션을 포함한 최종 쿼리 실행
      if (orderBy != null && offset != null && limit != null) {
        // 정렬 + 범위 페이지네이션
        return await queryBuilder
            .order(orderBy, ascending: ascending)
            .range(offset, offset + limit - 1);
      } else if (orderBy != null && limit != null) {
        // 정렬 + 제한
        return await queryBuilder
            .order(orderBy, ascending: ascending)
            .limit(limit);
      } else if (orderBy != null) {
        // 정렬만
        return await queryBuilder.order(orderBy, ascending: ascending);
      } else if (offset != null && limit != null) {
        // 범위 페이지네이션만
        return await queryBuilder.range(offset, offset + limit - 1);
      } else if (limit != null) {
        // 제한만
        return await queryBuilder.limit(limit);
      } else {
        // 필터만 또는 전체 조회
        return await queryBuilder;
      }
    } catch (e) {
      throw DatabaseException('데이터 조회 실패: $e');
    }
  }

  /// 단일 레코드 조회
  Future<Map<String, dynamic>?> selectOne({
    required String table,
    String? select,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final result = await this.select(
        table: table,
        select: select,
        filters: filters,
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      throw DatabaseException('단일 레코드 조회 실패: $e');
    }
  }

  /// 데이터 삽입
  Future<List<Map<String, dynamic>>> insert({
    required String table,
    required Map<String, dynamic> data,
    String? select,
  }) async {
    try {
      return await _client.from(table).insert(data).select(select ?? '*');
    } catch (e) {
      throw DatabaseException('데이터 삽입 실패: $e');
    }
  }

  /// 데이터 업데이트
  Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> filters,
    String? select,
  }) async {
    try {
      var query = _client.from(table).update(data);

      filters.forEach((key, value) {
        if (value != null) {
          query = query.eq(key, value);
        }
      });

      return await query.select(select ?? '*');
    } catch (e) {
      throw DatabaseException('데이터 업데이트 실패: $e');
    }
  }

  /// 데이터 삭제
  Future<void> delete({
    required String table,
    required Map<String, dynamic> filters,
  }) async {
    try {
      var query = _client.from(table).delete();

      filters.forEach((key, value) {
        if (value != null) {
          query = query.eq(key, value);
        }
      });

      await query;
    } catch (e) {
      throw DatabaseException('데이터 삭제 실패: $e');
    }
  }
}

/// 데이터베이스 예외 클래스
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
