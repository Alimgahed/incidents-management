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
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_detail_dialogs.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_photo_gallery.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/incident_description_present.dart';
import 'package:incidents_managment/core/helpers/date_format.dart';
import 'package:incidents_managment/core/helpers/incident_description_parse.dart';
import 'package:incidents_managment/core/helpers/responsive.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class IncidentDetailsPanel extends StatelessWidget {
  const IncidentDetailsPanel({
    super.key,
    this.contentPadding,
    this.showBackToList = false,
    this.onBackToList,
  });

  /// When set (e.g. web full-screen route), overrides [ResponsiveHelper.responsivePadding].
  final EdgeInsets? contentPadding;
  final bool showBackToList;
  final VoidCallback? onBackToList;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          current is DashboardIncidentSelected ||
          current is DashboardIncidentUpdated ||
          current is DashboardMissionUpdated,
      builder: (context, state) {
        final incident = context.read<DashboardCubit>().selectedIncident;
        if (incident == null) {
          return const _EmptyIncidentState();
        }

        final padding =
            contentPadding ?? ResponsiveHelper.responsivePadding(context);
        final spacing = ResponsiveHelper.responsiveSpacing(
          context,
          mobileSpacing: 10,
          desktopSpacing: 10,
        );

        return Container(
          color: backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showBackToList)
                Material(
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'العودة إلى قائمة الأزمات',
                          onPressed: onBackToList,
                          icon: const Icon(Icons.arrow_forward_rounded),
                        ),
                        const Expanded(
                          child: Text(
                            'تفاصيل الأزمة',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: padding.copyWith(
                    top: showBackToList ? 8 : padding.top,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _IncidentHeroHeader(incident: incident),
                      SizedBox(height: spacing),
                      _QuickStatsRow(incident: incident),
                      SizedBox(height: spacing),
                      _buildOverviewSection(context, incident),
                      const SizedBox(height: 12),
                      _MissionsCard(incident: incident),
                      const SizedBox(height: 12),
                      if (incident.currentIncidentId != null)
                        IncidentPhotosGrid(
                          incident: incident,
                          incidentId: incident.currentIncidentId!,
                        ),
                      const SizedBox(height: 12),
                      if (incident.currentIncidentXAxis != null &&
                          incident.currentIncidentYAxis != null)
                        AppMapSection(
                          lat: incident.currentIncidentXAxis!,
                          lng: incident.currentIncidentYAxis!,
                          mapHeight: 320,
                        )
                      else
                        _NoLocationPlaceholder(),
                      const SizedBox(height: 12),
                      _TimelineCard(incident: incident),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewSection(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 768;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _DescriptionCard(incident: incident),
                    if (incident.currentIncidentNotes != null) ...[
                      const SizedBox(height: 12),
                      _NotesCard(notes: incident.currentIncidentNotes!),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _MetadataCard(incident: incident)),
            ],
          );
        }
        return Column(
          children: [
            _DescriptionCard(incident: incident),
            const SizedBox(height: 12),
            _MetadataCard(incident: incident),
            if (incident.currentIncidentNotes != null) ...[
              const SizedBox(height: 12),
              _NotesCard(notes: incident.currentIncidentNotes!),
            ],
          ],
        );
      },
    );
  }
}

class _NoLocationPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_rounded, size: 40, color: Color(0xFFCBD5E1)),
          SizedBox(height: 8),
          Text(
            'لا يوجد موقع محدد لهذه الأزمة',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
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
                color: appColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: appColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'اختر أزمة لعرض التفاصيل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'انقر على أي أزمة من القائمة لعرض معلوماتها الكاملة والتحكم بها',
              style: TextStyle(fontSize: 13, color: secondaryTextColor),
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
    final parsed = IncidentDescriptionParser.parse(
      incident.currentIncidentDescription,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2744), Color(0xFF1E3A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColor.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;

          final headerContent = [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            if (!isNarrow)
              const SizedBox(width: 16)
            else
              const SizedBox(height: 12),
            Expanded(
              flex: isNarrow ? 0 : 1,
              child: Column(
                crossAxisAlignment: isNarrow
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    parsed.displayTitle,
                    textAlign: isNarrow ? TextAlign.center : TextAlign.start,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (parsed.technicalDetails != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      parsed.technicalDetails!,
                      textAlign: isNarrow ? TextAlign.center : TextAlign.start,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: isNarrow
                        ? WrapAlignment.center
                        : WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (incident.branchName != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_city_rounded,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              incident.branchName!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: isNarrow
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
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
            if (isNarrow) const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.12),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 24),
                  tooltip: 'تعيين مسؤول',
                  onPressed: () {
                    context.pushNamed(
                      Routes.missionAssign,
                      arguments: incident,
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.12),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 24),
                  onPressed: () => showEditDialog(
                    context,
                    incident,
                    context.read<EditIncidentCubit>(),
                  ),
                  tooltip: 'تعديل الأزمة',
                ),
              ],
            ),
          ];

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: headerContent,
            );
          }

          return Row(children: headerContent);
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSeverityIcon(severity), size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
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
        return Icons.priority_high_rounded;
      case 3:
        return Icons.warning_amber_rounded;
      case 2:
        return Icons.info_outline;
      default:
        return Icons.check_circle_outline;
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

    final cards = [
      _StatCard(
        icon: Icons.assignment_outlined,
        title: 'المهام',
        value: '${missions.length}',
        subtitle: '$completedMissions مكتملة',
        color: const Color(0xFF0D9488),
      ),
      _StatCard(
        icon: Icons.person_outline,
        title: 'تم الإنشاء بواسطة',
        value: widget.incident.username ?? '-',
        subtitle: 'المسؤول الفني',
        color: const Color(0xFF8B5CF6),
      ),
      _StatCard(
        icon: Icons.access_time,
        title: 'الوقت المنقضي',
        value: _elapsed.format(),
        subtitle: widget.incident.currentIncidentStatus == 7
            ? 'تم الإيقاف'
            : 'جاري الاحتساب',
        color: const Color(0xFFEC4899),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        if (isNarrow) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                cards[i],
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
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

class _DescriptionCard extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _DescriptionCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'وصف البلاغ والأزمة',
      icon: Icons.description_outlined,
      child: IncidentDescriptionPresentation(
        description: incident.currentIncidentDescription,
        textColor: primaryTextColor,
        secondaryColor: secondaryTextColor,
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
      title: 'ملاحظات وتوجيهات إضافية',
      icon: Icons.sticky_note_2_outlined,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notes,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF92400E),
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
      title: 'معلومات إضافية',
      icon: Icons.info_outlined,
      child: Column(
        children: [
          _MetadataRow(
            icon: Icons.category_outlined,
            label: 'تصنيف الأزمة',
            value: incident.currentIncidentTypeName ?? '-',
          ),
          if ((incident.currentIncidentXAxis ?? 0) != 0 &&
              (incident.currentIncidentYAxis ?? 0) != 0) ...[
            _buildDivider(),
            _MetadataRow(
              icon: Icons.location_on_outlined,
              label: 'الموقع الجغرافي',
              value:
                  '${incident.currentIncidentXAxis?.toStringAsFixed(3)}, ${incident.currentIncidentYAxis?.toStringAsFixed(3)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Divider(height: 1, color: Color(0xFFEDF2F7)),
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
        Icon(icon, size: 18, color: const Color(0xFF1E3A5F)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
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

    if (missions.isEmpty) {
      return _SectionCard(
        title: 'المهام المطلوبة',
        icon: Icons.task_alt,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.checklist_rounded, size: 40, color: Color(0xFFCBD5E1)),
              SizedBox(height: 8),
              Text(
                'لا توجد مهام معينة حالياً للأزمة',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return _SectionCard(
      title: 'المهام المطلوبة',
      icon: Icons.task_alt,
      badge: '${missions.length}',
      child: Column(
        children: missions.map((mission) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: appColor.withOpacity(0.08),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mission.missionName ??
                      'مهمة #${mission.currentIncidentMissionId}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
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
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              icon: const Icon(Icons.sync_alt_rounded, size: 18),
              color: const Color(0xFF475569),
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
}

class _TimelineCard extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _TimelineCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final items = [
      if (incident.currentIncidentCreatedAt != null)
        _TimelineItem(
          icon: Icons.add_circle_outline,
          title: 'تم إنشاء البلاغ',
          time: incident.currentIncidentCreatedAt!,
          userId: incident.currentIncidentCreatedBy,
          isFirst: true,
        ),
      if (incident.currentIncidentStatusUpdatedAt != null)
        _TimelineItem(
          icon: Icons.update_rounded,
          title: 'تحديث حالة الأزمة',
          time: incident.currentIncidentStatusUpdatedAt!,
          userId: incident.currentIncidentStatusUpdatedBy,
        ),
      if (incident.currentIncidentSeverityUpdateAt != null)
        _TimelineItem(
          icon: Icons.priority_high_rounded,
          title: 'تحديث مستوى الخطورة',
          time: incident.currentIncidentSeverityUpdateAt!,
          userId: incident.currentIncidentSeverityUpdateBy,
          isLast: true,
        ),
    ];

    if (items.isEmpty) {
      return _SectionCard(
        title: 'الخط الزمني',
        icon: Icons.timeline,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timeline_rounded, size: 40, color: Color(0xFFCBD5E1)),
              SizedBox(height: 8),
              Text(
                'لا توجد سجلات خط زمني حالياً',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    // Set correctly the isLast property
    if (items.isNotEmpty) {
      // Clean up sequence flags
      final list = <_TimelineItem>[];
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        list.add(
          _TimelineItem(
            icon: item.icon,
            title: item.title,
            time: item.time,
            userId: item.userId,
            isFirst: i == 0,
            isLast: i == items.length - 1,
          ),
        );
      }
      return _SectionCard(
        title: 'الخط الزمني للحالة',
        icon: Icons.timeline,
        child: Column(children: list),
      );
    }

    return _SectionCard(
      title: 'الخط الزمني للحالة',
      icon: Icons.timeline,
      child: Column(children: items),
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
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appColor.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, size: 14, color: appColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time.timeAgoArabic(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (userId != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'بواسطة المعرّف: #$userId',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: appColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: appColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
