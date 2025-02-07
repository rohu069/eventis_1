import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance.collection("users").doc(_studentIdController.text.trim()).set({
          "name": _nameController.text.trim(),
          "studentId": _studentIdController.text.trim(),
          "phone": _phoneController.text.trim(),
          "email": _emailController.text.trim(),
          "uid": userCredential.user!.uid,
        });

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-up successful!')),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)), // Text color white
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)), // Subtle white hint text
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: const Color.fromARGB(179, 0, 0, 0)), // White border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)), // Stronger white border on focus
        ),
        filled: true,
        fillColor:  Colors.white.withOpacity(0.8), // Fully transparent field
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      _passwordController,
      'Enter your password',
      keyboardType: TextInputType.visiblePassword,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/Untitleddesign.png',
              fit: BoxFit.cover,
            ),
          ),

          // Transparent Overlay
          Container(
            color: Colors.black.withOpacity(0.3), // Light overlay for better visibility
          ),

          // Form and Button Container
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40), // Adjusted space from top
                    _buildTextField(_nameController, 'Enter your name'),
                    SizedBox(height: 16),
                    _buildTextField(_studentIdController, 'Enter your Student ID'),
                    SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Enter your phone number', keyboardType: TextInputType.phone),
                    SizedBox(height: 16),
                    _buildTextField(_emailController, 'Enter your email', keyboardType: TextInputType.emailAddress),
                    SizedBox(height: 16),
                    _buildPasswordField(),
                    SizedBox(height: 30),

                    // Sign-Up Button
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Colors.teal, // Consistent button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                    SizedBox(height: 20), // Reduced extra bottom space
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
