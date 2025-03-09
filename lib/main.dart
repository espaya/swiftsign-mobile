import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:swift_mobile/screens/account_screen.dart';
import 'package:swift_mobile/screens/attendance_history.dart';
import 'package:swift_mobile/screens/dashboard_screen.dart';
import 'package:swift_mobile/screens/login_screen.dart';
import 'package:swift_mobile/screens/new_attendance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async operations

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('id');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
      ],
      child: MyApp(isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swift Sign',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const Dashboard() : const Login(), // Auto-login logic
      routes: {
        '/login': (context) => const Login(),
        '/new-attendance': (context) => const NewAttendance(),
        '/dashboard': (context) => const Dashboard(),
        '/attendance-history': (context) => const AttendanceHistory(),
        '/account': (context) => const AccountScreen(),
      },
    );
  }
}
