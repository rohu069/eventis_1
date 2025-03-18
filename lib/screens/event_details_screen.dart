import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:new_event/screens/EventFullDetailsScreen.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'package:new_event/screens/event_registration_screen.dart';
import 'package:new_event/screens/user_details_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  List<Map<String, dynamic>> events = [];
  int carouselCurrentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVerifiedEvents();
  }

  Future<void> fetchVerifiedEvents() async {
    setState(() => isLoading = true);
    List<Map<String, dynamic>> fetchedEvents = await AppwriteService.getVerifiedEvents();
    setState(() {
      events = fetchedEvents;
      isLoading = false;
    });
  }

  // Show bottom sheet for user menu
  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: const Text("User Details"),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserDetailsScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text("Logout"),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    List<Map<String, dynamic>> todayEvents = events.where((event) {
      String? dateRange = event["event_date"];
      if (dateRange != null && dateRange.contains('→')) {
        try {
          List<String> dates = dateRange.split('→').map((e) => e.trim()).toList();
          DateTime startDate = DateTime.parse(dates[0]);
          DateTime endDate = DateTime.parse(dates[1]);

          DateTime todayOnly = DateTime(today.year, today.month, today.day);
          DateTime startOnly = DateTime(startDate.year, startDate.month, startDate.day);
          DateTime endOnly = DateTime(endDate.year, endDate.month, endDate.day);

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? const Center(child: Text('No verified events available'))
              : Column(
                  children: [
                    const SizedBox(height: 10),

                    if (todayEvents.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Events Happening Today",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),

                    todayEvents.isNotEmpty
                        ? CarouselSlider.builder(
                            itemCount: todayEvents.length,
                            itemBuilder: (context, index, realIndex) {
                              final event = todayEvents[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventFullDetailsScreen(event: event),
                                    ),
                                  );
                                },
                                child: FlipCard(
                                  fill: Fill.fillBack,
                                  direction: FlipDirection.HORIZONTAL,
                                  front: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        event["event_name"],
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: 230,
                              viewportFraction: 0.7,
                              enableInfiniteScroll: true,
                              enlargeCenterPage: true,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 3),
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

                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
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
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${event["event_date"]} | ${event["event_venue"]}",
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventFullDetailsScreen(event: event),
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

      // Floating Action Button (Register for Event)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventRegistrationScreen()),
          );
        },
        shape: const CircleBorder(),
        backgroundColor:  Color.fromARGB(255, 91, 232, 232),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 91, 232, 232),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                onPressed: _showUserMenu,
              ),
              const Icon(Icons.search, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
