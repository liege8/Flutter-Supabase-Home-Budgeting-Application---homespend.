// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:araneta_HBA_it14/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:araneta_HBA_it14/pages/auth/login_page.dart';
import 'dart:ui';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;
  Uint8List? profileImageBytes;
  String? imageName;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        profileImageBytes = bytes;
        imageName = pickedFile.name;
      });
    }
  }

  Future<String?> uploadProfileImage(String userId) async {
    if (profileImageBytes == null) return null;

    try {
      final String filePath = 'profiles/$userId.jpg';
      await supabase.storage.from('profile_pictures').uploadBinary(
            filePath,
            profileImageBytes!,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage.from('profile_pictures').getPublicUrl(filePath);
    } catch (e) {
      print("❌ Image Upload Failed: $e");
      return null;
    }
  }

  Future<void> signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords do not match!"),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
      return;
    }

    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Full name and email are required!"),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        final userId = response.user!.id;
        final profileImageUrl = await uploadProfileImage(userId);

        await supabase.from('users').insert({
          'id': userId,
          'full_name': fullNameController.text.trim(),
          'email': emailController.text.trim(),
          'address': addressController.text.trim(),
          'profile_image': profileImageUrl ?? '',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Signup successful! Check your email for verification."),
            backgroundColor: secondary1,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            action: SnackBarAction(
              label: "UNDO",
              textColor: palette3,
              onPressed: () {
                print("Undo pressed!");
              },
            ),
          ),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup Failed: ${e.toString()}"),
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
          Positioned.fill(
            child: Image.asset(
              "assets/images/signup bg.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 10, sigmaY: 10), // Glass effect
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: secondary1.withOpacity(
                                        0.3), // Semi-transparent background
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(
                                            0.2)), // Optional border
                                  ),
                                  child: const Text(
                                    "Register",
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
                        const SizedBox(height: 300),
                        GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: palette3,
                            backgroundImage: profileImageBytes != null
                                ? MemoryImage(profileImageBytes!)
                                : null,
                            child: profileImageBytes == null
                                ? const Icon(Icons.camera_alt,
                                    size: 40, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(fullNameController, "Full Name",
                            Icons.person_3_rounded),
                        SizedBox(
                          height: 5,
                        ),
                        _buildTextField(
                            emailController, "Email", Icons.mail_rounded),
                        SizedBox(
                          height: 5,
                        ),
                        _buildTextField(addressController, "Address",
                            Icons.location_on_rounded),
                        SizedBox(
                          height: 5,
                        ),
                        _buildPasswordField(
                          passwordController,
                          "Password",
                          isPasswordVisible,
                          () {
                            setState(
                                () => isPasswordVisible = !isPasswordVisible);
                          },
                          Icons.key_sharp,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        _buildPasswordField(
                          confirmPasswordController,
                          "Confirm Password",
                          isConfirmPasswordVisible,
                          () {
                            setState(
                              () => isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible,
                            );
                          },
                          Icons.key_rounded,
                        ),
                        const SizedBox(height: 20),
                        isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: secondary1),
                              )
                            : GestureDetector(
                                onTap: signUp,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        secondary1,
                                        primary1.withOpacity(0.8)
                                      ],
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
                                        "Sign Up",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(
                                          width:
                                              8), // Spacing between text and icon
                                      const Icon(Icons.app_registration_rounded,
                                          color: Colors.white, size: 22),
                                    ],
                                  ),
                                ),
                              ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: secondary1,
                          ),
                          child: const Text("Already have an account? Log in"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData prefixIcon,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glass effect
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // Semi-transparent effect
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Colors.white.withOpacity(0.3)), // Optional border
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(prefixIcon, color: secondary1),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: TextStyle(
                color: Colors.white), // Adjust text color for visibility
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool isVisible,
    VoidCallback toggleVisibility,
    IconData prefixIcon,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isVisible,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(prefixIcon, color: secondary1),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: secondary1,
                ),
                onPressed: toggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
