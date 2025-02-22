import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
// import 'package:appwrite/models.dart';
import 'admin_login_screen.dart';
import 'event_details_screen.dart';
import 'sign_in_screen.dart';

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
    // 🔍 Check if a user is already logged in
    try {
      final user = await account.get();
      if (user.$id.isNotEmpty) {
        print("✅ User already logged in: ${user.$id}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EventDetailsScreen()),
        );
        return; // Exit function if already logged in
      }
    } catch (e) {
      print("⚠ No active session found. Proceeding with login...");
    }

    // ✅ Now, create a new login session
    await account.createEmailPasswordSession(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // ✅ Navigate to event details screen after successful login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EventDetailsScreen()),
    );
  } on AppwriteException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: ${e.message}')),
    );
  }
}

  // Navigate to Admin Login page
  void _navigateToAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminLoginScreen()),
    );
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
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: _navigateToAdminLogin,
                ),
              ],
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