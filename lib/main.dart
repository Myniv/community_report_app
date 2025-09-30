import 'package:community_report_app/provider/auth_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/routes.dart';
import 'package:community_report_app/screens/auth/auth_wrapper.dart';
import 'package:community_report_app/screens/auth/login_screen.dart';
// import 'package:community_report_app/screens/auth/login_test.dart';
import 'package:community_report_app/screens/auth/register_screen.dart';
import 'package:community_report_app/screens/home_screen.dart';
import 'package:community_report_app/screens/profile/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      projectId: 'communityreportapp', // Project ID
      messagingSenderId: '309990585762', //Project Number
      apiKey: 'AIzaSyCIOyUg9tFdXVxOGXiymgwkMbT7VBJnYmI', //Web API Key
      appId: '1:309990585762:android:77d8627d31b4e72e51eefb',
    ), // App ID
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );
  await Supabase.initialize(
    url: 'https://ltvskbkhdfgvkveqaxpg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx0dnNrYmtoZGZndmt2ZXFheHBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1MjU3NjUsImV4cCI6MjA3MzEwMTc2NX0.i2YH6LvyAwkreZ11f-NbUkQBq7oQ5xuKHqe9sIEWhGE',
    //bucketname : profile_photos_community_app
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthWrapper(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  List<String> _titleScreen = [];
  List<IconData> _iconScreen = [];

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _changeScreen(
    List<Widget> screen,
    List<IconData> icon,
    List<String> title,
  ) {
    setState(() {
      _screens = screen;
      _iconScreen = icon;
      _titleScreen = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    //TODO CHAGNE THE SCREENS BASED ON THE CORRESPONDED
    final List<String> _titleScreen = ["Home", "Login", "Regist"];
    final List<String> _titleScreenMember = ["Home", "Profile", "Regist"];
    final List<Widget> _screensMember = [
      HomeScreen(),
      ProfileScreen(),
      RegisterScreen(),
    ];
    final List<IconData> _iconScreenMember = [
      Icons.home,
      Icons.login,
      Icons.person,
    ];

    final List<String> _titleScreenLeader = ["Home", "Regist", "Profile"];
    final List<Widget> _screensLeader = [
      HomeScreen(),
      RegisterScreen(),
      ProfileScreen(),
    ];
    final List<IconData> _iconScreenLeader = [
      Icons.home,
      Icons.app_registration,
      Icons.person,
    ];

    final List<String> _titleScreenAdmin = ["Home", "Regist", "Profile"];
    final List<Widget> _screensAdmin = [
      HomeScreen(),
      RegisterScreen(),
      ProfileScreen(),
    ];
    final List<IconData> _iconScreenAdmin = [
      Icons.home,
      Icons.app_registration,
      Icons.person,
    ];

    if (profileProvider.profile!.role == 'member') {
      _changeScreen(_screensMember, _iconScreenMember, _titleScreenMember);
    } else if (profileProvider.profile!.role == 'leader') {
      _changeScreen(_screensLeader, _iconScreenLeader, _titleScreenLeader);
    } else if (profileProvider.profile!.role == 'admin') {
      _changeScreen(_screensAdmin, _iconScreenAdmin, _titleScreenAdmin);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_titleScreen[_currentIndex]),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: List.generate(
          _iconScreen.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_iconScreen[index]),
            label: _titleScreen[index],
          ),
        ),
        onTap: _changeTab,
      ),
    );
  }
}
