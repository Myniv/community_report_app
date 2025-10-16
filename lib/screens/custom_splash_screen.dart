import 'dart:async';

import 'package:community_report_app/screens/auth/auth_wrapper.dart';
import 'package:flutter/material.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({Key? key}) : super(key: key);

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _visible = true;
      });
    });

    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: Duration(seconds: 2),
          child: AnimatedDefaultTextStyle(
            style: TextStyle(
              color: Colors.white,
              fontSize: _visible ? 64 : 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
            duration: Duration(seconds: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 200, height: 200),
                SizedBox(height: 20),
                AnimatedScale(
                  scale: _visible ? 1.5 : 0.5,
                  duration: const Duration(seconds: 2),
                  child: const CircularProgressIndicator(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
