import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import '../modules/supabase/supabase_module.dart';
import '../modules/app_module_manager.dart';
import '../presentation/splash/pages/splash_page.dart';
import '../presentation/content/pages/content_feed_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaongDaong',
      theme: AppTheme.theme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('🚀 앱 초기화 시작');
    try {
      // 스플래시 화면 최소 표시 시간과 초기화를 병렬로 실행
      final List<Future> futures = [
        // 최소 4초간 스플래시 화면 표시
        Future.delayed(const Duration(seconds: 4)),
        // AppModuleManager를 통해 모든 모듈 초기화
        _initializeModules(),
      ];

      await Future.wait(futures);
      print('✅ 앱 초기화 완료');

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('❌ 앱 초기화 실패: $e');
      print('📍 에러 스택: ${e.toString()}');

      // 초기화 실패 시에도 최소 시간은 대기
      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _initializeModules() async {
    try {
      print('📦 모듈 초기화 시작...');
      await AppModuleManager.instance.initialize(
        SupabaseModule.instance.client,
      );
      print('✅ 모든 모듈 초기화 성공');
    } catch (e) {
      print('❌ 모듈 초기화 실패: $e');
      if (e is Exception) {
        print('📋 에러 타입: ${e.runtimeType}');
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashPage();
    }

    final authService = SupabaseModule.instance.auth;

    // 일시적으로 ContentFeedPage로 이동 (개발/테스트용)
    return const ContentFeedPage();

    // if (authService.isAuthenticated) {
    //   // TODO: MainTabPage로 이동 (구현되면 연결)
    //   return const Scaffold(
    //     body: Center(child: Text('Main Tab Page - TODO\n(로그인된 상태)')),
    //   );
    // } else {
    //   // TODO: LoginPage로 이동 (구현되면 연결)
    //   return const Scaffold(
    //     body: Center(child: Text('Login Page - TODO\n(로그인 필요)')),
    //   );
    // }
  }
}
