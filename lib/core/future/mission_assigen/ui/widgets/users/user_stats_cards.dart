import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/constant/colors.dart';

class UserStatsCards extends StatelessWidget {
  final List<ActiveUser> users;

  const UserStatsCards({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final totalUsers = users.length;
    final activeUsers = users.where((u) => u.isActive == true).length;
    final inactiveUsers = totalUsers - activeUsers;
    final groupsCount = users.map((u) => u.groupName).where((name) => name != null && name.isNotEmpty).toSet().length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final cardWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 48) / 4;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'إجمالي المستخدمين',
              subtitle: 'جميع حسابات النظام',
              count: totalUsers,
              icon: Icons.people_alt,
              iconColor: const Color(0xFF1B4F8A),
              iconBgColor: const Color(0xFF1B4F8A).withValues(alpha: 0.1),
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'المستخدمون النشطون',
              subtitle: 'حسابات تعمل حالياً',
              count: activeUsers,
              icon: Icons.how_to_reg,
              iconColor: Colors.green.shade600,
              iconBgColor: Colors.green.shade50,
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'المستخدمون غير النشطين',
              subtitle: 'حسابات غير مفعلة حالياً',
              count: inactiveUsers,
              icon: Icons.person_off,
              iconColor: Colors.red.shade400,
              iconBgColor: Colors.red.shade50,
              width: cardWidth,
            ),
            _buildStatCard(
              title: 'عدد المجموعات',
              subtitle: 'المجموعات الإدارية في النظام',
              count: groupsCount,
              icon: Icons.groups,
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
                    color: iconColor, // The text color matches the icon color in the design
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
