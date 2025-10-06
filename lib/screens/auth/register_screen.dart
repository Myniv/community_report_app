import 'package:community_report_app/custom_theme.dart';
import 'package:community_report_app/models/enum_list.dart';
import 'package:community_report_app/models/profile.dart';
import 'package:community_report_app/provider/auth_provider.dart';
import 'package:community_report_app/provider/profileProvider.dart';
import 'package:community_report_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final CustomTheme _customTheme = CustomTheme();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _frontNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _selectedLocationValue = null;

  // final locationItem = const [
  //   "Binong Permai",
  //   "Bintaro",
  //   "Kalibata",
  //   "Karawaci",
  //   "Kemanggisan Baru",
  // ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    final phoneFormatter = MaskTextInputFormatter(
      mask: '+62 ###-####-####',
      filter: {"#": RegExp(r'[0-9]')},
    );

    final locationItem = LocationItem.values.map((e) => e.displayName).toList();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                Image.asset("assets/images/logo.png", height: 120),
                const SizedBox(height: 20),

                // Username
                _customTheme.customTextField(
                  context: context,
                  controller: _usernameController,
                  icon: Icons.verified_user,
                  label: "Username",
                  hint: "Enter username",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a username";
                    }
                    if (value.trim().length < 3) {
                      return "Username must be at least 3 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _customTheme.customTextField(
                        context: context,
                        controller: _frontNameController,
                        icon: Icons.person,
                        label: "First name",
                        hint: "Enter First name",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a first name";
                          }
                          if (value.trim().length < 2) {
                            return "Username must be at least 1 characters";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _customTheme.customTextField(
                        context: context,
                        controller: _lastNameController,
                        icon: Icons.person,
                        label: "Last name",
                        hint: "Enter last name",
                        validator: null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Email
                _customTheme.customTextField(
                  context: context,
                  controller: _emailController,
                  icon: Icons.email,
                  label: "Email",
                  hint: "Enter email",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your email";
                    }
                    if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                _customTheme.customTextField(
                  context: context,
                  controller: _phoneController,
                  icon: Icons.phone,
                  label: "Phone",
                  hint: "Enter phone number",
                  keyboardType: TextInputType.number,
                  inputFormatters: [phoneFormatter],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a phone number";
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return "Employee ID must be a number";
                    }
                    if (value.trim().length < 10) {
                      return "Phone number must be at least 10 characters";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                _customTheme.customDropdown<String>(
                  context: context,
                  icon: Icons.location_on,
                  value: null,
                  items: locationItem,
                  label: "Location",
                  hint: "Select Location",
                  onChanged: (value) {
                    setState(() {
                      _selectedLocationValue = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a location";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomTheme().customTextField(
                  context: context,
                  controller: _passwordController,
                  label: "Password",
                  hint: "Enter your password",
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  isPassword: true,
                  onToggleObscure: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                await authProvider.registerWithEmail(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  profileProvider,
                                  Profile(
                                    uid: '',
                                    email: _emailController.text.trim(),
                                    username: _usernameController.text.trim(),
                                    front_name: _frontNameController.text
                                        .trim(),
                                    last_name: _lastNameController.text.trim(),
                                    phone: _phoneController.text.trim(),
                                    location: _selectedLocationValue,
                                    photo: '', // Set photo to an empty string
                                    created_at: DateTime.now(),
                                    role: "member",
                                  ),
                                );

                                if (mounted &&
                                    profileProvider.profile != null) {
                                  if (profileProvider.profile!.role ==
                                      "admin") {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.home,
                                    );
                                  } else {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.home,
                                    );
                                  }
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Register failed: $e"),
                                  ),
                                );
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            }
                          },

                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Register",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 15),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: CustomTheme.green,
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
      ),
    );
  }
}
