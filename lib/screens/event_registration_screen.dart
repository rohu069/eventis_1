import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    'Competition and Challenges', 'Hackathon', 'Quiz', 'Seminar', 
    'Tech Bootcamps', 'Tech Events', 'Webinar', 'Workshop'
  ];

  final List<String> _departments = [
    'Civil', 'Computer', 'Electrical', 'Electronics', 
    'Information Technology', 'Mechanical', 'Safety and Fire'
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

  Future<void> _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        _showErrorDialog("User not logged in.");
        return;
      }

      try {
        String imageUrl = "";
        if (_image != null) {
          imageUrl = await _uploadImageToFirebase(_image!, userId);
        }

        // Store event details under user's collection
        await FirebaseFirestore.instance.collection('users').doc(userId)
          .collection('registrations').add({
            'name': _nameController.text,
            'batch': _batchController.text,
            'department': _selectedDepartment,
            'category': _selectedCategory,
            'eventName': _eventNameController.text,
            'eventPurpose': _eventPurposeController.text,
            'eventDate': _eventDateController.text,
            'eventVenue': _eventVenueController.text,
            'imageUrl': imageUrl,
            'timestamp': FieldValue.serverTimestamp(),
        });

        _showSuccessDialog();
      } catch (e) {
        _showErrorDialog(e.toString());
      }
    }
  }

  Future<String> _uploadImageToFirebase(File image, String userId) async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref('users/$userId/event_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: const Text('You have successfully registered for the event.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register for Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Your Name'),
              _buildTextField(_batchController, 'Batch'),
              _buildDropdownField('Select Department', _departments, _selectedDepartment, (val) => setState(() => _selectedDepartment = val)),
              _buildDropdownField('Select Category', _eventCategories, _selectedCategory, (val) => setState(() => _selectedCategory = val)),
              _buildTextField(_eventNameController, 'Event Name'),
              _buildTextField(_eventPurposeController, 'Event Purpose'),
              _buildDatePickerField(),
              _buildTextField(_eventVenueController, 'Event Venue'),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitRegistration,
                child: const Text('Submit Registration'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildDatePickerField() {
    return _buildTextField(_eventDateController, 'Event Date (YYYY-MM-DD)');
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: _image == null ? const Text('Pick an Image') : Image.file(_image!, height: 150),
    );
  }
}
