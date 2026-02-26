import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/mission_assgien_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/all_active_user_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_assign_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/all_active_user_state.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_assign_states.dart';

class MissionAssignScreen extends StatefulWidget {
  final CurrentIncidentModel incident;
  const MissionAssignScreen({super.key, required this.incident});

  @override
  State<MissionAssignScreen> createState() => _MissionAssignScreenState();
}

class _MissionAssignScreenState extends State<MissionAssignScreen>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  String? selectedAuthority;
  String? selectedSector;
  bool _isAssigning = false;

  /// Mission → Set of assigned user objects
  final Map<int, Set<dynamic>> missionUserMap = {};

  /// Currently active mission (whose users are shown)
  int? activeMissionId;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Set<dynamic> get _activeUsers =>
      activeMissionId != null ? (missionUserMap[activeMissionId] ?? {}) : {};

  int get assignedMissionsCount =>
      missionUserMap.values.where((s) => s.isNotEmpty).length;

  bool get canAssign => assignedMissionsCount > 0;

  void _toggleUserForActiveMission(dynamic user) {
    if (activeMissionId == null) return;
    setState(() {
      final set = missionUserMap.putIfAbsent(activeMissionId!, () => {});
      if (set.contains(user)) {
        set.remove(user);
      } else {
        set.add(user);
      }
    });
  }

  /// Build the payload for the API: list of MissionAssgienModel
  List<MissionAssgienModel> _buildPayload() {
    final List<MissionAssgienModel> models = [];
    for (final entry in missionUserMap.entries) {
      if (entry.value.isEmpty) continue;
      for (final user in entry.value) {
        models.add(
          MissionAssgienModel(missionId: entry.key, userId: user.userId as int),
        );
      }
    }
    return models;
  }

  void _assignAll() {
    if (!canAssign) return;
    // Capture the cubit BEFORE opening the dialog, since showDialog creates
    // a new route with a different BuildContext that has no access to providers.
    final cubit = context.read<MissionAssignCubit>();
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "تأكيد التعيين",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: appColor,
              fontSize: 18,
            ),
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "سيتم إرسال تعيينات لـ $assignedMissionsCount مهمة",
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: secondaryTextColor),
                ),
                const SizedBox(height: 12),
                ...missionUserMap.entries.where((e) => e.value.isNotEmpty).map((
                  e,
                ) {
                  final mission = widget.incident.currentIncidentWithMissions
                      ?.firstWhere(
                        (m) => m.currentIncidentMissionId == e.key,
                        orElse: () => CurrentIncidentWithMissions(
                          currentIncidentMissionId: e.key,
                        ),
                      );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "📋 ${mission?.missionName ?? 'مهمة ${e.key}'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: appColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 4,
                          runSpacing: 4,
                          children: e.value
                              .map(
                                (u) => Chip(
                                  label: Text(
                                    u.empName ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: buttonColor.withOpacity(0.1),
                                  side: BorderSide(
                                    color: buttonColor.withOpacity(0.3),
                                  ),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "إلغاء",
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
            BlocConsumer<MissionAssignCubit, MissionAssignState>(
              listener: (context, state) {
                state.when(
                  initial: () {},
                  loading: () {},
                  loaded: (_) {
                    Navigator.pop(ctx);
                    _onAssignSuccess(); // also resets _isAssigning via setState
                  },
                  error: (message) {
                    Navigator.pop(ctx);
                    _showErrorSnackbar(message);
                    if (mounted) setState(() => _isAssigning = false);
                  },
                );
              },
              builder: (context, state) {
                final isLoading = state is MissionAssignStateLoading;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoading ? null : () => _performAssignment(cubit),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("تأكيد التعيين"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Sends one API call per mission (sequential).
  /// Accepts the already-captured [cubit] to avoid using a dialog's BuildContext.
  Future<void> _performAssignment([MissionAssignCubit? passedCubit]) async {
    final cubit = passedCubit ?? context.read<MissionAssignCubit>();
    setState(() => _isAssigning = true);
    final missionsToAssign = missionUserMap.entries
        .where((e) => e.value.isNotEmpty)
        .toList();

    for (final entry in missionsToAssign) {
      await cubit.missionUserAssign(entry.key);
      if (!mounted) return;
      if (cubit.state is MissionAssignStateError) {
        setState(() => _isAssigning = false);
        return;
      }
    }
    if (mounted) setState(() => _isAssigning = false);
  }

  void _onAssignSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: appColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "تم تعيين $assignedMissionsCount مهمة بنجاح",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
    setState(() {
      missionUserMap.clear();
      activeMissionId = null;
      _isAssigning = false;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: errorColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isWideScreen => MediaQuery.of(context).size.width >= 800;

  @override
  Widget build(BuildContext context) {
    final missions = widget.incident.currentIncidentWithMissions ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _isWideScreen
            ? _buildWideLayout(missions)
            : _buildNarrowLayout(missions),
      ),
    );
  }

  // ─── Wide (Web / Tablet) Layout ────────────────────────────────────────────

  Widget _buildWideLayout(List<CurrentIncidentWithMissions> missions) {
    return Column(
      children: [
        _buildIncidentCard(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left panel: missions + bottom bar
              SizedBox(
                width: 260,
                child: Column(
                  children: [
                    Expanded(child: _buildMissionsList(missions)),
                    _buildBottomBar(),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, color: borderColor),
              // Right panel: users
              Expanded(
                child: Column(
                  children: [
                    _buildActiveMissionLabel(missions),
                    Expanded(
                      child: activeMissionId == null
                          ? _buildSelectMissionPlaceholder()
                          : BlocBuilder<AllActiveUserCubit, AllActiveUserState>(
                              builder: (context, state) => state.when(
                                initial: () => const SizedBox(),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    color: appColor,
                                  ),
                                ),
                                error: (msg) => _buildErrorWidget(msg),
                                loaded: (users) => _buildUsersSection(users),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Narrow (Mobile) Layout ─────────────────────────────────────────────────

  Widget _buildNarrowLayout(List<CurrentIncidentWithMissions> missions) {
    return Column(
      children: [
        _buildIncidentCard(),
        _buildMissionsSection(missions),
        _buildActiveMissionLabel(missions),
        const SizedBox(height: 8),
        Expanded(
          child: activeMissionId == null
              ? _buildSelectMissionPlaceholder()
              : BlocBuilder<AllActiveUserCubit, AllActiveUserState>(
                  builder: (context, state) => state.when(
                    initial: () => const SizedBox(),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: appColor),
                    ),
                    error: (msg) => _buildErrorWidget(msg),
                    loaded: (users) => _buildUsersSection(users),
                  ),
                ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  // ─── Shared Widgets ──────────────────────────────────────────────────────────

  Widget _buildActiveMissionLabel(List<CurrentIncidentWithMissions> missions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Expanded(child: Divider(color: borderColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              activeMissionId != null
                  ? "مستخدمو: ${missions.firstWhere((m) => m.currentIncidentMissionId == activeMissionId, orElse: () => CurrentIncidentWithMissions()).missionName ?? ''}"
                  : "اختر مهمة أولاً",
              style: TextStyle(
                color: activeMissionId != null ? appColor : secondaryTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const Expanded(child: Divider(color: borderColor)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: errorColor, size: 48),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: errorColor)),
        ],
      ),
    );
  }

  Widget _buildSelectMissionPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_rounded,
            color: appColor.withOpacity(0.3),
            size: 64,
          ),
          const SizedBox(height: 12),
          Text(
            "اضغط على مهمة لتعيين مستخدمين لها",
            style: const TextStyle(color: secondaryTextColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: appColor,
      elevation: 0,
      title: const Text(
        "تعيين مسؤول للمهمة",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.15)),
      ),
    );
  }

  Widget _buildIncidentCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [appColor, Color(0xFF2A4D7C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.incident.currentIncidentDescription ?? "بدون وصف",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.incident.branchName ?? "",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Vertical list used in the wide layout sidebar
  Widget _buildMissionsList(List<CurrentIncidentWithMissions> missions) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        final mId = mission.currentIncidentMissionId!;
        final isActive = activeMissionId == mId;
        final assignedCount = missionUserMap[mId]?.length ?? 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() => activeMissionId = mId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? appColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? appColor : borderColor,
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: appColor.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      mission.missionName ?? "مهمة",
                      style: TextStyle(
                        color: isActive ? Colors.white : appColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (assignedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withOpacity(0.25)
                            : buttonColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "👤 $assignedCount",
                        style: TextStyle(
                          color: isActive ? Colors.white : buttonColor,
                          fontSize: 11,
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
  }

  /// Horizontal chip list used in the narrow (mobile) layout
  Widget _buildMissionsSection(List<CurrentIncidentWithMissions> missions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                "المهام",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: appColor,
                ),
              ),
              const SizedBox(width: 8),
              if (assignedMissionsCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: appColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$assignedMissionsCount مهمة لها مستخدمون",
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 58,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: missions.length,
            itemBuilder: (context, index) {
              final mission = missions[index];
              final mId = mission.currentIncidentMissionId!;
              final isActive = activeMissionId == mId;
              final assignedCount = missionUserMap[mId]?.length ?? 0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => setState(() => activeMissionId = mId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? appColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? appColor : borderColor,
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: appColor.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mission.missionName ?? "مهمة",
                          style: TextStyle(
                            color: isActive ? Colors.white : appColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (assignedCount > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            "👤 $assignedCount",
                            style: TextStyle(
                              color: isActive ? Colors.white70 : buttonColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildUsersSection(List<dynamic> users) {
    final authorities = users.map((e) => e.authorityName).toSet().toList();
    final sectors = users.map((e) => e.sectorManagementName).toSet().toList();

    final filteredUsers = users.where((user) {
      final matchesSearch = (user.empName ?? '').toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesAuthority =
          selectedAuthority == null || user.authorityName == selectedAuthority;
      final matchesSector =
          selectedSector == null || user.sectorManagementName == selectedSector;
      return matchesSearch && matchesAuthority && matchesSector;
    }).toList();

    final activeUsers = _activeUsers;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "بحث بالاسم...",
                  hintStyle: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: appColor,
                    size: 22,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: appColor, width: 1.5),
                  ),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: "الصلاحية",
                      value: selectedAuthority,
                      items: authorities.cast<String?>(),
                      onChanged: (val) =>
                          setState(() => selectedAuthority = val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown(
                      label: "القطاع",
                      value: selectedSector,
                      items: sectors.cast<String?>(),
                      onChanged: (val) => setState(() => selectedSector = val),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${filteredUsers.length} مستخدم",
                style: const TextStyle(color: secondaryTextColor, fontSize: 13),
              ),
              Row(
                children: [
                  if (activeUsers.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${activeUsers.length} محدد",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        final set = missionUserMap.putIfAbsent(
                          activeMissionId!,
                          () => {},
                        );
                        if (set.length == filteredUsers.length) {
                          set.clear();
                        } else {
                          set.addAll(filteredUsers);
                        }
                      });
                    },
                    icon: Icon(
                      activeUsers.length == filteredUsers.length
                          ? Icons.deselect
                          : Icons.people,
                      size: 16,
                      color: buttonColor,
                    ),
                    label: Text(
                      activeUsers.length == filteredUsers.length
                          ? "إلغاء الكل"
                          : "تحديد الكل",
                      style: const TextStyle(color: buttonColor, fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final isSelected = activeUsers.contains(user);
              return _buildUserCard(user, isSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String?> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryTextColor, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: appColor, width: 1.5),
        ),
        suffixIcon: value != null
            ? GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: secondaryTextColor,
                ),
              )
            : null,
      ),
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down, color: appColor),
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
    );
  }

  Widget _buildUserCard(dynamic user, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? appColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? appColor : borderColor,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: appColor.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: () => _toggleUserForActiveMission(user),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundColor: isSelected
                  ? appColor
                  : appColor.withOpacity(0.1),
              radius: 22,
              child: Text(
                (user.empName?[0] ?? "").toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : appColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: appColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
        title: Text(
          user.empName ?? "",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isSelected ? appColor : primaryTextColor,
          ),
        ),
        subtitle: Text(
          "${user.authorityName ?? ''} · ${user.sectorManagementName ?? ''}",
          style: const TextStyle(color: secondaryTextColor, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (val) => _toggleUserForActiveMission(user),
          activeColor: appColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(
            color: isSelected ? appColor : borderColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        _isWideScreen ? 12 : MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: assignedMissionsCount > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: missionUserMap.entries
                        .where((e) => e.value.isNotEmpty)
                        .map((e) {
                          final mission = widget
                              .incident
                              .currentIncidentWithMissions
                              ?.firstWhere(
                                (m) => m.currentIncidentMissionId == e.key,
                                orElse: () => CurrentIncidentWithMissions(
                                  currentIncidentMissionId: e.key,
                                ),
                              );
                          return Text(
                            "📋 ${mission?.missionName ?? 'مهمة'}: 👤 ${e.value.length}",
                            style: const TextStyle(
                              color: appColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        })
                        .toList(),
                  )
                : const Text(
                    "اختر مهمة ثم عيّن مستخدمين لها",
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
          ),
          const SizedBox(width: 12),
          AnimatedOpacity(
            opacity: canAssign ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: canAssign && !_isAssigning ? _assignAll : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAssign ? appColor : Colors.grey.shade300,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey,
                elevation: canAssign ? 4 : 0,
                shadowColor: appColor.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isAssigning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _isAssigning ? "جاري الإرسال..." : "تعيين الكل",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
