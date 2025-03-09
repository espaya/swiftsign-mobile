import 'package:flutter/material.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isObscured = true; // toggle password visibility
  bool _isLoading = false; // track loading state

  @override
  void initState() {
    super.initState();
    Provider.of<Auth>(context, listen: false).checkLoginStatus(context);
  }

  Future<void> _signIn(BuildContext context) async {
    final auth = Provider.of<Auth>(context, listen: false);

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      await auth.signIn(context); // Call your authentication method
    } catch (e) {
      // Handle errors if needed
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(top: 30.0),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.purple])),
          child: Column(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/SwiftSign.png'))),
              ),
              const Text(
                "SIGN IN TO CONTINUE",
                style: TextStyle(fontSize: 20.0),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 0.0, left: 50.0, right: 50.0),
                child: Text(
                  textAlign: TextAlign.center,
                  auth.errorMessage.isNotEmpty ? auth.errorMessage : "",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 30, right: 30),
                child: Container(
                  width: 400.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ), // Padding inside
                  margin: const EdgeInsets.symmetric(
                      vertical: 10), // Margin outside
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color
                    borderRadius: BorderRadius.circular(50), // Rounded corners
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26, // Soft shadow
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(2, 4), // Shadow position
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: auth.emailController,
                    decoration: const InputDecoration(
                      hintText: "youremail@example.com",
                      hintStyle: TextStyle(color: Colors.black45),
                      border:
                          InputBorder.none, // No border (handled by Container)
                      prefixIcon: Icon(Icons.account_circle,
                          color: Colors.grey), // Optional icon
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15), // Adjust text position
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Container(
                  width: 400.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ), // Padding inside
                  margin: const EdgeInsets.symmetric(
                      vertical: 10), // Margin outside
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color
                    borderRadius: BorderRadius.circular(50), // Rounded corners
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26, // Soft shadow
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(2, 4), // Shadow position
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: auth.passwordController,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      hintText: "**********",
                      hintStyle: const TextStyle(color: Colors.black45),
                      border:
                          InputBorder.none, // No border (handled by Container)
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                        child: Icon(
                          _isObscured ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ), // Optional icon
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15), // Adjust text position
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 17),
                child: Container(
                  width: 200, // Increase width
                  height: 80, // Keep height same for round shape
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blueAccent,
                        Colors.purpleAccent
                      ], // Gradient colors
                      begin: Alignment.topLeft, // Start gradient
                      end: Alignment.bottomRight, // End gradient
                    ),
                    borderRadius: BorderRadius.circular(50), // Rounded corners
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: _isLoading
                          ? null
                          : () =>
                              _signIn(context), // Disable button when loading
                      icon: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white, // Match the loader color
                            )
                          : const Icon(
                              Icons.arrow_forward,
                              size: 40.0,
                              color: Colors.white,
                            ),
                      padding: const EdgeInsets.all(15), // Space around icon
                      splashRadius: 35, // Ripple effect size
                    ),
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
