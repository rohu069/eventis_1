import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore
import 'event_registration_screen.dart'; // Import the Event Registration Screen

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int _currentIndex = 0; // Track the selected tab index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 122, 17, 17), // Dark Blue
              Color.fromARGB(255, 172, 49, 49),  // Medium Blue
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
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('events')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          var events = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              var event = events[index];
                              return ListTile(
                                title: Text(event['event_name']),
                                subtitle: Text(event['event_date']),
                                onTap: () {
                                  // Handle event click to show details
                                },
                              );
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
            backgroundColor: Color.fromARGB(255, 255, 255, 255), // Dark Blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration, color: Colors.white),
            label: 'Event Registration',
            backgroundColor: Color.fromARGB(255, 255, 255, 255), // Dark Blue
          ),
        ],
        backgroundColor: Color.fromARGB(255, 172, 49, 49), // Match the background
        selectedItemColor: Colors.white, // White for selected tab
        unselectedItemColor: Colors.white60, // Light gray for unselected tabs
      ),
    );
  }
}
