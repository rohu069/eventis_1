import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'admin_login_screen.dart'; // Import the AdminLoginScreen
import 'event_details_screen.dart'; // Import the EventDetailsScreen
import 'sign_in_screen.dart'; // Import the SignUpScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle login with Firebase
  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Firebase sign-in using email/password
        await _auth.signInWithEmailAndPassword(
          email: _usernameController.text, // Using the username as email
          password: _passwordController.text,
        );

        // If successful, navigate to the event details screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventDetailsScreen()),
        );
      } on FirebaseAuthException catch (e) {
        // Handle errors (invalid credentials, etc.)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.message}')),
        );
      }
    }
  }

  // Function to handle navigation to Admin Login page
  void _navigateToAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminLoginScreen()),
    );
  }

  // Function to navigate to the Sign Up page
  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()), // Navigate to SignUpScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color using gradient
      body: Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/Untitleddesign.png'), // Ensure the image is in the assets folder
      fit: BoxFit.cover, // Cover the entire screen
    ),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromARGB(255, 16, 237, 237), // Cyan
        Color.fromARGB(255, 255, 255, 255), // White
      ],
    ),
  ),
  child: Column(
    children: [
      AppBar(
        title: Text(
          'Login Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: _navigateToAdminLogin,
          ),
        ],
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8), // Make fields slightly transparent
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: Text('Log In'),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: _navigateToSignUp,
                  child: Text(
                    'Don’t have an account? Sign Up',
                    style: TextStyle(color: Colors.black),
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

    );
  }
}
