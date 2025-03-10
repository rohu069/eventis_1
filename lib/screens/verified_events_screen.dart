import 'package:flutter/material.dart';
import 'package:new_event/services/appwrite_service.dart';

class VerifiedEventsScreen extends StatefulWidget {
  const VerifiedEventsScreen({super.key});

  @override
  _VerifiedEventsScreenState createState() => _VerifiedEventsScreenState();
}

class _VerifiedEventsScreenState extends State<VerifiedEventsScreen> {
  late Future<List<Map<String, dynamic>>> _verifiedEvents;

  @override
  void initState() {
    super.initState();
    _fetchVerifiedEvents();
  }

  void _fetchVerifiedEvents() {
    setState(() {
      _verifiedEvents = AppwriteService.getVerifiedEvents(); // ✅ Fetch only verified events
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verified Events')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _verifiedEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No verified events found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final event = snapshot.data![index];

              return Card(
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
                      Text("Organizer: ${event['name'] ?? 'Unknown'}"),
                      Text("Date: ${event['event_date'] ?? 'Unknown'}"),
                    ],
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
