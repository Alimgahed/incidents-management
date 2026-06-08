import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/missions/missions_card.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/helpers/routing.dart';

class AllMissionsWeb extends StatefulWidget {
  const AllMissionsWeb({super.key});

  @override
  State<AllMissionsWeb> createState() => _AllMissionsWebState();
}

class _AllMissionsWebState extends State<AllMissionsWeb> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<AllMissionsCubit>().clearSearch();
    setState(() {
      _isSearchActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Enterprise background
      body: Column(
        children: [
          _buildWebHeader(context),
          Expanded(
            child: BlocBuilder<AllMissionsCubit, GetAllMissionState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(
                    child: BuildEmptyState(
                      title: 'لا توجد مهام حالياً',
                      message: 'ابدأ بإضافة مهمة جديدة',
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(color: appColor)),
                  loaded: (missions) {
                    if (missions.isEmpty) {
                      return const Center(
                        child: BuildEmptyState(
                          title: 'لا توجد مهام مطابقة',
                          message: 'حاول تعديل معايير البحث أو أضف مهام جديدة',
                        ),
                      );
                    }
                    return _buildGridView(missions);
                  },
                  error: (message) => const Center(child: Text("حدث خطأ في تحميل المهام", style: TextStyle(color: Colors.red))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Breadcrumbs + Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("الرئيسية", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_left, size: 16, color: Colors.grey)),
                  Text("المهام", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_left, size: 16, color: Colors.grey)),
                  const Text("إدارة جميع المهام القياسية", style: TextStyle(color: appColor, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: () => context.pushNamed(Routes.addMissions),
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text("إضافة مهمة جديدة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title + Search Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "المهام القياسية",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 350,
                    height: 48,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _isSearchActive = value.isNotEmpty;
                        });
                        context.read<AllMissionsCubit>().searchMissions(value);
                      },
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        hintText: 'ابحث عن اسم أو تصنيف المهمة...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                        suffixIcon: _isSearchActive
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey.shade500, size: 18),
                                onPressed: _clearSearch,
                                splashRadius: 20,
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: appColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: Colors.grey.shade700, size: 20),
                      onPressed: () {
                        // Filter logic could go here
                      },
                      tooltip: 'خيارات التصفية',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<AllMissionModel> missions) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2; // Default for smaller screens
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(40),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.5,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final mission = missions[index];
            return _buildEnterpriseMissionCard(context, mission);
          },
        );
      },
    );
  }

  Widget _buildEnterpriseMissionCard(BuildContext context, AllMissionModel mission) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final result = await context.pushNamed(
            Routes.editMissions,
            arguments: mission,
          );
          if (result == true && context.mounted) {
            context.read<AllMissionsCubit>().getAllMissions();
          }
        },
        borderRadius: BorderRadius.circular(12),
        hoverColor: appColor.withAlpha(10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: appColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.assignment_outlined, color: appColor, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission.missionName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'التصنيف: ${mission.className}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
}
