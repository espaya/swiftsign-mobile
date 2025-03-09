import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Auth extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
  bool isAuthenticated = false; // Track auth state

  Future<void> signIn(BuildContext context) async {
    const String apiUrl = 'http://192.168.0.100:8000/api/employee/sign-in';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Login successful: ${data['name']}');
        print('Login successful: ${data['id']}');

        // ✅ Save user data to SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'user',
          jsonEncode({
            'name': data['name'] ?? '',
            'email': data['email'] ?? '',
            'token': data['token'] ?? '',
            'id':
                data['id']?.toString() ?? '', // Convert ID to String for safety
          }),
        );

        // Debug: Retrieve immediately after storing
        print("✅ Saved User Data: ${prefs.getString('user')}");

        // Clear error message
        errorMessage = "";
        notifyListeners();

        // ✅ Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        errorMessage = data['message'] ?? "An error occurred";
        notifyListeners();
      }
    } catch (e) {
      errorMessage = "Server error. Please try again later. $e";
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      isAuthenticated = true;
      notifyListeners();

      // Redirect to Dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('user');

    isAuthenticated = false;
    notifyListeners();

    // Redirect to Login
    Navigator.pushReplacementNamed(context, '/login');
  }
}
