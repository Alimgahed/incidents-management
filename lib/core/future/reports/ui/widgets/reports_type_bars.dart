import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_cubit.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';

class ReportsTypeBarsCard extends StatelessWidget {
  final ReportsLoaded state;

  const ReportsTypeBarsCard({super.key, required this.state});

  static const _barColors = [
    Color(0xFF38BDF8), // Sky blue
    Color(0xFF2DD4BF), // Teal
    Color(0xFFFB923C), // Orange
    Color(0xFFA855F7), // Purple
    Color(0xFFF87171), // Red / Coral
    Color(0xFF60A5FA), // Light blue
    Color(0xFF818CF8), // Indigo
  ];

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat('#,###');
    final cubit = context.read<ReportsCubit>();

    // Sort types descending by real count
    final sortedEntries = state.typeCounts.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final displayEntries = sortedEntries.take(7).toList();

    final maxVal = displayEntries.fold<int>(
      1,
      (max, e) => math.max(max, e.value),
    );

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
              // Badge showing number of active types
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  '${displayEntries.length} نوع',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              // Title
              const Text(
                'الأزمات حسب النوع',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Content Area: Empty State or Real Bars
          Expanded(
            child: displayEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.category_outlined,
                          size: 38,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'لا توجد أزمات مطابقة للأنواع المحددة',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: List.generate(displayEntries.length, (index) {
                        final item = displayEntries[index];
                        final fraction = (item.value / maxVal).clamp(0.06, 1.0);
                        final color = _barColors[index % _barColors.length];
                        final isSelected = state.selectedType == item.key;

                        return InkWell(
                          onTap: () {
                            if (isSelected) {
                              cubit.setSelectedType(null);
                            } else {
                              cubit.setSelectedType(item.key);
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFEFF6FF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Count Value Label on left
                                SizedBox(
                                  width: 38,
                                  child: Text(
                                    f.format(item.value),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Animated Bar
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, barConstraints) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          height: 15,
                                          width: barConstraints.maxWidth *
                                              fraction,
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Type Name Label on right
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    item.key,
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF1B72E8)
                                          : const Color(0xFF475569),
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
