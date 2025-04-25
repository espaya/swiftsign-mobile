import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:swift_mobile/inc/get_profile_pic.dart';
import 'package:swift_mobile/screens/login_screen.dart';
import 'package:swift_mobile/uitls/my_appbar.dart';
import 'package:swift_mobile/uitls/my_list_view.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String userName = ""; // Store user name
  String email = ""; // Store user email

  Auth auth = Auth();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load data when screen initializes
  }

  Future<void> _loadUserData() async {
    final auth = Provider.of<Auth>(context, listen: false);
    if (auth.user != null) {
      setState(() {
        userName = auth.user!['name'] ?? "User";
        email = auth.user!['email'] ?? "user@example.com";
      });

      // Fetch the profile picture URL
      String? userId = auth.user!['id'];
      if (userId != null) {
        GetProfilePic getProfilePic = GetProfilePic();
        String? imageUrl =
            await getProfilePic.fetchProfilePicture(userId, context);
        if (imageUrl != null) {
          setState(() {
// Update the profile picture URL
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);

    // Redirect to Login if the user is not logged in
    if (auth.user == null || auth.user!['id'] == null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      });
    }
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: MyAppBar(context),
      // drawer: const Drawer(),
      // bottomNavigationBar:  const BottomAppBar(
      //   child: Row(
      //     children: [Icon(Icons.home)],
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 0),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.3), // Shadow color
                            blurRadius: 10, // Softness of shadow
                            spreadRadius: 3, // Spread distance
                            offset: const Offset(
                                4, 6), // Horizontal and vertical shadow offset
                          ),
                        ],
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
                                color: Colors.white, // Make icon more visible
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.3), // Shadow color
                            blurRadius: 10, // Softness of shadow
                            spreadRadius: 3, // Spread distance
                            offset: const Offset(
                                4, 6), // Horizontal and vertical shadow offset
                          ),
                        ],
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
                                color: Colors.white, // Make icon more visible
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Attendance",
                      style: TextStyle(color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/attendance-history');
                      },
                      child: const Text(
                        "See All",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // margin: const EdgeInsets.only(top: 5.0),
                padding: EdgeInsets.only(top: 10, bottom: 10),
                height: MediaQuery.of(context).size.height / 0.5,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(35), // Apply border radius to child
                  child: const MyListView(itemCount: 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
