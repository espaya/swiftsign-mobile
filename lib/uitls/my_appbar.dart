import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:swift_mobile/inc/get_profile_pic.dart'; // Import the GetProfilePic class

// ignore: non_constant_identifier_names
AppBar MyAppBar(BuildContext context) {
  final auth =
      Provider.of<Auth>(context); // Access the Auth class using Provider

  // Fetch the profile picture URL using GetProfilePic
  return AppBar(
    toolbarHeight: 70,
    backgroundColor: Colors.transparent,
    leading: GestureDetector(
      onTap: () {
        _showLogoutConfirmationDialog(
            context, auth); // Show confirmation dialog
      },
      child: Container(
        color: Colors.transparent,
        child: const Icon(Icons.logout),
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 0, top: 0), // Apply padding here
        child: FutureBuilder<String?>(
          future: _fetchProfilePicture(
              auth, context), // Fetch the profile picture URL
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while fetching the image URL
              return const CircularProgressIndicator(
                color: Colors.white,
              );
            } else if (snapshot.hasError) {
              // Show an error icon if the fetch fails
              return const Icon(Icons.error, color: Colors.red);
            } else {
              // Use the fetched image URL or fallback to the default image
              String? profileImageUrl = snapshot.data;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/account'); // Navigate to account screen
                },
                child: Container(
                  margin: const EdgeInsets.all(
                      8), // Add some margin around the image
                  width: 35, // Adjust width
                  height: 35, // Adjust height
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Make it circular
                    border: Border.all(
                        color: Colors.transparent, width: 2), // Add a border
                    image: DecorationImage(
                      image: profileImageUrl != null
                          ? NetworkImage(
                              profileImageUrl) // Use the profile picture URL
                          : const AssetImage("images/Sample_User_Icon.png")
                              as ImageProvider, // Fallback to default image
                      fit: BoxFit.cover, // Ensure the image fits well
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    ],
    title: const Text(""),
    centerTitle: true,
  );
}

// Helper function to fetch the profile picture URL
Future<String?> _fetchProfilePicture(Auth auth, BuildContext context) async {
  if (auth.user != null && auth.user!['id'] != null) {
    GetProfilePic getProfilePic = GetProfilePic();
    return await getProfilePic.fetchProfilePicture(auth.user!['id'], context);
  }
  return null;
}

//  Helper function to show the logout confirmation dialog
void _showLogoutConfirmationDialog(BuildContext context, Auth auth) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout of your account?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              auth.logout(context); // Proceed with logout
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
