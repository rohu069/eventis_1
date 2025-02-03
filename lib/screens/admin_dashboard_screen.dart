import 'package:flutter/material.dart';
import 'add_event_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEventScreen()),
                );
              },
              child: Text('Add New Event'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to manage events or another section
              },
              child: Text('Manage Events'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logout or go back to login screen
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
