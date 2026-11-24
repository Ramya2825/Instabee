import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmedia_project/widgets/button_widget.dart';

import '../services/cloudinary_service.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;

  const EditProfilePage({super.key, required this.uid});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();

  TextEditingController usernameController = TextEditingController();

  TextEditingController bioController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  final ImagePicker picker = ImagePicker();
  XFile? selectedImage;
  String? imageUrl;
  bool isUploading = false;

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        selectedImage = XFile(image.path);
        imageUrl = null;
      });
    }
  }

  Future<String?> uploadImage() async {
    if (selectedImage == null) return imageUrl;
    setState(() {
      isLoading = true;
    });
    try {
      final url = await CloudinaryService.uploadImage(selectedImage!);
      return url;
    } catch (e) {
      debugPrint('Cloudinary upload error');
    } finally {
      if (mounted) {
        setState(() {
          isUploading = true;
        });
      }
    }
  }

  Future<void> getUserData() async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        var user = userDoc.data() as Map<String, dynamic>;
        nameController.text = user['name'] ?? '';
        usernameController.text = user['username'] ?? user['user_name'] ?? '';
        bioController.text = user['bio'] ?? '';

        imageUrl = user['profile_url'] ?? '';
      }
    } catch (e) {
      debugPrint('Error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> saveProfile() async {
    String name = nameController.text;
    String username = usernameController.text;
    String bio = bioController.text;

    if (name.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Name and username required')));
      return;
    }
    setState(() {
      isSaving = true;
    });
    try {
      String? uploadedUrl = await uploadImage();
      await _firestore.collection('users').doc(widget.uid).set({
        'name': name,
        'username': username,
        'bio': bio,
        'profile_url': uploadedUrl,
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile update failed')));
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: selectedImage != null
                          ? FileImage(File(selectedImage!.path))
                          : imageUrl != null && imageUrl!.isNotEmpty
                          ? NetworkImage(imageUrl!)
                          : null,
                      child:
                          selectedImage == null &&
                              (imageUrl == null || imageUrl!.isEmpty)
                          ? Icon(Icons.person, size: 65, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          onPressed: isSaving ? null : pickImage,

                          icon: Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),

              SizedBox(height: 8),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 15),

              Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),

              SizedBox(height: 8),

              TextField(
                controller: usernameController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Username',
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 15),

              Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),

              SizedBox(height: 8),

              TextField(
                controller: bioController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Write something about yourself',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                child: ButtonWidget(
                  text: "Save Changes",
                  onPressed: () {
                    if (!isSaving) saveProfile();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
