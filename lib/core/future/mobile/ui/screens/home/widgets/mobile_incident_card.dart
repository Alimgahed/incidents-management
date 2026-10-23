import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/helpers/date_format.dart';
import 'package:incidents_managment/core/realtime/services/realtime_alert_manager.dart';

class MobileIncidentCard extends StatefulWidget {
  final CurrentIncidentModel incident;
  final VoidCallback onTap;

  const MobileIncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  @override
  State<MobileIncidentCard> createState() => _MobileIncidentCardState();
}

class _MobileIncidentCardState extends State<MobileIncidentCard> {
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 600)) {
      return; // Debounce rapid double-taps
    }
    _lastTapTime = now;
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    final severity = incident.currentIncidentSeverity ?? 1;
    final status = incident.currentIncidentStatus ?? 1;
    final branch = incident.branchName ?? 'المنيا';
    final typeName = incident.currentIncidentTypeName ?? 'توقف محطة مياه';
    final description =
        (incident.currentIncidentDescription?.isNotEmpty == true)
            ? incident.currentIncidentDescription!
            : (incident.currentIncidentNotes?.isNotEmpty == true
                ? incident.currentIncidentNotes!
                : 'لا توجد تفاصيل إضافية مسجلة لهذه الأزمة');

    final managerName =
        incident.managerName ?? (incident.username ?? 'مسؤول الأزمة');

    final photosCount = incident.photos?.length ?? 0;
    final missions = incident.currentIncidentWithMissions ?? [];
    final totalMissions = missions.length;
    final completedMissions = missions
        .where((m) => m.currentIncidentMissionStatus == 6)
        .length;

    // Severity visual elements
    final isCritical = severity == 4;
    final isHigh = severity == 3;

    final severityIconData = isCritical
        ? Icons.notifications_active_rounded
        : (isHigh
            ? Icons.warning_amber_rounded
            : (severity == 2
                ? Icons.info_outline_rounded
                : Icons.check_circle_outline_rounded));

    final severityBgColor = isCritical
        ? const Color(0xFFFEE2E2)
        : (isHigh ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE));

    final severityColor = isCritical
        ? const Color(0xFFDC2626)
        : (isHigh ? const Color(0xFFD97706) : const Color(0xFF0284C7));

    final severityLabel = getSeverityArabic(severity);
    final statusLabel = getStatusArabic(status);
    final statusColor = getStatusColor(status);

    final alertManager = getIt.isRegistered<RealTimeAlertManager>()
        ? getIt<RealTimeAlertManager>()
        : null;

    return StreamBuilder<Set<int>>(
      stream: alertManager?.highlightedIncidentIdsStream,
      initialData: alertManager?.highlightedIncidentIds ?? const {},
      builder: (context, snapshot) {
        final isHighlighted = incident.currentIncidentId != null &&
            (snapshot.data?.contains(incident.currentIncidentId) ?? false);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFEEF2F6),
              width: isHighlighted ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isHighlighted)
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Row: Details Arrow Button (left in RTL), Branch & Title, Severity Badge (right in RTL)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Severity Icon Badge (Right side in RTL)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: severityBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            severityIconData,
                            color: severityColor,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 2. Middle: Branch name & Incident type
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'فرع $branch',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  if (isHighlighted) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'تحديث جديد',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                typeName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                    const SizedBox(width: 8),

                    // 3. Left in RTL: Arrow button pointing to the left (forward into details in RTL)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description with vertical pipe accent
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFF3B82F6), width: 2.5),
                    ),
                  ),
                  child: Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: secondaryTextColor,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Upper Metadata Badges: Status Pill, Severity Pill, Date & Time Pill
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 13,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Severity Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: severityBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            severityLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 14,
                            color: severityColor,
                          ),
                        ],
                      ),
                    ),

                    // Date & Time Pill
                    if (incident.currentIncidentCreatedAt != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              incident.currentIncidentCreatedAt!
                                  .timeAgoArabic(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 10),

                // Lower Metadata Row: Attachments, Tasks, Responsible Person
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Attachments count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$photosCount',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            const Text(
                              'مرفقات',
                              style: TextStyle(
                                fontSize: 9,
                                color: disabledTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Missions / Tasks count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              totalMissions > 0
                                  ? '$completedMissions/$totalMissions'
                                  : '0/0',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            const Text(
                              'مهام',
                              style: TextStyle(
                                fontSize: 9,
                                color: disabledTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Responsible Person
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              managerName,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'المسؤول',
                              style: TextStyle(
                                fontSize: 9,
                                color: disabledTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
