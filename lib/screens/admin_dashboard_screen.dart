import 'package:flutter/material.dart';
import 'package:new_event/services/appwrite_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<Map<String, dynamic>>> _eventRegistrations;

  @override
  void initState() {
    super.initState();
    _eventRegistrations = AppwriteService.getEventRegistrations(); // ✅ Now it works
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventRegistrations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No event registrations found'));
          }

          final eventRegistrations = snapshot.data!;
          return ListView.builder(
            itemCount: eventRegistrations.length,
            itemBuilder: (context, index) {
              final event = eventRegistrations[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
  title: Text(event['event_name'] ?? 'Unknown Event'),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Organizer: ${event['name'] ?? 'Unknown'}"),
      Text("Department: ${event['department'] ?? 'Unknown'}"),
      Text("Batch: ${event['batch'] ?? 'Unknown'}"),
      Text("Date: ${event['event_date'] ?? 'Unknown'}"),
      Text("Venue: ${event['event_venue'] ?? 'Unknown'}"),
    ],
  ),
)

              );
            },
          );
        },
      ),
    );
  }
}
