import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';

enum HeatmapMetricMode {
  count, // عدد البلاغات
  severity, // مجموع أو متوسط الخطورة
}

class ReportsTimeHeatmapCard extends StatefulWidget {
  final ReportsLoaded state;

  const ReportsTimeHeatmapCard({
    super.key,
    required this.state,
  });

  @override
  State<ReportsTimeHeatmapCard> createState() => _ReportsTimeHeatmapCardState();
}

class _ReportsTimeHeatmapCardState extends State<ReportsTimeHeatmapCard> {
  HeatmapMetricMode _metricMode = HeatmapMetricMode.count;

  // أيام الأسبوع بالترتيب العربي (ابتداءً من السبت)
  // DateTime.weekday: Monday=1, ..., Saturday=6, Sunday=7
  static const List<Map<String, dynamic>> _weekDays = [
    {'name': 'السبت', 'weekday': DateTime.saturday},
    {'name': 'الأحد', 'weekday': DateTime.sunday},
    {'name': 'الاثنين', 'weekday': DateTime.monday},
    {'name': 'الثلاثاء', 'weekday': DateTime.tuesday},
    {'name': 'الأربعاء', 'weekday': DateTime.wednesday},
    {'name': 'الخميس', 'weekday': DateTime.thursday},
    {'name': 'الجمعة', 'weekday': DateTime.friday},
  ];

  // فترات الساعات (تجميع كل ساعتين أو 3 ساعات لتكون واضحة وجذابة للشاشات، أو 24 ساعة مقسمة إلى 8 فترات من 3 ساعات)
  static const List<Map<String, dynamic>> _hourSlots = [
    {'label': '12 ص - 3 ص', 'start': 0, 'end': 2},
    {'label': '3 ص - 6 ص', 'start': 3, 'end': 5},
    {'label': '6 ص - 9 ص', 'start': 6, 'end': 8},
    {'label': '9 ص - 12 م', 'start': 9, 'end': 11},
    {'label': '12 م - 3 م', 'start': 12, 'end': 14},
    {'label': '3 م - 6 م', 'start': 15, 'end': 17},
    {'label': '6 م - 9 م', 'start': 18, 'end': 20},
    {'label': '9 م - 12 ص', 'start': 21, 'end': 23},
  ];

  @override
  Widget build(BuildContext context) {
    // مصفوفة الحساب: [dayIndex][slotIndex] -> {count: int, totalSeverity: int}
    final matrixData = List.generate(
      _weekDays.length,
      (_) => List.generate(_hourSlots.length, (_) => {'count': 0, 'severity': 0}),
    );

    int maxMetric = 0;
    int totalIncidentsCounted = 0;

    for (final inc in widget.state.filteredIncidents) {
      final dt = inc.currentIncidentCreatedAt;
      if (dt == null) continue;

      final dayIdx = _weekDays.indexWhere((d) => d['weekday'] == dt.weekday);
      if (dayIdx == -1) continue;

      final hour = dt.hour;
      final slotIdx = _hourSlots.indexWhere(
        (s) => hour >= (s['start'] as int) && hour <= (s['end'] as int),
      );
      if (slotIdx == -1) continue;

      matrixData[dayIdx][slotIdx]['count'] = (matrixData[dayIdx][slotIdx]['count'] ?? 0) + 1;
      final sev = inc.currentIncidentSeverity ?? 1;
      matrixData[dayIdx][slotIdx]['severity'] = (matrixData[dayIdx][slotIdx]['severity'] ?? 0) + sev;
      totalIncidentsCounted++;
    }

    // حساب القيمة القصوى لحساب كثافة اللون
    for (int d = 0; d < _weekDays.length; d++) {
      for (int s = 0; s < _hourSlots.length; s++) {
        final val = _metricMode == HeatmapMetricMode.count
            ? matrixData[d][s]['count']!
            : matrixData[d][s]['severity']!;
        if (val > maxMetric) {
          maxMetric = val;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Metric Toggle
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleBtn(
                      title: 'كثافة العدد',
                      active: _metricMode == HeatmapMetricMode.count,
                      onTap: () => setState(() => _metricMode = HeatmapMetricMode.count),
                    ),
                    const SizedBox(width: 4),
                    _buildToggleBtn(
                      title: 'درجة الخطورة',
                      active: _metricMode == HeatmapMetricMode.severity,
                      onTap: () => setState(() => _metricMode = HeatmapMetricMode.severity),
                    ),
                  ],
                ),
              ),

              // Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.whatshot_rounded, size: 14, color: Color(0xFFDC2626)),
                        const SizedBox(width: 4),
                        Text(
                          '$totalIncidentsCounted بلاغ محلل',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'الخريطة الحرارية لأوقات الذروة (Heatmap Matrix)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Subtitle / Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Legend
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'أقل نشاطاً',
                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'Cairo'),
                  ),
                  const SizedBox(width: 6),
                  _buildLegendCell(const Color(0xFFF1F5F9)),
                  _buildLegendCell(const Color(0xFFFED7AA)),
                  _buildLegendCell(const Color(0xFFFB923C)),
                  _buildLegendCell(const Color(0xFFEA580C)),
                  _buildLegendCell(const Color(0xFFDC2626)),
                  _buildLegendCell(const Color(0xFF991B1B)),
                  const SizedBox(width: 6),
                  const Text(
                    'أعلى نشاطاً (بؤرة ذروة)',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626), fontFamily: 'Cairo'),
                  ),
                ],
              ),
              const Text(
                'توزيع البلاغات حسب أيام الأسبوع وفترات الساعات لمعرفة أوقات الضغط والتأهب',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // The Heatmap Grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Row: Hour slots
                      Row(
                        children: [
                          const SizedBox(
                            width: 75,
                            child: Text(
                              'اليوم / الفترة',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                                fontFamily: 'Cairo',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ..._hourSlots.map((slot) => Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    slot['label'] as String,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF334155),
                                      fontFamily: 'Cairo',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Days rows
                      ...List.generate(_weekDays.length, (dIdx) {
                        final day = _weekDays[dIdx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              // Day Name Label
                              SizedBox(
                                width: 75,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    day['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Cairo',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                              // Matrix Cells for this day
                              ...List.generate(_hourSlots.length, (sIdx) {
                                final count = matrixData[dIdx][sIdx]['count']!;
                                final sev = matrixData[dIdx][sIdx]['severity']!;
                                final val = _metricMode == HeatmapMetricMode.count ? count : sev;
                                final ratio = maxMetric > 0 ? (val / maxMetric) : 0.0;
                                final cellColor = _getColorForRatio(ratio, count > 0);
                                final isDark = ratio > 0.45;

                                return Expanded(
                                  child: Tooltip(
                                    message: '${day['name']} (${_hourSlots[sIdx]['label']})\n'
                                        'عدد البلاغات: $count\n'
                                        'إجمالي ثقل الخطورة: $sev',
                                    textStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 11),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Container(
                                      height: 38,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: cellColor,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: count > 0
                                              ? cellColor.withValues(alpha: 0.9)
                                              : const Color(0xFFE2E8F0),
                                          width: 0.8,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        count > 0 ? '$val' : '-',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: count == 0
                                              ? const Color(0xFF94A3B8)
                                              : (isDark ? Colors.white : const Color(0xFF7C2D12)),
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? const Color(0xFF1B72E8) : const Color(0xFF64748B),
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  Widget _buildLegendCell(Color color) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Color _getColorForRatio(double ratio, bool hasData) {
    if (!hasData || ratio <= 0) return const Color(0xFFF8FAFC);
    if (ratio < 0.2) return const Color(0xFFFFEDD5); // برتقالي باهت جدا
    if (ratio < 0.4) return const Color(0xFFFDBA74); // برتقالي متوسط
    if (ratio < 0.6) return const Color(0xFFFB923C); // برتقالي زاهي
    if (ratio < 0.8) return const Color(0xFFEA580C); // برتقالي داكن
    if (ratio < 0.95) return const Color(0xFFDC2626); // أحمر تحذيري
    return const Color(0xFF991B1B); // أحمر داكن جداً (بؤرة حرارية قصوى)
  }
}
