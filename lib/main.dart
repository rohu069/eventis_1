import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';  // Import Splash Screen
import 'screens/login_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/event_registration_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Event Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF5BE8E8), // Teal color
        scaffoldBackgroundColor: Color(0xFF2E2E2E), // Grey background
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF5BE8E8), // Teal AppBar
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF10EDED), // Teal button
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/', // Start with Splash Screen
      routes: {
        '/': (context) => SplashScreen(), // Updated to Splash Screen
        '/login': (context) => LoginScreen(),
        '/sign_in': (context) => SignInScreen(),
        '/event_details': (context) => EventDetailsScreen(),
        '/event_registration': (context) => EventRegistrationScreen(),
        '/add_event': (context) => AddEventScreen(),
        '/admin_dashboard': (context) => AdminDashboardScreen(),
        '/admin_login': (context) => AdminLoginScreen(),
      },
    );
  }
}