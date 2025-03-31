import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_event/screens/event_details_screen.dart';
import 'package:new_event/services/appwrite_service.dart';
import 'package:intl/intl.dart';

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _eventPurposeController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventVenueController = TextEditingController();
  final _linkController = TextEditingController();
  final _noParticipantsController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedCategory;
  String? _selectedDepartment;
  String? _selectedBatch;
  bool _isSubmitting = false;
  bool _isLoadingCategories = true;

  final List<String> _batch = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8'
  ];

  final List<String> _departments = [
    'Civil',
    'Computer',
    'Electrical',
    'Electronics',
    'Information Technology',
    'Mechanical',
    'Safety and Fire'
  ];

  List<String> _eventCategories = [];

  @override
  void initState() {
    super.initState();
    _loadEventCategories();
  }

  Future<void> _loadEventCategories() async {
    List<String> categories = await AppwriteService.fetchEventCategories();
    if (mounted) {
      setState(() {
        _eventCategories = categories;
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _eventPurposeController.dispose();
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventVenueController.dispose();
    _linkController.dispose();
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
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
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
      link: _linkController.text,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (errorMessage == null) {
      _showRegistrationSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Registration Successful',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text('You have successfully registered for the event.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EventDetailsScreen()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF6200EE),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register for Event',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 91, 232, 232),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 91, 232, 232),
              Color.fromARGB(255, 91, 232, 232),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create New Event',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 91, 232, 232),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fill in the details to register your event',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Personal Information'),
                        _buildTextField(
                            _nameController, 'Your Name', Icons.person),
                        _buildDropdownField(
                            'Select Batch',
                            _batch,
                            _selectedBatch,
                            (val) => setState(() => _selectedBatch = val),
                            Icons.school),
                        _buildDropdownField(
                            'Select Department',
                            _departments,
                            _selectedDepartment,
                            (val) => setState(() => _selectedDepartment = val),
                            Icons.business),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Event Details'),
                        _isLoadingCategories
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _buildDropdownField(
                                'Select Category',
                                _eventCategories,
                                _selectedCategory,
                                (val) =>
                                    setState(() => _selectedCategory = val),
                                Icons.category),
                        _buildTextField(
                            _eventNameController, 'Event Name', Icons.event),
                        _buildTextField(_eventPurposeController,
                            'Event Purpose', Icons.description),
                        _buildDatePickerField(),
                        _buildTextField(_eventVenueController, 'Event Venue',
                            Icons.location_on),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Event Banner'),
                        _buildImagePicker(),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: _isSubmitting
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _submitRegistration,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 91, 232, 232),
                                    foregroundColor: Colors.white,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Text(
                                    'SUBMIT REGISTRATION',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 91, 232, 232),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: Color.fromARGB(255, 91, 232, 232),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options,
      String? selectedValue, Function(String?) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: Color.fromARGB(255, 91, 232, 232),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        value: selectedValue,
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color.fromARGB(255, 91, 232, 232),
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _eventDateController,
        decoration: InputDecoration(
          labelText: 'Select Event Date Range',
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: Color.fromARGB(255, 91, 232, 232),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.date_range,
              color: Color.fromARGB(255, 91, 232, 232),
            ),
            onPressed: _pickDateRange,
          ),
        ),
        readOnly: true,
        validator: (value) =>
            value!.isEmpty ? 'Please select a date range' : null,
      ),
    );
  }

  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 91, 232, 232),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 91, 232, 232),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        String startDate = DateFormat('yyyy-MM-dd').format(picked.start);
        String endDate = DateFormat('yyyy-MM-dd').format(picked.end);
        _eventDateController.text = "$startDate → $endDate";
      });
    }
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: _image == null
          ? DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(15),
              dashPattern: [6, 3], // Defines dash pattern
              strokeWidth: 2,
              color: Colors.grey.shade300,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 50,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to upload event banner',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recommended size: 1200 x 630 pixels',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    _image!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
