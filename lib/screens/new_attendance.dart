import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:swift_mobile/screens/login_screen.dart';
import 'package:swift_mobile/uitls/my_appbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';

class NewAttendance extends StatefulWidget {
  const NewAttendance({super.key});

  @override
  State<NewAttendance> createState() => _NewAttendanceState();
}

class _NewAttendanceState extends State<NewAttendance> {
  bool _isScanningEnabled = false; // Flag to control scanning behavior
  bool _isCameraRunning = false; // Track if the camera is running
  bool _hasScanned = false; // Track if a scan has already been processed
  final List<String> _scannedCodes = []; // Store all scanned QR codes
  DateTime? _lastScanTime; // Track the time of the last scan

  @override
  void initState() {
    super.initState();
    checkCameraPermission();
  }

  Future<void> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isDenied) {
      showAlertDialog(context, "❌ Camera permission denied!");
    } else if (status.isPermanentlyDenied) {
      showAlertDialog(context,
          "⚠️ Camera permission permanently denied! Redirecting to settings...");
      openAppSettings();
    } else {
      showAlertDialog(context, "✅ Camera permission granted!");
    }
  }

  MobileScannerController cameraController = MobileScannerController();
  final String apiUrl =
      "http://192.168.0.101:8000/api/employee/log-attendance"; // Replace with actual API

  void processScannedCode(String scannedData) async {
    if (!_isScanningEnabled || _hasScanned) return;

    // Debouncing: Check if the same QR code was scanned recently
    if (_lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!) <
            const Duration(seconds: 1)) {
      return;
    }

    // Add the scanned code to the list
    setState(() {
      _scannedCodes.add(scannedData);
    });

    // Process only the first scan
    if (_scannedCodes.length == 1) {
      try {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 100);
        }

        String decodedString = utf8.decode(base64.decode(scannedData));

        Map<String, dynamic> jsonData = jsonDecode(decodedString);
        String sessionId = jsonData['session_id'];
        String timestamp = jsonData['timestamp'];
        String checkInAt = jsonData['check_in_at'];
        String checkoutAt = jsonData['checkout_at'];

        final prefs = await SharedPreferences.getInstance();
        String userID = prefs.getString('id').toString();

        await sendScannedDataToServer(
            sessionId, timestamp, checkInAt, checkoutAt);

        // Disable scanning after successful scan
        setState(() {
          _isScanningEnabled = false;
          _hasScanned = true;
          _lastScanTime = DateTime.now(); // Store the last scan time
        });

        // showSnackBar("✅ Attendance logged successfully!");
      } catch (e) {
        showAlertDialog(context, "❌ Error processing QR code: $e");
        handleInvalidData();
      }
    }
  }

  Future<void> sendScannedDataToServer(String sessionId, String timestamp,
      String checkInAt, String checkoutAt) async {
    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user');

      String userID = '';

      if (userData != null) {
        Map<String, dynamic> user = jsonDecode(userData);
        userID = user['id'].toString(); // ✅ Ensure it's a String
      } else {
        showAlertDialog(context, "❌ User data not found in SharedPreferences");
      }

      Map<String, dynamic> body = {
        "userID": userID,
        "session_id": sessionId,
        "logged_at": DateTime.now().toIso8601String(),
        "checkout_at": checkoutAt
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        showAlertDialog(context, responseData['message']);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String errorMessage = responseData.containsKey('message')
            ? responseData['message']
            : "Unknown error occurred.";

        showAlertDialog(context,
            "⚠️ Failed to send data. Status: ${response.statusCode}, Response: ${response.body}");

        // Displaying the 400 error
        if (response.statusCode == 400) {
          showAlertDialog(context, errorMessage); // Show message in UI
        } else if (response.statusCode == 422) {
          // Laravel validation errors
          if (responseData.containsKey('errors')) {
            String errorMessages = responseData['errors']
                .values
                .map((errorList) => errorList.join("\n"))
                .join("\n");

            showAlertDialog(context, "⚠️ $errorMessages");
          } else {
            showAlertDialog(context,
                "⚠️ Validation failed. Please check your input. ${response.body}");
          }
        } else {
          showAlertDialog(
              context, "⚠️ Failed to log attendance: $errorMessage");
        }
      }
    } catch (e) {
      showAlertDialog(context, "❌ Error sending data to server: $e");
    }
  }

  void handleInvalidData() {
    showAlertDialog(context, "⚠️ Invalid QR code format");
  }

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Alert",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
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
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(context),
      bottomNavigationBar: Container(
        color: Colors.transparent, // Remove white background
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
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
              onPressed: () async {
                if (_hasScanned) {
                  // If already scanned, reset the scanning state
                  setState(() {
                    _isScanningEnabled = true; // Enable scanning
                    _hasScanned = false; // Reset scan state
                    _scannedCodes.clear(); // Clear scanned codes
                    _lastScanTime = null; // Clear last scan time
                  });
                } else {
                  // If not scanned yet, start scanning
                  setState(() {
                    _isScanningEnabled = true; // Enable scanning
                    _hasScanned = false; // Reset scan state
                  });

                  if (!_isCameraRunning) {
                    await cameraController.start();
                    setState(() {
                      _isCameraRunning = true; // Camera is running
                    });
                  }
                }
              },
              icon: const Icon(
                Icons.qr_code,
                size: 40.0,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(15),
              splashRadius: 35,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(top: 100.0, left: 30.0, right: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Text(
                    "Scan QR Code",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                  child: Text(
                    "Please scan the QR Code to log your attendance for today",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0, right: 0, top: 0),
                child: SizedBox(
                  height: 320, // Set a finite height for the MobileScanner
                  child: Stack(
                    children: [
                      // MobileScanner
                      MobileScanner(
                        controller: cameraController,
                        fit: BoxFit.cover,
                        onScannerStarted: (arguments) {
                          setState(() {
                            _isCameraRunning = true; // Update camera state
                          });
                        },
                        onDetect: (capture) async {
                          if (!mounted || !_isScanningEnabled || _hasScanned) {
                            return; // Exit if scanning is disabled or a scan has already been processed
                          }
                          for (final barcode in capture.barcodes) {
                            if (barcode.rawValue != null) {
                              processScannedCode(barcode.rawValue!);
                              return; // Exit after processing the first scan
                            }
                          }
                        },
                      ),

                      // Top-left target
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _buildTargetCorner(top: true, left: true),
                      ),

                      // Top-right target
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _buildTargetCorner(top: true, right: true),
                      ),

                      // Bottom-left target
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: _buildTargetCorner(bottom: true, left: true),
                      ),

                      // Bottom-right target
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: _buildTargetCorner(bottom: true, right: true),
                      ),
                    ],
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

// Reusable method to build a target corner
Widget _buildTargetCorner(
    {bool top = false,
    bool bottom = false,
    bool left = false,
    bool right = false}) {
  return Container(
    width: 40, // Size of the target
    height: 40,
    decoration: BoxDecoration(
      border: Border(
        top: top ? BorderSide(color: Colors.white, width: 2) : BorderSide.none,
        left:
            left ? BorderSide(color: Colors.white, width: 2) : BorderSide.none,
        right:
            right ? BorderSide(color: Colors.white, width: 2) : BorderSide.none,
        bottom: bottom
            ? BorderSide(color: Colors.white, width: 2)
            : BorderSide.none,
      ),
    ),
  );
}
