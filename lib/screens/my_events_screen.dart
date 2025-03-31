import 'package:flutter/material.dart';
import 'package:new_event/services/appwrite_service.dart';

class MyEventsScreen extends StatefulWidget {
  final String? userId;

  const MyEventsScreen({Key? key, this.userId}) : super(key: key);

  @override
  _MyEventsScreenState createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<Map<String, dynamic>> myEvents = [];
  Map<String, List<Map<String, dynamic>>> registrations = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyEvents();
  }

  Future<void> fetchMyEvents() async {
    print("🚀 Fetching My Events...");

    final events = await AppwriteService.getMyEvents();
    Map<String, List<Map<String, dynamic>>> eventRegistrations = {};

    final appwriteService = AppwriteService(); // ✅ Create an instance

    for (var event in events) {
      final eventId = event["\$id"];
      final isVerified = event['is_verified'] ?? false;

      print("🔍 Checking event: ${event["event_name"]} (ID: $eventId)");

      // ✅ Skip fetching registrations for unverified events
      if (!isVerified) {
        print(
            "⚠️ Skipping registrations for unverified event: ${event["event_name"]}");
        eventRegistrations[eventId] = []; // Empty list
        continue;
      }

      var registeredUsers =
          await appwriteService.getEventRegistrations(eventId) ?? [];

      // ✅ Ensure every user has valid data
      registeredUsers = registeredUsers.map((user) {
        return {
          "user_name": user["user_name"] ?? "Unknown",
          "user_email": user["user_email"] ?? "N/A",
          "user_phone": user["user_phone"] ?? "N/A",
        };
      }).toList();

      print("✅ Processed Registrations for $eventId: $registeredUsers");

      eventRegistrations[eventId] = registeredUsers;
    }

    setState(() {
      myEvents = events;
      registrations = eventRegistrations;
      isLoading = false;
    });

    print("🎯 Final registrations mapping: $registrations");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myEvents.isEmpty
              ? const Center(child: Text('No events created yet.'))
              : ListView.builder(
                  itemCount: myEvents.length,
                  itemBuilder: (context, index) {
                    final event = myEvents[index];
                    final eventId = event["\$id"];
                    final registeredUsers = registrations[eventId] ?? [];

                    print(
                        "📌 UI - Event: ${event["event_name"]} | Users: $registeredUsers");

                    return Card(
                      margin: const EdgeInsets.all(10),
                      color: event['is_verified'] == true
                          ? Colors.white
                          : Colors.red.shade100,
                      child: ExpansionTile(
                        title: Text(event['event_name'] ?? "No Name"),
                        subtitle: Text(event['is_verified'] == true
                            ? 'Registrations: ${registeredUsers.length}'
                            : '❌ Event not verified'),
                        children: event['is_verified'] == true
                            ? (registeredUsers.isEmpty
                                ? [
                                    const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('No registrations yet.'))
                                  ]
                                : registeredUsers.map((user) {
                                    return ListTile(
                                      title:
                                          Text(user["user_name"] ?? "Unknown"),
                                      subtitle: Text(
                                          "Email: ${user["user_email"] ?? "N/A"} | "
                                          "Phone: ${user["user_phone"] ?? "N/A"}"),
                                    );
                                  }).toList())
                            : [],
                      ),
                    );
                  },
                ),
    );
  }
}
