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

  // Theme colors
  final Color _primaryColor = const Color(0xFF3EBBCA);
  final Color _backgroundColor = Colors.white;
  final Color _cardColor = Colors.white;
  final Color _textFieldBgColor = const Color(0xFFF5F7FA);

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
    _noParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 630,
    );
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
          content: Text('Please select an event banner'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    int? noParticipants = int.tryParse(_noParticipantsController.text);
    if (noParticipants == null) {
      print("Invalid number of participants");
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
        link: _linkController.text,
        noparticipants: noParticipants);

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Registration Successful',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: _primaryColor, size: 60),
            const SizedBox(height: 16),
            const Text('Event has been successfully registered.'),
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
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Create Event',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: _cardColor,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Event',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter event details below',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Organizer Information'),
                      _buildTextField(
                        _nameController,
                        'Your Name',
                        Icons.person_outline,
                      ),
                      _buildDropdownField(
                        'Batch',
                        _batch,
                        _selectedBatch,
                        (val) => setState(() => _selectedBatch = val),
                        Icons.school_outlined,
                      ),
                      _buildDropdownField(
                        'Department',
                        _departments,
                        _selectedDepartment,
                        (val) => setState(() => _selectedDepartment = val),
                        Icons.business_outlined,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Event Information'),
                      _isLoadingCategories
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(
                                  color: _primaryColor,
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : _buildDropdownField(
                              'Category',
                              _eventCategories,
                              _selectedCategory,
                              (val) => setState(() => _selectedCategory = val),
                              Icons.category_outlined,
                            ),
                      _buildTextField(
                        _eventNameController,
                        'Event Name',
                        Icons.event_outlined,
                      ),
                      _buildTextField(
                        _eventPurposeController,
                        'Event Purpose',
                        Icons.description_outlined,
                      ),
                      _buildDatePickerField(),
                      _buildTextField(
                        _eventVenueController,
                        'Venue',
                        Icons.location_on_outlined,
                      ),
                      _buildTextField(
                        _noParticipantsController,
                        'Maximum Participants',
                        Icons.group_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Event Banner'),
                      _buildImagePicker(),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isSubmitting
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: _primaryColor,
                                  strokeWidth: 3,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _submitRegistration,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'SUBMIT EVENT',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: _primaryColor,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: _textFieldBgColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        style: const TextStyle(fontSize: 14),
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
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: _primaryColor,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: _textFieldBgColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        value: selectedValue,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(
              option,
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
        icon: Icon(
          Icons.arrow_drop_down,
          color: _primaryColor,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _eventDateController,
        decoration: InputDecoration(
          labelText: 'Event Dates',
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.calendar_today_outlined,
            color: _primaryColor,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: _textFieldBgColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        style: const TextStyle(fontSize: 14),
        readOnly: true,
        onTap: _pickDateRange,
        validator: (value) =>
            value!.isEmpty ? 'Please select event dates' : null,
      ),
    );
  }

  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _primaryColor,
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
              radius: const Radius.circular(8),
              dashPattern: const [6, 3],
              strokeWidth: 1.5,
              color: Colors.grey.shade400,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _textFieldBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Upload event banner',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recommended: 1200 × 630',
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
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _image!,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: _pickImage,
                      constraints: const BoxConstraints(
                        minHeight: 36,
                        minWidth: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
