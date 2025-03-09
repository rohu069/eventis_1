import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:new_event/screens/EventFullDetailsScreen.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'package:new_event/screens/event_registration_screen.dart';



class EventDetailsScreen extends StatefulWidget {
  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  List<Map<String, dynamic>> events = [];
  int carouselCurrentIndex = 0;
  bool isLoading = true;
  String? userId;
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    fetchVerifiedEvents();
    fetchUserDetails(); // Add this call to fetch user details
  }

  /// **Fetch Verified Events from Appwrite**
  Future<void> fetchVerifiedEvents() async {
    setState(() => isLoading = true);

    List<Map<String, dynamic>> fetchedEvents =
        await AppwriteService.getVerifiedEvents();

    setState(() {
      events = fetchedEvents;
      isLoading = false;
    });
  }

  /// **Fetch User Details**
Future<void> fetchUserDetails() async {
  try {
    Map<String, dynamic>? userDetails = await AppwriteService.getCurrentUserDetails();

    // Check if userDetails is not null
    if (userDetails != null) {
      setState(() {
        // Access values from userDetails
        userId = userDetails['id'];
        userName = userDetails['name'];
        userEmail = userDetails['email'];
      });
    }

    // Log the user details for debugging
    // print("User ID: $userId");
    print("User Name: $userName");
    print("User Email: $userEmail");
  } catch (e) {
    print("Error fetching user details: $e");
  }
}

  /// **Show User Details Dialog**
  void showUserDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("User ID: $userId"),
              Text("User Name: $userName"),
              Text("User Email: $userEmail"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// **Logout Function**
  void logout() {
    // TODO: Implement actual logout logic
    Navigator.pushReplacementNamed(context, '/login');
  }
  

@override
Widget build(BuildContext context) {
  DateTime today = DateTime.now();

List<Map<String, dynamic>> todayEvents = events.where((event) {
  String? dateRange = event["event_date"]; // Example: "2025-03-10 → 2025-03-15"

  if (dateRange != null && dateRange.contains('→')) {
    try {
      // Split the date range string into start and end dates
      List<String> dates = dateRange.split('→').map((e) => e.trim()).toList();
      DateTime startDate = DateTime.parse(dates[0]); // "2025-03-10"
      DateTime endDate = DateTime.parse(dates[1]);   // "2025-03-15"

      // Get only the date part (ignoring time)
      DateTime todayOnly = DateTime(today.year, today.month, today.day);
      DateTime startOnly = DateTime(startDate.year, startDate.month, startDate.day);
      DateTime endOnly = DateTime(endDate.year, endDate.month, endDate.day);

      // Check if today is within the range
      return todayOnly.isAfter(startOnly.subtract(const Duration(days: 1))) &&
             todayOnly.isBefore(endOnly.add(const Duration(days: 1)));
    } catch (e) {
      print("Error parsing date range: $e");
      return false;
    }
  }
  return false;
}).toList();

  return Scaffold(
    appBar: AppBar(
      title: const Text('Event Details'),
      actions: [
        PopupMenuButton<String>(
          icon: const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          onSelected: (value) {
            if (value == 'profile') {
              showUserDetails();
            } else if (value == 'logout') {
              logout();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text("User Details"),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text("Logout"),
              ),
            ),
          ],
        ),
      ],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : events.isEmpty
            ? const Center(child: Text('No verified events available'))
            : Column(
                children: [
                  const SizedBox(height: 10),

                  /// **📌 Events Happening Today Text**
                  if (todayEvents.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Events Happening Today",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  /// **📌 Carousel Slider**
                  todayEvents.isNotEmpty
                      ? CarouselSlider(
                          items: todayEvents.map((event) {
                            return FlipCard(
                              fill: Fill.fillBack,
                              direction: FlipDirection.HORIZONTAL,
                              front: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  event["image_url"]!,
                                  width: 250,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              back: Container(
                                width: 250,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    event["event_name"],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          options: CarouselOptions(
                            initialPage: 1,
                            viewportFraction: 0.6,
                            enlargeCenterPage: true,
                            onPageChanged: (index, _) {
                              setState(() {
                                carouselCurrentIndex = index;
                              });
                            },
                          ),
                        )
                      : const Center(
                          child: Text(
                            "No events happening today",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),

                  const SizedBox(height: 20),

                  /// **📌 Event List**
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                event["image_url"]!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              event["event_name"],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${event["event_date"]} | ${event["event_venue"]}",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade700),
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventFullDetailsScreen(event: event),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

    /// **📌 Bottom Navigation Bar**
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/eventsPage');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.event, size: 25, color: Colors.grey),
                Text('Events'),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EventRegistrationScreen()),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add_circle_outline, size: 25, color: Colors.grey),
                Text('Create'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}