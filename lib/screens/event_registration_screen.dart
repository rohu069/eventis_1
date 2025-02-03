import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the fields
  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  final _departmentController = TextEditingController();
  final _eventCategoryController = TextEditingController();
  final _eventPurposeController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventVenueController = TextEditingController();

  // Variable to hold the selected image
  File? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    // Dispose controllers to free resources
    _nameController.dispose();
    _batchController.dispose();
    _departmentController.dispose();
    _eventCategoryController.dispose();
    _eventPurposeController.dispose();
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventVenueController.dispose();
    super.dispose();
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      // If all fields are valid, show success dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Successful'),
            content:
                const Text('You have successfully registered for the event. Please wait for the confirmation from admin'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 122, 17, 17), // Dark Red
              Color.fromARGB(255, 172, 49, 49), // Light Red
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false, // Remove back button
              title: const Text('Register for Event',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
              ),
              elevation: 0, // Remove shadow
              backgroundColor: const Color.fromARGB(0, 255, 255, 255), // Transparent background
              flexibleSpace: const SizedBox.shrink(), // No extra flexible space
            ),
           Expanded(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing form fields
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Your Name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0), // Curved corners
                ),
                borderSide: BorderSide.none, // No border lines
              ),
               errorStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _batchController,
            decoration: const InputDecoration(
              hintText: 'Batch',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
                borderSide: BorderSide.none,
              ),
               errorStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your batch.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _departmentController,
            decoration: const InputDecoration(
              hintText: 'Department',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
                borderSide: BorderSide.none,
              ),
               errorStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your department.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _eventCategoryController,
            decoration: const InputDecoration(
              hintText: 'Event Category',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
                borderSide: BorderSide.none,
              ),
               errorStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the event category.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _eventPurposeController,
            decoration: const InputDecoration(
              hintText: 'Event Purpose',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
                borderSide: BorderSide.none,
              ),
               errorStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the event purpose.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _eventNameController,
            decoration: const InputDecoration(
              hintText:  'Event Name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
                borderSide: BorderSide.none,
              ),
               errorStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the event name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _eventDateController,
            decoration: const InputDecoration(
              hintText:  'Event Date (YYYY-MM-DD)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
                borderSide: BorderSide.none,
              ),
               errorStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the event date.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _eventVenueController,
            decoration: const InputDecoration(
              hintText: 'Event Venue',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
                borderSide: BorderSide.none,
              ),
              errorStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the event venue.';
              }
              return null;
            },
          ),

          // Image picker section
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: _image == null
                  ? const Center(child: Text('Pick an Image'))
                  : Image.file(_image!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),

          // Submit button
          Center(
            child: ElevatedButton(
              onPressed: _submitRegistration,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 122, 17, 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // Button corners
                ),
              ),
              child: const Text('Submit Registration'),
            ),
          ),
        ],
      ),
    ),
  ),
),

          ],
        ),
      ),
bottomNavigationBar: BottomNavigationBar(
  currentIndex: 1, // Default to Event Registration screen
  onTap: (index) {
    if (index == 0) {
      Navigator.pop(context); // Go back to Event Details
    }
  },
  type: BottomNavigationBarType.fixed, // Fixes spacing for even distribution
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.info, color: Colors.white),
      label: 'Event Details',
      backgroundColor: Color.fromARGB(255, 122, 17, 17), // Dark Red
    ),
    BottomNavigationBarItem(
      icon: SizedBox(width: 48), // Adds a gap by making this item "empty"
      label: '',
      backgroundColor: Color.fromARGB(255, 122, 17, 17), // Background consistent
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.app_registration, color: Colors.white),
      label: 'Event Registration',
      backgroundColor: Color.fromARGB(255, 172, 49, 49), // Dark Red
    ),
  ],
  backgroundColor: const Color.fromARGB(255, 172, 49, 49),
  selectedItemColor: Colors.white,
  unselectedItemColor: Colors.white60,
),
    );
  }
}
