import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'event_details_screen.dart';
import 'sign_in_screen.dart';
import 'admin_dashboard_screen.dart';

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
    ..setEndpoint('https://cloud.appwrite.io/v1') // Correct endpoint
    ..setProject('67aa277600042d235f09'); // Replace with your project ID

  late final Account account;

  @override
  void initState() {
    super.initState();
    account = Account(client);
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await account.deleteSessions();
      print("🔄 Previous session cleared.");
    } catch (_) {
      print("⚠ No previous session found. Proceeding with login...");
    }

    try {
      await account.createEmailPasswordSession(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final loggedInUser = await account.get();
      print("✅ Successfully logged in: ${loggedInUser.$id}");

      if (loggedInUser.email == "admin@yourdomain.com") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventDetailsScreen()),
        );
      }
    } on AppwriteException catch (e) {
      print("❌ Login failed: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.message}')),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/stool.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Adjust opacity for better visibility
            ),
          ),

          // Scrollable Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 40), // Increased height to push it up

                  // Animated Welcome Text
                  Animate(
                    effects: [
                      FadeEffect(duration: 600.ms),
                      SlideEffect(begin: const Offset(0, -0.5), end: Offset.zero, curve: Curves.easeOut),
                    ],
                    child: const Text(
                      "Welcome Back",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20), // Adjusted spacing

                  // Form Fields
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_emailController, "Email", false),
                        const SizedBox(height: 16),
                        _buildTextField(_passwordController, "Password", true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Animated Login Button
                  Animate(
                    effects: [FadeEffect(duration: 500.ms)],
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Log In", style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 59, 48, 61))),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Animated Sign-up Text
                  Animate(
                    effects: [
                      FadeEffect(duration: 800.ms, delay: 400.ms),
                      SlideEffect(begin: const Offset(0, 0.5), end: Offset.zero, curve: Curves.easeOut),
                    ],
                    child: TextButton(
                      onPressed: _navigateToSignUp,
                      child: const Text(
                        "Don’t have an account? Sign Up",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom Styled TextFormField
  Widget _buildTextField(TextEditingController controller, String hint, bool obscureText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: const Color.fromARGB(0, 0, 0, 0), blurRadius: 5, offset: Offset(2, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter your $hint' : null,
      ),
    );
  }
}
