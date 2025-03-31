import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:new_event/screens/my_events_screen.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({Key? key}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Map<String, dynamic>? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      Map<String, dynamic>? fetchedUserDetails =
          await AppwriteService.getCurrentUserDetails();

      if (fetchedUserDetails == null) {
        // If not found in the collection, try getting user details from Appwrite Account
        fetchedUserDetails = await AppwriteService.getCurrentUserDetails();
      }

      if (fetchedUserDetails != null) {
        setState(() {
          userDetails = fetchedUserDetails;
          isLoading = false;
        });
      } else {
        print("⚠️ User details not found");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching user details: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _logoutUser() async {
    try {
      await AppwriteService.logoutUser();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print("❌ Logout failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Edit profile feature coming soon")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logoutUser,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userDetails == null
              ? _buildErrorState()
              : _buildProfileContent(context),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 56,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Failed to fetch user details",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            onPressed: () {
              setState(() => isLoading = true);
              fetchUserDetails();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    if (userDetails == null) {
      return _buildErrorState();
    }

    final displayName = userDetails!['name'] ?? "User";
    final email = userDetails!['email'] ?? "No email";
    // Optional fields with fallbacks
    final phone = userDetails!['phone'] ?? "Not provided";
    final bio = userDetails!['bio'] ?? "No bio information available";

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(displayName, email),
          _buildInfoCard(context),
          _buildBioSection(bio),
          _buildActionsSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String displayName, String email) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: userDetails!['profileImage'] != null
                  ? CachedNetworkImage(
                      imageUrl: userDetails!['profileImage'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Account Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email_outlined, "Email",
                userDetails!['email'] ?? "Not provided"),
            if (userDetails!['phone'] != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                  Icons.phone_outlined, "Phone", userDetails!['phone']),
            ],
            if (userDetails!['location'] != null) ...[
              const Divider(height: 24),
              _buildInfoRow(Icons.location_on_outlined, "Location",
                  userDetails!['location']),
            ],
            const Divider(height: 24),
            _buildInfoRow(Icons.calendar_today_outlined, "Member Since",
                _formatDate(userDetails!['createdAt'] ?? "Unknown")),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection(String bio) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "About",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              bio,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MyEventsScreen(), // No need to pass userId
                ),
              );
            },
            child: const Text("Go to My Events"),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text("Back to Home"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              minimumSize: const Size(double.infinity, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}
