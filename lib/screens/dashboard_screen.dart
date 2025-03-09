import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swift_mobile/uitls/my_appbar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String userName = ""; // Store user name
  String email = ""; // Store user email

  @override
  void initState() {
    super.initState();
    loadUserData(); // Load data when screen initializes
  }

  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user'); // Retrieve user data

    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData); // Convert JSON to Map

      setState(() {
        userName = user['name'] ?? "User"; // Set user name
        email = user['email'] ?? "No email"; // Set email
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(context),
      drawer: const Drawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Welcome, $userName",
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              // const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Text(
                  "Email: $email",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.purple,
                            Colors.blue
                          ], // Purple to Blue gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed('/new-attendance');
                              },
                              child: const Icon(
                                Icons.qr_code,
                                size: 90,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(), // Pushes containers apart
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.blue], // Same gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed('/attendance-history');
                              },
                              child: const Icon(
                                Icons.history,
                                size: 90,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
