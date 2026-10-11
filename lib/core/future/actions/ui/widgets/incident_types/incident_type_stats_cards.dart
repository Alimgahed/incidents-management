import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/constant/colors.dart';

class IncidentTypeStatsCards extends StatelessWidget {
  final List<IncidentType> incidentTypes;

  const IncidentTypeStatsCards({super.key, required this.incidentTypes});

  @override
  Widget build(BuildContext context) {
    final totalTypes = incidentTypes.length;
    final mainCategoriesCount = incidentTypes.map((e) => e.className).where((c) => c != null && c.isNotEmpty).toSet().length;
    
    // Total missions linked across all types
    int totalMissions = 0;
    for (final type in incidentTypes) {
      totalMissions += type.missions?.length ?? 0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final cardWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 32) / 3;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'إجمالي الأنواع',
              subtitle: 'مضافة في النظام',
              count: totalTypes,
              icon: Icons.category_rounded,
              iconColor: Colors.green.shade600,
              iconBgColor: Colors.green.shade50,
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'الفئات والتصنيفات',
              subtitle: 'لتصنيف الأنواع',
              count: mainCategoriesCount,
              icon: Icons.layers_rounded,
              iconColor: Colors.red.shade400,
              iconBgColor: Colors.red.shade50,
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'إجمالي المهام',
              subtitle: 'لجميع الأنواع',
              count: totalMissions,
              icon: Icons.assignment_rounded,
              iconColor: Colors.purple.shade400,
              iconBgColor: Colors.purple.shade50,
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
                    fontWeight: FontWeight.w900,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
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
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ],
      ),
    );
  }
}
