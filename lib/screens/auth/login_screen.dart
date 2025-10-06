import 'package:community_report_app/custom_theme.dart';
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
              Center(
                child: Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF249A00),
                  ),
                ),
              ),

              // Email
              CustomTheme().customTextField(
                context: context,
                controller: _emailController,
                label: "Email",
                hint: "Insert email",
                icon: Icons.email,
                iconColor: CustomTheme.green,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // Password
              CustomTheme().customTextField(
                context: context,
                controller: _passwordController,
                label: "Password",
                hint: "Insert password",
                icon: Icons.lock,
                iconColor: CustomTheme.green,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.green,
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
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
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
                    "Sign In With Email",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // GOOGLE SIGN IN BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: CustomTheme.green,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                  ),
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
                  const Text("Don't have an account? "),
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
