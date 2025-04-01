import 'package:flutter/material.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
      TextEditingController();
  String? imageUrl;
  bool isLoading = false;

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
      maxParticipantsController.text =
          (widget.event!['no_participants'] ?? 0).toString();
    }
  }

  void verifyEvent() async {
    if (widget.event == null || widget.event!['\$id'] == null) return;

    setState(() => isLoading = true);

    bool success = await AppwriteService.verifyEvent(widget.event!['\$id']);

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      _showSnackBar("Event verified successfully", Colors.green);
      Navigator.pop(context, true);
    } else {
      _showSnackBar("Failed to verify event", Colors.red);
    }
  }

  Future<void> deleteEvent() async {
    if (widget.event == null || widget.event!['\$id'] == null) return;

    bool confirmDelete = await _confirmDeleteDialog();
    if (!confirmDelete) return;

    setState(() => isLoading = true);

    bool success = await AppwriteService.deleteEvent(widget.event!['\$id']);

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      _showSnackBar("Event deleted successfully", Colors.green);
      Navigator.pop(context, true);
    } else {
      _showSnackBar("Failed to delete event", Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Future<bool> _confirmDeleteDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              "Delete Event",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Are you sure you want to delete this event? This action cannot be undone.",
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Delete", style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ) ??
        false;
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
          'Event Verification',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null && imageUrl!.trim().isNotEmpty)
                      Container(
                        height: 240,
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                imageUrl!,
                                width: double.infinity,
                                height: 240,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 240,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 240,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image_outlined,
                                            size: 50, color: Colors.grey[400]),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Image not available",
                                          style: GoogleFonts.poppins(
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(16)),
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
                                  eventNameController.text,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Details Section
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.event_note,
                                    color: Colors.blue),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Event Information",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Event Details Card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildInfoItem(
                                  icon: Icons.event,
                                  label: 'Event Name',
                                  value: eventNameController.text,
                                ),
                                _buildDivider(),
                                _buildInfoItem(
                                  icon: Icons.person,
                                  label: 'Organizer',
                                  value: organizerController.text,
                                ),
                                _buildDivider(),
                                _buildInfoItem(
                                  icon: Icons.business,
                                  label: 'Department',
                                  value: departmentController.text,
                                ),
                                _buildDivider(),
                                _buildInfoItem(
                                  icon: Icons.group,
                                  label: 'Batch',
                                  value: batchController.text,
                                ),
                                _buildDivider(),
                                _buildInfoItem(
                                  icon: Icons.calendar_today,
                                  label: 'Date',
                                  value: dateController.text,
                                ),
                                _buildDivider(),
                                _buildInfoItem(
                                  icon: Icons.location_on,
                                  label: 'Venue',
                                  value: venueController.text,
                                ),
                                if (linkController.text.isNotEmpty) ...[
                                  _buildDivider(),
                                  _buildInfoItem(
                                    icon: Icons.link,
                                    label: 'Registration Link',
                                    value: linkController.text,
                                    isLink: true,
                                  ),
                                ],
                                _buildDivider(),
                                _buildInfoItem(
                                  icon: Icons.people,
                                  label: 'Max Participants',
                                  value: maxParticipantsController.text,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: verifyEvent,
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: Text(
                                    "Verify Event",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: deleteEvent,
                                  icon: const Icon(Icons.delete_outline),
                                  label: Text(
                                    "Delete Event",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: isLink ? Colors.blue : Colors.black87,
                    fontWeight: isLink ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 16,
      endIndent: 16,
    );
  }
}
