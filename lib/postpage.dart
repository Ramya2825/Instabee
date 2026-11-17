import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
          isUploading = false;
        });
      }
    }
  }

  Future<void> createpost() async {
    String? uploadedUrl = await uploadImage();

    await FirebaseFirestore.instance.collection('posts').add({
      'image_url': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'reshareCount': 0,
    });
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
      backgroundColor: const Color(0xFF101010),

      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        centerTitle: true,
        title: const Text(
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                      ),

                      const SizedBox(width: 10),

                      const Text(
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
                                const Icon(
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
                      hintStyle: const TextStyle(color: Colors.white38),
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
                text: "Publish",
                backgroundColor: Colors.blueGrey,
                onPressed: () {
                  widget.onPublished();
                  createpost;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
