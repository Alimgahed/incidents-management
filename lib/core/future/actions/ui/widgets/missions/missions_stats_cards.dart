import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';

class MissionsStatsCards extends StatelessWidget {
  final List<AllMissionModel> missions;

  const MissionsStatsCards({super.key, required this.missions});

  @override
  Widget build(BuildContext context) {
    final totalMissions = missions.length;
    final distinctCategoriesCount = missions
        .map((e) => e.className)
        .where((c) => c != null && c.isNotEmpty)
        .toSet()
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final cardWidth = isMobile
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'إجمالي المهام',
              subtitle: 'المسجلة في النظام',
              count: totalMissions,
              icon: Icons.assignment_rounded,
              iconColor: const Color(0xFF1B4F8A),
              iconBgColor: const Color(0xFFE8F1FC),
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'التصنيفات والفئات',
              subtitle: 'المرتبطة بالمهام',
              count: distinctCategoriesCount,
              icon: Icons.category_rounded,
              iconColor: Colors.teal.shade700,
              iconBgColor: Colors.teal.shade50,
              width: cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required int count,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }
}
