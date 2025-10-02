import 'package:community_report_app/provider/auth_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/routes.dart';
import 'package:community_report_app/screens/home_screen.dart';
import 'package:community_report_app/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MainScreenLoggedIn extends StatefulWidget {
  const MainScreenLoggedIn({super.key});
  @override
  State<MainScreenLoggedIn> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenLoggedIn> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    Homescreen(),
    ProfileScreen(),
    // AttendanceHistoryScreen(),
  ];
  final List<String> _titles = ['Home', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _titles[_currentIndex],
                style: GoogleFonts.pacifico(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),

            Text(
              DateFormat('MMMM dd, yyyy').format(DateTime.now()),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens, // list of widgets
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: Color(0xFF004966),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                "${profile!.front_name} ${profile.last_name}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(profile.email),
              currentAccountPicture: CircleAvatar(
                radius: 55,
                backgroundImage:
                    (profile.photo != null && profile.photo!.isNotEmpty)
                    ? NetworkImage(profile.photo!)
                    : null,
                child: profile.photo == null
                    ? const Icon(Icons.person, size: 55)
                    : null,
              ),
              decoration: BoxDecoration(color: Color(0xFF004966)),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('SettingsPage'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.home),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('AboutPage'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.home),
            ),
            ListTile(
              leading: Icon(Icons.logout_outlined),
              title: Text('Log Out'),
              onTap: () async {
                await authProvider.signOut();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
