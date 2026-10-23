import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_cubit.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';

class ReportsTabBar extends StatelessWidget {
  final VoidCallback? onExport;

  const ReportsTabBar({
    super.key,
    this.onExport,
  });

  static const _tabs = [
    _TabItem(title: 'الملخص التنفيذي', icon: Icons.analytics_outlined),
    _TabItem(title: 'الملخص والمناطق', icon: Icons.pie_chart_outline_rounded),
    _TabItem(title: 'الأنواع والخطورة', icon: Icons.donut_large_rounded),
    _TabItem(title: 'الفروع والمناطق', icon: Icons.location_city_rounded),
    _TabItem(title: 'الحالات والمهام', icon: Icons.task_alt_rounded),
    _TabItem(title: 'التحليل الزمني', icon: Icons.timeline_rounded),
    _TabItem(title: 'التحليل الجغرافي', icon: Icons.map_outlined),
    _TabItem(title: 'الجدول التفصيلي', icon: Icons.table_chart_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      buildWhen: (p, c) =>
          p is! ReportsLoaded ||
          c is! ReportsLoaded ||
          p.activeTabIndex != c.activeTabIndex,
      builder: (context, state) {
        final activeIndex = state is ReportsLoaded ? state.activeTabIndex : 0;
        final cubit = context.read<ReportsCubit>();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(_tabs.length, (index) {
                final item = _tabs[index];
                final isSelected = activeIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => cubit.selectTab(index),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1B72E8)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 16,
                            color: isSelected
                                ? const Color(0xFF1B72E8)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF1B72E8)
                                  : const Color(0xFF64748B),
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Export Button with equal spacing in row
              if (onExport != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton.icon(
                    onPressed: onExport,
                    icon: const Icon(
                      Icons.file_upload_outlined,
                      size: 16,
                      color: Color(0xFF1B72E8),
                    ),
                    label: const Text(
                      'تصدير',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B72E8),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TabItem {
  final String title;
  final IconData icon;

  const _TabItem({required this.title, required this.icon});
}
