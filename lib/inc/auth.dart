import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Auth extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
  bool isAuthenticated = false; // Track auth state
  Map<String, dynamic>? _user; // Store user data

  // Getter for user data
  Map<String, dynamic>? get user => _user;

  Future<void> signIn(BuildContext context) async {
    const String apiUrl = 'http://192.168.0.101:8000/api/employee/sign-in';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Login successful: ${data['name']}');
        print('Login successful: ${data['id']}');

        // Save user data to SharedPreferences
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

        // Update the user property
        _user = {
          'name': data['name'],
          'email': data['email'],
          'token': data['token'],
          'id': data['id']?.toString(),
        };

        // Clear error message
        errorMessage = "";
        isAuthenticated = true;
        notifyListeners();

        // Navigate to dashboard
        Navigator.of(context).pushNamed('/dashboard');
      } else {
        errorMessage = data['message'] ?? "An error occurred";
        notifyListeners();
      }
    } catch (e) {
      errorMessage = "Server error. Please try again later. $e";
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');

    if (userJson != null) {
      final Map<String, dynamic> userData = jsonDecode(userJson);
      _user = userData;
      isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');

    _user = null;
    isAuthenticated = false;
    notifyListeners();

    // Redirect to Login
    Navigator.of(context).pushNamed('/login');
  }

  Future<String?> fetchProfilePicture(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.0.101:8000/api/employee/get-profile-pic/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print(data['image_url']);
          return data['image_url']; // Return the profile picture URL
        }
      }
      return null; // Return null if the request fails
    } catch (e) {
      print("Error fetching profile picture: $e");
      return null;
    }
  }
}
