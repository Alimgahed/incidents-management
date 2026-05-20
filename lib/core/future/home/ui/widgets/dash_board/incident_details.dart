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
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_detail_dialogs.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_photo_gallery.dart';

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
                color: appColor.withAlpha(13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 80,
                color: appColor.withAlpha(77),
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
          colors: [appColor, appColor.withAlpha(204)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColor.withAlpha(51),
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
              color: Colors.white.withAlpha(51),
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
              Icons.person_add_alt_outlined,
              color: Colors.white,
              size: 28,
            ),
            tooltip: 'تعيين مسؤول',
            onPressed: () {
              context.pushNamed(Routes.missionAssign, arguments: incident);
            },
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
            color: Colors.black.withAlpha(26),
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
              color: color.withAlpha(26),
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
          color: warningColor.withAlpha(13),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: warningColor.withAlpha(51)),
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
              color: appColor.withAlpha(26),
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
                    color: statusColor.withAlpha(31),
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
              color: accentColor.withAlpha(26),
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
                  color: accentColor.withAlpha(26),
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
            color: Colors.black.withAlpha(5),
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
                    color: accentColor.withAlpha(26),
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
