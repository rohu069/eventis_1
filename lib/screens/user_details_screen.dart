import 'package:flutter/material.dart';
import 'package:new_event/services/appwrite_service.dart';

class UserDetailsScreen extends StatefulWidget {
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
        await AppwriteService.getUserDetailsFromCollection();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userDetails == null
              ? const Center(child: Text("Failed to fetch user details"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User ID: ${userDetails!['\$id']}",
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text("User Name: ${userDetails!['name']}",
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text("User Email: ${userDetails!['email']}",
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Back"),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
