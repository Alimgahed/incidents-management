import 'package:flutter/material.dart';

/// Pixel-perfect vector water valve icon matching GIS pipeline diagrams
class ValveIconWidget extends StatelessWidget {
  final double size;
  final Color color;

  const ValveIconWidget({
    super.key,
    this.size = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ValvePainter(color: color),
    );
  }
}

class _ValvePainter extends CustomPainter {
  final Color color;

  const _ValvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // 1. Two triangular wedges of valve body
    final path = Path();
    // Left wedge
    path.moveTo(w * 0.15, h * 0.38);
    path.lineTo(w * 0.50, h * 0.60);
    path.lineTo(w * 0.15, h * 0.82);
    path.close();

    // Right wedge
    path.moveTo(w * 0.85, h * 0.38);
    path.lineTo(w * 0.50, h * 0.60);
    path.lineTo(w * 0.85, h * 0.82);
    path.close();

    canvas.drawPath(path, fillPaint);

    // 2. Center hub circle
    canvas.drawCircle(Offset(w * 0.50, h * 0.60), w * 0.08, fillPaint);

    // 3. Vertical stem
    canvas.drawLine(
      Offset(w * 0.50, h * 0.60),
      Offset(w * 0.50, h * 0.22),
      strokePaint,
    );

    // 4. Top handwheel
    canvas.drawLine(
      Offset(w * 0.28, h * 0.22),
      Offset(w * 0.72, h * 0.22),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ValvePainter oldDelegate) =>
      oldDelegate.color != color;
}
