// ignore_for_file: deprecated_member_use

import 'dart:typed_data';
import 'package:araneta_HBA_it14/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  bool isLoading = true;
  String email = "";
  String profileImage = "";
  Uint8List? profileImageBytes;
  String? imageName;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // Fetch User Profile Data
  Future<void> fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User is not logged in!"),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating, // Makes it float above UI
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)), // Rounded corners
          margin: EdgeInsets.symmetric(
              horizontal: 20, vertical: 10), // Margin from edges
        ),
      );
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select('full_name, email, profile_image, bio')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No profile found. Please update your details."),
            backgroundColor: red,
            behavior: SnackBarBehavior.floating, // Makes it float above UI
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)), // Rounded corners
            margin: EdgeInsets.symmetric(
                horizontal: 20, vertical: 10), // Margin from edges
          ),
        );
        return;
      }

      final String newImageUrl = supabase.storage
          .from('profile_pictures')
          .getPublicUrl('profiles/${user.id}.jpg');

      setState(() {
        fullNameController.text = response['full_name'] ?? "Unknown User";
        bioController.text = response['bio'] ?? "No bio available";
        email = response['email'] ?? "No Email";
        profileImage = response['profile_image'] ?? newImageUrl;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load profile: ${e.toString()}"),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating, // Makes it float above UI
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)), // Rounded corners
          margin: EdgeInsets.symmetric(
              horizontal: 20, vertical: 10), // Margin from edges
        ),
      );
      setState(() => isLoading = false);
    }
  }

  // Pick and Upload Profile Image
  Future<void> pickAndUploadImage() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      final String filePath = 'profiles/${user.id}.jpg';

      setState(() {
        profileImageBytes = bytes;
        imageName = pickedFile.name;
      });

      try {
        await supabase.storage.from('profile_pictures').uploadBinary(
              filePath,
              profileImageBytes!,
              fileOptions: const FileOptions(upsert: true),
            );

        final String newImageUrl =
            supabase.storage.from('profile_pictures').getPublicUrl(filePath);

        await supabase.from('storage.objects').update(
            {'owner': supabase.auth.currentUser!.id}).eq('name', filePath);

        setState(() {
          profileImage = newImageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile picture updated successfully!"),
            backgroundColor: green,
            behavior: SnackBarBehavior.floating, // Makes it float above UI
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)), // Rounded corners
            margin: EdgeInsets.symmetric(
                horizontal: 20, vertical: 10), // Margin from edges
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image Upload Failed: ${e.toString()}"),
            backgroundColor: red,
            behavior: SnackBarBehavior.floating, // Makes it float above UI
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)), // Rounded corners
            margin: EdgeInsets.symmetric(
                horizontal: 20, vertical: 10), // Margin from edges
          ),
        );
      }
    }
  }

  // Update User Profile (Full Name & Bio)
  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final String newFullName = fullNameController.text.trim();
    final String newBio = bioController.text.trim();

    if (newFullName.isEmpty || newBio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fields cannot be empty!"),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
      return;
    }

    try {
      await supabase
          .from('users')
          .update({'full_name': newFullName, 'bio': newBio}).eq('id', user.id);

      setState(() {
        fullNameController.text = newFullName;
        bioController.text = newBio;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );

      // ✅ Pass back `true` to indicate an update was made
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: ${e.toString()}"),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.1),
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: white)),
        backgroundColor: secondary1,
        elevation: 6,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primary),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Image with Edit Button
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: secondary1,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : const AssetImage(
                                      "assets/images/default_avatar.png")
                                  as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: pickAndUploadImage,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: secondary1,
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Full Name Input
                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bio Input
                  TextFormField(
                    controller: bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Bio",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email (Non-editable)
                  TextFormField(
                    initialValue: email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Changes Button
                  ElevatedButton(
                    onPressed: updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary1,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }
}
