import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/mission_assgien_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/all_active_user_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_assign_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_selction_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/all_active_user_state.dart';
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
      return const Color(0xFFF59E0B); // amber
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
            builder: (dialogContext) => _ConfirmDialogDesktop(
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
            builder: (sheetContext) => _ConfirmBottomSheet(
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
                _BottomActionBar(
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
                  child: _UsersPanel(isWide: true, onAssign: onAssign),
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
        _MissionHorizontalTabs(missions: missions),
        const SizedBox(height: 4),
        // ─── Users 
        Expanded(child: _UsersPanel(isWide: false)),
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
class _MissionHorizontalTabs extends StatelessWidget {
  final List<CurrentIncidentWithMissions> missions;
  const _MissionHorizontalTabs({required this.missions});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_rounded,
                    color: appColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "المهام",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: primaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${missions.length} مهمة",
                    style: const TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: missions.length,
                itemBuilder: (context, index) {
                  final mission = missions[index];
                  final mId = mission.idCurrentIncidentMission!;
                  final isActive = state.activeMissionId == mId;
                  final count = state.missionUserMap[mId]?.length ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context
                            .read<MissionSelectionCubit>()
                            .setActiveMission(mId),
                        borderRadius: BorderRadius.circular(22),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? const LinearGradient(
                                    colors: [appColor, Color(0xFF2B6CB0)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isActive ? null : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isActive
                                  ? Colors.transparent
                                  : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: appColor.withAlpha(60),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mission.missionName ?? "مهمة",
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : secondaryTextColor,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.white.withAlpha(51)
                                        : appColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "$count",
                                    style: TextStyle(
                                      color: isActive ? Colors.white : appColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
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
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// USERS PANEL
// ═══════════════════════════════════════════════════════════════════════════════
class _UsersPanel extends StatelessWidget {
  final bool isWide;
  final VoidCallback? onAssign;
  const _UsersPanel({required this.isWide, this.onAssign});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
      buildWhen: (prev, curr) => prev.activeMissionId != curr.activeMissionId,
      builder: (context, selState) {
        if (selState.activeMissionId == null) {
          return _EmptyMissionPlaceholder(isWide: isWide);
        }
        return BlocBuilder<AllActiveUserCubit, AllActiveUserState>(
          builder: (context, state) => state.when(
            initial: () => const SizedBox(),
            loading: () => _buildLoadingState(),
            error: (msg) => _ErrorWidget(message: msg),
            loaded: (users) => _UsersList(users: users, isWide: isWide, onAssign: onAssign),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: appColor,
              strokeWidth: 3,
              backgroundColor: appColor.withAlpha(30),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "جاري تحميل المستخدمين...",
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// USERS LIST (Search + Filter + Grid/List)
// ═══════════════════════════════════════════════════════════════════════════════
class _UsersList extends StatelessWidget {
  final List<dynamic> users;
  final bool isWide;
  final VoidCallback? onAssign;

  const _UsersList({required this.users, required this.isWide, this.onAssign});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
      builder: (context, state) {
        final selCubit = context.read<MissionSelectionCubit>();
        final authorities = users.map((e) => e.authorityName).toSet().toList();
        final sectors = users
            .map((e) => e.sectorManagementName)
            .toSet()
            .toList();

        final filteredUsers = users.where((user) {
          final matchesSearch = (user.empName ?? '').toLowerCase().contains(
            state.searchQuery.toLowerCase(),
          );
          final matchesAuthority =
              state.selectedAuthority == null ||
              user.authorityName == state.selectedAuthority;
          final matchesSector =
              state.selectedSector == null ||
              user.sectorManagementName == state.selectedSector;
          return matchesSearch && matchesAuthority && matchesSector;
        }).toList();

        final activeUsers = selCubit.activeUsers(state.activeMissionId);

        Widget content;
        if (isWide) {
          content = Container(
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
                _buildSearchAndFilters(
                  context,
                  selCubit,
                  state,
                  authorities,
                  sectors,
                ),
                _buildCountBar(context, selCubit, filteredUsers, activeUsers),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 3.8,
                        ),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelected = activeUsers.contains(user);
                      return _UserCard(
                        user: user,
                        isSelected: isSelected,
                        onTap: () => selCubit.toggleUser(user),
                      );
                    },
                  ),
                ),
                if (onAssign != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: const Text("إلغاء", style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: onAssign,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4F8A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text("تعيين المهام", style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),

              ],
            ),
          );
        } else {
          content = Column(
            children: [
              _buildSearchAndFilters(
                context,
                selCubit,
                state,
                authorities,
                sectors,
              ),
              _buildCountBar(context, selCubit, filteredUsers, activeUsers),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isSelected = activeUsers.contains(user);
                    return _UserCard(
                      user: user,
                      isSelected: isSelected,
                      onTap: () => selCubit.toggleUser(user),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return content;
      },
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    MissionSelectionCubit selCubit,
    MissionSelectionState state,
    List<dynamic> authorities,
    List<dynamic> sectors,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "بحث بالاسم...",
                hintStyle: TextStyle(
                  color: secondaryTextColor.withAlpha(150),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.search_rounded,
                    color: appColor,
                    size: 22,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: selCubit.updateSearch,
            ),
          ),
          const SizedBox(height: 10),
          // Filter row
          Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  label: "الصلاحية",
                  value: state.selectedAuthority,
                  items: authorities.cast<String?>(),
                  onChanged: selCubit.updateAuthority,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterDropdown(
                  label: "القطاع",
                  value: state.selectedSector,
                  items: sectors.cast<String?>(),
                  onChanged: selCubit.updateSector,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountBar(
    BuildContext context,
    MissionSelectionCubit selCubit,
    List<dynamic> filteredUsers,
    Set<dynamic> activeUsers,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${filteredUsers.length} مستخدم",
              style: const TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          if (activeUsers.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [appColor, Color(0xFF2B6CB0)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${activeUsers.length} محدد",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton.icon(
            onPressed: () => selCubit.toggleAllUsers(filteredUsers),
            icon: Icon(
              activeUsers.length == filteredUsers.length
                  ? Icons.deselect_rounded
                  : Icons.select_all_rounded,
              size: 16,
              color: appColor,
            ),
            label: Text(
              activeUsers.length == filteredUsers.length
                  ? "إلغاء الكل"
                  : "تحديد الكل",
              style: const TextStyle(
                color: appColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FILTER DROPDOWN
// ═══════════════════════════════════════════════════════════════════════════════
class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String?> items;
  final void Function(String?) onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: secondaryTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: value != null
              ? GestureDetector(
                  onTap: () => onChanged(null),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                )
              : null,
        ),
        initialValue: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: appColor,
          size: 20,
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(
                  e ?? "",
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// USER CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _UserCard extends StatelessWidget {
  final dynamic user;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  Color _avatarColor() {
    final name = user.empName ?? '';
    if (name.isEmpty) return appColor;
    final colors = [
      const Color(0xFF1B4F8A), const Color(0xFF059669),
      const Color(0xFFD97706), const Color(0xFF7C3AED),
      const Color(0xFFDC2626), const Color(0xFF0891B2),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? appColor.withAlpha(10) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? appColor.withAlpha(80) : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? appColor : color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      (user.empName?[0] ?? "").toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.empName ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isSelected ? appColor : const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "${user.authorityName ?? ''} - ${user.sectorManagementName ?? ''}",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  activeColor: appColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final CurrentIncidentModel incident;
  final VoidCallback onAssign;
  final bool isWide;

  const _BottomActionBar({
    required this.incident,
    required this.onAssign,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
      builder: (context, selState) {
        return BlocBuilder<MissionAssignCubit, MissionAssignState>(
          builder: (context, assignState) {
            final selCubit = context.read<MissionSelectionCubit>();
            final isLoading = assignState is MissionAssignStateLoading;
            final canAssign = selCubit.canAssign;

            return ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    isWide ? 10 : MediaQuery.paddingOf(context).bottom + 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    border: const Border(
                      top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Summary
                      Expanded(
                        child: canAssign
                            ? _buildSummary(selState, selCubit)
                            : const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: secondaryTextColor,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "اختر مهمة ثم عيّن مستخدمين",
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(width: 16),
                      // CTA Button
                      AnimatedOpacity(
                        opacity: canAssign ? 1.0 : 0.5,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: canAssign
                                ? const LinearGradient(
                                    colors: [appColor, Color(0xFF2B6CB0)],
                                  )
                                : null,
                            color: canAssign ? null : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: canAssign
                                ? [
                                    BoxShadow(
                                      color: appColor.withAlpha(80),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: canAssign && !isLoading ? onAssign : null,
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLoading)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    const SizedBox(width: 10),
                                    Text(
                                      isLoading
                                          ? "جاري التعيين..."
                                          : "تعيين المهام",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummary(
    MissionSelectionState selState,
    MissionSelectionCubit selCubit,
  ) {
    final assigned = selState.missionUserMap.entries
        .where((e) => e.value.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.summarize_rounded, color: appColor, size: 16),
            const SizedBox(width: 6),
            Text(
              "${selCubit.assignedMissionsCount} مهمة · ${assigned.fold<int>(0, (sum, e) => sum + e.value.length)} مستخدم",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: appColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...assigned.take(2).map((e) {
          final mission = incident.currentIncidentWithMissions?.firstWhere(
            (m) => m.idCurrentIncidentMission == e.key,
            orElse: () =>
                CurrentIncidentWithMissions(idCurrentIncidentMission: e.key),
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              "${mission?.missionName ?? 'مهمة'}: ${e.value.length} مستخدم",
              style: const TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
        if (assigned.length > 2)
          Text(
            "+${assigned.length - 2} مهام أخرى",
            style: TextStyle(
              color: appColor.withAlpha(150),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EMPTY / ERROR STATES
// ═══════════════════════════════════════════════════════════════════════════════
class _EmptyMissionPlaceholder extends StatelessWidget {
  final bool isWide;
  const _EmptyMissionPlaceholder({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final container = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: appColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.touch_app_rounded,
              color: appColor.withAlpha(100),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "اضغط على مهمة لتعيين مستخدمين لها",
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "اختر مهمة من ${isWide ? 'القائمة الجانبية' : 'الأعلى'} للبدء",
            style: TextStyle(
              color: secondaryTextColor.withAlpha(150),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );

    if (isWide) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: container,
      );
    }
    return container;
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: errorColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: errorColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: errorColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () =>
                context.read<AllActiveUserCubit>().allActiveUsers(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text("إعادة المحاولة"),
            style: TextButton.styleFrom(foregroundColor: appColor),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIRM DIALOG (Desktop)
// ═══════════════════════════════════════════════════════════════════════════════
class _ConfirmDialogDesktop extends StatelessWidget {
  final CurrentIncidentModel incident;
  final VoidCallback onConfirm;

  const _ConfirmDialogDesktop({
    required this.incident,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final selState = context.watch<MissionSelectionCubit>().state;
    final assignState = context.watch<MissionAssignCubit>().state;
    final isLoading = assignState is MissionAssignStateLoading;
    final assignedCount = context
        .read<MissionSelectionCubit>()
        .assignedMissionsCount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [appColor.withAlpha(30), appColor.withAlpha(12)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: appColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "تأكيد التعيين",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: primaryTextColor,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "سيتم إرسال تعيينات لـ $assignedCount مهمة",
                style: const TextStyle(color: secondaryTextColor, fontSize: 14),
              ),
              const SizedBox(height: 20),
              // Assignments list
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: selState.missionUserMap.entries
                        .where((e) => e.value.isNotEmpty)
                        .map((e) => _buildMissionSummaryRow(e))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "إلغاء",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [appColor, Color(0xFF2B6CB0)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: appColor.withAlpha(60),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.pop(context);
                                onConfirm();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "تأكيد التعيين",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionSummaryRow(MapEntry<int, Set<dynamic>> entry) {
    final mission = incident.currentIncidentWithMissions?.firstWhere(
      (m) => m.idCurrentIncidentMission == entry.key,
      orElse: () =>
          CurrentIncidentWithMissions(idCurrentIncidentMission: entry.key),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: appColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: appColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mission?.missionName ?? 'مهمة ${entry.key}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: appColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${entry.value.length} مستخدم",
                  style: const TextStyle(
                    color: appColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entry.value
                .map(
                  (u) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: appColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              (u.empName?[0] ?? '').toUpperCase(),
                              style: const TextStyle(
                                color: appColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          u.empName ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIRM BOTTOM SHEET (Mobile)
// ═══════════════════════════════════════════════════════════════════════════════
class _ConfirmBottomSheet extends StatelessWidget {
  final CurrentIncidentModel incident;
  final VoidCallback onConfirm;

  const _ConfirmBottomSheet({required this.incident, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final selState = context.watch<MissionSelectionCubit>().state;
    final assignState = context.watch<MissionAssignCubit>().state;
    final isLoading = assignState is MissionAssignStateLoading;
    final assignedCount = context
        .read<MissionSelectionCubit>()
        .assignedMissionsCount;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          const Icon(
            Icons.assignment_turned_in_rounded,
            color: appColor,
            size: 36,
          ),
          const SizedBox(height: 12),
          const Text(
            "تأكيد التعيين",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "سيتم إرسال تعيينات لـ $assignedCount مهمة",
            style: const TextStyle(color: secondaryTextColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          // List
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: selState.missionUserMap.entries
                    .where((e) => e.value.isNotEmpty)
                    .map((e) {
                      final mission = incident.currentIncidentWithMissions
                          ?.firstWhere(
                            (m) => m.idCurrentIncidentMission == e.key,
                            orElse: () => CurrentIncidentWithMissions(
                              idCurrentIncidentMission: e.key,
                            ),
                          );
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: appColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.assignment_rounded,
                                color: appColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                mission?.missionName ?? 'مهمة',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: appColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${e.value.length} مستخدم",
                                style: const TextStyle(
                                  color: appColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Actions
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: secondaryTextColor,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "إلغاء",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [appColor, Color(0xFF2B6CB0)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: appColor.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                              onConfirm();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "تأكيد التعيين",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
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
