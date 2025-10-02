import 'dart:io';

import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/provider/auth_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  final CustomTheme _theme = CustomTheme();

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: Column(
        children: [
          // Enhanced Header with Profile
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [CustomTheme.green, CustomTheme.lightGreen],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Close Button
                  Padding(
                    padding: EdgeInsets.only(right: 8, top: 8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Profile Picture
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: CustomTheme.whiteKindaGreen,
                        backgroundImage: profileProvider.profile?.photo != null
                            ? NetworkImage(profileProvider.profile!.photo!)
                            : null,
                        child: profileProvider.profile?.photo == null
                            ? Icon(
                                Icons.person,
                                size: 40,
                                color: CustomTheme.green,
                              )
                            : null,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // User Info
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          profileProvider.profile?.username ?? "User",
                          style: _theme
                              .mediumFont(Colors.white, FontWeight.bold, context)
                              .copyWith(letterSpacing: 0.5),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 16),
                children: [
                  //TODO Change the menu items based corresponded user
                  _buildMenuItem(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'Learn more about the app',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'Manage your preferences',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/setting');
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(color: Colors.grey[300]),
                  ),

                  _buildMenuItem(
                    context: context,
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    isDestructive: true,
                    onTap: () async {
                      final shouldLogout = await _showLogoutDialog(context);
                      if (shouldLogout == true) {
                        final profileProvider = Provider.of<ProfileProvider>(
                          context,
                          listen: false,
                        );
                        profileProvider.clearProfile();

                        await authProvider.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.eco_rounded, color: CustomTheme.green, size: 16),
                SizedBox(width: 8),
                Text(
                  'Community Report v1.0',
                  style: _theme.superSmallFont(
                    Colors.grey[600]!,
                    FontWeight.w500,
                    context,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : CustomTheme.green;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: _theme.smallFont(
                          Colors.grey[800]!,
                          FontWeight.w600,
                          context,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: _theme.superSmallFont(
                            Colors.grey[600]!,
                            FontWeight.w400,
                            context,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout_rounded, color: Colors.red, size: 24),
              ),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: _theme
                    .mediumFont(Colors.grey[800]!, FontWeight.bold, context)
                    .copyWith(letterSpacing: 0),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: _theme.smallFont(
              Colors.grey[700]!,
              FontWeight.w400,
              context,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Cancel',
                style: _theme.superSmallFont(
                  Colors.grey[600]!,
                  FontWeight.w600,
                  context,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: _theme.superSmallFont(
                  Colors.white,
                  FontWeight.w600,
                  context,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
