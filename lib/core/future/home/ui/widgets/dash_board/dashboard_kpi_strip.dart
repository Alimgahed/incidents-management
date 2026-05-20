import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

/// Live operational KPIs from the current incident list only (no dummy values).
class DashboardKpiStrip extends StatelessWidget {
  final List<CurrentIncidentModel> incidents;
  final bool connected;

  const DashboardKpiStrip({
    super.key,
    required this.incidents,
    required this.connected,
  });

  static int _missionsTotal(List<CurrentIncidentModel> list) {
    var n = 0;
    for (final i in list) {
      n += i.currentIncidentWithMissions?.length ?? 0;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final total = incidents.length;
    final critical = incidents.where((i) => i.currentIncidentSeverity == 4).length;
    final active = incidents.where((i) => (i.currentIncidentStatus ?? 0) != 7).length;
    final missions = _missionsTotal(incidents);

    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  connected ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                  size: 18,
                  color: connected ? const Color(0xFF059669) : const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 6),
                Text(
                  connected ? 'متصل بالتدفق المباشر' : 'غير متصل',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: connected ? const Color(0xFF059669) : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, c) {
                final narrow = c.maxWidth < 520;
                final children = [
                  _KpiTile(
                    label: 'إجمالي الأزمات',
                    value: '$total',
                    icon: Icons.emergency_outlined,
                    color: const Color(0xFF1E3A5F),
                  ),
                  _KpiTile(
                    label: 'حرجة (شدة 4)',
                    value: '$critical',
                    icon: Icons.priority_high,
                    color: const Color(0xFFDC2626),
                  ),
                  _KpiTile(
                    label: 'نشطة (حالة ≠ 7)',
                    value: '$active',
                    icon: Icons.play_circle_outline,
                    color: const Color(0xFF2563EB),
                  ),
                  _KpiTile(
                    label: 'المهام (مجمّع)',
                    value: '$missions',
                    icon: Icons.checklist_rtl,
                    color: const Color(0xFF0D9488),
                  ),
                ];
                if (narrow) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: children
                        .map(
                          (w) => SizedBox(
                            width: (c.maxWidth - 8) / 2,
                            child: w,
                          ),
                        )
                        .toList(),
                  );
                }
                return Row(
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(child: children[i]),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
