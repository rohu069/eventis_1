import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class RegisteredUsersScreen extends StatefulWidget {
  final String eventId; // Event ID to fetch registrations

  const RegisteredUsersScreen({Key? key, required this.eventId})
      : super(key: key);

  @override
  _RegisteredUsersScreenState createState() => _RegisteredUsersScreenState();
}

class _RegisteredUsersScreenState extends State<RegisteredUsersScreen> {
  final Client _client = Client();
  late Databases _databases;
  List<Map<String, dynamic>> registeredUsers = [];

  @override
  void initState() {
    super.initState();
    _client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('YOUR_PROJECT_ID')
        .setSelfSigned();
    _databases = Databases(_client);
    _fetchRegisteredUsers();
  }

  Future<void> _fetchRegisteredUsers() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: 'YOUR_DATABASE_ID',
        collectionId:
            'registrations', // Collection where registrations are stored
        queries: [
          Query.equal("event_id", widget.eventId)
        ], // Fetch users for this event
      );

      setState(() {
        registeredUsers = response.documents.map((doc) => doc.data).toList();
      });
    } catch (e) {
      print("Error fetching registered users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registered Users")),
      body: registeredUsers.isEmpty
          ? const Center(
              child: Text("No users have registered for this event."))
          : ListView.builder(
              itemCount: registeredUsers.length,
              itemBuilder: (context, index) {
                final user = registeredUsers[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  child: ListTile(
                    title: Text(user["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📧 Email: ${user["email"]}"),
                        Text("📞 Phone: ${user["phone"]}"),
                        Text("🆔 Student ID: ${user["studentId"]}"),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
