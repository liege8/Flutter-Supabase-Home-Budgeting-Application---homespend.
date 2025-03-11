// ignore_for_file: deprecated_member_use

import 'package:araneta_HBA_it14/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:araneta_HBA_it14/pages/root_app.dart';
import 'package:araneta_HBA_it14/pages/auth/signup_page.dart';
import 'dart:ui';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  Future<void> signIn() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RootApp()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Failed: ${e.toString()}"),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/login bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Content Layer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                            sigmaX: 10, sigmaY: 10), // Glass effect
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: secondary1.withOpacity(
                                0.3), // Semi-transparent background
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.white
                                    .withOpacity(0.2)), // Soft border
                          ),
                          child: const Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 350),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: 10, sigmaY: 10), // Glass blur effect
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.2), // Semi-transparent background
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.white
                                .withOpacity(0.3)), // Optional border
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon:
                              Icon(Icons.mail_rounded, color: secondary1),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        style: TextStyle(
                            color:
                                Colors.white), // Adjust text color for contrast
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon:
                              Icon(Icons.lock_rounded, color: secondary1),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: secondary1,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(
                        child: LinearProgressIndicator(
                          color: secondary1,
                        ),
                      )
                    : GestureDetector(
                        onTap: signIn,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [secondary1, primary1.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: palette4.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(
                                  width: 8), // Spacing between text and icon
                              const Icon(Icons.login_rounded,
                                  color: Colors.white, size: 22),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: primary1,
                  ),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
