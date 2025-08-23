import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/result.dart';
import '../models/point_transaction.dart';

class PointService {
  final SupabaseClient _supabase;

  PointService(this._supabase);

  /// 포인트 적립
  Future<Result<PointTransaction>> earnPoints({
    required String userId,
    required int amount,
    required String description,
    String? referenceType,
    String? referenceId,
    DateTime? expiresAt,
  }) async {
    try {
      // 현재 포인트 잔액 조회
      final currentBalance = await _getCurrentBalance(userId);

      // 포인트 적립 거래 생성
      final transactionData = {
        'user_id': userId,
        'type': 'earn',
        'amount': amount,
        'balance_after': currentBalance + amount,
        'description': description,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
      };

      final response =
          await _supabase
              .from('point_transactions')
              .insert(transactionData)
              .select()
              .single();

      final transaction = PointTransaction.fromJson(response);
      return Result.success(transaction);
    } catch (e) {
      return Result.failure('포인트를 적립하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 포인트 사용
  Future<Result<PointTransaction>> spendPoints({
    required String userId,
    required int amount,
    required String description,
    String? referenceType,
    String? referenceId,
  }) async {
    try {
      // 현재 포인트 잔액 조회
      final currentBalance = await _getCurrentBalance(userId);

      if (currentBalance < amount) {
        return Result.failure('포인트가 부족합니다.', null);
      }

      // 포인트 사용 거래 생성
      final transactionData = {
        'user_id': userId,
        'type': 'spend',
        'amount': -amount, // 음수로 저장
        'balance_after': currentBalance - amount,
        'description': description,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from('point_transactions')
              .insert(transactionData)
              .select()
              .single();

      final transaction = PointTransaction.fromJson(response);
      return Result.success(transaction);
    } catch (e) {
      return Result.failure('포인트를 사용하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 포인트 환불
  Future<Result<PointTransaction>> refundPoints({
    required String userId,
    required int amount,
    required String description,
    required String originalTransactionId,
  }) async {
    try {
      // 현재 포인트 잔액 조회
      final currentBalance = await _getCurrentBalance(userId);

      // 포인트 환불 거래 생성
      final transactionData = {
        'user_id': userId,
        'type': 'refund',
        'amount': amount,
        'balance_after': currentBalance + amount,
        'description': description,
        'reference_type': 'refund',
        'reference_id': originalTransactionId,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _supabase
              .from('point_transactions')
              .insert(transactionData)
              .select()
              .single();

      final transaction = PointTransaction.fromJson(response);
      return Result.success(transaction);
    } catch (e) {
      return Result.failure('포인트를 환불하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 보너스 포인트 지급
  Future<Result<PointTransaction>> giveBonusPoints({
    required String userId,
    required int amount,
    required String description,
    String? referenceType,
    String? referenceId,
    DateTime? expiresAt,
  }) async {
    try {
      // 현재 포인트 잔액 조회
      final currentBalance = await _getCurrentBalance(userId);

      // 보너스 포인트 거래 생성
      final transactionData = {
        'user_id': userId,
        'type': 'bonus',
        'amount': amount,
        'balance_after': currentBalance + amount,
        'description': description,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
      };

      final response =
          await _supabase
              .from('point_transactions')
              .insert(transactionData)
              .select()
              .single();

      final transaction = PointTransaction.fromJson(response);
      return Result.success(transaction);
    } catch (e) {
      return Result.failure('보너스 포인트를 지급하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 현재 포인트 잔액 조회
  Future<int> getCurrentBalance(String userId) async {
    return await _getCurrentBalance(userId);
  }

  /// 포인트 거래 내역 조회
  Future<Result<List<PointTransaction>>> getPointTransactions({
    required String userId,
    String? type,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _supabase
          .from('point_transactions')
          .select()
          .eq('user_id', userId);

      if (type != null) {
        query = query.eq('type', type);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      final transactions =
          (response as List)
              .map((json) => PointTransaction.fromJson(json))
              .toList();

      return Result.success(transactions);
    } catch (e) {
      return Result.failure('포인트 거래 내역을 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 포인트 거래 상세 조회
  Future<Result<PointTransaction>> getPointTransaction(
    String transactionId,
  ) async {
    try {
      final response =
          await _supabase
              .from('point_transactions')
              .select()
              .eq('id', transactionId)
              .single();

      final transaction = PointTransaction.fromJson(response);
      return Result.success(transaction);
    } catch (e) {
      return Result.failure('포인트 거래를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 포인트 통계 조회
  Future<Result<Map<String, dynamic>>> getPointStats(String userId) async {
    try {
      // 전체 거래 내역 조회
      final transactionsResponse = await _supabase
          .from('point_transactions')
          .select('type, amount, created_at')
          .eq('user_id', userId);

      int totalEarned = 0;
      int totalSpent = 0;
      int totalBonus = 0;
      int totalRefunded = 0;

      for (final transaction in transactionsResponse as List) {
        final type = transaction['type'] as String;
        final amount = transaction['amount'] as int;

        switch (type) {
          case 'earn':
            totalEarned += amount;
            break;
          case 'spend':
            totalSpent += amount.abs();
            break;
          case 'bonus':
            totalBonus += amount;
            break;
          case 'refund':
            totalRefunded += amount;
            break;
        }
      }

      final currentBalance = await _getCurrentBalance(userId);

      final stats = {
        'currentBalance': currentBalance,
        'totalEarned': totalEarned,
        'totalSpent': totalSpent,
        'totalBonus': totalBonus,
        'totalRefunded': totalRefunded,
        'netPoints': totalEarned + totalBonus + totalRefunded - totalSpent,
      };

      return Result.success(stats);
    } catch (e) {
      return Result.failure('포인트 통계를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 만료 예정 포인트 조회
  Future<Result<List<PointTransaction>>> getExpiringPoints({
    required String userId,
    int daysThreshold = 30,
  }) async {
    try {
      final thresholdDate = DateTime.now().add(Duration(days: daysThreshold));

      final response = await _supabase
          .from('point_transactions')
          .select()
          .eq('user_id', userId)
          .eq('type', 'earn')
          .not('expires_at', 'is', null)
          .lte('expires_at', thresholdDate.toIso8601String())
          .order('expires_at', ascending: true);

      final expiringTransactions =
          (response as List)
              .map((json) => PointTransaction.fromJson(json))
              .toList();

      return Result.success(expiringTransactions);
    } catch (e) {
      return Result.failure('만료 예정 포인트를 조회하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 포인트 만료 처리 (배치 작업용)
  Future<Result<void>> expirePoints() async {
    try {
      final now = DateTime.now();

      // 만료된 포인트 조회
      final expiredTransactions = await _supabase
          .from('point_transactions')
          .select('id, user_id, amount')
          .eq('type', 'earn')
          .not('expires_at', 'is', null)
          .lt('expires_at', now.toIso8601String());

      // 만료된 포인트를 사용 처리로 변경
      for (final transaction in expiredTransactions as List) {
        final userId = transaction['user_id'] as String;
        final amount = transaction['amount'] as int;

        // 현재 잔액 조회
        final currentBalance = await _getCurrentBalance(userId);

        // 만료 거래 생성
        final expireData = {
          'user_id': userId,
          'type': 'spend',
          'amount': -amount,
          'balance_after': currentBalance - amount,
          'description': '포인트 만료',
          'reference_type': 'expiration',
          'reference_id': transaction['id'],
          'created_at': now.toIso8601String(),
        };

        await _supabase.from('point_transactions').insert(expireData);
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure('포인트 만료 처리를 하는 중 오류가 발생했습니다.', e);
    }
  }

  /// 학습 세션 완료로 인한 포인트 지급
  Future<Result<PointTransaction>> earnPointsForLearningSession({
    required String userId,
    required String sessionId,
    required int amount,
    String description = '학습 세션 완료',
  }) async {
    try {
      return await earnPoints(
        userId: userId,
        amount: amount,
        description: description,
        referenceType: 'study_group',
        referenceId: sessionId,
      );
    } catch (e) {
      return Result.failure('학습 세션 포인트 지급 중 오류가 발생했습니다.', e);
    }
  }

  /// 짧은 토론 참여 포인트 적립 (단순화)
  Future<Result<PointTransaction>> earnPointsForDiscussion({
    required String userId,
    required String groupId,
    required int duration,
  }) async {
    try {
      // 단순한 포인트 계산: 5분당 1포인트
      int points = (duration / 5).floor();

      return await earnPoints(
        userId: userId,
        amount: points,
        description: '토론 참여 ($duration분)',
        referenceType: 'discussion',
        referenceId: groupId,
      );
    } catch (e) {
      return Result.failure('토론 포인트 적립 중 오류가 발생했습니다.', e);
    }
  }

  /// 현재 포인트 잔액 조회 (내부 메서드)
  Future<int> _getCurrentBalance(String userId) async {
    try {
      final response =
          await _supabase
              .from('point_transactions')
              .select('balance_after')
              .eq('user_id', userId)
              .order('created_at', ascending: false)
              .limit(1)
              .single();

      return response['balance_after'] as int? ?? 0;
    } catch (e) {
      return 0; // 거래 내역이 없는 경우 0 반환
    }
  }
}
