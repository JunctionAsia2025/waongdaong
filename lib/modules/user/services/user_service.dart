import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../../supabase/supabase_module.dart';

/// 사용자 관련 비즈니스 로직을 담당하는 서비스
class UserService {
  final UserRepository _userRepository = UserRepository();

  /// 현재 사용자 프로필 조회
  Future<UserModel?> getCurrentUserProfile() async {
    final username = SupabaseModule.instance.auth.currentUsername;
    if (username == null) return null;

    return await _userRepository.getUserByUsername(username);
  }

  /// 사용자 이름으로 검색 (현재 사용자 제외)
  Future<List<UserModel>> searchUsers({
    required String searchTerm,
    int? limit,
    int? offset,
  }) async {
    final currentUsername = SupabaseModule.instance.auth.currentUsername;
    if (currentUsername == null) return [];

    final users = await _userRepository.searchUsersByUsername(
      searchTerm: searchTerm,
      limit: limit,
      offset: offset,
    );

    // 현재 사용자 제외
    return users.where((user) => user.username != currentUsername).toList();
  }

  /// 사용자 이름 중복 확인
  Future<bool> isUsernameAvailable(String username) async {
    return await _userRepository.isUsernameAvailable(username);
  }

  /// 모든 사용자 조회 (현재 사용자 제외)
  Future<List<UserModel>> getAllUsersExceptCurrent() async {
    final currentUsername = SupabaseModule.instance.auth.currentUsername;
    if (currentUsername == null) return [];

    final currentUser = await _userRepository.getUserByUsername(
      currentUsername,
    );
    if (currentUser == null) return [];

    return await _userRepository.getAllUsersExceptCurrent(currentUser.id);
  }

  /// 사용자 정보 조회
  Future<UserModel?> getUserByUsername(String username) async {
    return await _userRepository.getUserByUsername(username);
  }

  /// 사용자 ID로 사용자 정보 조회
  Future<UserModel?> getUserById(int userId) async {
    return await _userRepository.getUserById(userId);
  }
}
