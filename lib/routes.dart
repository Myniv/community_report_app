import 'package:community_report_app/main.dart';
import 'package:community_report_app/screens/auth/login_screen.dart';
import 'package:community_report_app/screens/auth/register_screen.dart';
import 'package:community_report_app/screens/community_post/create_community_post_screen.dart';
import 'package:community_report_app/screens/community_post/detail_community_post_screen.dart';
import 'package:community_report_app/screens/profile/edit_profile_screen.dart';
import 'package:community_report_app/screens/profile/profile_list_screen.dart';
import 'package:community_report_app/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String editProfile = '/edit_profile';
  static const String profileList = '/list_profile';
  static const String mainScreen = '/main';
  static const String discussionDetail = '/discussion_detail';
  static const String editPost = '/edit_post';

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
        final args = settings.arguments as Map<String, dynamic>?;
        final profileId = args?['uid'];
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(profileId: profileId),
          settings: settings,
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (_) => UpdateProfileScreen(),
          settings: settings,
        );
      case mainScreen:
        return MaterialPageRoute(
          builder: (_) => MainScreen(),
          settings: settings,
        );
      case profileList:
        return MaterialPageRoute(
          builder: (_) => ProfileListScreen(),
          settings: settings,
        );
      case editPost:
        return MaterialPageRoute(
          builder: (_) => CreateCommunityPostScreen(onTabSelected: null),
          settings: settings,
        );
      case discussionDetail:
        final postId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => DetailCommunityPostScreen(postId: postId),
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
