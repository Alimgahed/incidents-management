import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/list_header.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/incident_description_present.dart';
import 'package:incidents_managment/core/helpers/date_format.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';
import 'package:incidents_managment/core/theming/styling.dart';

/// Column count for the web incident grid from available width.
int incidentGridCrossAxisCount(double width) {
  if (width >= 1680) return 6;
  if (width >= 1380) return 5;
  if (width >= 1080) return 4;
  if (width >= 780) return 3;
  if (width >= 480) return 2;
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
    final id = widget.incident.currentIncidentId;

    final statusColor = getStatusColor(status);
    final severityColor = getSeverityColor(severity);

    final baseBorderColor = widget.isSelected
        ? appColor
        : (_isHovered
              ? appColor.withAlpha((0.35 * 255).toInt())
              : const Color(0xFFE2E8F0));

    final cardBgColor = widget.isSelected
        ? appColor.withAlpha((0.04 * 255).toInt())
        : (_isHovered ? const Color(0xFFF8FAFC) : theme.colorScheme.surface);

    final headline = incidentDescriptionHeadline(
      widget.incident.currentIncidentDescription,
    ).trim();

    final title = headline.isEmpty
        ? (widget.incident.currentIncidentTypeName ??
              'أزمة #${widget.incident.currentIncidentId}')
        : headline;

    // ===================== WEB GRID CARD (compact) =====================
    if (widget.useWebTileLayout) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: baseBorderColor,
                  width: widget.isSelected ? 1.8 : 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: appColor.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(width: 4, color: severityColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              if (id != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '#$id',
                                    style: TextStyles.size11(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              if (id != null) const SizedBox(width: 6),
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
                              const SizedBox(width: 6),
                              _StatusBadge(
                                status: status,
                                statusColor: statusColor,
                                compact: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.apartment_rounded,
                                size: 13,
                                color: AppTheme.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.incident.branchName ?? '—',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.size11(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              _SeverityBadge(
                                severity: severity,
                                severityColor: severityColor,
                                compact: true,
                              ),
                              if (widget.incident.currentIncidentCreatedAt !=
                                  null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  widget.incident.currentIncidentCreatedAt!
                                      .timeAgoArabic(),
                                  style: TextStyles.size11(
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: _isHovered ? appColor : AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ===================== MOBILE LIST CARD / VERTICAL LIST CARD =====================

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        child: Material(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: baseBorderColor,
                  width: widget.isSelected ? 2 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: _isHovered ? 8 : 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: ID + Title + Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#$id',
                          style: TextStyles.size10(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      if (id != null) const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.size12(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(
                        status: status,
                        statusColor: statusColor,
                        compact: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  // Row 2: Branch + Severity
                  Row(
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: 13,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.incident.branchName ?? '—',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.size10(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SeverityBadge(
                        severity: severity,
                        severityColor: severityColor,
                        compact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

  const IncidentsList({
    super.key,
    required this.allIncidents,
    this.useWebGrid = false,
    this.onIncidentTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();
        final incidents = cubit.filterIncidents(allIncidents);

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(useWebGrid ? 12 : 16),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              useWebGrid ? 10 : 16,
              useWebGrid ? 8 : 16,
              useWebGrid ? 10 : 16,
              useWebGrid ? 6 : 16,
            ),
            child: Column(
              children: [
                DashboardListHeader(
                  count: incidents.length,
                  compact: useWebGrid,
                ),
                Divider(
                  height: useWebGrid ? 10 : 20,
                  color: AppTheme.dividerColor.withValues(alpha: 0.7),
                ),
                Expanded(
                  child: incidents.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          cacheExtent: 500,
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
                                useWebTileLayout: useWebGrid,
                                onTap: () {
                                  cubit.selectIncident(incident);
                                  onIncidentTap?.call(incident);
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
