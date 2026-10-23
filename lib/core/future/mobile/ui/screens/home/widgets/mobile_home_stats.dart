import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';

class MobileHomeStats extends StatelessWidget {
  final List<CurrentIncidentModel> incidents;
  final DashboardCubit dashboardCubit;

  const MobileHomeStats({
    super.key,
    required this.incidents,
    required this.dashboardCubit,
  });

  @override
  Widget build(BuildContext context) {
    var totalActive = 0;
    var criticalCount = 0;
    var highCount = 0;
    var mediumCount = 0;
    var lowCount = 0;

    // Single pass over incidents to compute all counts efficiently
    for (var i = 0; i < incidents.length; i++) {
      final incident = incidents[i];
      final status = incident.currentIncidentStatus;
      final severity = incident.currentIncidentSeverity;

      if (status != 6 && status != 7) {
        totalActive++;
      }

      switch (severity) {
        case 4:
          criticalCount++;
          break;
        case 3:
          highCount++;
          break;
        case 2:
          mediumCount++;
          break;
        case 1:
          lowCount++;
          break;
      }
    }

    final totalCount = incidents.isEmpty ? 1 : incidents.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeroActiveCard(totalActive),
        const SizedBox(height: 12),
        _buildSeverityCardsRow(
          criticalCount: criticalCount,
          highCount: highCount,
          mediumCount: mediumCount,
          lowCount: lowCount,
          totalCount: totalCount,
        ),
      ],
    );
  }

  Widget _buildHeroActiveCard(int totalActive) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E56A0), Color(0xFF163E75), Color(0xFF0F2B56)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163E75).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              left: -20,
              bottom: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 80,
              top: -25,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'الحالة التشغيلية الآن',
                              style: TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'إجمالي البلاغات النشطة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '$totalActive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityCardsRow({
    required int criticalCount,
    required int highCount,
    required int mediumCount,
    required int lowCount,
    required int totalCount,
  }) {
    return Row(
      children: [
        // 1. Low (منخفضة)
        Expanded(
          child: _buildSeverityCard(
            label: 'منخفضة',
            count: lowCount,
            total: totalCount,
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF10B981),
            barColor: const Color(0xFF10B981),
            isSelected: dashboardCubit.selectedSeverity == 1,
            onTap: () {
              final newSeverity =
                  dashboardCubit.selectedSeverity == 1 ? null : 1;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
        const SizedBox(width: 8),

        // 2. Critical (حرجة)
        Expanded(
          child: _buildSeverityCard(
            label: 'حرجة',
            count: criticalCount,
            total: totalCount,
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFFEF4444),
            barColor: const Color(0xFFEF4444),
            isSelected: dashboardCubit.selectedSeverity == 4,
            onTap: () {
              final newSeverity =
                  dashboardCubit.selectedSeverity == 4 ? null : 4;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
        const SizedBox(width: 8),

        // 3. High (عالية)
        Expanded(
          child: _buildSeverityCard(
            label: 'عالية',
            count: highCount,
            total: totalCount,
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF59E0B),
            barColor: const Color(0xFFF59E0B),
            isSelected: dashboardCubit.selectedSeverity == 3,
            onTap: () {
              final newSeverity =
                  dashboardCubit.selectedSeverity == 3 ? null : 3;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
        const SizedBox(width: 8),

        // 4. Medium (متوسطة)
        Expanded(
          child: _buildSeverityCard(
            label: 'متوسطة',
            count: mediumCount,
            total: totalCount,
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF2563EB),
            barColor: const Color(0xFF2563EB),
            isSelected: dashboardCubit.selectedSeverity == 2,
            onTap: () {
              final newSeverity =
                  dashboardCubit.selectedSeverity == 2 ? null : 2;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityCard({
    required String label,
    required int count,
    required int total,
    required IconData icon,
    required Color iconColor,
    required Color barColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final progress = total > 0 ? (count / total).clamp(0.08, 1.0) : 0.08;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? barColor : const Color(0xFFEAEEF4),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? barColor.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 15),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: count > 0 ? primaryTextColor : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? primaryTextColor : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 3.5,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
