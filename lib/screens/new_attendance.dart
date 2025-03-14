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
  List<String> _scannedCodes = []; // Store all scanned QR codes
  DateTime? _lastScanTime; // Track the time of the last scan

  @override
  void initState() {
    super.initState();
    checkCameraPermission();
  }

  Future<void> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isDenied) {
      print("❌ Camera permission denied!");
    } else if (status.isPermanentlyDenied) {
      print(
          "⚠️ Camera permission permanently denied! Redirecting to settings...");
      openAppSettings();
    } else {
      print("✅ Camera permission granted!");
    }
  }

  MobileScannerController cameraController = MobileScannerController();
  final String apiUrl =
      "http://192.168.0.100:8000/api/employee/log-attendance"; // Replace with actual API

  void processScannedCode(String scannedData) async {
    if (!_isScanningEnabled || _hasScanned) return;

    // Debouncing: Check if the same QR code was scanned recently
    if (_lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!) <
            const Duration(seconds: 1)) {
      print("🔄 Ignoring duplicate scan: $scannedData");
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
        print("✅ Decoded Data: $decodedString");

        Map<String, dynamic> jsonData = jsonDecode(decodedString);
        String sessionId = jsonData['session_id'];
        String timestamp = jsonData['timestamp'];
        String expiresAt = jsonData['expires_at'];
        String checkoutAt = jsonData['checkout_at'];

        print("🆔 Session ID: $sessionId");
        print("⏳ Timestamp: $timestamp");

        final prefs = await SharedPreferences.getInstance();
        String userID = prefs.getString('id').toString();

        print("User ID: $userID");

        await sendScannedDataToServer(
            sessionId, timestamp, expiresAt, checkoutAt);

        // Disable scanning after successful scan
        setState(() {
          _isScanningEnabled = false;
          _hasScanned = true;
          _lastScanTime = DateTime.now(); // Store the last scan time
        });

        // showSnackBar("✅ Attendance logged successfully!");
      } catch (e) {
        print("❌ Error processing QR code: $e");
        handleInvalidData();
      }
    } else {
      print("🔄 Ignoring subsequent scan: $scannedData");
    }
  }

  Future<void> sendScannedDataToServer(String sessionId, String timestamp,
      String expiresAt, String checkoutAt) async {
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
        print("Retrieved UserID: $userID");
      } else {
        print("❌ User data not found in SharedPreferences");
      }

      print("User ID: $userID");

      Map<String, dynamic> body = {
        "session_id": sessionId,
        "logged_at": DateTime.now().toIso8601String(),
        "userID": userID,
        "expires_at": expiresAt
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ Successfully logged attendance: ${response.body}");
        Map<String, dynamic> responseData = jsonDecode(response.body);
        showSnackBar(responseData['message']);
      } else {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String errorMessage = responseData.containsKey('message')
            ? responseData['message']
            : "Unknown error occurred.";

        print(
            "⚠️ Failed to send data. Status: ${response.statusCode}, Response: ${response.body}");

        // Displaying the 400 error
        if (response.statusCode == 400) {
          showSnackBar(errorMessage); // Show message in UI
        } else if (response.statusCode == 422) {
          // Laravel validation errors
          if (responseData.containsKey('errors')) {
            String errorMessages = responseData['errors']
                .values
                .map((errorList) => errorList.join("\n"))
                .join("\n");

            print("⚠️ Validation Errors: $errorMessages");
            showSnackBar("⚠️ $errorMessages");
          } else {
            print("⚠️ Unexpected validation error format: ${response.body}");
            showSnackBar("⚠️ Validation failed. Please check your input.");
          }
        } else {
          showSnackBar("⚠️ Failed to log attendance: $errorMessage");
        }
      }
    } catch (e) {
      print("❌ Error sending data to server: $e");
      showSnackBar("❌ Error connecting to server!");
    }
  }

  void handleInvalidData() {
    showSnackBar("⚠️ Invalid QR code format");
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10),
      ),
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
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(top: 100.0, left: 30.0, right: 30.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Colors.purple],
            ),
          ),
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
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: SizedBox(
                  height: 250, // Set a finite height for the MobileScanner
                  child: MobileScanner(
                    controller: cameraController,
                    fit: BoxFit.cover,
                    onScannerStarted: (arguments) {
                      print("📷 Camera is ready");
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
            ],
          ),
        ),
      ),
    );
  }
}
