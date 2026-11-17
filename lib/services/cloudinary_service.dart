import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {

  static String cloudName = 'z9gu9oqb';
  static String uploadPreset = 'instabee';
  static Future<String?> uploadImage(XFile image) async {

    try {
      var url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      var request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return data['secure_url'];
      } else {
         throw Exception(
          data['error']?['message'] ?? 'Cloudinary upload failed',
         );
      }

    } catch (e) {
       throw Exception('Image upload error: $e');
    }
  }
}
