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

    await _firestore.collection('posts').add({
      'image_url': uploadedUrl,
      'createdAt': FieldValue.serverTimestamp(),
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
      appBar: AppBar(title: Center(child: Text("New Posts"))),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Share photos and videos on Instagram.'),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.network(
                        imageUrl ?? '',
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: descriptioncontroller,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: 'Write something about your post...',
                    ),
                  ),

                  SizedBox(height: 15),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  createpost();
                  widget.onPublished();
                },
                child: ButtonWidget(text: "Publish", onPressed: () {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
