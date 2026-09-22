import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/users_panel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/mission_assgien_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_assign_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_selction_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_assign_states.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_selection_state.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/incident_description_present.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────
const _kWideBreakpoint = 800.0;
const _kSidebarWidth = 220.0;

const _kGradientStart = appColor;
const _kGradientEnd = Color(0xFF0D3B6E);

// Severity color helpers
Color _severityColor(int? severity) {
  switch (severity) {
    case 1:
      return const Color(0xFF22C55E); // green
    case 2:
      return const Color(0xFFFFC107); // blue (medium severity)
    case 3:
      return const Color(0xFFF97316); // orange
    case 4:
      return const Color(0xFFEF4444); // red
    default:
      return secondaryTextColor;
  }
}

String _severityLabel(int? severity) {
  switch (severity) {
    case 1:
      return 'منخفض';
    case 2:
      return 'متوسطة';
    case 3:
      return 'مرتفعة';
    case 4:
      return 'حرجة';
    default:
      return 'غير محدد';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry Point
// ─────────────────────────────────────────────────────────────────────────────
class MissionAssignWebScreen extends StatelessWidget {
  final CurrentIncidentModel incident;
  const MissionAssignWebScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MissionSelectionCubit(),
      child: Builder(
        builder: (context) => _MissionAssignView(incident: incident),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main View
// ─────────────────────────────────────────────────────────────────────────────
class _MissionAssignView extends StatelessWidget {
  final CurrentIncidentModel incident;
  const _MissionAssignView({required this.incident});

  bool _isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _kWideBreakpoint;

  List<MissionAssgienModel> _buildPayload(int missionId, Set<dynamic> users) {
    return users
        .map(
          (u) => MissionAssgienModel(
            missionId: missionId,
            userId: u.userId as int,
          ),
        )
        .toList();
  }

  Future<void> _performAssignment(BuildContext context) async {
    final selCubit = context.read<MissionSelectionCubit>();
    final assignCubit = context.read<MissionAssignCubit>();

    final allPayload = selCubit.state.missionUserMap.entries
        .where((e) => e.value.isNotEmpty)
        .expand((e) => _buildPayload(e.key, e.value))
        .toList();

    if (allPayload.isEmpty) return;

    await assignCubit.missionUserAssign(
      incident.currentIncidentId!,
      allPayload,
    );
  }

  void _showConfirmSheet(BuildContext context) {
    final selCubit = context.read<MissionSelectionCubit>();
    final assignCubit = context.read<MissionAssignCubit>();
    final isWide = _isWide(context);

    if (isWide) {
      // Web: centered dialog
      showDialog(
        context: context,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: selCubit),
            BlocProvider.value(value: assignCubit),
          ],
          child: Builder(
            builder: (dialogContext) => ConfirmDialogDesktop(
              incident: incident,
              onConfirm: () => _performAssignment(dialogContext),
            ),
          ),
        ),
      );
    } else {
      // Mobile: bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: selCubit),
            BlocProvider.value(value: assignCubit),
          ],
          child: Builder(
            builder: (sheetContext) => ConfirmBottomSheet(
              incident: incident,
              onConfirm: () => _performAssignment(sheetContext),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final missions = incident.currentIncidentWithMissions ?? [];
    final isWide = _isWide(context);

    return BlocListener<MissionAssignCubit, MissionAssignState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          loaded: (_) => _onSuccess(context),
          error: (msg) => _showError(context, msg.error ?? "error"),
        );
      },
      child: Scaffold(
        backgroundColor: isWide
            ? const Color(0xFFF1F5F9)
            : const Color(0xFFF8FAFC),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // ─── Premium AppBar ──────────────────────────────────────
              _PremiumAppBar(incident: incident, isWide: isWide),
              Expanded(
                child: isWide
                    ? _buildWideLayout(context, missions, () => _showConfirmSheet(context))
                    : _buildNarrowLayout(context, missions),
              ),
              if (!isWide)
                BottomActionBar(
                incident: incident,
                onAssign: () => _showConfirmSheet(context),
                isWide: isWide,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 
  // WIDE LAYOUT (Web / Desktop)
  Widget _buildWideLayout(
    BuildContext context,
    List<CurrentIncidentWithMissions> missions,
    VoidCallback onAssign,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 24, 40, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: _MissionsSidebar(missions: missions, incident: incident),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: UsersPanel(isWide: true),
                      ),
                      BottomActionBar(
                        incident: incident,
                        onAssign: onAssign,
                        isWide: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    List<CurrentIncidentWithMissions> missions,
  ) {
    return Column(
      children: [
        _IncidentInfoCard(incident: incident),
        MissionHorizontalTabs(missions: missions),
        const SizedBox(height: 4),
        // ─── Users 
        Expanded(child: UsersPanel(isWide: false)),
      ],
    );
  }

  void _onSuccess(BuildContext context) {
    final count = context.read<MissionSelectionCubit>().assignedMissionsCount;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        backgroundColor: const Color(0xFF059669),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              "تم تعيين $count مهمة بنجاح ✓",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
    context.read<MissionSelectionCubit>().reset();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        backgroundColor: errorColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREMIUM APP BAR
// ═══════════════════════════════════════════════════════════════════════════════
class _PremiumAppBar extends StatelessWidget {
  final CurrentIncidentModel incident;
  final bool isWide;

  const _PremiumAppBar({required this.incident, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final headline = incidentDescriptionHeadline(
      incident.currentIncidentDescription,
    ).trim();
    final title = headline.isEmpty ? 'بدون وصف' : headline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87, size: 18),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text("الرئيسية", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_left, size: 16, color: Colors.grey)),
                    Text("تعيين المهام", style: TextStyle(color: appColor, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isWide) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _AppBarChip(
                        icon: Icons.location_on_rounded,
                        label: incident.branchName ?? 'غير محدد',
                      ),
                      const SizedBox(width: 8),
                      if (incident.currentIncidentTypeName != null)
                        _AppBarChip(
                          icon: Icons.category_rounded,
                          label: incident.currentIncidentTypeName!,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
            builder: (context, state) {
              final count = context
                  .read<MissionSelectionCubit>()
                  .assignedMissionsCount;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: appColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: appColor.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: appColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "$count",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "مهام محددة",
                      style: TextStyle(
                        color: appColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(38)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _AppBarChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AppBarChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(210),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final int? severity;
  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
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
            _severityLabel(severity),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INCIDENT INFO CARD (Mobile only)
// ═══════════════════════════════════════════════════════════════════════════════
class _IncidentInfoCard extends StatelessWidget {
  final CurrentIncidentModel incident;
  const _IncidentInfoCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: appColor.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appColor.withAlpha(30), appColor.withAlpha(12)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.campaign_rounded,
              color: appColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: secondaryTextColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      incident.branchName ?? 'غير محدد',
                      style: const TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    _SeverityBadge(severity: incident.currentIncidentSeverity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MISSIONS SIDEBAR (Web)
// ═══════════════════════════════════════════════════════════════════════════════
class _MissionsSidebar extends StatelessWidget {
  final List<CurrentIncidentWithMissions> missions;
  final CurrentIncidentModel incident;

  const _MissionsSidebar({required this.missions, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: appColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: appColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "المهام المطلوبة",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: primaryTextColor,
                    ),
                  ),
                ),
                BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
                  builder: (context, state) {
                    final count = context
                        .read<MissionSelectionCubit>()
                        .assignedMissionsCount;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [appColor, Color(0xFF2B6CB0)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$count",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Mission list
          Expanded(
            child: BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
              builder: (context, state) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  itemCount: missions.length,
                  itemBuilder: (context, index) {
                    final mission = missions[index];
                    final mId = mission.idCurrentIncidentMission!;
                    final isActive = state.activeMissionId == mId;
                    final assignedCount =
                        state.missionUserMap[mId]?.length ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context
                              .read<MissionSelectionCubit>()
                              .setActiveMission(mId),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? LinearGradient(
                                      colors: [
                                        appColor.withAlpha(20),
                                        appColor.withAlpha(8),
                                      ],
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isActive
                                    ? appColor.withAlpha(60)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Active indicator bar
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 4,
                                  height: isActive ? 28 : 0,
                                  decoration: BoxDecoration(
                                    gradient: isActive
                                        ? const LinearGradient(
                                            colors: [appColor, waterBlue],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(width: isActive ? 12 : 0),
                                // Mission icon
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? appColor
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.white
                                            : secondaryTextColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    mission.missionName ?? "مهمة",
                                    style: TextStyle(
                                      color: isActive
                                          ? appColor
                                          : primaryTextColor,
                                      fontWeight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (assignedCount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? appColor
                                          : successColor.withAlpha(25),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person_rounded,
                                          size: 12,
                                          color: isActive
                                              ? Colors.white
                                              : successColor,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          "$assignedCount",
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.white
                                                : successColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MISSION HORIZONTAL TABS (Mobile)
// ═══════════════════════════════════════════════════════════════════════════════