// ignore_for_file: deprecated_member_use

import 'package:araneta_HBA_it14/pages/auth/signup_page.dart';
import 'package:araneta_HBA_it14/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:araneta_HBA_it14/pages/auth/login_page.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg-final.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // Logo with Rounded Square Background
          Positioned(
            top: 30,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10), // Space around the logo
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.6), // Semi-transparent background
                borderRadius:
                    BorderRadius.circular(12), // Rounded square effect
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 2), // Subtle shadow for depth
                  ),
                ],
              ),
              child: Image.asset(
                "assets/images/homespend - primaryLOGO.png",
                height: 50,
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Welcome\nto homespend.",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),

                SizedBox(height: 10),

                // Subtitle (Left-Aligned)
                Text(
                  "Manage your home finances smarter and easier",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                SizedBox(height: 30),

                // Login with Email Button (Modern, Oval-Shaped)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 18),
                      elevation: 5,
                    ),
                    child: Text(
                      "Login with Email",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ),

                SizedBox(height: 15),

                // Signup Button (Outlined, No Fill, Oval-Shaped)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),

                // Terms & Privacy (Centered)
                Center(
                  child: Text(
                    "By continuing you agree to our\nTerms & Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
