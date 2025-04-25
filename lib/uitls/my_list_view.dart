import 'package:flutter/material.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http; // For API calls
import 'package:shared_preferences/shared_preferences.dart'; // For storing userId
import 'dart:async'; // For Timer

class MyListView extends StatefulWidget {
  final int? itemCount; // Optional itemCount parameter

  const MyListView({super.key, this.itemCount});

  @override
  State<MyListView> createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  List<dynamic> _attendanceData = []; // Holds fetched data
  bool _isLoading = true; // Loading state
  String? _userId; // User ID from SharedPreferences
  Timer? _timer; // Timer for periodic fetching

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load user ID before fetching data

    // Start a timer to fetch data every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_userId != null) {
        _fetchAttendance(_userId!);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('user');

    if (userDataString != null) {
      final Map<String, dynamic> userData = jsonDecode(userDataString);
      final String userId = userData['id'] ?? '';

      if (userId.isNotEmpty) {
        setState(() {
          _userId = userId;
        });
        _fetchAttendance(userId);
      } else {
        setState(() {
          _isLoading = false; // Stop loading if userId is missing
        });
      }
    } else {
      setState(() {
        _isLoading = false; // Stop loading if no user data found
      });
    }
  }

  Future<void> _fetchAttendance(String userId) async {
    final url = Uri.parse(
        'http://192.168.0.101:8000/api/employee/log-attendance/all/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _attendanceData = data['attendance']; // Assign fetched data
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(), // Show loading spinner
          )
        : _userId == null
            ? const Center(child: Text("User not found"))
            : _attendanceData.isEmpty
                ? const Center(
                    child:
                        Text("No attendance data found"), // Handle empty data
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: widget.itemCount != null
                        ? (widget.itemCount! <= _attendanceData.length
                            ? widget.itemCount
                            : _attendanceData.length)
                        : _attendanceData.length, // Use dynamic itemCount
                    itemBuilder: (context, index) {
                      final attendance = _attendanceData[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            "${attendance['qr_code_names'].join(', ')}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14),
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.purple.withValues(alpha: 0.2),
                            child: const Icon(Icons.work_history_rounded,
                                color: Colors.purple),
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: attendance['expired'] == "NO"
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.red.withValues(red: 0.2),
                            child: Icon(
                              attendance['expired'] == "NO"
                                  ? Icons.check_circle
                                  : Icons.cancel_rounded,
                              color: attendance['expired'] == "NO"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${attendance['logged_at']}",
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                "${attendance['signed_out_at']}",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
  }
}
