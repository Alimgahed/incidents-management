import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularProgressGauge extends StatelessWidget {
  final double percentage; // 0 to 100
  final String label;
  final String fraction;
  final Color color;
  final double size;

  const CircularProgressGauge({
    super.key,
    required this.percentage,
    required this.label,
    required this.fraction,
    required this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CircularGaugePainter(
              percentage: percentage,
              color: color,
            ),
            child: Center(
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: size * 0.24,
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          fraction,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  final double percentage;
  final Color color;

  _CircularGaugePainter({
    required this.percentage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.12;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc Paint
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (percentage.clamp(0.0, 100.0) / 100.0) * (2 * math.pi);
    const startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
