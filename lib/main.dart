import 'package:community_report_app/provider/auth_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/screens/auth/login_screen.dart';
import 'package:community_report_app/screens/auth/register_screen.dart';
import 'package:community_report_app/screens/home_screen.dart';
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
      home: MainScreen(),
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

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<String> _titleScreen = ["Home", "Login", "Regist"];
  final List<IconData> _iconScreen = [
    Icons.home,
    Icons.access_time,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(),
      LoginScreen(),
      RegisterScreen(),
    ];
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
