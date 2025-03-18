import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventFullDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventFullDetailsScreen({Key? key, required this.event}) : super(key: key);

  /// **📌 Show Full-Screen Image Dialog**
  void showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0, // Zoom functionality
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  /// **📌 Open URL in Browser**
void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    print('Could not launch $url');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event["event_name"])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **📌 Clickable Event Image (For Full-Screen View)**
            Center(
              child: GestureDetector(
                onTap: () => showFullScreenImage(context, event["image_url"]),
                child: Hero(
                  tag: "eventImage_${event["image_url"]}",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      event["image_url"] ?? "https://via.placeholder.com/250",
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
              event["event_name"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Date: ${event["event_date"]}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Venue: ${event["event_venue"]}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Event category: ${event["category"]}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            /// **📌 Clickable Registration Link**
            if (event["link"] != null && event["link"].trim().isNotEmpty)
              GestureDetector(
                onTap: () => _launchURL(event["link"]),
                child: Text(
                  "Register Here",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
