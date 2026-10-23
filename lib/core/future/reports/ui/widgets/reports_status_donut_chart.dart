import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/charts/custom_donut_painter.dart';

class ReportsStatusDonutChartCard extends StatelessWidget {
  final ReportsLoaded state;

  const ReportsStatusDonutChartCard({super.key, required this.state});

  static const _statusColors = {
    'تم التبليغ': Color(0xFFF59E0B), // warningColor / amber
    'تم الارسال': Color(0xFF0284C7), // buttonColor / blue
    'قيد التنفيذ': Color(0xFF475569), // darkTextSecondary / slate
    'قيد الانتظار': Color(0xFF94A3B8), // darkDivider / gray
    'قيد المراجعة': Color(0xFF0EA5E9), // infoColor / cyan
    'تم حلها': Color(0xFF10B981), // successColor / emerald
    'تم الرفض': Color(0xFFEF4444), // warningColor / red
  };

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat('#,###');
    final total = state.totalIncidents;

    final segments = <DonutSegment>[];
    for (final entry in state.statusCounts.entries) {
      if (entry.value > 0) {
        segments.add(
          DonutSegment(
            label: entry.key,
            value: entry.value.toDouble(),
            color: _statusColors[entry.key] ?? const Color(0xFF64748B),
          ),
        );
      }
    }

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
            children: const [
              Icon(Icons.pie_chart_outline_rounded, size: 18, color: Color(0xFF1B72E8)),
              Text(
                'الأزمات حسب الحالة',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Donut Chart on Left, List on Right
          Expanded(
            child: Row(
              children: [
                // Donut Chart
                Expanded(
                  flex: 5,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomPaint(
                        painter: CustomDonutPainter(
                          segments: segments,
                          strokeWidth: 24,
                          centerTitle: f.format(total),
                          centerSubtitle: 'إجمالي الأزمات',
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Breakdown List
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: state.statusCounts.entries.map((entry) {
                        final count = entry.value;
                        final pct = total > 0 ? (count / total) * 100 : 0.0;
                        final color =
                            _statusColors[entry.key] ?? const Color(0xFF64748B);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              // Percentage
                              SizedBox(
                                width: 38,
                                child: Text(
                                  '${pct.toStringAsFixed(1)}%',
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF94A3B8),
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),

                              const SizedBox(width: 6),

                              // Count / Number (fixed width, perfectly aligned under each other)
                              SizedBox(
                                width: 34,
                                child: Text(
                                  f.format(count),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),

                              const SizedBox(width: 6),

                              // Name + Dot
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        entry.key,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF475569),
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
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
