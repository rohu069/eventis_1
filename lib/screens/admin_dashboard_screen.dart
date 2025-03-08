import 'package:flutter/material.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'add_event_screen.dart';
import 'verified_events_screen.dart'; // ✅ Import Verified Events Screen

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
    _fetchEventRegistrations();
  }

  void _fetchEventRegistrations() {
    setState(() {
      _eventRegistrations = AppwriteService.getEventRegistrations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: const Text('Admin Dashboard'),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifiedEventsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.verified, color: Colors.white), // ✅ Checkmark icon
        label: const Text(
          "Verified Events",
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, // ✅ Green color for verification
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // ✅ Pill shape
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        ),
      ),
    ),
  ],
),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventRegistrations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No event registrations found'));
          }

          final unverifiedEvents =
              snapshot.data!.where((event) => event['is_verified'] == false).toList();

          return _buildEventList(unverifiedEvents);
        },
      ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () async {
              bool? verified = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventScreen(event: event),
                ),
              );

              if (verified == true) {
                _fetchEventRegistrations();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['event_name'] ?? 'Unknown Event',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Organizer: ${event['name'] ?? 'Unknown'}"),
                  Text("Date: ${event['event_date'] ?? 'Unknown'}"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
