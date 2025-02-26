import 'package:flutter/material.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'add_event_screen.dart'; // Import AddEventScreen

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

  // ✅ Fetch event registrations
  void _fetchEventRegistrations() {
    setState(() {
      _eventRegistrations = AppwriteService.getEventRegistrations();
    });
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

              return Material(  // ✅ Ensures InkWell gets proper click effect
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    print("🔹 Event clicked: ${event['event_name']}"); // Debugging log
                    bool? verified = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEventScreen(event: event),
                      ),
                    );

                    if (verified == true) {
                      _fetchEventRegistrations(); // ✅ Refresh list after verification
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['event_name'] ?? 'Unknown Event',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text("Organizer: ${event['name'] ?? 'Unknown'}"),
                          Text("Department: ${event['department'] ?? 'Unknown'}"),
                          Text("Batch: ${event['batch'] ?? 'Unknown'}"),
                          Text("Date: ${event['event_date'] ?? 'Unknown'}"),
                          Text("Venue: ${event['event_venue'] ?? 'Unknown'}"),
                          const SizedBox(height: 10),

                          // ✅ Show image only if it's a valid URL
                          if (event['image_url'] != null &&
                              event['image_url']!.trim().isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                event['image_url']!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            const Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 100, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
