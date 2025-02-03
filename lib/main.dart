import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:new_event/screens/admin_login_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/event_registration_screen.dart';
import 'screens/add_event_screen.dart';
import 'package:new_event/screens/admin_dashboard_screen.dart';
import 'firebase_options.dart';
import 'screens/admin_login_screen.dart'; // Ensure this is present


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Ensure this is correct
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Event Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // The initial screen route
routes: {
  '/': (context) => LoginScreen(),
  '/sign_in': (context) => SignInScreen(),
  '/event_details': (context) => EventDetailsScreen(),
  '/event_registration': (context) => EventRegistrationScreen(),
  '/add_event': (context) => AddEventScreen(),
  '/admin_dashboard': (context) => AdminDashboardScreen(),
  '/admin_login_screen': (context) => AdminLoginScreen(), // Ensure this is correct
},
    );
  }
}
