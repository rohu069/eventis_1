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
  bool _isPasswordVisible = false;
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true;
    });

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

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.message}'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
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
          // Background Image with Parallax Effect
          Positioned.fill(
            child: Animate(
              effects: [
                ScaleEffect(
                  begin: const Offset(1.05, 1.05),
                  end: const Offset(1.0, 1.0),
                  duration: 1500.ms,
                  curve: Curves.easeOutQuad,
                ),
              ],
              child: Image.asset(
                'assets/stool.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay for better text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // App Logo or Icon (using a placeholder)
                    Animate(
                      effects: [
                        FadeEffect(duration: 800.ms),
                        ScaleEffect(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Welcome Text with Animation
                    Animate(
                      effects: [
                        FadeEffect(duration: 600.ms, delay: 300.ms),
                        SlideEffect(
                          begin: const Offset(0, -0.2),
                          end: Offset.zero,
                          curve: Curves.easeOut,
                          duration: 600.ms,
                        ),
                      ],
                      child: const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle text
                    Animate(
                      effects: [
                        FadeEffect(duration: 600.ms, delay: 400.ms),
                      ],
                      child: const Text(
                        "Sign in to continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Form with Glass Morphism Effect
                    Animate(
                      effects: [
                        FadeEffect(duration: 800.ms, delay: 500.ms),
                        SlideEffect(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                          curve: Curves.easeOut,
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _emailController,
                                hint: "Email",
                                obscureText: false,
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _passwordController,
                                hint: "Password",
                                obscureText: !_isPasswordVisible,
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 12),

                              // Forgot Password Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // Handle forgot password
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Login Button with Loading State
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    shadowColor: Colors.indigo.withOpacity(0.5),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : const Text(
                                          "Sign In",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Sign-up Text with Animation
                    Animate(
                      effects: [
                        FadeEffect(duration: 800.ms, delay: 800.ms),
                      ],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToSignUp,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Text Field with Icon
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white70,
            size: 22,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white70,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: InputBorder.none,
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter your $hint' : null,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
