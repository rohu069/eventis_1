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
  final TextEditingController maxParticipantsController =
      TextEditingController(); // New field
  String? imageUrl;

  @override
  void initState() {
    super.initState();

    if (widget.event != null) {
      eventNameController.text = widget.event!['event_name'] ?? '';
      organizerController.text = widget.event!['name'] ?? '';
      departmentController.text = widget.event!['department'] ?? '';
      batchController.text = widget.event!['batch'] ?? '';
      dateController.text = widget.event!['event_date'] ?? '';
      venueController.text = widget.event!['event_venue'] ?? '';
      linkController.text = widget.event!['link'] ?? '';
      imageUrl = widget.event!['image_url'];

      // Set max participants (default to 0 if null)
      maxParticipantsController.text =
          (widget.event!['no_participants'] ?? 0).toString();
    }
  }

  void verifyEvent() async {
    if (widget.event == null || widget.event!['\$id'] == null) return;

    bool success = await AppwriteService.verifyEvent(widget.event!['\$id']);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event verified successfully!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to verify event")),
      );
    }
  }

  Future<void> deleteEvent() async {
    if (widget.event == null || widget.event!['\$id'] == null) return;

    bool confirmDelete = await _confirmDeleteDialog();
    if (!confirmDelete) return;

    bool success = await AppwriteService.deleteEvent(widget.event!['\$id']);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event deleted successfully!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete event")),
      );
    }
  }

  Future<bool> _confirmDeleteDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Event"),
            content: const Text(
                "Are you sure you want to delete this event? This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Event',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl!.trim().isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl!,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.error_outline,
                                size: 50, color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Event Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                          icon: Icons.event,
                          label: 'Event Name',
                          controller: eventNameController),
                      _buildInfoField(
                          icon: Icons.person,
                          label: 'Organizer',
                          controller: organizerController),
                      _buildInfoField(
                          icon: Icons.business,
                          label: 'Department',
                          controller: departmentController),
                      _buildInfoField(
                          icon: Icons.group,
                          label: 'Batch',
                          controller: batchController),
                      _buildInfoField(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          controller: dateController),
                      _buildInfoField(
                          icon: Icons.location_on,
                          label: 'Venue',
                          controller: venueController),
                      _buildInfoField(
                          icon: Icons.link,
                          label: 'Registration Link',
                          controller: linkController),
                      _buildInfoField(
                          icon: Icons.people,
                          label: 'Max Participants',
                          controller: maxParticipantsController),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: verifyEvent,
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                      label: const Text("Verify Event",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: deleteEvent,
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.white),
                      label: const Text("Delete Event",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(
      {required IconData icon,
      required String label,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        readOnly: true,
      ),
    );
  }
}
