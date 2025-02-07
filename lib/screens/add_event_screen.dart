import 'package:flutter/material.dart';

class AddEventScreen extends StatelessWidget {
  AddEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Event',
          style: TextStyle(
            color: Colors.white, // Make the text white for visibility
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow of AppBar
      ),
      extendBodyBehindAppBar: true, // Allow body to extend behind AppBar
      body: SizedBox(
        width: double.infinity,
        height: double.infinity, // Ensure full height
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 122, 17, 17), // Dark Red
                Color.fromARGB(255, 172, 49, 49), // Light Red
              ],
            ),
          ),
          child: Stack(
            children: [
              // Custom shapes added to the background
              Positioned.fill(
                child: CustomPaint(
                  painter: BackgroundShapesPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter to draw geometric shapes (circles, squares, triangles)
class BackgroundShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(255, 244, 68, 68).withOpacity(0.2); // Light blue color for shapes

    // Draw circles
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.2), 100, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 80, paint);

    // Draw squares
    paint.color = const Color.fromARGB(255, 99, 38, 38).withOpacity(0.2); // Different color for squares
    canvas.drawRect(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.4), radius: 1000), paint);

    // Draw triangles
    paint.color = const Color.fromARGB(255, 238, 129, 129).withOpacity(0.2); // Different color for triangles
    Path trianglePath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.9)
      ..lineTo(size.width * 0.0, size.height * 0.9)
      ..close();
    canvas.drawPath(trianglePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
