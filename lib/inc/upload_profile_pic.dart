import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class UploadProfilePic {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String?> uploadImage(
      File imageFile, String userId, BuildContext context) async {
    try {
      var uri = Uri.parse(
          "http://192.168.0.100:8000/api/employee/update-profile-picture");
      var request = http.MultipartRequest("POST", uri);
      request.fields['userID'] = userId;

      var mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      var fileStream = http.MultipartFile(
        'img',
        imageFile.readAsBytes().asStream(),
        imageFile.lengthSync(),
        filename: basename(imageFile.path),
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(fileStream);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      String message = "Unknown error occurred";
      bool isSuccess = false;

      switch (response.statusCode) {
        case 200:
          message = data['message'] ?? "Profile picture updated successfully";
          isSuccess = true;
          return data['image_url']; // Return the new image URL
        case 422:
          message = data['message'] ?? "Validation error: Invalid data";
          break;
        case 404:
          message = data['message'] ?? "User not found";
          break;
        case 500:
          message = data['message'] ?? "Server error: Please try again later";
          break;
        default:
          message = "Unexpected error occurred";
      }

      // Show the response in a modal
      _showResponseModal(context, message, isSuccess);
    } catch (e) {
      print("Error uploading image: $e");
      _showResponseModal(context, "An error occurred: $e", false);
    }
    return null; // Return null if the request fails
  }

  void _showResponseModal(
      BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isSuccess ? "Success" : "Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
