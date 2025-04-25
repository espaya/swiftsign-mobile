import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:swift_mobile/inc/get_profile_pic.dart';
import 'package:swift_mobile/inc/upload_profile_pic.dart';
import 'package:swift_mobile/screens/login_screen.dart';
import 'package:swift_mobile/uitls/my_appbar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _name = "User"; // Default name
  String _email = "user@example.com"; // Default email
  String? _profileImageUrl; // Store the profile picture URL
  bool _isUploading = false; // Track upload state

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final auth = Provider.of<Auth>(context, listen: false);
    if (auth.user != null) {
      setState(() {
        _name = auth.user!['name'] ?? "User";
        _email = auth.user!['email'] ?? "user@example.com";
      });

      // Fetch the profile picture URL
      String? userId = auth.user!['id'];
      if (userId != null) {
        String? imageUrl = await auth.fetchProfilePicture(userId);
        if (imageUrl != null) {
          setState(() {
            _profileImageUrl = imageUrl; // Update the profile picture URL
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
      appBar: MyAppBar(context),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
        child: ElevatedButton(
          onPressed: () {
            // Action when button is pressed
            Navigator.of(context).pushNamed('/username-email');
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.purple),
            minimumSize: WidgetStateProperty.all(const Size(300, 70)),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            )),
          ),
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor:
                          Colors.grey[300], // Optional background color
                      child: ClipOval(
                        child: _profileImageUrl != null
                            ? Image.network(
                                _profileImageUrl!, // Use the profile picture URL
                                fit: BoxFit.cover,
                                width: 120, // Match the diameter (2 * radius)
                                height: 120,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print("Error loading image: $error");
                                  return Image.asset(
                                    'images/Sample_User_Icon.png', // Fallback to default image
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  );
                                },
                              )
                            : Image.asset(
                                'images/Sample_User_Icon.png', // Default asset image
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          if (_isUploading) return; // Prevent multiple uploads

                          UploadProfilePic uploader = UploadProfilePic();
                          File? imageFile = await uploader.pickImage();

                          if (imageFile != null) {
                            String? userId = auth.user!['id'];
                            if (userId != null) {
                              setState(() {
                                _isUploading = true; // Show loader
                              });

                              try {
                                // Step 1: Upload the new profile picture
                                String? imageUrl = await uploader.uploadImage(
                                    imageFile, userId, context);
                                if (imageUrl != null) {
                                  // Step 2: Fetch the updated profile picture URL
                                  GetProfilePic getProfilePic = GetProfilePic();
                                  String? updatedImageUrl = await getProfilePic
                                      .fetchProfilePicture(userId, context);
                                  if (updatedImageUrl != null) {
                                    setState(() {
                                      _profileImageUrl =
                                          updatedImageUrl; // Update the profile picture URL
                                    });
                                  }
                                }
                              } catch (e) {
                                print("Error uploading image: $e");
                              } finally {
                                setState(() {
                                  _isUploading = false; // Hide loader
                                });
                              }
                            } else {
                              print("User ID not found in SharedPreferences");
                            }
                          }
                        },
                        child: _isUploading
                            ? const CircularProgressIndicator(
                                color: Colors.purple,
                              )
                            : Container(
                                height: 37,
                                width: 37,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.black,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              _name,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              _email,
              style: const TextStyle(color: Colors.black54),
            ),
            Container(
              margin: const EdgeInsets.only(top: 25.0),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      "Username",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      _name,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text(
                      "Email",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      _email,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    onTap: () {},
                    title: const Text(
                      "Reset Password",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: Colors.black54,
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
