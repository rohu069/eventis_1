import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Create a flip animation that goes from 0 to 2*pi (full 360 degree rotation)
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        // Using elasticOut for a bouncy finish to the rotation
        curve: Curves.easeOutBack,
      ),
    );

    // Start the animation
    _controller.forward();

    // Navigate after the animation completes plus a small delay
    Timer(const Duration(milliseconds: 2300), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 255, 255, 255), // Keeping the teal background
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Create a 3D rotation transform around the Y axis
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(_flipAnimation.value),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/logo.png',
                    width: 280,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
