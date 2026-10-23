import 'package:flutter/material.dart';

class ValveNearbyAlertCallout extends StatelessWidget {
  final double distanceMeters;
  final bool isCritical;
  final bool isMuted;
  final VoidCallback onTap;
  final VoidCallback onStopAlert;

  const ValveNearbyAlertCallout({
    super.key,
    required this.distanceMeters,
    this.isCritical = false,
    this.isMuted = false,
    required this.onTap,
    required this.onStopAlert,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = isCritical || distanceMeters <= 0.5
        ? 'أقل من نصف متر (0.5 م)'
        : distanceMeters < 1.0
            ? '${(distanceMeters * 100).round()} سم'
            : '${distanceMeters.toStringAsFixed(0)} متر';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main Tooltip Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626), // Strong red matching screenshot
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stop / Mute Alert button
                InkWell(
                  onTap: onStopAlert,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMuted ? Icons.volume_off_rounded : Icons.notifications_off_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Text labels
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isCritical ? '⚠️ محبس مياه ملاصق لك!' : 'محبس مياه قريب منك',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'المسافة: $distanceText',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),

                // Alert Bell Icon
                Icon(
                  isCritical ? Icons.warning_amber_rounded : Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),

          // Downward pointer beak (triangle)
          CustomPaint(
            size: const Size(14, 7),
            painter: _TrianglePainter(color: const Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
