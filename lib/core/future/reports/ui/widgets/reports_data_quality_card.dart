import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/charts/circular_gauge_painter.dart';

class ReportsDataQualityCard extends StatelessWidget {
  final ReportsLoaded state;

  const ReportsDataQualityCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat('#,###');
    final q = state.dataQuality;
    final total = q.total;

    // Strictly real stats from actual incidents
    final hasDescPct = q.hasDescriptionPercentage;
    final hasDescCnt = q.hasDescriptionCount;

    final hasBranchPct = q.hasBranchPercentage;
    final hasBranchCnt = q.hasBranchCount;

    final hasCoordsPct = q.hasCoordinatesPercentage;
    final hasCoordsCnt = q.hasCoordinatesCount;

    final hasPhotosPct = q.hasPhotosPercentage;
    final hasPhotosCnt = q.hasPhotosCount;

    final hasMissionsPct = q.hasMissionsPercentage;
    final hasMissionsCnt = q.hasMissionsCount;

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
                  'إجمالي ${f.format(total)} أزمة مفحوصة',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const Text(
                'جودة واكتمال البيانات',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 5 Circular Gauges in a Row (Strictly Real Data)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. لها وصف
                Expanded(
                  child: CircularProgressGauge(
                    percentage: total > 0 ? hasDescPct : 0.0,
                    label: 'لها وصف',
                    fraction: '${f.format(hasDescCnt)}/${f.format(total)}',
                    color: const Color(0xFF10B981),
                    size: 68,
                  ),
                ),

                // 2. لها فرع
                Expanded(
                  child: CircularProgressGauge(
                    percentage: total > 0 ? hasBranchPct : 0.0,
                    label: 'لها فرع',
                    fraction: '${f.format(hasBranchCnt)}/${f.format(total)}',
                    color: const Color(0xFF14B8A6),
                    size: 68,
                  ),
                ),

                // 3. لها إحداثيات
                Expanded(
                  child: CircularProgressGauge(
                    percentage: total > 0 ? hasCoordsPct : 0.0,
                    label: 'لها إحداثيات',
                    fraction: '${f.format(hasCoordsCnt)}/${f.format(total)}',
                    color: const Color(0xFF06B6D4),
                    size: 68,
                  ),
                ),

                // 4. موثقة بصور
                Expanded(
                  child: CircularProgressGauge(
                    percentage: total > 0 ? hasPhotosPct : 0.0,
                    label: 'موثقة بصور',
                    fraction: '${f.format(hasPhotosCnt)}/${f.format(total)}',
                    color: const Color(0xFF3B82F6),
                    size: 68,
                  ),
                ),

                // 5. تحتوي على مهام
                Expanded(
                  child: CircularProgressGauge(
                    percentage: total > 0 ? hasMissionsPct : 0.0,
                    label: 'تحتوي على مهام',
                    fraction: '${f.format(hasMissionsCnt)}/${f.format(total)}',
                    color: const Color(0xFF8B5CF6),
                    size: 68,
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
