import '../../supabase/services/database_service.dart';
import '../models/user_model.dart';

/// 사용자 데이터를 관리하는 리포지토리
/// Repository Pattern을 적용하여 데이터 접근을 추상화합니다.
class UserRepository {
  final DatabaseService _databaseService = DatabaseService();

  static const String _tableName = 'users';

  /// 사용자 이름으로 사용자 조회
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final data = await _databaseService.selectOne(
        table: _tableName,
        select: '*',
        filters: {'username': username},
      );

      if (data != null) {
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw RepositoryException('사용자 조회 실패: $e');
    }
  }

  /// 사용자 ID로 사용자 조회
  Future<UserModel?> getUserById(int userId) async {
    try {
      final data = await _databaseService.selectOne(
        table: _tableName,
        select: '*',
        filters: {'id': userId},
      );

      if (data != null) {
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw RepositoryException('사용자 조회 실패: $e');
    }
  }

  /// 모든 사용자 조회 (현재 사용자 제외)
  Future<List<UserModel>> getAllUsersExceptCurrent(int currentUserId) async {
    try {
      final result = await _databaseService.select(
        table: _tableName,
        select: '*',
        filters: {'id': 'neq.$currentUserId'}, // 현재 사용자 제외
        orderBy: 'created_at',
        ascending: false,
      );

      return result.map((data) => UserModel.fromJson(data)).toList();
    } catch (e) {
      throw RepositoryException('사용자 목록 조회 실패: $e');
    }
  }

  /// 사용자 이름으로 검색
  Future<List<UserModel>> searchUsersByUsername({
    required String searchTerm,
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await _databaseService.select(
        table: _tableName,
        select: '*',
        filters: null,
        limit: limit,
        offset: offset,
        orderBy: 'created_at',
        ascending: false,
      );

      // 사용자 이름에 검색어가 포함된 사용자들만 필터링
      return result
          .where(
            (user) =>
                user['username']?.toString().toLowerCase().contains(
                  searchTerm.toLowerCase(),
                ) ==
                true,
          )
          .map((data) => UserModel.fromJson(data))
          .toList();
    } catch (e) {
      throw RepositoryException('사용자 검색 실패: $e');
    }
  }

  /// 사용자 이름 중복 확인
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final existingUser = await getUserByUsername(username);
      return existingUser == null;
    } catch (e) {
      throw RepositoryException('사용자 이름 중복 확인 실패: $e');
    }
  }
}

/// 리포지토리 예외 클래스
class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}
