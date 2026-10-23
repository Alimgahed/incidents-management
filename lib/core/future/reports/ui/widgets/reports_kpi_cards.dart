import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';

class ReportsKpiCards extends StatelessWidget {
  final ReportsLoaded state;

  const ReportsKpiCards({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat('#,###');
    final total = state.totalIncidents;

    final activePct = total > 0
        ? (state.activeIncidents / total * 100).toStringAsFixed(1)
        : '0';
    final highSevPct = total > 0
        ? (state.highSeverityIncidents / total * 100).toStringAsFixed(1)
        : '0';
    final closedPct = total > 0
        ? (state.closedIncidents / total * 100).toStringAsFixed(1)
        : '0';
    final photosPct = total > 0
        ? (state.documentedWithPhotos / total * 100).toStringAsFixed(1)
        : '0';

    return LayoutBuilder(
      builder: (context, constraints) {
        // 6 responsive KPI cards
        return Row(
          children: [
            // 6. الموثقة بالصور
            Expanded(
              child: _KpiCard(
                title: 'الموثقة بالصور',
                value: f.format(state.documentedWithPhotos),
                subtitle: '$photosPct% من إجمالي الأزمات',
                icon: Icons.image_outlined,
                iconColor: const Color(0xFF1B72E8),
                iconBgColor: const Color(0xFFEFF6FF),
                valueColor: const Color(0xFF1B72E8),
              ),
            ),
            const SizedBox(width: 12),

            // 5. الأزمات المغلقة
            Expanded(
              child: _KpiCard(
                title: 'الأزمات المغلقة',
                value: f.format(state.closedIncidents),
                subtitle: '$closedPct% تم حلها أو إغلاقها',
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF9333EA),
                iconBgColor: const Color(0xFFFAF5FF),
                valueColor: const Color(0xFF7E22CE),
              ),
            ),
            const SizedBox(width: 12),

            // 4. الأزمات الجديدة
            Expanded(
              child: _KpiCard(
                title: 'الأزمات الجديدة',
                value: f.format(state.newIncidents),
                subtitle: state.startDate != null
                    ? 'خلال نطاق التاريخ المحدد'
                    : 'خلال آخر 7 أيام',
                icon: Icons.add_rounded,
                iconColor: const Color(0xFFEA580C),
                iconBgColor: const Color(0xFFFFF7ED),
                valueColor: const Color(0xFFC2410C),
              ),
            ),
            const SizedBox(width: 12),

            // 3. عالية الخطورة
            Expanded(
              child: _KpiCard(
                title: 'عالية الخطورة',
                value: f.format(state.highSeverityIncidents),
                subtitle: '$highSevPct% مستوى حرجة وعالية',
                isAlert: state.highSeverityIncidents > 0,
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEF2F2),
                valueColor: const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 12),

            // 2. الأزمات النشطة
            Expanded(
              child: _KpiCard(
                title: 'الأزمات النشطة',
                value: f.format(state.activeIncidents),
                subtitle: '$activePct% قيد المتابعة والمعالجة',
                icon: Icons.show_chart_rounded,
                iconColor: const Color(0xFF059669),
                iconBgColor: const Color(0xFFECFDF5),
                valueColor: const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 12),

            // 1. إجمالي الأزمات
            Expanded(
              child: _KpiCard(
                title: 'إجمالي الأزمات',
                value: f.format(state.totalIncidents),
                subtitle: 'أزمة مطابقة للفلاتر',
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xFF1B72E8),
                iconBgColor: const Color(0xFFEFF6FF),
                valueColor: const Color(0xFF0F172A),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool isAlert;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color valueColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.isAlert = false,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isAlert
            ? Border.all(color: const Color(0xFFFCA5A5), width: 1.2)
            : null,
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
          // Top Row: Title + Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Main Value
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: valueColor,
              fontFamily: 'Cairo',
              height: 1.1,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle / Trend
          Text(
            subtitle,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isAlert
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF64748B),
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
