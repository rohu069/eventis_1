import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import 'package:intl/intl.dart';

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
  bool eventDatePassed =
      false; // Add this line to track if the event date has passed

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
    eventDatePassed = _isEventDatePassed(widget.event["event_date"]);
  }

  // Function to check if event date has passed

  bool _isEventDatePassed(String? eventDateString) {
    if (eventDateString == null || eventDateString.isEmpty) return true;

    try {
      // If the event date contains a range (e.g., "2025-04-23 → 2025-04-24")
      if (eventDateString.contains("→")) {
        // Extract the start date of the range
        final startDateString = eventDateString.split("→")[0].trim();

        // Create a DateFormat for the "yyyy-MM-dd" format (e.g., "2025-04-23")
        final dateFormat = DateFormat('yyyy-MM-dd');

        // Parse the start date
        final startDate = dateFormat.parse(startDateString);

        // Get the current date (ignoring the time part for comparison)
        final now = DateTime.now();

        // Ensure we're comparing only the date portion (without time)
        final eventDateOnly =
            DateTime(startDate.year, startDate.month, startDate.day);
        final nowOnly = DateTime(now.year, now.month, now.day);

        return eventDateOnly.isBefore(nowOnly) ||
            eventDateOnly.isAtSameMomentAs(nowOnly);
      } else {
        // If the date is not a range, parse it as a single date
        final dateFormat =
            DateFormat('MMM dd, yyyy'); // Format for "Apr 02, 2025"
        final eventDate = dateFormat.parse(eventDateString);

        // Get the current date (ignoring the time part for comparison)
        final now = DateTime.now();

        // Ensure we're comparing only the date portion (without time)
        final eventDateOnly =
            DateTime(eventDate.year, eventDate.month, eventDate.day);
        final nowOnly = DateTime(now.year, now.month, now.day);

        return eventDateOnly.isBefore(nowOnly) ||
            eventDateOnly.isAtSameMomentAs(nowOnly);
      }
    } catch (e) {
      print("❌ Error parsing event date: $e");
      return true; // If error in parsing, assume the event date is passed
    }
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
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Register"),
                style: FilledButton.styleFrom(
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
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM d, y').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String imageUrl = widget.event["image_url"]?.isNotEmpty == true
        ? widget.event["image_url"]
        : "https://via.placeholder.com/250";

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // App Bar with Image
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Event Image
                        Hero(
                          tag: "eventImage_$imageUrl",
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                        // Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Image Viewer on Tap
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: const EdgeInsets.all(12),
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
                        // Event Title
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Text(
                            widget.event["event_name"] ?? "Unknown Event",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3.0,
                                  color: Color.fromARGB(150, 0, 0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Event Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Details Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Date & Time
                            _buildDetailRow(
                              context,
                              Icons.calendar_today,
                              "Date and Time",
                              _formatDate(widget.event["event_date"]),
                            ),

                            const Divider(height: 1, indent: 64),

                            // Venue
                            _buildDetailRow(
                              context,
                              Icons.location_on,
                              "Venue",
                              widget.event["event_venue"] ??
                                  "Venue not specified",
                            ),

                            const Divider(height: 1, indent: 64),

                            // Category
                            _buildDetailRow(
                              context,
                              Icons.category,
                              "Category",
                              widget.event["category"] ?? "Uncategorized",
                            ),
                          ],
                        ),
                      ),

                      // Description Section
                      if (widget.event["description"] != null &&
                          widget.event["description"].isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "About the Event",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.event["description"],
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Registration Button
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: eventDatePassed
                              ? OutlinedButton.icon(
                                  onPressed: null,
                                  icon: const Icon(Icons.access_time),
                                  label: const Text(
                                    "Time Exceeded for Registration",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side:
                                        BorderSide(color: colorScheme.outline),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                )
                              : _isRegistered
                                  ? OutlinedButton.icon(
                                      onPressed: null,
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text(
                                        "Already Registered",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: colorScheme.outline),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    )
                                  : FilledButton.icon(
                                      onPressed: _registerForEvent,
                                      icon: const Icon(Icons.app_registration),
                                      label: const Text(
                                        "Register Now",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: FilledButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.12),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
