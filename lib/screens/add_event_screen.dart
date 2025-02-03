import 'package:flutter/material.dart';

class AddEventScreen extends StatelessWidget {
    AddEventScreen({super.key});
  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventCategoryController = TextEditingController();
  final _eventDescriptionController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Event')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _eventDateController,
              decoration: InputDecoration(labelText: 'Event Date'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _eventCategoryController,
              decoration: InputDecoration(labelText: 'Event Category'),
            ),
            TextField(
              controller: _eventDescriptionController,
              decoration: InputDecoration(labelText: 'Event Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate event addition success
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Event Added'),
                      content: Text('The event has been successfully added.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}
