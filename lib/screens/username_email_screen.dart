import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:swift_mobile/inc/update_email_username.dart';
import 'package:swift_mobile/uitls/my_appbar.dart';

class UsernameEmailScreen extends StatefulWidget {
  final int userId; // Add userId as a parameter
  const UsernameEmailScreen({super.key, required this.userId});

  @override
  State<UsernameEmailScreen> createState() => _UsernameEmailScreenState();
}

class _UsernameEmailScreenState extends State<UsernameEmailScreen> {
  // Controllers for the text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (!_isInitialized) {
      Future.microtask(() {
        final auth = Provider.of<Auth>(context, listen: false);
        print('Auth user: ${auth.user}'); // Debug statement
        if (auth.user != null) {
          setState(() {
            _usernameController.text = auth.user!['name'] ?? "";
            _emailController.text = auth.user!['email'] ?? "";
            _isInitialized = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is removed
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Handle form submission
  Future<void> _submitForm() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    // Validate the form
    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Please fill in all fields"),
        ),
      );
      return;
    }

    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Please enter a valid email address"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the update method
      await UpdateEmailUsername.updateUser(
        // userId: widget.userId, // Pass the userId from the widget
        username: username,
        email: email,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Update successful!"),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text("Failed to update: ${e.toString()}"),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 50, right: 50, top: 30), // Add padding around the form
          child: Column(
            children: [
              // Username Field
              _buildTextField(
                controller: _usernameController,
                hintText: "Username",
                icon: Icons.person,
              ),
              const SizedBox(height: 20), // Spacing between fields

              // Email Field
              _buildTextField(
                controller: _emailController,
                hintText: "youremail@example.com",
                icon: Icons.email,
              ),
              const SizedBox(height: 20), // Spacing between fields

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Button color
                  minimumSize: const Size(double.infinity, 50), // Full width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200], // Light grey background
        borderRadius: BorderRadius.circular(10), // Rounded corners
        border: Border.all(
          color: Colors.grey[400]!, // Border color
          width: 1, // Border width
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15), // Inner padding
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black45),
            border: InputBorder.none, // Remove the default underline
            prefixIcon: Icon(
              icon,
              color: Colors.grey, // Icon color
            ),
          ),
        ),
      ),
    );
  }
}
