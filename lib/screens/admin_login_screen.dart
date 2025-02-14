import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Function to validate admin login
  Future<bool> _validateAdminLogin(String username, String password) async {
    try {
      // Query Firestore to check if admin exists
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('admin')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password) // Insecure, use hashing instead
          .get();

      return query.docs.isNotEmpty; // If there is a match, return true
    } catch (e) {
      print("Error checking admin login: $e");
      return false;
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      bool isValid = await _validateAdminLogin(
          _usernameController.text, _passwordController.text);
      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
           Color.fromARGB(255, 16, 237, 237), // Cyan
        Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(
                "Admin Login",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen
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
                      // Username text field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your username',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorStyle: TextStyle(color: Colors.white), // Set error text color to white
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      // Password text field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorStyle: TextStyle(color: Colors.white), // Set error text color to white
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      // Login button
                      ElevatedButton(
                        onPressed: _handleLogin,
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
