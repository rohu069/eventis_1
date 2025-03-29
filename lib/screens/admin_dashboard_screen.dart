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
  Future<List<Map<String, dynamic>>> _eventRegistrations = Future.value([]);

  @override
  void initState() {
    super.initState();
    _fetchEventRegistrations();
  }

  void _fetchEventRegistrations() async {
    List<Map<String, dynamic>> events =
        await AppwriteService.getEventRegistrations();

    DateTime currentDate = DateTime.now();
    DateTime today =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    List<Map<String, dynamic>> upcomingEvents = [];

    for (var event in events) {
      String? eventDateStr = event['event_date'];

      if (eventDateStr != null && eventDateStr.isNotEmpty) {
        try {
          eventDateStr = eventDateStr.trim();

          // Extract first date if range format detected
          if (eventDateStr.contains("→")) {
            eventDateStr = eventDateStr.split("→")[0].trim();
          }

          DateTime eventDate = DateTime.parse(eventDateStr);
          DateTime formattedEventDate =
              DateTime(eventDate.year, eventDate.month, eventDate.day);

          if (formattedEventDate.isAfter(today) ||
              formattedEventDate.isAtSameMomentAs(today)) {
            upcomingEvents.add(event);
          } else {
            print(
                "🗑 Deleting past event: ${event['event_name']} (${event['event_date']})");
            await AppwriteService.deleteEvent(event['\$id']);
          }
        } catch (e) {
          print(
              "⚠ Invalid date format for event: ${event['event_name']} | Error: $e");
        }
      }
    }

    print("✅ Total upcoming events: ${upcomingEvents.length}");

    setState(() {
      _eventRegistrations = Future.value(upcomingEvents);
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
              icon: const Icon(Icons.verified,
                  color: Colors.white), // ✅ Checkmark icon
              label: const Text(
                "Verified Events",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // ✅ Green color for verification
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // ✅ Pill shape
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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

          final unverifiedEvents = snapshot.data!
              .where((event) => event['is_verified'] == false)
              .toList();

          return _buildEventList(unverifiedEvents);
        },
      ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
    // Step 1: Create a map to track duplicate events
    Map<String, int> eventCount = {};

    for (var event in events) {
      String key = "${event['event_name']}_${event['event_date']}";
      eventCount[key] = (eventCount[key] ?? 0) + 1;
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        String key = "${event['event_name']}_${event['event_date']}";

        // Step 2: Check if the event is a duplicate
        bool isDuplicate = (eventCount[key] ?? 0) > 1;

        return Card(
          margin: const EdgeInsets.all(10),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDuplicate
              ? Colors.red[100]
              : Colors.white, // 🔴 Highlight duplicate events in red
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDuplicate
                          ? Colors.red
                          : Colors.black, // 🔴 Highlight text if duplicate
                    ),
                  ),
                  Text("Organizer: ${event['name'] ?? 'Unknown'}"),
                  Text("Date: ${event['event_date'] ?? 'Unknown'}"),
                  Text("Registration Link: ${event['link'] ?? 'unknown'}"),
                  if (isDuplicate) // 🛑 Show a warning if it's a duplicate
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red),
                          SizedBox(width: 5),
                          Text(
                            "Duplicate event detected!",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
