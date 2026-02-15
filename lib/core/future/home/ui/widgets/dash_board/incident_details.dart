import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/update_statues.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/helpers/date_format.dart';
import 'package:incidents_managment/core/helpers/responsive.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class IncidentDetailsPanel extends StatelessWidget {
  const IncidentDetailsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DashboardCubit, DashboardState, CurrentIncidentModel?>(
      selector: (state) => state.maybeWhen(
        orElse: () => null,
        incidentSelected: (incident) => incident,
      ),
      builder: (context, incident) {
        if (incident == null) {
          return const _EmptyIncidentState();
        }

        final padding = ResponsiveHelper.responsivePadding(context);

        return Container(
          color: backgroundColor,
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header
                _IncidentHeroHeader(incident: incident),
                SizedBox(
                  height: ResponsiveHelper.responsiveSpacing(
                    context,
                    mobileSpacing: 16,
                    desktopSpacing: 24,
                  ),
                ),

                // Quick Stats Row - Responsive
                _QuickStatsRow(incident: incident),
                SizedBox(
                  height: ResponsiveHelper.responsiveSpacing(
                    context,
                    mobileSpacing: 16,
                    desktopSpacing: 24,
                  ),
                ),

                // Main Content Grid - Responsive
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _DescriptionCard(incident: incident),
                          const SizedBox(height: 16),
                          _MissionsCard(incident: incident),
                          const SizedBox(height: 16),

                          IncidentPhotosGrid(
                            incident: incident,
                            incidentId: incident.currentIncidentId!,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Column
                    Expanded(
                      child: Column(
                        children: [
                          _MetadataCard(incident: incident),
                          const SizedBox(height: 16),
                          if (incident
                                  .currentIncidentWithMissions
                                  ?.isNotEmpty ==
                              true)
                            if (incident.currentIncidentXAxis != null &&
                                incident.currentIncidentYAxis != null)
                              AppMapSection(
                                lat: incident.currentIncidentXAxis!,
                                lng: incident.currentIncidentYAxis!,
                                mapHeight: 200,
                              ),
                          const SizedBox(height: 16),
                          if (incident.currentIncidentNotes != null)
                            _NotesCard(notes: incident.currentIncidentNotes!),
                          const SizedBox(height: 16),

                          _TimelineCard(incident: incident),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyIncidentState extends StatelessWidget {
  const _EmptyIncidentState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: appColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 80,
                color: appColor.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'اختر أزمة لعرض التفاصيل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'انقر على أي أزمة من القائمة لعرض معلوماتها الكاملة',
              style: TextStyle(fontSize: 14, color: disabledTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidentHeroHeader extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _IncidentHeroHeader({required this.incident});

  @override
  Widget build(BuildContext context) {
    final status = incident.currentIncidentStatus ?? 1;
    final severity = incident.currentIncidentSeverity ?? 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appColor, appColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أزمة #${incident.currentIncidentDescription}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (incident.branchName != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        incident.branchName!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatusChip(
                      text: getStatusArabic(status),
                      color: getStatusColor(status),
                    ),
                    const SizedBox(width: 8),
                    _SeverityChip(
                      text: getSeverityArabic(severity),
                      severity: severity,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => showEditDialog(
              context,
              incident,
              context.read<EditIncidentCubit>(),
            ),
            tooltip: 'تعديل الأزمة',
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final String text;
  final int severity;

  const _SeverityChip({required this.text, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = getSeverityColor(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSeverityIcon(severity), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(int severity) {
    switch (severity) {
      case 4:
        return Icons.priority_high;
      case 3:
        return Icons.warning;
      case 2:
        return Icons.info;
      default:
        return Icons.check_circle;
    }
  }
}

class _QuickStatsRow extends StatefulWidget {
  final CurrentIncidentModel incident;

  const _QuickStatsRow({required this.incident});

  @override
  State<_QuickStatsRow> createState() => _QuickStatsRowState();
}

class _QuickStatsRowState extends State<_QuickStatsRow> {
  late Duration _elapsed;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initElapsed();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _QuickStatsRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // لو الـ incident اتغير
    if (oldWidget.incident.currentIncidentId !=
        widget.incident.currentIncidentId) {
      _timer?.cancel();
      _initElapsed();
      _startTimerIfNeeded();
    }
  }

  void _initElapsed() {
    final createdAt = widget.incident.currentIncidentCreatedAt;
    if (createdAt == null) {
      _elapsed = Duration.zero;
      return;
    }

    _elapsed = DateTime.now().difference(createdAt);
  }

  void _startTimerIfNeeded() {
    // لو الحالة = 7 لا تشغل العداد
    if (widget.incident.currentIncidentStatus == 7) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final missions = widget.incident.currentIncidentWithMissions ?? [];
    final completedMissions = missions
        .where((m) => m.currentIncidentMissionStatus == 6)
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.assignment_outlined,
            title: 'المهام',
            value: '${missions.length}',
            subtitle: '$completedMissions مكتملة',
            color: accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.person_outline,
            title: 'تم الإنشاء بواسطة',
            value: '#${widget.incident.username ?? '-'}',
            subtitle: 'معرف المستخدم',
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.access_time,
            title: 'الوقت المنقضي',
            value: (_elapsed.format()),
            subtitle: widget.incident.currentIncidentStatus == 7
                ? 'تم الإيقاف'
                : 'جاري العد',
            color: const Color(0xFFEC4899),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: disabledTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _DescriptionCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'وصف الأزمة',
      icon: Icons.description_outlined,
      child: Text(
        incident.currentIncidentDescription ?? 'لا يوجد وصف متاح',
        style: TextStyle(fontSize: 15, color: primaryTextColor, height: 1.6),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ملاحظات إضافية',
      icon: Icons.sticky_note_2_outlined,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: warningColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: warningColor.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: warningColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notes,
                style: TextStyle(
                  fontSize: 14,
                  color: primaryTextColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _MetadataCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'معلومات النظام',
      icon: Icons.info_outlined,
      child: Column(
        children: [
          _MetadataRow(
            icon: Icons.category,
            label: 'نوع الأزمة',
            value: '#${incident.currentIncidentTypeName ?? '-'}',
          ),
          _buildDivider(),
          _MetadataRow(
            icon: Icons.apartment,
            label: 'الفرع',
            value: incident.branchName ?? '#${incident.branchId ?? '-'}',
          ),
          _buildDivider(),
          _MetadataRow(
            icon: Icons.person_add,
            label: 'تم الإنشاء بواسطة',
            value: '#${incident.username ?? '-'}',
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Divider(height: 1),
  );
}

class _MetadataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: accentColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
      ],
    );
  }
}

class _MissionsCard extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _MissionsCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UpdateStatuesCubit>();

    final missions = [...(incident.currentIncidentWithMissions ?? [])]
      ..sort(
        (a, b) => (a.currentIncidentMissionOrder ?? 0).compareTo(
          b.currentIncidentMissionOrder ?? 0,
        ),
      );

    return _SectionCard(
      title: 'المهام المطلوبة',
      icon: Icons.task_alt,
      badge: '${missions.length}',
      child: Column(
        children: missions.map((mission) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MissionItem(
              mission: mission,
              incidentId: incident.currentIncidentId!,
              cubit: cubit,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MissionItem extends StatelessWidget {
  final CurrentIncidentWithMissions mission;
  final int incidentId;
  final UpdateStatuesCubit cubit;

  const _MissionItem({
    required this.mission,
    required this.incidentId,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final status = mission.currentIncidentMissionStatus ?? 1;
    final order = mission.currentIncidentMissionOrder ?? 0;
    final missionId = mission.currentIncidentMissionId;
    final updateStatuesCubit = context.read<UpdateStatuesCubit>();

    final statusColor = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Order Circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$order',
                style: const TextStyle(
                  color: appColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Mission Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.missionName ??
                      'مهمة #${mission.currentIncidentMissionId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),

                // Status Badge (Dialog style)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    getStatusArabicLabel(status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Change Status Button
          Container(
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.sync_alt, size: 20),
              color: accentColor,
              onPressed: missionId == null
                  ? null
                  : () => showStatusSelector(
                      context,
                      mission,
                      incidentId,
                      updateStatuesCubit,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔽 Bottom Sheet (نظيف ومتناغم)
}

class _TimelineCard extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _TimelineCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'الخط الزمني',
      icon: Icons.timeline,
      child: Column(
        children: [
          if (incident.currentIncidentCreatedAt != null)
            _TimelineItem(
              icon: Icons.add_circle_outline,
              title: 'تم الإنشاء',
              time: incident.currentIncidentCreatedAt!,
              userId: incident.currentIncidentCreatedBy,
              isFirst: true,
            ),

          if (incident.currentIncidentStatusUpdatedAt != null)
            _TimelineItem(
              icon: Icons.update,
              title: 'آخر تحديث للحالة',
              time: incident.currentIncidentStatusUpdatedAt!,
              userId: incident.currentIncidentStatusUpdatedBy,
            ),

          if (incident.currentIncidentSeverityUpdateAt != null)
            _TimelineItem(
              icon: Icons.priority_high,
              title: 'آخر تحديث للخطورة',
              time: incident.currentIncidentSeverityUpdateAt!,
              userId: incident.currentIncidentSeverityUpdateBy,
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final DateTime time;
  final int? userId;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.time,
    this.userId,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 2),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: borderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time.timeAgoArabic(),
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                  if (userId != null)
                    Text(
                      'بواسطة: #$userId',
                      style: TextStyle(fontSize: 11, color: disabledTextColor),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final String? badge;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

void showStatusSelector(
  BuildContext context,
  CurrentIncidentWithMissions mission,
  int incidentId,
  UpdateStatuesCubit cubit,
) {
  int selectedStatus = mission.currentIncidentMissionStatus ?? 1;

  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit, color: appColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'تغيير حالة المهمة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: appColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Status Dropdown
                _buildLabel("حالة المهمة"),
                _buildDropdown(
                  value: selectedStatus,
                  icon: Icons.sync_alt,
                  items: allStatuses
                      .map(
                        (statusId) => DropdownMenuItem(
                          value: statusId,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: getStatusColor(statusId),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(getStatusArabicLabel(statusId)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedStatus = v!),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          cubit.updateStatues(
                            incidentid: incidentId,
                            missionid: mission.currentIncidentMissionId!,
                            statusid: selectedStatus,
                            orderid: mission.currentIncidentMissionOrder ?? 0,
                          );
                        },
                        child: const Text(
                          'حفظ التغييرات',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

// Helper Widgets
Widget _buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
    ),
  );
}

Widget _buildDropdown({
  required int value,
  required IconData icon,
  required List<DropdownMenuItem<int>> items,
  required ValueChanged<int?> onChanged,
}) {
  return DropdownButtonFormField<int>(
    initialValue: value,
    icon: Icon(Icons.arrow_drop_down, color: accentColor),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: accentColor, size: 20),
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
    ),
    items: items,
    onChanged: onChanged,
  );
}

void showEditDialog(
  BuildContext context,
  CurrentIncidentModel incident,
  EditIncidentCubit cubit,
) {
  int selectedStatus = incident.currentIncidentStatus!;
  int selectedSeverity = incident.currentIncidentSeverity!;

  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit, color: appColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'تعديل بيانات الأزمة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: appColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Status Dropdown
                _buildLabel("حالة الأزمة"),
                _buildDropdown(
                  value: selectedStatus,
                  icon: Icons.sync_alt,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('تم التبليغ')),
                    DropdownMenuItem(value: 2, child: Text('تم الارسال')),
                    DropdownMenuItem(value: 3, child: Text('قيد التنفيذ')),
                    DropdownMenuItem(value: 4, child: Text('قيد الانتظار')),
                    DropdownMenuItem(value: 5, child: Text('قيد المراجعة')),
                    DropdownMenuItem(value: 6, child: Text('تم حلها')),
                    DropdownMenuItem(value: 7, child: Text('تم الرفض')),
                  ],
                  onChanged: (v) => setState(() => selectedStatus = v!),
                ),
                const SizedBox(height: 20),

                // Severity Dropdown
                _buildLabel("درجة الخطورة"),
                _buildDropdown(
                  value: selectedSeverity,
                  icon: Icons.priority_high,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('منخفضة')),
                    DropdownMenuItem(value: 2, child: Text('متوسطة')),
                    DropdownMenuItem(value: 3, child: Text('عالية')),
                    DropdownMenuItem(value: 4, child: Text('حرجة')),
                  ],
                  onChanged: (v) => setState(() => selectedSeverity = v!),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          cubit.submitIncident(
                            id: incident.currentIncidentId!,
                            status: selectedStatus,
                            severity: selectedSeverity,
                            typeId: incident.currentIncidentTypeId!,
                            branchId: incident.branchId!,
                            location: LatLng(
                              incident.currentIncidentXAxis!,
                              incident.currentIncidentYAxis!,
                            ),
                            description:
                                incident.currentIncidentDescription ?? '',
                          );
                        },
                        child: const Text(
                          'حفظ التغييرات',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class IncidentPhotosGrid extends StatelessWidget {
  final CurrentIncidentModel incident;
  final int incidentId;

  const IncidentPhotosGrid({
    super.key,
    required this.incident,
    required this.incidentId,
  });

  @override
  Widget build(BuildContext context) {
    if (incident.photos?.isEmpty ?? true) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'صور الأزمة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${incident.photos?.length} صورة',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'أزمة #$incidentId',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: incident.photos?.length,
            itemBuilder: (context, index) {
              return _PhotoGridItem(
                photo: incident.photos![index],
                onTap: () =>
                    _showFullScreenGallery(context, incident.photos!, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.textTertiary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد صور',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'لم يتم رفع أي صور لهذه الأزمة بعد',
            style: TextStyle(fontSize: 14, color: AppTheme.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFullScreenGallery(
    BuildContext context,
    List<CurrentIncidentPhoto> photos,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenPhotoView(photo: photos[initialIndex]),
      ),
    );
  }
}

class _PhotoGridItem extends StatelessWidget {
  final CurrentIncidentPhoto photo;
  final VoidCallback onTap;

  const _PhotoGridItem({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'photo_${photo.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                CachedNetworkImage(
                  imageUrl:
                      'http://172.16.0.31:5000/view-incident-photo/${photo.id}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.backgroundColor,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.backgroundColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          size: 48,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'فشل التحميل',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Info overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                photo.currentIncidentPhotoUploadedAt!
                                    .timeAgoArabic(),

                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (photo.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            photo.description!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Zoom icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.zoom_in_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenPhotoView extends StatelessWidget {
  final CurrentIncidentPhoto photo;

  const FullScreenPhotoView({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen image with pinch/zoom using InteractiveViewer
          Center(
            child: Hero(
              tag: 'photo_${photo.id}',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl:
                      'http://172.16.0.31:5000/view-incident-photo/${photo.id}',
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          size: 64,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'فشل تحميل الصورة',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top bar with back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Info badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'أزمة #${photo.currentIncidentId}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                      ),
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'share') {
                          // Implement share
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('مشاركة الصورة')),
                          );
                        } else if (value == 'download') {
                          // Implement download
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تحميل الصورة')),
                          );
                        } else if (value == 'delete') {
                          _showDeleteDialog(context);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(
                                Icons.share_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'مشاركة',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: [
                              Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'تحميل',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_rounded,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text('حذف', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (photo.description != null) ...[
                    Text(
                      photo.description!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.access_time_rounded,
                        DateFormat(
                          'dd/MM/yyyy - hh:mm a',
                          'ar',
                        ).format(photo.currentIncidentPhotoUploadedAt!),
                      ),
                      _buildInfoChip(
                        Icons.person_rounded,
                        'مستخدم #${photo.currentIncidentPhotoUploadedBy}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pinch_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'اضغط بإصبعين للتكبير والتصغير',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الصورة', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل أنت متأكد من حذف هذه الصورة؟',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close full screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف الصورة'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
