import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Import intl for date formatting

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() => _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  final _eventPurposeController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventVenueController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;
  String? _selectedDepartment;

  final List<String> _eventCategories = [
    'Competition and Challenges',
    'Hackathon',
    'Quiz',
    'Seminar',
    'Tech Bootcamps',
    'Tech Events',
    'Webinar',
    'Workshop'
  ];

  final List<String> _department = [
    'Civil',
    'Computer',
    'Electrical',
    'Electronics',
    'Information Technology',
    'Mechanical',
    'Safety and Fire'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _eventPurposeController.dispose();
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventVenueController.dispose();
    super.dispose();
  }

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
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Successful'),
            content: const Text(
                'You have successfully registered for the event. Please wait for confirmation from the admin.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildBottomNavBar() {
  return BottomNavigationBar(
    currentIndex: 1, // Set the default index to your current screen (Event Registration)
    onTap: (index) {
      if (index == 0) {
        Navigator.pop(context); // Go back to the previous screen
      }
      // Add more logic if you want to handle other tab selections
    },
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.info),
        label: 'Event Details',
      ),
      BottomNavigationBarItem(
        icon: SizedBox(width: 48), // Creates a gap between items
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.app_registration),
        label: 'Register',
      ),
    ],
    backgroundColor: const Color.fromARGB(255, 172, 49, 49), // Custom background color
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white60,
  );
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
              automaticallyImplyLeading: false,
              title: const Text(
                'Register for Event',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(_nameController, 'Your Name'),
                      _buildTextField(_batchController, 'Batch'),
                      _buildDropdownField(
                        hintText: 'Select Department',
                        value: _selectedDepartment,
                        items: _department,
                        onChanged: (value) => setState(() => _selectedDepartment = value),
                      ),
                      _buildDropdownField(
                        hintText: 'Select Category',
                        value: _selectedCategory,
                        items: _eventCategories,
                        onChanged: (value) => setState(() => _selectedCategory = value),
                      ),
                      _buildTextField(_eventNameController, 'Event Name'),
                      _buildTextField(_eventPurposeController, 'Event Purpose'),
                      _buildDatePickerField(),
                      _buildTextField(_eventVenueController, 'Event Venue'),
                      const SizedBox(height: 16),
                      _buildImagePicker(),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitRegistration,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color.fromARGB(255, 122, 17, 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(color: Colors.white),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $hintText.' : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(color: Colors.white),
        ),
        hint: Text(hintText),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null || value.isEmpty ? 'Please select $hintText.' : null,
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _eventDateController,
        readOnly: true,
        decoration: const InputDecoration(
          hintText: 'Event Date (YYYY-MM-DD)',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            borderSide: BorderSide.none,
          ),
          suffixIcon: Icon(Icons.calendar_today),
          errorStyle: TextStyle(color: Colors.white),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            _eventDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
        validator: (value) => value == null || value.isEmpty ? 'Please enter the event date.' : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: _image == null ? const Center(child: Text('Pick an Image')) : Image.file(_image!, fit: BoxFit.cover),
      ),
    );
  }
}
