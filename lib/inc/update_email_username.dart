import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart';
import 'package:swift_mobile/inc/auth.dart'; // For parsing HTML

class UpdateEmailUsername {
  static Future<Map<String, dynamic>> updateUser({
    required String username,
    required String email,
    required BuildContext context,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');

      if (userData == null) {
        Navigator.pop(context);
        _showErrorDialog(context, "User data not found. Please log in again.");
        throw Exception("User data not found");
      }

      final user = jsonDecode(userData) as Map<String, dynamic>;
      final userId = user['id']?.toString();

      if (userId == null || userId.isEmpty) {
        Navigator.pop(context);
        _showErrorDialog(context, "User ID is missing. Please log in again.");
        throw Exception("User ID is missing");
      }

      final response = await http
          .post(
            Uri.parse(
                'http://192.168.0.101:8000/api/employee/update-email-username/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': username,
              'email': email,
              'userID': userId, // ✅ Not needed since ID is in URL
            }),
          )
          .timeout(const Duration(seconds: 30));

      Navigator.pop(context); // Close loading dialog

      final responseBody = response.body;

      // Try parsing JSON
      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(responseBody);
      } catch (_) {
        // Handle non-JSON responses
        final errorMsg =
            _parseHtmlError(responseBody) ?? 'Unexpected server response';
        _showErrorDialog(context, errorMsg);
        throw HttpException(errorMsg, statusCode: response.statusCode);
      }

      if (response.statusCode == 200) {
        final message = responseData['message']?.toString().toLowerCase() ?? "";

        if (message.contains("no changes")) {
          _showSuccessDialog(context, responseData['message']);
          return user; // or throw if you want to handle this as an error
        }

        _showSuccessDialog(context,
            responseData['message'] ?? "Profile updated successfully!");

        // Wait 5 seconds then logout
        Future.delayed(const Duration(seconds: 5), () {
          Auth auth = Auth();
          auth.logout(context);
        });

        return user;
      }

      // Handle validation (422), not found (404), server error (500), etc.
      String errorMsg = responseData['message'] ?? 'An error occurred';

      // Special handling for validation errors
      if (response.statusCode == 422 && responseData.containsKey('errors')) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        errorMsg = errors.entries
            .map((e) => "${e.key}: ${(e.value as List).join(', ')}")
            .join('\n');
      }

      _showErrorDialog(context, errorMsg);
      throw HttpException(errorMsg, statusCode: response.statusCode);
    } on TimeoutException {
      Navigator.pop(context);
      _showErrorDialog(context, "Request timed out. Please try again.");
      throw Exception("Request timed out");
    } on http.ClientException catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, "Network error: ${e.message}");
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(
          context, "An unexpected error occurred: ${e.toString()}");
      debugPrint("Update error: ${e.toString()}");
      throw Exception("Update failed: ${e.toString()}");
    }
  }



  // ✅ Now static and simplified HTML error extractor
  static String? _parseHtmlError(String htmlBody) {
    try {
      final document = parse(htmlBody);
      final title = document.querySelector('title')?.text;
      final h1 = document.querySelector('h1')?.text;
      final bodyText = document.body?.text.trim();
      return title ?? h1 ?? bodyText ?? null;
    } catch (_) {
      return null;
    }
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  static void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

class HttpException implements Exception {
  final String message;
  final int? statusCode;

  HttpException(this.message, {this.statusCode});

  @override
  String toString() => 'HttpException: $message (Status code: $statusCode)';
}
