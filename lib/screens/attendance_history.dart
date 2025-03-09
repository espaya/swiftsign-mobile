import 'package:flutter/material.dart';
import 'package:swift_mobile/uitls/my_appbar.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: ListView(
          shrinkWrap: true, // Allow it to take only the space it needs
          children: const [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Icon(Icons.lock_clock),
                title: Text("Night Action"),
                subtitle: Text('Dec 24, 2024'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                tileColor: Colors.black12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
