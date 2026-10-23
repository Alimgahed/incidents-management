import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutSegment {
  final String label;
  final double value;
  final Color color;

  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class CustomDonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double strokeWidth;
  final String centerTitle;
  final String centerSubtitle;
  final Color centerTitleColor;
  final Color centerSubtitleColor;

  CustomDonutPainter({
    required this.segments,
    this.strokeWidth = 26,
    required this.centerTitle,
    required this.centerSubtitle,
    this.centerTitleColor = const Color(0xFF1E293B),
    this.centerSubtitleColor = const Color(0xFF64748B),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final total = segments.fold<double>(0, (sum, s) => sum + s.value);

    if (total <= 0) {
      // Draw placeholder empty ring
      final emptyPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, emptyPaint);
    } else {
      double startAngle = -math.pi / 2;
      const gapAngle = 0.04; // small gap between slices for clean modern look

      for (final segment in segments) {
        if (segment.value <= 0) continue;
        final sweepAngle = (segment.value / total) * (2 * math.pi) - gapAngle;
        if (sweepAngle <= 0) continue;

        final paint = Paint()
          ..color = segment.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + (gapAngle / 2),
          sweepAngle,
          false,
          paint,
        );

        startAngle += sweepAngle + gapAngle;
      }
    }

    // Center text
    final titlePainter = TextPainter(
      text: TextSpan(
        text: centerTitle,
        style: TextStyle(
          color: centerTitleColor,
          fontSize: (radius * 0.38).clamp(16.0, 26.0),
          fontWeight: FontWeight.w800,
          fontFamily: 'Cairo',
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: radius * 1.5);

    final subPainter = TextPainter(
      text: TextSpan(
        text: centerSubtitle,
        style: TextStyle(
          color: centerSubtitleColor,
          fontSize: (radius * 0.18).clamp(10.0, 13.0),
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: radius * 1.5);

    final titleOffset = Offset(
      center.dx - titlePainter.width / 2,
      center.dy - titlePainter.height / 2 - (subPainter.height / 2),
    );
    final subOffset = Offset(
      center.dx - subPainter.width / 2,
      center.dy + titlePainter.height / 2 - 2,
    );

    titlePainter.paint(canvas, titleOffset);
    subPainter.paint(canvas, subOffset);
  }

  @override
  bool shouldRepaint(covariant CustomDonutPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.centerTitle != centerTitle ||
        oldDelegate.centerSubtitle != centerSubtitle;
  }
}
