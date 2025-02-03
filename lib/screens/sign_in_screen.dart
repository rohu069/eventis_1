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

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _studentIdFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isLoading = false;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create user authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Save user details to Firestore (Collection: "users", Document: Student ID)
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

        // Navigate to home screen (or login screen)
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
      {TextInputType keyboardType = TextInputType.text, TextInputAction? action, FocusNode? focusNode, FocusNode? nextFocus}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: action ?? TextInputAction.next,
      focusNode: focusNode,
      onFieldSubmitted: (value) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      decoration: InputDecoration(
        hintText: hint,  // Changed from labelText to hintText
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),  // Set the radius for rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),  // Same for enabled state
          borderSide: BorderSide(color: Colors.grey, width: 1), // Optional border color for enabled state
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),  // Same for focused state
          borderSide: BorderSide(color: Color.fromARGB(255, 122, 17, 17), width: 2), // Border color when focused
        ),
        filled: true,
        fillColor: Colors.white,
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
      action: TextInputAction.done,
      focusNode: _passwordFocus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign In',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 122, 17, 17),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 122, 17, 17),
              Color.fromARGB(255, 172, 49, 49),
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(_nameController, 'Enter your name', focusNode: _nameFocus, nextFocus: _studentIdFocus),
              SizedBox(height: 16),
              _buildTextField(_studentIdController, 'Enter your Student ID', focusNode: _studentIdFocus, nextFocus: _phoneFocus),
              SizedBox(height: 16),
              _buildTextField(_phoneController, 'Enter your phone number', keyboardType: TextInputType.phone, focusNode: _phoneFocus, nextFocus: _emailFocus),
              SizedBox(height: 16),
              _buildTextField(_emailController, 'Enter your email', keyboardType: TextInputType.emailAddress, focusNode: _emailFocus, nextFocus: _passwordFocus),
              SizedBox(height: 16),
              _buildPasswordField(),
              SizedBox(height: 16),
              _isLoading  // Show loading indicator if sign-up is in progress
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(minimumSize: Size(150, 50)),
                      child: Text('Sign Up'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
