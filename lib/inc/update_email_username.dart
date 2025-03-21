import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UpdateEmailUsername {
  // Update username and email via API
  static Future<void> updateUser({
    required String username,
    required String email,
    // required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the stored user data
    String? userData = prefs.getString('user');

    if (userData == null) {
      throw Exception("User data not found. Please log in again.");
    }

    // Decode the JSON string
    Map<String, dynamic> user = jsonDecode(userData);
    String? userId = user['id']; // Fetch user ID as a String

    if (userId == null || userId.isEmpty) {
      throw Exception("User ID is missing. Please log in again.");
    }

    const String url =
        'http://192.168.0.101:8000/employee/update-email-username';

    final Uri uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': username,
          'email': email,
          'userID': userId,
        }),
      );

      print("User ID in Update After Submission: $userId");

      if (response.statusCode == 200) {
        print('Update successful: ${response.body}');
      } else {
        throw Exception(
            'Failed to update user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
}
