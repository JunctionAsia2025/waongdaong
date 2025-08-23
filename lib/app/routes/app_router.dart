import 'package:flutter/material.dart';
import 'route_names.dart';

// TODO: 각 페이지들이 구현되면 import 추가 예정
// import '../../presentation/auth/pages/login_page.dart';
// import '../../presentation/main/pages/main_tab_page.dart';
// 등등...

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        // TODO: LoginPage 구현 후 연결
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Login Page - TODO')),
              ),
          settings: settings,
        );

      case RouteNames.mainTab:
        // TODO: MainTabPage 구현 후 연결
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Main Tab Page - TODO')),
              ),
          settings: settings,
        );

      // TODO: 나머지 라우트들도 페이지 구현 후 추가

      default:
        return MaterialPageRoute(
          builder:
              (_) =>
                  const Scaffold(body: Center(child: Text('Page Not Found'))),
        );
    }
  }
}
