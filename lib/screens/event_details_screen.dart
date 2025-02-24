import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:new_event/screens/event_registration_screen.dart';


class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late CarouselSliderController carouselController;

  int carouselCurrentIndex = 1;
  String? choiceChipsValue;

  List<Map<String, String>> dummyEvents = [
    {
      "title": "Flutter Workshop",
      "date": "Feb 15, 2025",
      "time": "10:00 AM - 2:00 PM",
      "location": "Tech Park, NY",
      "image": "https://picsum.photos/seed/101/600"
    },
    {
      "title": "AI & ML Conference",
      "date": "Feb 20, 2025",
      "time": "9:00 AM - 5:00 PM",
      "location": "Silicon Valley, CA",
      "image": "https://picsum.photos/seed/102/600"
    },
    {
      "title": "Startup Pitch Event",
      "date": "Feb 25, 2025",
      "time": "4:00 PM - 7:00 PM",
      "location": "Innovation Hub, TX",
      "image": "https://picsum.photos/seed/103/600"
    },
    {
      "title": "Cybersecurity Summit",
      "date": "Mar 5, 2025",
      "time": "8:30 AM - 3:00 PM",
      "location": "Downtown Conference Hall, LA",
      "image": "https://picsum.photos/seed/104/600"
    },
  ];

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
@override
void initState() {
  super.initState();
  carouselController = CarouselSliderController(); // Change this
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Carousel Slider Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  const Text('Events today', style: TextStyle(fontSize: 18)),
                  CarouselSlider(
                    items: dummyEvents.map((event) {
                      return FlipCard(
                        fill: Fill.fillBack,
                        direction: FlipDirection.HORIZONTAL,
                        front: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            event["image"]!,
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
                              event["title"]!,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    carouselController: carouselController,
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
                  ),
                ],
              ),
            ),

            // Upcoming Events Section
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('Upcoming Events', style: TextStyle(fontSize: 18)),
                    ),

                    // Choice Chips
                    Wrap(
                      spacing: 8.0,
                      children: ['Seminars', 'Webinars', 'Workshops'].map((category) {
                        return ChoiceChip(
                          label: Text(category),
                          selected: choiceChipsValue == category,
                          onSelected: (bool selected) {
                            setState(() {
                              choiceChipsValue = selected ? category : null;
                            });
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: choiceChipsValue == category ? Colors.white : Colors.black,
                          ),
                          backgroundColor: Colors.grey.shade200,
                        );
                      }).toList(),
                    ),

                    // Event List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: dummyEvents.length,
                        itemBuilder: (context, index) {
                          final event = dummyEvents[index];
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
                                  event["image"]!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                event["title"]!,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${event["date"]} | ${event["time"]}\n${event["location"]}",
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                              onTap: () {
                                // Navigate to event details page
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            Container(
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
                      children: [
                        const Icon(Icons.favorite_border, size: 25, color: Colors.grey),
                        const Text('Events'),
                      ],
                    ),
                  ),
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventRegistrationScreen()),
    );
  },
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.add_circle_outline, size: 25, color: Colors.grey),
      const Text('Create'),
    ],
  ),
),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
