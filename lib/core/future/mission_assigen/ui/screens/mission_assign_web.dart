import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/mission_assgien_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/all_active_user_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_assign_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_selction_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/all_active_user_state.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_assign_states.dart';
import 'package:incidents_managment/core/helpers/arabic_text_helper.dart';

import '../widgets/users_panel.dart' show ConfirmDialogDesktop;
import '../widgets/web/web_bottom_action_bar.dart';
import '../widgets/web/web_mission_header.dart';
import '../widgets/web/web_missions_sidebar.dart';
import '../widgets/web/web_user_filters_bar.dart';
import '../widgets/web/web_users_section.dart';

class MissionAssignWebScreen extends StatelessWidget {
  final CurrentIncidentModel incident;

  const MissionAssignWebScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MissionSelectionCubit(),
      child: Builder(
        builder: (context) => _MissionAssignWebView(incident: incident),
      ),
    );
  }
}

class _MissionAssignWebView extends StatefulWidget {
  final CurrentIncidentModel incident;

  const _MissionAssignWebView({required this.incident});

  @override
  State<_MissionAssignWebView> createState() => _MissionAssignWebViewState();
}

class _MissionAssignWebViewState extends State<_MissionAssignWebView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedAuthority;
  String? _selectedSector;
  String? _selectedGroup;
  String? _selectedStatus;

  List<CurrentIncidentWithMissions> get _sortedMissions {
    final list = List<CurrentIncidentWithMissions>.from(
      widget.incident.currentIncidentWithMissions ?? [],
    );
    list.sort((a, b) {
      final orderA = a.currentIncidentMissionOrder ??
          a.currentIncidentMissionId ??
          a.idCurrentIncidentMission ??
          999999;
      final orderB = b.currentIncidentMissionOrder ??
          b.currentIncidentMissionId ??
          b.idCurrentIncidentMission ??
          999999;
      return orderA.compareTo(orderB);
    });
    return list;
  }

  @override
  void initState() {
    super.initState();
    // Automatically select the first mission in sorted order if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final missions = _sortedMissions;
      final selCubit = context.read<MissionSelectionCubit>();
      if (missions.isNotEmpty && selCubit.activeMissionIds.isEmpty) {
        final firstId = missions.first.idCurrentIncidentMission;
        if (firstId != null) {
          selCubit.setActiveMission(firstId);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedAuthority = null;
      _selectedSector = null;
      _selectedGroup = null;
      _selectedStatus = null;
    });
  }

  List<ActiveUser> _filterUsers(List<ActiveUser> users) {
    return users.where((user) {
      // 1. Text Search (name, emp_code, username, authority)
      if (_searchQuery.isNotEmpty) {
        final matchesName = ArabicTextHelper.contains(user.empName, _searchQuery);
        final matchesCode =
            (user.empCode ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesUsername =
            (user.username ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesAuthority =
            ArabicTextHelper.contains(user.authorityName, _searchQuery);

        if (!matchesName && !matchesCode && !matchesUsername && !matchesAuthority) {
          return false;
        }
      }

      // 2. Authority Filter
      if (_selectedAuthority != null && user.authorityName != _selectedAuthority) {
        return false;
      }

      // 3. Sector / Management Filter
      if (_selectedSector != null &&
          user.sectorManagementName != _selectedSector) {
        return false;
      }

      // 4. Group Filter
      if (_selectedGroup != null && user.groupName != _selectedGroup) {
        return false;
      }

      // 5. Status / Availability Filter
      if (_selectedStatus != null) {
        final isAvailable = user.isActive != false;
        if (_selectedStatus == 'متاح' && !isAvailable) return false;
        if (_selectedStatus == 'غير متاح' && isAvailable) return false;
      }

      return true;
    }).toList();
  }

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
      widget.incident.currentIncidentId!,
      allPayload,
    );
  }

  void _showConfirmDialog(BuildContext context) {
    final selCubit = context.read<MissionSelectionCubit>();
    final assignCubit = context.read<MissionAssignCubit>();

    showDialog(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: selCubit),
          BlocProvider.value(value: assignCubit),
        ],
        child: Builder(
          builder: (dialogContext) => ConfirmDialogDesktop(
            incident: widget.incident,
            onConfirm: () => _performAssignment(dialogContext),
          ),
        ),
      ),
    );
  }

  void _onSuccess(BuildContext context) {
    final count = context.read<MissionSelectionCubit>().assignedMissionsCount;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(32, 0, 32, 24),
        backgroundColor: const Color(0xFF059669),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              'تم تعيين $count مهمة بنجاح ✓',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
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
        margin: const EdgeInsets.fromLTRB(32, 0, 32, 24),
        backgroundColor: const Color(0xFFDC2626),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missions = _sortedMissions;

    return BlocListener<MissionAssignCubit, MissionAssignState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          loaded: (_) => _onSuccess(context),
          error: (msg) => _showError(context, msg.error ?? 'حدث خطأ أثناء التعيين'),
        );
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: SafeArea(
            child: Column(
              children: [
                // Top Header (Breadcrumbs, Title, Subtitle, Back button)
                WebMissionHeader(
                  onBack: () => Navigator.of(context).pop(),
                ),

                // Main Content Body: Sidebar (Right in RTL) + Users Area (Left in RTL)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Right Side Panel: Required Missions
                        SizedBox(
                          width: 320,
                          child: WebMissionsSidebar(
                            missions: missions,
                            incident: widget.incident,
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Left Side Main Area: Filters + Users Grid
                        Expanded(
                          child: BlocBuilder<AllActiveUserCubit, AllActiveUserState>(
                            builder: (context, state) {
                              return state.when(
                                initial: () => const SizedBox.shrink(),
                                loading: () => _buildLoadingState(),
                                error: (msg) => _buildErrorState(context, msg),
                                loaded: (users) => _buildLoadedContent(users),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Persistent Bottom Action Bar
                WebBottomActionBar(
                  onAssign: () => _showConfirmDialog(context),
                  onCancel: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(List<ActiveUser> rawUsers) {
    // Extract distinct filter values
    final authorities = rawUsers
        .map((u) => u.authorityName)
        .where((a) => a != null && a.trim().isNotEmpty)
        .map((a) => a!.trim())
        .toSet()
        .toList()
      ..sort();

    final sectors = rawUsers
        .map((u) => u.sectorManagementName)
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toSet()
        .toList()
      ..sort();

    final groups = rawUsers
        .map((u) => u.groupName)
        .where((g) => g != null && g.trim().isNotEmpty)
        .map((g) => g!.trim())
        .toSet()
        .toList()
      ..sort();

    final filteredUsers = _filterUsers(rawUsers);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Card
          WebUserFiltersBar(
            searchController: _searchController,
            onSearchChanged: (query) => setState(() => _searchQuery = query),
            selectedAuthority: _selectedAuthority,
            onAuthorityChanged: (val) => setState(() => _selectedAuthority = val),
            authorities: authorities,
            selectedSector: _selectedSector,
            onSectorChanged: (val) => setState(() => _selectedSector = val),
            sectors: sectors,
            selectedGroup: _selectedGroup,
            onGroupChanged: (val) => setState(() => _selectedGroup = val),
            groups: groups,
            selectedStatus: _selectedStatus,
            onStatusChanged: (val) => setState(() => _selectedStatus = val),
            onResetFilters: _resetFilters,
          ),
          const SizedBox(height: 16),

          // User Selection Toolbar + Grid
          WebUsersSection(
            filteredUsers: filteredUsers,
            totalCount: filteredUsers.length,
            onResetFilters: _resetFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              color: Color(0xFF2563EB),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل بيانات المستخدمين...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 44,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<AllActiveUserCubit>().allActiveUsers(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
