import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_cubit.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/charts/custom_line_chart_painter.dart';

class ReportsTrendChartCard extends StatelessWidget {
  final ReportsLoaded state;

  const ReportsTrendChartCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportsCubit>();

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
          // Header Row: Title + Period Toggle + Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              const Text(
                'اتجاه الأزمات عبر الزمن',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Cairo',
                ),
              ),

              // Period Toggle (شهري / أسبوعي / يومي)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPeriodBtn('شهري', state.trendPeriod == 'شهري', () {
                      cubit.setTrendPeriod('شهري');
                    }),
                    _buildPeriodBtn('أسبوعي', state.trendPeriod == 'أسبوعي', () {
                      cubit.setTrendPeriod('أسبوعي');
                    }),
                    _buildPeriodBtn('يومي', state.trendPeriod == 'يومي', () {
                      cubit.setTrendPeriod('يومي');
                    }),
                  ],
                ),
              ),

              // Legend
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _LegendDot(label: 'إجمالي الأزمات', color: Color(0xFF1B72E8)),
                  SizedBox(width: 14),
                  _LegendDot(label: 'أزمات نشطة', color: Color(0xFF00BFA5)),
                  SizedBox(width: 14),
                  _LegendDot(label: 'أزمات حرجة', color: Color(0xFFE53935)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Chart Area
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: CustomLineChartPainter(
                points: state.trendData,
                totalColor: const Color(0xFF1B72E8),
                activeColor: const Color(0xFF00BFA5),
                criticalColor: const Color(0xFFE53935),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodBtn(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B72E8) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
