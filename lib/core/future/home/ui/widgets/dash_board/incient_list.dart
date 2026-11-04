import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/list_header.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/incident_description_present.dart';
import 'package:incidents_managment/core/helpers/date_format.dart';
import 'package:incidents_managment/core/realtime/services/realtime_alert_manager.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';
import 'package:incidents_managment/core/theming/styling.dart';

/// Column count for the web incident grid from available width.
int incidentGridCrossAxisCount(double width) {
  if (width >= 1560) return 4;
  if (width >= 1160) return 3;
  if (width >= 720) return 2;
  return 1;
}

// Web grid sizing constants (kept for future use)
// const double _kWebGridRowHeight = 78;
// const double _kWebGridSpacing = 8;

class IncidentCard extends StatefulWidget {
  final CurrentIncidentModel incident;
  final bool isSelected;
  final VoidCallback onTap;
  final bool useWebTileLayout;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.isSelected,
    required this.onTap,
    this.useWebTileLayout = false,
  });

  @override
  State<IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends State<IncidentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final severity = widget.incident.currentIncidentSeverity ?? 1;
    final status = widget.incident.currentIncidentStatus ?? 1;
    final theme = Theme.of(context);

    final statusColor = getStatusColor(status);
    final severityColor = getSeverityColor(severity);

    final cardBgColor = widget.isSelected
        ? appColor.withAlpha((0.04 * 255).toInt())
        : (_isHovered
              ? theme.colorScheme.surfaceContainerLow
              : theme.colorScheme.surface);

    final headline = incidentDescriptionHeadline(
      widget.incident.currentIncidentDescription,
    ).trim();

    final title = headline.isEmpty
        ? (widget.incident.currentIncidentTypeName ??
              'أزمة #${widget.incident.currentIncidentId}')
        : headline;

    final alertManager = getIt.isRegistered<RealTimeAlertManager>()
        ? getIt<RealTimeAlertManager>()
        : null;

    return StreamBuilder<Set<int>>(
      stream: alertManager?.highlightedIncidentIdsStream,
      initialData: alertManager?.highlightedIncidentIds ?? const {},
      builder: (context, snapshot) {
        final isHighlighted = widget.incident.currentIncidentId != null &&
            (snapshot.data?.contains(widget.incident.currentIncidentId) ?? false);

        final effectiveBorderColor = isHighlighted
            ? const Color(0xFF2563EB)
            : (widget.isSelected
                  ? appColor
                  : (_isHovered
                        ? appColor.withValues(alpha: 0.4)
                        : const Color(0xFFE2E8F0)));
        final effectiveBorderWidth = isHighlighted
            ? 2.0
            : (widget.isSelected ? 1.8 : 1.0);
        final incidentIdLabel = widget.incident.currentIncidentId != null
            ? '#${widget.incident.currentIncidentId}'
            : '#—';
        final missionCount =
            widget.incident.currentIncidentWithMissions?.length ?? 0;

        // ===================== UNIFIED 2-ROW ENTERPRISE INCIDENT CARD =====================
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: widget.useWebTileLayout
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: effectiveBorderColor,
                width: effectiveBorderWidth,
              ),
              boxShadow: [
                if (isHighlighted)
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.22),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  )
                else ...[
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _isHovered ? 0.06 : 0.025,
                    ),
                    blurRadius: _isHovered ? 12 : 6,
                    offset: Offset(0, _isHovered ? 4 : 2),
                  ),
                  if (widget.isSelected)
                    BoxShadow(
                      color: appColor.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 4, color: severityColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Row 1: Incident ID badge + Title + Severity & Status badges
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: appColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      incidentIdLabel,
                                      style: TextStyles.size11(
                                        fontWeight: FontWeight.w800,
                                        color: appColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyles.size13(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isHighlighted) ...[
                                    const SizedBox(width: 6),
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
                                  const SizedBox(width: 6),
                                  _SeverityBadge(
                                    severity: severity,
                                    severityColor: severityColor,
                                    compact: true,
                                  ),
                                  const SizedBox(width: 5),
                                  _StatusBadge(
                                    status: status,
                                    statusColor: statusColor,
                                    compact: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Row 2: Branch + Timestamp + Mission count
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.apartment_rounded,
                                    size: 13.5,
                                    color: AppTheme.textTertiary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      widget.incident.branchName ?? 'غير محدد',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyles.size12(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: AppTheme.textTertiary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.incident.currentIncidentCreatedAt !=
                                              null
                                          ? widget
                                                .incident
                                                .currentIncidentCreatedAt!
                                                .formatDateTimeArabic()
                                          : '—',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyles.size11(
                                        color: AppTheme.textTertiary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (missionCount > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.assignment_outlined,
                                            size: 11,
                                            color: Color(0xFF475569),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '$missionCount',
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int status;
  final Color statusColor;
  final bool compact;

  const _StatusBadge({
    required this.status,
    required this.statusColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 6 : 30),
      ),
      child: Text(
        getStatusArabic(status),
        style: TextStyle(
          color: statusColor,
          fontSize: compact ? 10 : 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final int severity;
  final Color severityColor;
  final bool compact;

  const _SeverityBadge({
    required this.severity,
    required this.severityColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 5,
      ),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(compact ? 6 : 10),
        border: Border.all(color: severityColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: BoxDecoration(
              color: severityColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            getSeverityArabic(severity),
            style: TextStyle(
              color: severityColor,
              fontSize: compact ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================= INCIDENT LIST =======================

class IncidentsList extends StatelessWidget {
  final List<CurrentIncidentModel> allIncidents;
  final bool useWebGrid;
  final void Function(CurrentIncidentModel incident)? onIncidentTap;
  final VoidCallback? onToggleViewMode;

  const IncidentsList({
    super.key,
    required this.allIncidents,
    this.useWebGrid = false,
    this.onIncidentTap,
    this.onToggleViewMode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();
        final incidents = cubit.filterIncidents(allIncidents);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(useWebGrid ? 12 : 16),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              useWebGrid ? 12 : 14,
              useWebGrid ? 10 : 14,
              useWebGrid ? 12 : 14,
              useWebGrid ? 10 : 14,
            ),
            child: Column(
              children: [
                DashboardListHeader(
                  count: incidents.length,
                  compact: useWebGrid,
                  isFullWidthGrid: useWebGrid,
                  onToggleViewMode: onToggleViewMode,
                ),
                Divider(
                  height: useWebGrid ? 14 : 20,
                  color: AppTheme.dividerColor.withValues(alpha: 0.7),
                ),
                Expanded(
                  child: incidents.isEmpty
                      ? _buildEmptyState()
                      : useWebGrid
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = incidentGridCrossAxisCount(
                              constraints.maxWidth,
                            );
                            return GridView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisExtent: 84,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                              itemCount: incidents.length,
                              itemBuilder: (context, index) {
                                final incident = incidents[index];
                                final isSelected =
                                    cubit.selectedIncident?.currentIncidentId ==
                                    incident.currentIncidentId;

                                return RepaintBoundary(
                                  key: ValueKey(incident.currentIncidentId),
                                  child: IncidentCard(
                                    incident: incident,
                                    isSelected: isSelected,
                                    useWebTileLayout: true,
                                    onTap: () {
                                      cubit.selectIncident(incident);
                                      onIncidentTap?.call(incident);
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: incidents.length,
                          itemBuilder: (context, index) {
                            final incident = incidents[index];

                            final isSelected =
                                cubit.selectedIncident?.currentIncidentId ==
                                incident.currentIncidentId;

                            return RepaintBoundary(
                              key: ValueKey(incident.currentIncidentId),
                              child: IncidentCard(
                                incident: incident,
                                isSelected: isSelected,
                                useWebTileLayout: false,
                                onTap: () {
                                  cubit.selectIncident(incident);
                                  if (MediaQuery.sizeOf(context).width <= 899) {
                                    onIncidentTap?.call(incident);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد أزمات مطابقة للبحث',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'حاول تغيير الفلاتر أو كتابة عبارة بحث أخرى',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
