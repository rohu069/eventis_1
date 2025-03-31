import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';

class EventFullDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  final String? userId; // userId remains optional

  const EventFullDetailsScreen({
    Key? key,
    required this.event,
    this.userId,
  }) : super(key: key);

  void showFullScreenImage(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Future<void> _registerForEvent(BuildContext context) async {
    final String? eventId = event['\$id']; // ✅ Correct way to get Event ID

    print("🔍 Checking eventId: $eventId");

    if (eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error: Event ID is missing!")),
      );
      return;
    }

    try {
      print("🚀 Registering for event $eventId...");
      bool success = await AppwriteService.registerForEvent(
        eventId: eventId, // ✅ Only pass eventId, userId is fetched internally
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "✅ Successfully registered for the event!"
              : "❌ Registration failed. Try again!"),
        ),
      );
    } catch (e) {
      print("❌ Error during registration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Something went wrong! Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = event["image_url"]?.isNotEmpty == true
        ? event["image_url"]
        : "https://via.placeholder.com/250";

    return Scaffold(
      appBar: AppBar(title: Text(event["event_name"] ?? "Event Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => showFullScreenImage(context, imageUrl),
                child: Hero(
                  tag: "eventImage_$imageUrl",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              event["event_name"] ?? "Unknown Event",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("📅 Date: ${event["event_date"] ?? "N/A"}",
                style: const TextStyle(fontSize: 16)),
            Text("📍 Venue: ${event["event_venue"] ?? "N/A"}",
                style: const TextStyle(fontSize: 16)),
            Text("🎟 Event Category: ${event["category"] ?? "N/A"}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _registerForEvent(context),
                child: const Text("Register for Event"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
