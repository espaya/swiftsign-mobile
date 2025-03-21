import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GetProfilePic {
  // Fetch the profile picture URL from the server
  Future<String?> fetchProfilePicture(String userId, BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.101:8000/api/employee/get-profile-pic/$userId'),
      );

      String message = "Unknown error occurred";
      bool isSuccess = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          message = data['message'] ?? "Profile picture fetched successfully";
          isSuccess = true;
          return data['image_url']; // Return the profile picture URL
        } else {
          message = data['message'] ?? "Failed to fetch profile picture";
        }
      } else if (response.statusCode == 404) {
        message = "User not found";
      } else if (response.statusCode == 500) {
        message = "Server error: Please try again later";
      } else {
        message = "Unexpected error: ${response.statusCode}";
      }

      // Show the response in a modal
      _showResponseModal(context, message, isSuccess);
    } catch (e) {
      print("Error fetching profile picture: $e");
      _showResponseModal(context, "An error occurred: $e", false);
    }
    return null; // Return null if the request fails
  }

  void _showResponseModal(BuildContext context, String message, bool isSuccess) {
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