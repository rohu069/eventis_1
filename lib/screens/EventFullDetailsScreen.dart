import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import 'package:intl/intl.dart'; // Add this package for date formatting

class EventFullDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final String? userId;

  const EventFullDetailsScreen({
    Key? key,
    required this.event,
    this.userId,
  }) : super(key: key);

  @override
  _EventFullDetailsScreenState createState() => _EventFullDetailsScreenState();
}

class _EventFullDetailsScreenState extends State<EventFullDetailsScreen> {
  bool _isRegistered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    setState(() => _isLoading = true);
    final String? eventId = widget.event['\$id'];

    if (eventId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      bool registered = await AppwriteService.isUserRegisteredForEvent(eventId);
      setState(() {
        _isRegistered = registered;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error checking registration status: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Registration"),
            content:
                const Text("Are you sure you want to register for this event?"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Register"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _registerForEvent() async {
    if (_isRegistered) {
      _showSnackBar("You're already registered for this event", isError: false);
      return;
    }

    final String? eventId = widget.event['\$id'];
    if (eventId == null) {
      _showSnackBar("Error: Event ID is missing", isError: true);
      return;
    }

    bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      print("🚀 Registering for event $eventId...");
      bool success = await AppwriteService.registerForEvent(eventId: eventId);

      if (success) {
        setState(() {
          _isRegistered = true;
          _isLoading = false;
        });
        _showSnackBar("Successfully registered for the event", isError: false);
      } else {
        setState(() => _isLoading = false);
        _showSnackBar("Registration failed. Please try again", isError: true);
      }
    } catch (e) {
      print("❌ Error during registration: $e");
      setState(() => _isLoading = false);
      _showSnackBar("Something went wrong. Please try again", isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Date not available";

    try {
      // Assuming the date is in a standard format - adjust as needed
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM d, y').format(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.event["image_url"]?.isNotEmpty == true
        ? widget.event["image_url"]
        : "https://via.placeholder.com/250";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event["event_name"] ?? "Event Details"),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image with gradient overlay
                  Stack(
                    children: [
                      Hero(
                        tag: "eventImage_$imageUrl",
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 3.0,
                                    child: Image.network(imageUrl,
                                        fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Title overlay at the bottom of the image
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            widget.event["event_name"] ?? "Unknown Event",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Event details in a card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event date
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: const Text("Date and Time",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                _formatDate(widget.event["event_date"]),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),

                            const Divider(),

                            // Event venue
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: const Text("Venue",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                widget.event["event_venue"] ??
                                    "Venue not specified",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),

                            const Divider(),

                            // Event category
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.category,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              title: const Text("Category",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                widget.event["category"] ?? "Uncategorized",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Description section (if available)
                  if (widget.event["description"] != null &&
                      widget.event["description"].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "About the Event",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.event["description"],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Registration button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isRegistered ? null : _registerForEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRegistered
                              ? Colors.grey[300]
                              : Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey[600],
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: _isRegistered ? 0 : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isRegistered
                                ? Icons.check_circle
                                : Icons.app_registration),
                            const SizedBox(width: 8),
                            Text(
                              _isRegistered
                                  ? "Already Registered"
                                  : "Register Now",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
