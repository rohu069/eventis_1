import 'package:flutter/material.dart';
import 'event_registration_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int _currentIndex = 0; // Track the selected tab index

  // Dummy event list (Replace with real data source if needed)
  final List<Map<String, String>> events = [
    {'event_name': 'Tech Fest', 'event_date': 'March 10, 2025'},
    {'event_name': 'Cultural Night', 'event_date': 'April 15, 2025'},
    {'event_name': 'Sports Day', 'event_date': 'May 5, 2025'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 45, 190, 190), // Dark Red
              Color.fromARGB(255, 255, 255, 255), // Medium Red
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(
                _currentIndex == 0 ? 'Event Details' : 'Event Registration',
                style: const TextStyle(
                  color: Colors.white, // White text for AppBar
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0, // Remove shadow to blend with the gradient
            ),
            Expanded(
              child: Center(
                child: _currentIndex == 0
                    ? ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          var event = events[index];
                          return ListTile(
                            title: Text(
                              event['event_name']!,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              event['event_date']!,
                              style: TextStyle(color: Colors.white70),
                            ),
                            onTap: () {
                              // Handle event click to show details
                            },
                          );
                        },
                      )
                    : null, // Placeholder for other content
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Highlight the selected tab
        onTap: (index) {
          if (index == 1) {
            // Navigate to the Event Registration Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventRegistrationScreen(),
              ),
            );
          } else {
            setState(() {
              _currentIndex = index; // Update the selected tab index
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info, color: Colors.white),
            label: 'Event Details',
            backgroundColor: Color.fromARGB(255, 255, 255, 255), // Dark Red
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration, color: Colors.white),
            label: 'Event Registration',
            backgroundColor: Color.fromARGB(255, 255, 255, 255), // Dark Red
          ),
        ],
        backgroundColor: Color.fromARGB(255, 172, 49, 49), // Match the background
        selectedItemColor: Colors.white, // White for selected tab
        unselectedItemColor: Colors.white60, // Light gray for unselected tabs
      ),
    );
  }
}
