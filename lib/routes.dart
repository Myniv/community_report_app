import 'package:community_report_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );
    }
  }
}
