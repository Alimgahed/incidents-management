import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/map/map_incident_details_modal.dart';

class ReportsStaleIncidentsTableCard extends StatelessWidget {
  final List<CurrentIncidentModel> incidents;
  final VoidCallback? onViewAll;

  const ReportsStaleIncidentsTableCard({
    super.key,
    required this.incidents,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd');
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
                children: const [
                  Text(
                    'أزمات معلقة تتطلب تحديثاً',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.history_toggle_off_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content: Empty State or Real Stale Incident Rows
          Expanded(
            child: rows.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.task_alt_rounded,
                          size: 36,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'جميع الأزمات النشطة محدثة بانتظام',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: rows.map((inc) {
                        final status = inc.currentIncidentStatus ?? 1;
                        final statusColor = getStatusColor(status);
                        final statusName = inc.statusName ?? getStatusArabic(status);

                        final lastUpdated = inc.currentIncidentStatusUpdatedAt ??
                            inc.currentIncidentCreatedAt;
                        final dateStr = lastUpdated != null
                            ? dateFormat.format(lastUpdated)
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
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Last Update Date (Left in RTL)
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    dateStr,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF92400E),
                                      fontWeight: FontWeight.w600,
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
                                    color: statusColor.withValues(alpha: 0.15),
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

                                // Branch
                                if (inc.branchName != null &&
                                    inc.branchName!.trim().isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFFFDE68A),
                                      ),
                                    ),
                                    child: Text(
                                      inc.branchName!.trim(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFB45309),
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
                                      color: Color(0xFF78350F),
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
