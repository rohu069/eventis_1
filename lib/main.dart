  import 'package:flutter/material.dart';
//import 'package:new_event/services/appwrite_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/event_registration_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Event Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5BE8E8),
        scaffoldBackgroundColor: const Color(0xFF2E2E2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5BE8E8),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>  SplashScreen(), // EventDetailsScreen(), // AdminDashboardScreen(), //  EventRegistrationScreen(),//  LoginScreen(), //   EventRegistrationScreen(),//  
       '/login': (context) =>  LoginScreen(),
        '/sign_in': (context) => SignInScreen(),
        '/event_details': (context) =>  EventDetailsScreen(),
        '/event_registration': (context) => const EventRegistrationScreen(),
         '/add_event': (context) => AddEventScreen(),
        '/admin_dashboard': (context) =>  AdminDashboardScreen(),
        
      },
    );
  }
}
 