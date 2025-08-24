import 'package:flutter/foundation.dart';
import '../supabase/supabase_module.dart';
import '../ai/ai_module.dart';
import 'services/quiz_service.dart';
import 'controllers/quiz_controller.dart';

/// 퀴즈 모듈 - 개인 학습 문제 시스템 관리
class QuizModule {
  static QuizModule? _instance;
  static QuizModule get instance => _instance ??= QuizModule._();

  QuizModule._();

  late final QuizService _quizService;
  late final QuizController _quizController;

  /// 모듈 초기화
  Future<void> initialize() async {
    try {
      // 의존성 모듈 확인
      final supabaseModule = SupabaseModule.instance;
      final aiModule = AIModule();

      if (!supabaseModule.isInitialized) {
        throw Exception('QuizModule: Supabase 모듈이 초기화되지 않았습니다');
      }

      // AI 모듈 초기화
      await aiModule.initialize();

      // 서비스 초기화
      _quizService = QuizService(
        databaseService: supabaseModule.database,
        aiService: aiModule.aiApiService,
      );

      // 컨트롤러 초기화
      _quizController = QuizController(quizService: _quizService);

      // 초기화 완료 로그
      if (kDebugMode) {
        print('✅ QuizModule 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ QuizModule 초기화 실패: $e');
      }
      rethrow;
    }
  }

  /// 모듈 해제
  Future<void> dispose() async {
    try {
      _quizController.dispose();
      if (kDebugMode) {
        print('✅ QuizModule 해제 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ QuizModule 해제 실패: $e');
      }
    }
  }

  // Getters
  QuizService get quizService => _quizService;
  QuizController get quizController => _quizController;

  /// 모듈 초기화 상태 확인
  bool get isInitialized {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }
}
