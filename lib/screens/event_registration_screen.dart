import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_event/screens/event_details_screen.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'package:intl/intl.dart';


class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() => _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _eventPurposeController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventVenueController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedCategory;
  String? _selectedDepartment;
  String? _selectedBatch;
  bool _isSubmitting = false;

  final List<String> _batch = [
    'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
    'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'
  ];

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
    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    String? errorMessage = await AppwriteService.registerEvent(
      name: _nameController.text,
      batch: _selectedBatch!,
      department: _selectedDepartment!,
      category: _selectedCategory!,
      eventName: _eventNameController.text,
      eventPurpose: _eventPurposeController.text,
      eventDate: _eventDateController.text,
      eventVenue: _eventVenueController.text,
      eventImage: _image!,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (errorMessage == null) {
      _showRegistrationSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: const Text('You have successfully registered for the event.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EventDetailsScreen()),
              );
            },
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
              _buildDropdownField('Select Batch', _batch, _selectedBatch, (val) => setState(() => _selectedBatch = val)),
              _buildDropdownField('Select Department', _departments, _selectedDepartment, (val) => setState(() => _selectedDepartment = val)),
              _buildDropdownField('Select Category', _eventCategories, _selectedCategory, (val) => setState(() => _selectedCategory = val)),
              _buildTextField(_eventNameController, 'Event Name'),
              _buildTextField(_eventPurposeController, 'Event Purpose'),
              _buildDatePickerField(),
              _buildTextField(_eventVenueController, 'Event Venue'),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
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

  /// ✅ **Fix: Dropdown Field Method**
  Widget _buildDropdownField(String label, List<String> options, String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        value: selectedValue,
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

Widget _buildDatePickerField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: _eventDateController, // Controller for selected date
        decoration: InputDecoration(
          labelText: 'Select Event Date Range',
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDateRange, // Open date range picker
          ),
        ),
        readOnly: true,
        validator: (value) => value!.isEmpty ? 'Please select a date range' : null,
      ),
      const SizedBox(height: 16), // Add spacing below the date field
    ],
  );
}

Future<void> _pickDateRange() async {
  DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );

  if (picked != null) {
    setState(() {
      // Format dates to "YYYY-MM-DD" and update text field
      String startDate = DateFormat('yyyy-MM-dd').format(picked.start);
      String endDate = DateFormat('yyyy-MM-dd').format(picked.end);

      _eventDateController.text = "$startDate → $endDate"; // Set formatted text
    });
  }
}

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _image == null
            ? const Center(child: Text('Tap to pick an image'))
            : Image.file(_image!, fit: BoxFit.cover),
      ),
    );
  }
}
