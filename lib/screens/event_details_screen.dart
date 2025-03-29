import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:new_event/screens/EventFullDetailsScreen.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'package:new_event/screens/event_registration_screen.dart';
import 'package:new_event/screens/user_details_screen.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatefulWidget {
  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> todayEvents = [];
  List<Map<String, dynamic>> filteredEvents = [];
  TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchVerifiedEvents();
  }

  Future<void> fetchVerifiedEvents() async {
    setState(() => isLoading = true);
    try {
      List<Map<String, dynamic>> fetchedEvents =
          await AppwriteService.getVerifiedEvents();
      DateTime todayDate = DateTime.now();

      // Filtering events that are still ongoing or upcoming
      List<Map<String, dynamic>> validEvents = fetchedEvents.where((event) {
        if (!event.containsKey("event_date") || event["event_date"].isEmpty) {
          return false; // Ignore events without dates
        }
        try {
          List<String> dateRange = event["event_date"].split(" → ");
          if (dateRange.length != 2) return false;

          DateTime endDate =
              DateFormat('yyyy-MM-dd').parse(dateRange[1].trim());
          return todayDate.isBefore(endDate) ||
              todayDate.isAtSameMomentAs(endDate);
        } catch (e) {
          return false;
        }
      }).toList();

      setState(() {
        events = validEvents; // Store only valid events
        filteredEvents = validEvents; // Update the filtered list

        todayEvents = validEvents.where((event) {
          try {
            List<String> dateRange = event["event_date"].split(" → ");
            DateTime startDate =
                DateFormat('yyyy-MM-dd').parse(dateRange[0].trim());
            DateTime endDate =
                DateFormat('yyyy-MM-dd').parse(dateRange[1].trim());
            return todayDate.isAtSameMomentAs(startDate) ||
                todayDate.isAtSameMomentAs(endDate) ||
                (todayDate.isAfter(startDate) && todayDate.isBefore(endDate));
          } catch (e) {
            return false;
          }
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching events: $e");
    }
  }

  void _filterEvents(String query) {
    setState(() {
      filteredEvents = events.where((event) {
        return event["event_name"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EventRegistrationScreen()));
    } else if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserDetailsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Event Details')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? const Center(child: Text('No verified events available'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterEvents,
                        decoration: InputDecoration(
                          hintText: "Search events...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterEvents("");
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (todayEvents.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 180,
                            autoPlay: todayEvents.length > 1,
                            enlargeCenterPage: true,
                            viewportFraction: 0.9,
                          ),
                          items: todayEvents.map((event) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventFullDetailsScreen(event: event),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      event["image_url"]!,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        color: Colors.black54,
                                        child: Text(
                                          event["event_name"],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                              title: Text(event["event_name"],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Register'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
