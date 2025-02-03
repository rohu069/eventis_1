import 'package:flutter/material.dart';
import 'admin_login_screen.dart'; // Import the AdminLoginScreen
import 'event_details_screen.dart'; // Import the EventDetailsScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Dummy authentication (Replace with actual authentication logic later)
  bool _validateLogin(String username, String password) {
    return username == 'user' && password == 'user123'; // User credentials
  }

  // Function to handle login for user
  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_validateLogin(_usernameController.text, _passwordController.text)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventDetailsScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid username or password')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color using gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 122, 17, 17), // Dark Red
              Color.fromARGB(255, 172, 49, 49), // Light Red
            ],
          ),
        ),
        child: Column(
          children: [
            // AppBar with transparent background so the gradient shows through
            AppBar(
              title: Text('Login Screen'),
              backgroundColor: Colors.transparent, // Make AppBar background transparent
              elevation: 0, // Remove the shadow
              actions: <Widget>[
                // Admin Login icon in the top-right corner
                IconButton(
                  icon: Icon(Icons.admin_panel_settings), // Admin icon
                  onPressed: _navigateToAdminLogin, // Navigate to Admin Login screen
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
                          fillColor: Colors.white,
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
                          fillColor: Colors.white,
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
                        onPressed: _handleLogin, // Handle login for regular user
                        child: Text('Log In'),
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
