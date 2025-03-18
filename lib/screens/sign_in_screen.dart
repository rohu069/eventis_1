import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
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
    ..setEndpoint('https://cloud.appwrite.io/v1') // Replace with Appwrite endpoint
    ..setProject('67aa277600042d235f09'); // Replace with Appwrite project ID
    

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

  setState(() {
    _isLoading = true;
  });

  try {
    //  Create User Account (This automatically logs in the user)
    final User newUser = await account.create(
      userId: ID.unique(),
      email: _emailController.text,
      password: _passwordController.text,
    );
    print(" User Created: ${newUser.$id}");

    //  No need to create a session manually!

    //  Fetch the authenticated user (they are already logged in)
    final User loggedInUser = await account.get();
    print(" Logged In User: ${loggedInUser.$id}");

    //  Create Document with Correct Permissions
    await databases.createDocument(
      databaseId: '67aa2889002cd582ca1c',
      collectionId: '67aa28a80008eb0d3bda',
      documentId: ID.unique(),
      data: {
        'name': _nameController.text,
        'studentId': _studentIdController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'userId': loggedInUser.$id,
      },
      permissions: [
  Permission.read(Role.any()), // Everyone can read
  Permission.write(Role.any()), // Everyone can write
],

    );
    print(" Document Created Successfully");

    // 5️ Show Success Message & Navigate to Login Screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign-up successful! Please log in.')),
    );

    await Future.delayed(Duration(milliseconds: 500));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  } on AppwriteException catch (e) {
    print(" Appwrite Exception: ${e.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign-up failed: ${e.message}')),
    );
  } catch (e) {
    print(" Unexpected Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred. Please try again.')),
    );
  }

  setState(() {
    _isLoading = false;
  });
}

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
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
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    body: Stack(
      children: [
        // Background Image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/stool.jpg'),
              fit: BoxFit.cover,
            ),
          ),

        ),

        // Dark Overlay
        IgnorePointer(
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),

        // Scrollable Content
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20), // Moves text a little higher

                    // Register Heading (Similar to Welcome Back)
                    Animate(
                      effects: [
                        FadeEffect(duration: 600.ms),
                        SlideEffect(begin: Offset(0, -0.5), end: Offset.zero, curve: Curves.easeOut),
                      ],
                      child: Text(
                        "Register",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),

                    SizedBox(height: 40), // Adjusted spacing

                    _buildTextField(_nameController, 'Enter your name'),
                    SizedBox(height: 16),
                    _buildTextField(_studentIdController, 'Enter your Student ID'),
                    SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Enter your phone number', keyboardType: TextInputType.phone),
                    SizedBox(height: 16),
                    _buildTextField(_emailController, 'Enter your email', keyboardType: TextInputType.emailAddress),
                    SizedBox(height: 16),
                    _buildPasswordField(),
                    SizedBox(height: 30),

                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Sign Up', style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 59, 48, 61))),
                          ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
