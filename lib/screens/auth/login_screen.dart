import 'package:community_report_app/provider/auth_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", height: 100),
              const SizedBox(height: 20),

              // EMAIL INPUT
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // PASSWORD INPUT
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final success = await authProvider.signInWithEmail(
                      email,
                      password,
                      profileProvider,
                    );

                    if (success && profileProvider.profile != null) {
                      if (profileProvider.profile!.role == "admin") {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.home,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            authProvider.errorMessage ?? "Login failed",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Login dengan Email",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // GOOGLE SIGN IN BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Image.asset(
                    "assets/images/google_logo.png", // logo google
                    height: 20,
                  ),
                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  onPressed: () async {
                    final success = await authProvider.signInWithGoogle();
                    if (success && mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            authProvider.errorMessage ??
                                "Google Sign-In failed",
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              // REGISTER LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
