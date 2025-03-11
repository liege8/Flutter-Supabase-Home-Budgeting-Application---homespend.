// ignore_for_file: deprecated_member_use

import 'package:araneta_HBA_it14/pages/onboarding_page.dart';
import 'package:araneta_HBA_it14/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:araneta_HBA_it14/pages/edit_profile_page.dart';
import 'dart:math' show pi;
import 'package:skeletonizer/skeletonizer.dart';

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 60.0; // Adjusted radius

    path.lineTo(0, size.height - 30); // Adjusted curve start point
    path.quadraticBezierTo(size.width / 4, size.height - 15,
        size.width / 2 - radius, size.height - 15);
    path.arcTo(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height - 15),
          radius: radius,
        ),
        0,
        pi,
        false);
    path.quadraticBezierTo(
        3 * size.width / 4, size.height - 15, size.width, size.height - 30);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool isLoading = true;
  String fullName = "";
  String email = "";
  String profileImage = "";
  String bio = "";
  String address = ""; // ✅ Added Address Field
  int totalTransactions = 0;
  int totalBudgets = 0;
  double totalIncome = 0;
  double totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User is not logged in!")),
      );
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select(
              'full_name, email, profile_image, bio, address') // ✅ Fetch Address
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("No profile found. Please update your details.")),
        );
        return;
      }

      final String newImageUrl = supabase.storage
          .from('profile_pictures')
          .getPublicUrl('profiles/${user.id}.jpg');

      if (mounted) {
        setState(() {
          fullName = response['full_name'] ?? "Unknown User";
          email = response['email'] ?? "No Email";
          profileImage = response['profile_image'] ?? newImageUrl;
          bio = response['bio'] ?? "No bio available";
          address =
              response['address'] ?? "No address available"; // ✅ Store Address
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: ${e.toString()}")),
      );
      setState(() => isLoading = false);
    }

    try {
      // Existing profile fetch code...

      // Fetch statistics
      final transactionsData =
          await supabase.from('transactions').select('amount, type');

      final budgetsCount = await supabase
          .from('budgets')
          .select('*', const FetchOptions(count: CountOption.exact));

      double incomeSum = 0;
      double expenseSum = 0;

      for (var transaction in transactionsData) {
        if (transaction['type'] == 'income') {
          incomeSum += (transaction['amount'] ?? 0).toDouble();
        } else {
          expenseSum += (transaction['amount'] ?? 0).toDouble();
        }
      }

      if (mounted) {
        setState(() {
          // Existing state updates...
          totalTransactions = transactionsData.length;
          totalBudgets = budgetsCount.count ?? 0;
          totalIncome = incomeSum;
          totalExpenses = expenseSum;
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: ${e.toString()}")),
      );
      setState(() => isLoading = false);
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );

    // ✅ If `true` is returned, refresh the profile data
    if (result == true) {
      fetchUserProfile();
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Skeletonizer(
        enabled: isLoading,
        child: getBody(),
      ),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Background Image
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 160,
                  decoration: const BoxDecoration(
                    color: secondary1,
                    image: DecorationImage(
                      image: AssetImage("assets/images/prof-header.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -45,
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary1,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(5),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : const AssetImage(
                                      "assets/images/default_avatar.png")
                                  as ImageProvider,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 70),

          // ✅ Display User Name & Bio
          Text(
            fullName,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            bio,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 25),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatsCard(
                  "Transact",
                  totalTransactions.toString(),
                  Icons.swap_horiz_rounded,
                  secondary1,
                ),
                _buildStatsCard(
                  "Budgets",
                  totalBudgets.toString(),
                  Icons.account_balance_wallet,
                  secondary1,
                ),
                _buildStatsCard(
                  "Income",
                  "₱${totalIncome.toStringAsFixed(0)}",
                  Icons.arrow_upward,
                  secondary1,
                ),
                _buildStatsCard(
                  "Expenses",
                  "₱${totalExpenses.toStringAsFixed(0)}",
                  Icons.arrow_downward,
                  secondary1,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Continue with existing profile options...
          _buildOption(
            Icons.edit,
            "Edit Profile",
            _navigateToEditProfile,
          ),
          _buildOption(Icons.lock, "Change Password", () {
            _showChangePasswordDialog();
          }),
          _buildOption(Icons.home, "Change Address", () {
            _showChangeAddressDialog();
          }),
          _buildOption(Icons.info, "About Developers", () {
            _showAboutDevelopersDialog();
          }),

          const SizedBox(height: 30),

          // ✅ Log Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text("Sign Out", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // ✅ Rounded Corners
            border: Border.all(
                color: Colors.grey.withOpacity(0.3)), // ✅ Subtle Border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // ✅ Soft Shadow
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: secondary1.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: secondary1, size: 20),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.lock_reset_rounded,
                color: secondary1,
                size: 40,
              ),
              const SizedBox(height: 10),
              const Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Enter your old and new password",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Old Password",
                    hintText: "Enter your current password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: secondary1, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: secondary1),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    hintText: "Enter your new password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: secondary1, width: 2),
                    ),
                    prefixIcon:
                        Icon(Icons.lock_person_rounded, color: secondary1),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final oldPassword = oldPasswordController.text.trim();
                      final newPassword = newPasswordController.text.trim();

                      if (oldPassword.isEmpty || newPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill in all fields"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      try {
                        // Add your password update logic here
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Password updated successfully!"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Failed to update password: ${e.toString()}"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary1,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Update"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showChangeAddressDialog() {
    final TextEditingController addressController =
        TextEditingController(text: address);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.home_rounded,
                color: secondary1,
                size: 40,
              ),
              const SizedBox(height: 10),
              const Text(
                "Update Address",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Enter your new address below",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "New Address",
                hintText: "Enter your address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: secondary1, width: 2),
                ),
                prefixIcon: Icon(Icons.location_on, color: secondary1),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 2,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = supabase.auth.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User not logged in!")),
                        );
                        return;
                      }

                      final String newAddress = addressController.text.trim();
                      if (newAddress.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Address cannot be empty!")),
                        );
                        return;
                      }

                      try {
                        await supabase
                            .from('users')
                            .update({'address': newAddress}).eq('id', user.id);

                        setState(() => address = newAddress);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Address updated successfully!"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Failed to update address: ${e.toString()}"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary1,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Update"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAboutDevelopersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Image.asset(
                "assets/images/homespend - primaryLOGO.png",
                height: 60,
              ),
              const SizedBox(height: 20),
              Text(
                "homespend.",
                style: TextStyle(
                  color: secondary1,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Version 2.2.0",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                _buildInfoSection(
                  "Developer",
                  "Aldrei Araneta",
                  Icons.code,
                ),
                _buildInfoSection(
                  "Purpose",
                  "Budget Management Application",
                  Icons.lightbulb_outline,
                ),
                _buildInfoSection(
                  "Year",
                  "2025",
                  Icons.calendar_today,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: secondary1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "homespend. helps you track and manage your household expenses efficiently.",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Powered by",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      "assets/images/flutter - logo.png",
                      height: 20,
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      "assets/images/supabase - logo.png",
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(color: secondary1),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: secondary1.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: secondary1, size: 20),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      height: 100,
      width: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
