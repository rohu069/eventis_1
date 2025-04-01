import 'package:flutter/material.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_event_screen.dart';
import 'verified_events_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Future<List<Map<String, dynamic>>> _eventRegistrations = Future.value([]);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEventRegistrations();
  }

  void _fetchEventRegistrations() async {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> events =
        await AppwriteService.getUnverifiedEvents();

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

    if (mounted) {
      setState(() {
        _eventRegistrations = Future.value(upcomingEvents);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _fetchEventRegistrations,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _eventRegistrations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                } else if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                // Include unverified events in the list
                final unverifiedEvents = snapshot.data!
                    .where((event) =>
                        event['is_verified'] == false ||
                        event['is_verified'] == null)
                    .toList();

                if (unverifiedEvents.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildEventList(unverifiedEvents);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifiedEventsScreen(),
            ),
          ).then((_) => _fetchEventRegistrations());
        },
        backgroundColor: Colors.green,
        elevation: 2,
        icon: const Icon(Icons.verified, color: Colors.white),
        label: Text(
          "Verified Events",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            "Loading events...",
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchEventRegistrations,
              icon: const Icon(Icons.refresh),
              label: Text(
                "Try Again",
                style: GoogleFonts.poppins(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No Pending Events",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "There are no events waiting for verification",
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifiedEventsScreen(),
                ),
              ).then((_) => _fetchEventRegistrations());
            },
            icon: const Icon(Icons.verified),
            label: Text(
              "View Verified Events",
              style: GoogleFonts.poppins(),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events) {
    // Create a map to track duplicate events
    Map<String, int> eventCount = {};

    for (var event in events) {
      String key = "${event['event_name']}_${event['event_date']}";
      eventCount[key] = (eventCount[key] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pending_actions, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Text(
                "Pending Verification",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${events.length} events",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              String key = "${event['event_name']}_${event['event_date']}";

              // Check if the event is a duplicate
              bool isDuplicate = (eventCount[key] ?? 0) > 1;

              return _buildEventCard(event, isDuplicate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, bool isDuplicate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDuplicate
            ? Border.all(color: Colors.red.shade300, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            bool? verified = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEventScreen(event: event),
              ),
            );

            if (verified == true) {
              // Re-fetch events after verification
              _fetchEventRegistrations();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event['image_url'] != null &&
                        event['image_url'].toString().isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          event['image_url'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event, color: Colors.grey),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['event_name'] ?? 'Unknown Event',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDuplicate ? Colors.red : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _buildInfoRow(
                            Icons.person_outline,
                            event['name'] ?? 'Unknown',
                          ),
                          const SizedBox(height: 4),
                          _buildInfoRow(
                            Icons.calendar_today,
                            event['event_date'] ?? 'Unknown',
                          ),
                          const SizedBox(height: 4),
                          _buildInfoRow(
                            Icons.people_outline,
                            "${event['no_participants'] ?? '0'} participants",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isDuplicate)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Duplicate event detected",
                            style: GoogleFonts.poppins(
                              color: Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        bool? verified = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEventScreen(event: event),
                          ),
                        );

                        if (verified == true) {
                          // Re-fetch events after verification
                          _fetchEventRegistrations();
                        }
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text(
                        "Review",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        bool success =
                            await AppwriteService.verifyEvent(event['\$id']);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Event verified successfully",
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(10),
                            ),
                          );
                          _fetchEventRegistrations();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Failed to verify event",
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(10),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(
                        "Verify",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
