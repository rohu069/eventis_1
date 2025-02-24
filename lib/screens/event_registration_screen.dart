import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_event/screens/event_details_screen.dart';
import 'package:new_event/services/appwrite_service.dart';

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() => _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final _nameController = TextEditingController();
  //final _batchController = TextEditingController();
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
      ' semester 1',
 'semester 2',
'semester 3',
 'semester 4',
 'semester 5',
 'semester 6',
 'semester 7',
 'semester 8'
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
    //_batchController.dispose();
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

final List<Map<String, String>> _selectedDateRanges = []; // Store selected date ranges

Future<void> _selectDateRange() async {
  DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );

  if (picked != null) {
    setState(() {
      _selectedDateRanges.add({
        "from": picked.start.toIso8601String().split('T').first,
        "to": picked.end.toIso8601String().split('T').first,
      });
    });
  }
}


void _submitRegistration() async {
  if (_formKey.currentState!.validate()) {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

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

    if (errorMessage == null) {
      _showRegistrationSuccessDialog(); // Show success dialog first
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}

// ✅ Only keep this function and remove any previous _showSuccessDialog function
void _showRegistrationSuccessDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Registration Successful'),
      content: const Text('You have successfully registered for the event.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog first
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EventDetailsScreen()),
            ); // Navigate to EventDetailsScreen after closing the dialog
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
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.teal], // White-to-Teal gradient
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Select Event Date Range',
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange, // Updated function
          ),
        ),
        readOnly: true,
        validator: (value) => _selectedDateRanges.isEmpty ? 'Please select at least one event date range' : null,
      ),
      const SizedBox(height: 10),
      ..._selectedDateRanges.map((range) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("📅 ${range["from"]} → ${range["to"]}"),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selectedDateRanges.remove(range);
                    });
                  },
                ),
              ],
            ),
          )),
    ],
  );
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
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Tap to pick an image', style: TextStyle(color: Colors.grey)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
      ),
    );
  }
}
