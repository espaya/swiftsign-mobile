import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:swift_mobile/uitls/my_appbar.dart';

class UsernameEmailScreen extends StatefulWidget {
  const UsernameEmailScreen({super.key});

  @override
  State<UsernameEmailScreen> createState() => _UsernameEmailScreenState();
}

class _UsernameEmailScreenState extends State<UsernameEmailScreen> {
  // Controllers for the text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  bool _isInitialized = false;

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
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  border: Border.all(
                    color: Colors.grey[400]!, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15), // Inner padding
                  child: TextField(
                    controller: _usernameController, // Set controller
                    decoration: const InputDecoration(
                      hintText: "Username",
                      hintStyle: TextStyle(color: Colors.black45),
                      border: InputBorder.none, // Remove the default underline
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.grey, // Icon color
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Spacing between fields

              // Email Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  border: Border.all(
                    color: Colors.grey[400]!, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15), // Inner padding
                  child: TextField(
                    controller: _emailController, // Set controller
                    decoration: const InputDecoration(
                      hintText: "youremail@example.com",
                      hintStyle: TextStyle(color: Colors.black45),
                      border: InputBorder.none, // Remove the default underline
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.grey, // Icon color
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Spacing between fields

              // Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  border: Border.all(
                    color: Colors.grey[400]!, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15), // Inner padding
                  child: TextField(
                    controller: _passwordController, // Set controller
                    obscureText: true, // Hide password text
                    decoration: const InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.black45),
                      border: InputBorder.none, // Remove the default underline
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.grey, // Icon color
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Spacing between fields

              // Repeat Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  border: Border.all(
                    color: Colors.grey[400]!, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15), // Inner padding
                  child: TextField(
                    controller: _repeatPasswordController, // Set controller
                    obscureText: true, // Hide password text
                    decoration: const InputDecoration(
                      hintText: "Repeat Password",
                      hintStyle: TextStyle(color: Colors.black45),
                      border: InputBorder.none, // Remove the default underline
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.grey, // Icon color
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Spacing before the button

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  // Handle form submission
                  final username = _usernameController.text;
                  final email = _emailController.text;
                  final password = _passwordController.text;
                  final repeatPassword = _repeatPasswordController.text;

                  // Validate the form
                  if (username.isEmpty ||
                      email.isEmpty ||
                      password.isEmpty ||
                      repeatPassword.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill in all fields"),
                      ),
                    );
                  } else if (password != repeatPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Passwords do not match"),
                      ),
                    );
                  } else {
                    // Perform form submission
                    print("Username: $username");
                    print("Email: $email");
                    print("Password: $password");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Button color
                  minimumSize: const Size(double.infinity, 50), // Full width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: const Text(
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
}
