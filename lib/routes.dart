import 'package:community_report_app/screens/auth/login_screen.dart';
import 'package:community_report_app/screens/auth/register_screen.dart';
import 'package:community_report_app/screens/profile/edit_profile_screen.dart';
import 'package:community_report_app/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String editProfile = '/edit_profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(),
          settings: settings,
        );
      case editProfile:
        return MaterialPageRoute(
          builder: (_) => UpdateProfileScreen(),
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
