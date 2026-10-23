import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/map/map_incident_details_modal.dart';

class ReportsLatestIncidentsTableCard extends StatelessWidget {
  final List<CurrentIncidentModel> incidents;
  final VoidCallback? onViewAll;
  final String? title;

  const ReportsLatestIncidentsTableCard({
    super.key,
    required this.incidents,
    this.onViewAll,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final rows = incidents;

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
              // View All Button
              if (onViewAll != null)
                OutlinedButton(
                  onPressed: onViewAll,
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B72E8),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              // Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? 'أحدث الأزمات المسجلة',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.fiber_new_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content: Empty State or Real Table Rows
          Expanded(
            child: rows.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.inbox_outlined,
                          size: 36,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'لا توجد أزمات حديثة مسجلة تطابق الفلاتر',
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
                      children: rows.map((inc) {
                        final sev = inc.currentIncidentSeverity ?? 1;
                        final sevColor = getSeverityColor(sev);
                        final status = inc.currentIncidentStatus ?? 1;
                        final statusColor = getStatusColor(status);
                        final statusName = inc.statusName ?? getStatusArabic(status);

                        final createdStr = inc.currentIncidentCreatedAt != null
                            ? dateFormat.format(inc.currentIncidentCreatedAt!)
                            : 'غير متوفر';

                        return InkWell(
                          onTap: () => showMapIncidentDetailsModal(context, inc),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Creation Date (Left in RTL)
                                SizedBox(
                                  width: 105,
                                  child: Text(
                                    createdStr,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF94A3B8),
                                      fontFamily: 'Cairo',
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Severity Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sevColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    getSeverityArabic(sev),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: sevColor,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Branch Badge
                                if (inc.branchName != null &&
                                    inc.branchName!.trim().isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      inc.branchName!.trim(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1B72E8),
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 10),

                                // Description / ID (Right in RTL)
                                Expanded(
                                  child: Text(
                                    '#${inc.currentIncidentId ?? ''} ${inc.currentIncidentDescription ?? inc.currentIncidentTypeName ?? "أزمة"}',
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
