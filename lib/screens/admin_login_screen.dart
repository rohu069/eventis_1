import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart'; // Import the AdminDashboardScreen
import 'login_screen.dart'; // Import the LoginScreen for going back

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Dummy authentication logic
  bool _validateAdminLogin(String username, String password) {
    return username == 'admin' && password == 'admin123';
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
              title: Text("Admin Login"),
              backgroundColor: Colors.transparent, // Make AppBar background transparent
              elevation: 0, // Remove the shadow
              leading: IconButton(  // This adds the back button
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen (LoginScreen)
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
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
                          labelText: 'Password',
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
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Validate admin login credentials
                            if (_validateAdminLogin(
                                _usernameController.text, _passwordController.text)) {
                              // If valid, navigate to the admin dashboard
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
                              );
                            } else {
                              // Show error if login fails
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Invalid username or password')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(150, 50),
                        ),
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
