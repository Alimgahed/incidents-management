// lib/widgets/alarm_banner.dart

import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';


class AlarmBanner extends StatelessWidget {
  final ValveModel valve;
  final double distanceMeters;
  final VoidCallback onDismiss;

  const AlarmBanner({
    super.key,
    required this.valve,
    required this.distanceMeters,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'تحذير! أنت قريب من محبس مياه',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  valve.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.social_distance, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                'المسافة: ${distanceMeters.toStringAsFixed(1)} متر',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          if (valve.description != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    valve.description!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDismiss,
              icon: const Icon(Icons.volume_off),
              label: const Text('إيقاف التنبيه'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}