import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmedia_project/services/cloudinary_service.dart';
import 'package:socialmedia_project/widgets/button_widget.dart';

class Postpage extends StatefulWidget {
  final VoidCallback onPublished;
  const Postpage({super.key, required this.onPublished});

  @override
  State<Postpage> createState() => _PostpageState();
}

class _PostpageState extends State<Postpage> {
  final descriptioncontroller = TextEditingController();
  final imagecontroller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
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
    if (selectedImage == null) return null;
    try {
      setState(() {
        isUploading = true;
      });
      final url = await CloudinaryService.uploadImage(selectedImage!);
      return url;
    } catch (e) {
      debugPrint('Cloudinary upload error:$e');
      return null;
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  bool isPublishing = false;

  Future<void> createpost() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a photo')));
      return;
    }

    if (isPublishing) return;

    setState(() {
      isPublishing = true;
    });

    try {
      String? uploadedUrl = await uploadImage();

      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        throw Exception('Image upload failed');
      }

      String uid = FirebaseAuth.instance.currentUser!.uid;

      await _firestore.collection('posts').add({
        'uid': uid,
        'image_url': uploadedUrl,
        'content': descriptioncontroller.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'reshareCount': 0,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Post published successfully!')));

      descriptioncontroller.clear();

      setState(() {
        selectedImage = null;
        imageUrl = null;
      });

      widget.onPublished();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to publish: $e')));

      debugPrint('POST ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          isPublishing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    descriptioncontroller.dispose();
    imagecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Create Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.photo_library_outlined, color: Colors.white),

                      SizedBox(width: 10),

                      Text(
                        'Add Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),

                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(selectedImage!.path),
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.white,
                                  size: 55,
                                ),

                                SizedBox(height: 12),

                                Text(
                                  'Select a photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  'Tap here to choose from gallery',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 22),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_outlined, color: Colors.white),

                      SizedBox(width: 10),

                      Text(
                        'Write a caption',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  TextField(
                    controller: descriptioncontroller,
                    maxLines: 5,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Write something about your post...',
                      hintStyle: TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Color(0xFF292929),
                      contentPadding: EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 60,

              child: ButtonWidget(
                text: isPublishing ? "Publishing..." : "Publish",
                backgroundColor: Colors.orange.shade600,
                textColor: Colors.white,
                onPressed: () {
                  if (!isPublishing) {
                    createpost();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
