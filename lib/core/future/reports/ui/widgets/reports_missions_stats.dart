import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';

class ReportsMissionsStatsCard extends StatelessWidget {
  final ReportsLoaded state;

  const ReportsMissionsStatsCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat('#,###');
    final s = state.missionsStats;

    // Strictly real data from actual incidents
    final totalMissions = s.totalMissions;
    final completedPct = s.completedPercentage;
    final inProgress = s.inProgressMissions;
    final notStartedPct = s.notStartedPercentage;
    final avgMissions = s.avgMissionsPerIncident;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${s.incidentsWithMissionsCount} أزمة بها مهام',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const Text(
                'إحصائيات المهام',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Items List
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. إجمالي المهام
                _buildMissionRow(
                  label: 'إجمالي المهام',
                  value: f.format(totalMissions),
                  icon: Icons.assignment_outlined,
                  iconColor: const Color(0xFF1B72E8),
                  iconBg: const Color(0xFFEFF6FF),
                ),
                // 2. المهام المكتملة
                _buildMissionRow(
                  label: 'المهام المكتملة',
                  value: totalMissions > 0
                      ? '${completedPct.toStringAsFixed(1)}% (${s.completedMissions})'
                      : '0%',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF10B981),
                  iconBg: const Color(0xFFECFDF5),
                ),
                // 3. قيد التنفيذ
                _buildMissionRow(
                  label: 'قيد التنفيذ',
                  value: f.format(inProgress),
                  icon: Icons.play_circle_outline_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  iconBg: const Color(0xFFEFF6FF),
                ),
                // 4. لم يبدأ
                _buildMissionRow(
                  label: 'لم يبدأ',
                  value: totalMissions > 0
                      ? '${notStartedPct.toStringAsFixed(1)}% (${s.notStartedMissions})'
                      : '0%',
                  icon: Icons.pause_circle_outline_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  iconBg: const Color(0xFFFEF3C7),
                ),
                // 5. متوسط عدد المهام لكل أزمة
                _buildMissionRow(
                  label: 'متوسط عدد المهام لكل أزمة',
                  value: avgMissions.toStringAsFixed(1),
                  icon: Icons.person_outline_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBg: const Color(0xFFF3E8FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionRow({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Value on Left
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            fontFamily: 'Cairo',
          ),
        ),
        // Icon + Label on Right
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
          ],
        ),
      ],
    );
  }
}
