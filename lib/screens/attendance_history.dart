import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:swift_mobile/screens/login_screen.dart';
import 'package:swift_mobile/uitls/my_appbar.dart';
import 'package:swift_mobile/uitls/my_list_view.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
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
      body: const Padding(
        padding: EdgeInsets.only(top: 120, bottom: 100, left: 20, right: 20),
        child: MyListView(),
      ),
    );
  }
}
