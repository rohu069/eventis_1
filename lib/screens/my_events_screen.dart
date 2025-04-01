import 'package:flutter/material.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'package:intl/intl.dart';

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
    try {
      final events = await AppwriteService.getMyEvents();
      Map<String, List<Map<String, dynamic>>> eventRegistrations = {};
      final appwriteService = AppwriteService();

      for (var event in events) {
        final eventId = event["\$id"];
        final isVerified = event['is_verified'] ?? false;

        if (!isVerified) {
          eventRegistrations[eventId] = [];
          continue;
        }

        var registeredUsers =
            await appwriteService.getEventRegistrations(eventId) ?? [];
        registeredUsers = registeredUsers.map((user) {
          return {
            "user_name": user["user_name"] ?? "Unknown",
            "user_email": user["user_email"] ?? "N/A",
            "user_phone": user["user_phone"] ?? "N/A",
          };
        }).toList();

        eventRegistrations[eventId] = registeredUsers;
      }

      if (mounted) {
        setState(() {
          myEvents = events;
          registrations = eventRegistrations;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Error fetching events: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    final isDeleted = await AppwriteService.deleteEvent(eventId);
    if (isDeleted) {
      _showSuccessSnackBar('Event deleted successfully');
      fetchMyEvents();
    } else {
      _showErrorSnackBar('Failed to delete event');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No date';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchMyEvents();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : myEvents.isEmpty
              ? _buildEmptyState()
              : _buildEventsList(isDarkMode),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            "No events created yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Events you create will appear here",
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myEvents.length,
      itemBuilder: (context, index) {
        final event = myEvents[index];
        final eventId = event["\$id"];
        final registeredUsers = registrations[eventId] ?? [];
        final isVerified = event['is_verified'] == true;

        // Determine colors based on verification status and theme
        final Color cardBorderColor = isVerified
            ? isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade200
            : isDarkMode
                ? Colors.red.shade800
                : Colors.red.shade200;

        final Color cardBackgroundColor = isVerified
            ? isDarkMode
                ? Colors.grey.shade900.withOpacity(0.3)
                : Colors.white
            : isDarkMode
                ? Colors.red.shade900.withOpacity(0.1)
                : Colors.red.shade50.withOpacity(0.5);

        final Color iconBackgroundColor = isVerified
            ? isDarkMode
                ? Colors.blue.shade900
                : Colors.blue.shade50
            : isDarkMode
                ? Colors.red.shade900
                : Colors.red.shade50;

        final Color iconColor = isVerified
            ? isDarkMode
                ? Colors.blue.shade300
                : Colors.blue.shade700
            : isDarkMode
                ? Colors.red.shade300
                : Colors.red.shade700;

        final Color badgeBackgroundColor = isVerified
            ? isDarkMode
                ? Colors.blue.shade900
                : Colors.blue.shade50
            : isDarkMode
                ? Colors.red.shade900
                : Colors.red.shade100;

        final Color badgeTextColor = isVerified
            ? isDarkMode
                ? Colors.blue.shade300
                : Colors.blue.shade700
            : isDarkMode
                ? Colors.red.shade300
                : Colors.red.shade700;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: cardBorderColor,
              width: isVerified ? 1 : 1.5,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isVerified
                          ? Icons.event_available_rounded
                          : Icons.pending_rounded,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['event_name'] ?? "Unnamed Event",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(event['event_date']),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVerified
                                    ? Icons.people_rounded
                                    : Icons.warning_rounded,
                                size: 14,
                                color: badgeTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isVerified
                                    ? '${registeredUsers.length} ${registeredUsers.length == 1 ? 'registration' : 'registrations'}'
                                    : 'Pending verification',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: badgeTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () async {
                  final confirm = await _showDeleteConfirmationDialog(
                      event['event_name'] ?? "this event");
                  if (confirm) {
                    _deleteEvent(eventId);
                  }
                },
                tooltip: 'Delete Event',
              ),
              children: [
                if (isVerified) ...[
                  const Divider(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Registered Users",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (registeredUsers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "No registrations yet",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: registeredUsers.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final user = registeredUsers[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildUserInfoRow(Icons.person_rounded,
                                      "Name", user['user_name']),
                                  const SizedBox(height: 6),
                                  _buildUserInfoRow(Icons.email_rounded,
                                      "Email", user['user_email']),
                                  const SizedBox(height: 6),
                                  _buildUserInfoRow(Icons.phone_rounded,
                                      "Phone", user['user_phone']),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            "$label:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.8),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _showDeleteConfirmationDialog(String eventName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Event'),
              content: Text('Are you sure you want to delete "$eventName"?'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
