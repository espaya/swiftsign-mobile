
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:swift_mobile/screens/account_screen.dart';
import 'package:swift_mobile/screens/attendance_history.dart';
import 'package:swift_mobile/screens/dashboard_screen.dart';
import 'package:swift_mobile/screens/login_screen.dart';
import 'package:swift_mobile/screens/new_attendance.dart';
import 'package:swift_mobile/screens/username_email_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => Auth()), // Ensure Auth provider is here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<Auth>(context, listen: false).checkLoginStatus());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context);

    return MaterialApp(
      title: 'Swift Sign',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: authProvider.isAuthenticated ? const Dashboard() : const Login(),
      routes: {
        '/login': (context) => const Login(),
        '/new-attendance': (context) => authProvider.isAuthenticated
            ? const NewAttendance()
            : const Login(),
        '/dashboard': (context) =>
            authProvider.isAuthenticated ? const Dashboard() : const Login(),
        '/attendance-history': (context) => authProvider.isAuthenticated
            ? const AttendanceHistory()
            : const Login(),
        '/account': (context) => authProvider.isAuthenticated
            ? const AccountScreen()
            : const Login(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/username-email') {
          final userId = int.tryParse(authProvider.user?['id'] ?? '0') ?? 0;

          return MaterialPageRoute(
            builder: (context) => userId > 0
                ? UsernameEmailScreen(userId: userId)
                : const Login(),
          );
        }
        return null;
      },
    );
  }
}
