import 'package:flutter/material.dart';
import 'package:new_event/services/appwrite_service.dart';

class AddEventScreen extends StatefulWidget {
  final Map<String, dynamic>? event;

  const AddEventScreen({super.key, this.event});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController organizerController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  String? imageUrl;

  @override
  void initState() {
    super.initState();

    // Pre-fill fields if event data exists
    if (widget.event != null) {
      eventNameController.text = widget.event!['event_name'] ?? '';
      organizerController.text = widget.event!['name'] ?? '';
      departmentController.text = widget.event!['department'] ?? '';
      batchController.text = widget.event!['batch'] ?? '';
      dateController.text = widget.event!['event_date'] ?? '';
      venueController.text = widget.event!['event_venue'] ?? '';
      linkController.text = widget.event!['link'];
      imageUrl = widget.event!['image_url'];
    }
  }

  void verifyEvent() async {
    if (widget.event == null || widget.event!['\$id'] == null) return;

    bool success = await AppwriteService.verifyEvent(widget.event!['\$id']); // ✅ Use `\$id` for Appwrite document ID
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event verified successfully!")),
      );
      Navigator.pop(context, true); // ✅ Return `true` to refresh admin dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to verify event")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Event')),
      body: SingleChildScrollView( // ✅ Prevents UI overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image (if available)
            if (imageUrl != null && imageUrl!.trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl!,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Center(
                child: Icon(Icons.image_not_supported, size: 150, color: Colors.grey),
              ),

            const SizedBox(height: 20),

            // Event Details (Read-Only)
            TextField(
              controller: eventNameController,
              decoration: const InputDecoration(labelText: 'Event Name'),
              readOnly: true,
            ),
            TextField(
              controller: organizerController,
              decoration: const InputDecoration(labelText: 'Organizer'),
              readOnly: true,
            ),
            TextField(
              controller: departmentController,
              decoration: const InputDecoration(labelText: 'Department'),
              readOnly: true,
            ),
            TextField(
              controller: batchController,
              decoration: const InputDecoration(labelText: 'Batch'),
              readOnly: true,
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date'),
              readOnly: true,
            ),
            TextField(
              controller: venueController,
              decoration: const InputDecoration(labelText: 'Venue'),
              readOnly: true,
            ),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(labelText: 'Regestration link'),
              readOnly: true,
            ),            

            const SizedBox(height: 20),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifyEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Verify Event", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
