import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';

class CustomLineChartPainter extends CustomPainter {
  final List<MonthlyTrendPoint> points;
  final Color totalColor;
  final Color activeColor;
  final Color criticalColor;

  CustomLineChartPainter({
    required this.points,
    this.totalColor = const Color(0xFF1B72E8),
    this.activeColor = const Color(0xFF00BFA5),
    this.criticalColor = const Color(0xFFE53935),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const leftPadding = 42.0;
    const rightPadding = 20.0;
    const topPadding = 24.0;
    const bottomPadding = 32.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // Find max value to determine scale
    int maxVal = 50;
    for (final p in points) {
      if (p.total > maxVal) maxVal = p.total;
    }
    // Round maxVal up to clean multiple of 50 or 20
    final step = maxVal > 150 ? 50 : (maxVal > 60 ? 25 : 10);
    final gridMax = ((maxVal / step).ceil() * step).toDouble().clamp(40.0, 10000.0);

    // Draw horizontal grid lines and Y-axis labels
    final gridSteps = 4;
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final yLabelStyle = const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i <= gridSteps; i++) {
      final yNorm = i / gridSteps;
      final y = topPadding + (1 - yNorm) * chartHeight;
      final value = (yNorm * gridMax).round();

      // Horizontal line
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      // Y Label
      final tp = TextPainter(
        text: TextSpan(text: '$value', style: yLabelStyle),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 8, y - tp.height / 2));
    }

    // X-axis coordinates for each month
    final count = points.length;
    final xCoords = List<double>.generate(count, (i) {
      // In RTL, index 0 (January) is on the right, or standard left-to-right timeline:
      // In Arabic charts, time usually flows left-to-right (Jan -> Dec) or right-to-left.
      // Looking at the screenshot, "يناير" is on the left, "ديسمبر" is on the right!
      return leftPadding + (i / (count - 1)) * chartWidth;
    });

    // Draw X labels
    final xLabelStyle = const TextStyle(
      color: Color(0xFF64748B),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < count; i++) {
      final x = xCoords[i];
      final tp = TextPainter(
        text: TextSpan(text: points[i].label, style: xLabelStyle),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomPadding + 8));
    }

    // Helper to calculate Y for a given value
    double getY(int val) {
      final norm = (val / gridMax).clamp(0.0, 1.0);
      return topPadding + (1 - norm) * chartHeight;
    }

    // Calculate point offsets
    final totalOffsets = <Offset>[];
    final activeOffsets = <Offset>[];
    final criticalOffsets = <Offset>[];

    for (int i = 0; i < count; i++) {
      final x = xCoords[i];
      totalOffsets.add(Offset(x, getY(points[i].total)));
      activeOffsets.add(Offset(x, getY(points[i].active)));
      criticalOffsets.add(Offset(x, getY(points[i].critical)));
    }

    // Draw area gradient for Total Incidents
    final areaPath = Path();
    areaPath.moveTo(totalOffsets.first.dx, size.height - bottomPadding);
    areaPath.lineTo(totalOffsets.first.dx, totalOffsets.first.dy);

    for (int i = 0; i < totalOffsets.length - 1; i++) {
      final p0 = totalOffsets[i];
      final p1 = totalOffsets[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      areaPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }
    areaPath.lineTo(totalOffsets.last.dx, size.height - bottomPadding);
    areaPath.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          totalColor.withValues(alpha: 0.18),
          totalColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight));
    canvas.drawPath(areaPath, gradientPaint);

    // Draw Lines with smooth curves
    void drawSmoothLine(List<Offset> offsets, Color color, double strokeWidth) {
      if (offsets.isEmpty) return;
      final path = Path();
      path.moveTo(offsets.first.dx, offsets.first.dy);

      for (int i = 0; i < offsets.length - 1; i++) {
        final p0 = offsets[i];
        final p1 = offsets[i + 1];
        final controlX = (p0.dx + p1.dx) / 2;
        path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }

      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, linePaint);

      // Draw point markers
      final dotBgPaint = Paint()..color = Colors.white;
      final dotBorderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      final dotFillPaint = Paint()..color = color;

      for (final pt in offsets) {
        canvas.drawCircle(pt, 4.5, dotBgPaint);
        canvas.drawCircle(pt, 4.5, dotBorderPaint);
        canvas.drawCircle(pt, 2.2, dotFillPaint);
      }
    }

    // 1. Total Line (Blue)
    drawSmoothLine(totalOffsets, totalColor, 3.2);

    // 2. Active Line (Teal)
    drawSmoothLine(activeOffsets, activeColor, 2.6);

    // 3. Critical Line (Red)
    drawSmoothLine(criticalOffsets, criticalColor, 2.2);
  }

  @override
  bool shouldRepaint(covariant CustomLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.totalColor != totalColor ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.criticalColor != criticalColor;
  }
}
