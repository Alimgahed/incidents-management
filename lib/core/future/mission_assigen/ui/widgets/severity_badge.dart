import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/colors.dart';

class SeverityBadge extends StatelessWidget {
  final int? severity;
  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _severityLabel(severity),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(int? severity) {
    switch (severity) {
      case 1:
        return const Color(0xFF22C55E); // green
      case 2:
        return const Color(0xFFFFC107); // blue (medium severity)
      case 3:
        return const Color(0xFFF97316); // orange
      case 4:
        return const Color(0xFFEF4444); // red
      default:
        return secondaryTextColor;
    }
  }

  String _severityLabel(int? severity) {
    switch (severity) {
      case 1:
        return 'منخفض';
      case 2:
        return 'متوسطة';
      case 3:
        return 'عالية';
      case 4:
        return 'عاجلة';
      default:
        return 'غير محدد';
    }
  }
}
