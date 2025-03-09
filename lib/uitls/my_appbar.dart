import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
AppBar MyAppBar(BuildContext context) {
  return AppBar(
    toolbarHeight: 70,
    backgroundColor: Colors.transparent,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 0, top: 0), // Apply padding here
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/account');
          },
          child: Container(
            margin: const EdgeInsets.all(8), // Add some margin around the image
            width: 35, // Adjust width
            height: 35, // Adjust height
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Make it circular
              border: Border.all(
                  color: Colors.transparent, width: 2), // Add a white border
              image: const DecorationImage(
                image: AssetImage(
                    "images/Sample_User_Icon.png"), // Change to your image path
                fit: BoxFit.cover, // Ensure the image fits well
              ),
            ),
          ),
        ),
      ),
    ],
    title: const Text(""),
    centerTitle: true,
  );
}
