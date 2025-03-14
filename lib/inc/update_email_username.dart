import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateEmailUsername {
  // Update username and email via API
  static Future<void> updateUser({
    required int userId,
    required String username,
    required String email,
  }) async {
    const String baseUrl =
        'https://192.168.0.100:8000'; // Replace with your API base URL
    final String endpoint = '/employee/update-email-username/$userId';

    final Uri uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers (e.g., authorization token) if needed
        },
        body: jsonEncode({
          'name': username,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        // Success
        print('Update successful: ${response.body}');
      } else {
        // Handle API errors
        throw Exception(
            'Failed to update user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle network errors
      throw Exception('Failed to update user: $e');
    }
  }
}
