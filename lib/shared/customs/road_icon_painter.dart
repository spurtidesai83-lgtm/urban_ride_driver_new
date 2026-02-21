import 'package:flutter/material.dart';

class RoadIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50) // Green color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;

    // Perspective lines (Trapezoid shape upside down-ish)
    // Left line /
    final leftPath = Path();
    leftPath.moveTo(width * 0.3, height * 0.1);
    leftPath.lineTo(width * 0.1, height * 0.9); 
    canvas.drawPath(leftPath, paint);

    // Right line \
    final rightPath = Path();
    rightPath.moveTo(width * 0.7, height * 0.1);
    rightPath.lineTo(width * 0.9, height * 0.9);
    canvas.drawPath(rightPath, paint);

    // Center Dashed Line
    final dashPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    double dashHeight = height * 0.2;
    double gapHeight = height * 0.15;
    double currentY = height * 0.1;
    double centerX = width * 0.5;

    while (currentY < height * 0.9) {
      canvas.drawLine(
        Offset(centerX, currentY),
        Offset(centerX, currentY + dashHeight),
        dashPaint,
      );
      currentY += dashHeight + gapHeight;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
