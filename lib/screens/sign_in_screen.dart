import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';

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

  final Client client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1')
    ..setProject('67aa277600042d235f09');

  late final Account account;
  late final Databases databases;

  @override
  void initState() {
    super.initState();
    account = Account(client);
    databases = Databases(client);
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await account.create(
        userId: ID.unique(),
        email: _emailController.text,
        password: _passwordController.text,
      );

      await databases.createDocument(
        databaseId: '67aa2889002cd582ca1c',
        collectionId: '67aa28a80008eb0d3bda',
        documentId: ID.unique(),
        data: {
          'name': _nameController.text,
          'studentId': _studentIdController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'userId': user.$id,
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up successful! Please log in.')),
      );

      await Future.delayed(Duration(milliseconds: 500));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: ${e.message}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text,
      bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'This field is required' : null,
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/stool.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                      "NEW USER?",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Color.fromARGB(137, 255, 255, 255),
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
                      "Register Here",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  Animate(
                    effects: [
                      FadeEffect(duration: 600.ms),
                      SlideEffect(
                          begin: Offset(0, 0.2),
                          end: Offset.zero,
                          curve: Curves.easeOut),
                    ],
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 255, 255, 255)
                                  .withOpacity(0.1),
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
                                  _nameController, 'Enter your name'),
                              SizedBox(height: 16),
                              _buildTextField(_studentIdController,
                                  'Enter your Student ID'),
                              SizedBox(height: 16),
                              _buildTextField(
                                  _phoneController, 'Enter your phone number',
                                  keyboardType: TextInputType.phone),
                              SizedBox(height: 16),
                              _buildTextField(
                                  _emailController, 'Enter your email',
                                  keyboardType: TextInputType.emailAddress),
                              SizedBox(height: 16),
                              _buildTextField(
                                  _passwordController, 'Enter your password',
                                  obscureText: true),
                              SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    elevation: 5,
                                    shadowColor: Colors.indigo.withOpacity(0.5),
                                  ),
                                  child: _isLoading
                                      ? CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 3)
                                      : Text('Sign Up',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2)),
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
