// lib/core/future/valve/ui/alarm.dart

import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';

class AlarmBanner extends StatelessWidget {
  final ValveModel valve;
  final double distanceMeters;
  final bool isCritical;
  final bool isMuted;
  final VoidCallback onDismiss;
  final VoidCallback? onTapDetails;

  const AlarmBanner({
    super.key,
    required this.valve,
    required this.distanceMeters,
    this.isCritical = false,
    this.isMuted = false,
    required this.onDismiss,
    this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = isCritical || distanceMeters <= 0.5
        ? 'أقل من نصف متر (0.5 م)'
        : distanceMeters < 1.0
            ? '${(distanceMeters * 100).round()} سم'
            : '${distanceMeters.toStringAsFixed(0)} متر';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Stop Alert Button
          ElevatedButton.icon(
            onPressed: onDismiss,
            icon: Icon(
              isMuted ? Icons.volume_up_rounded : Icons.notifications_off_rounded,
              size: 16,
              color: const Color(0xFFDC2626),
            ),
            label: Text(
              isMuted ? 'تشغيل' : 'إيقاف التنبيه',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDC2626),
                fontFamily: 'Cairo',
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Details text
          Expanded(
            child: InkWell(
              onTap: onTapDetails,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isCritical
                        ? '⚠️ تنبيه حرج: أنت عند المحبس مباشرة!'
                        : 'محبس مياه قريب منك',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'رقم: V-${valve.id ?? ""} | المسافة: $distanceText',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Bell Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCritical ? Icons.warning_rounded : Icons.notifications_active_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}