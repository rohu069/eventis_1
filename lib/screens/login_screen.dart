import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'event_details_screen.dart';
import 'sign_in_screen.dart';
import 'admin_dashboard_screen.dart'; // Import the admin dashboard screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Appwrite Client
  final Client client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1') // ✅ Use the correct endpoint
    ..setProject('67aa277600042d235f09'); // 🔹 Replace with your Appwrite project ID

  late final Account account;

  @override
  void initState() {
    super.initState();
    account = Account(client);
  }

  // Function to handle login using Appwrite
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    //  Logout any existing session
    await account.deleteSessions();
    print("🔄 Previous session cleared.");
  } catch (_) {
    print("⚠ No previous session found. Proceeding with login...");
  }

  try {
    // Debug: Print email and password for verification
    print("Email: ${_emailController.text.trim()}");
    print("Password: ${_passwordController.text.trim()}");

    print(" Attempting login for email: ${_emailController.text.trim()}");

    await account.createEmailPasswordSession(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final loggedInUser = await account.get();
    print(" Successfully logged in: ${loggedInUser.$id}");

    if (loggedInUser.email == "admin@yourdomain.com") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  AdminDashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  EventDetailsScreen()),
      );
    }
  } on AppwriteException catch (e) {
    print(" Login failed: ${e.message}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: ${e.message}')),
    );
  }
}

  // Navigate to Sign Up page
  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/Untitleddesign.png'),
            fit: BoxFit.cover,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 16, 237, 237),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                'Login Screen',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text('Log In'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _navigateToSignUp,
                        child: const Text(
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
