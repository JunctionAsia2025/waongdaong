import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/result.dart';
import 'services/point_service.dart';
import 'models/point_transaction.dart';

class PointModule {
  final SupabaseClient _supabase;
  late final PointService _pointService;

  PointModule(this._supabase);

  /// 모듈 초기화
  Future<void> initialize() async {
    _pointService = PointService(_supabase);
  }

  /// 모듈 정리
  Future<void> dispose() async {
    // 필요한 정리 작업이 있다면 여기에 구현
  }

  /// PointService 가져오기
  PointService get pointService => _pointService;

  /// 포인트 적립
  Future<Result<PointTransaction>> earnPoints({
    required String userId,
    required int amount,
    required String description,
    String? referenceType,
    String? referenceId,
    DateTime? expiresAt,
  }) async {
    return await _pointService.earnPoints(
      userId: userId,
      amount: amount,
      description: description,
      referenceType: referenceType,
      referenceId: referenceId,
      expiresAt: expiresAt,
    );
  }

  /// 포인트 사용
  Future<Result<PointTransaction>> spendPoints({
    required String userId,
    required int amount,
    required String description,
    String? referenceType,
    String? referenceId,
  }) async {
    return await _pointService.spendPoints(
      userId: userId,
      amount: amount,
      description: description,
      referenceType: referenceType,
      referenceId: referenceId,
    );
  }

  /// 현재 포인트 잔액 조회
  Future<int> getCurrentBalance(String userId) async {
    return await _pointService.getCurrentBalance(userId);
  }

  /// 포인트 거래 내역 조회
  Future<Result<List<PointTransaction>>> getPointTransactions({
    required String userId,
    String? type,
    int page = 0,
    int pageSize = 20,
  }) async {
    return await _pointService.getPointTransactions(
      userId: userId,
      type: type,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 포인트 통계 조회
  Future<Result<Map<String, dynamic>>> getPointStats(String userId) async {
    return await _pointService.getPointStats(userId);
  }

  /// 학습 완료 시 포인트 적립
  Future<Result<PointTransaction>> earnPointsForLearning({
    required String userId,
    required String sessionId,
    required int studyTime,
    required int comprehensionScore,
  }) async {
    return await _pointService.earnPointsForLearningSession(
      userId: userId,
      sessionId: sessionId,
      amount: studyTime + comprehensionScore,
      description: '학습 완료 보상 ($studyTime분, 이해도: $comprehensionScore점)',
    );
  }
}
