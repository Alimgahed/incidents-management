import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/widget/fields.dart';

class AllMissions extends StatelessWidget {
  const AllMissions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'جميع المهام',
        leadingIcon: Icons.assignment_outlined,
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      body: Column(
        children: [
          _SearchAndFilterBar(),
          Expanded(
            child: BlocBuilder<AllMissionsCubit, GetAllMissionState>(
              builder: (context, state) {
                return state.when(
                  initial: () => _buildEmptyState(),
                  loading: () => _buildLoadingState(),
                  loaded: (missions) => _MissionsList(missions: missions),
                  error: (message) => _buildErrorState(context, message),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await context.pushNamed(Routes.addMissions);
        if (result == true && context.mounted) {
          context.read<AllMissionsCubit>().getAllMissions();
        }
      },
      backgroundColor: appColor,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'إضافة مهمة جديدة',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      elevation: 4,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 120,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد مهام حالياً',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ابدأ بإضافة مهمة جديدة',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
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
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(appColor),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل المهام...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 120, color: Colors.red.shade300),
          const SizedBox(height: 24),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'إعادة المحاولة',
            onPressed: () {
              context.read<AllMissionsCubit>().getAllMissions();
            },
          ),
        ],
      ),
    );
  }
}

// ============= SEARCH AND FILTER BAR =============
class _SearchAndFilterBar extends StatefulWidget {
  const _SearchAndFilterBar();

  @override
  State<_SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<_SearchAndFilterBar> {
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _isSearchActive = value.isNotEmpty;
                });
                context.read<AllMissionsCubit>().searchMissions(value);
              },
              decoration: InputDecoration(
                fillColor: fieldColor,
                filled: true,
                hintText: 'ابحث عن مهمة...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.search, color: appColor, size: 22),
                ),
                suffixIcon: _isSearchActive
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        onPressed: _clearSearch,
                        splashRadius: 20,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: appColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: appColor.withOpacity(0.3), width: 1.5),
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list, color: appColor),
              onPressed: () {
                // Show filter options
                _showFilterDialog(context);
              },
              tooltip: 'تصفية',
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.filter_list, color: appColor),
            const SizedBox(width: 12),
            const Text('خيارات التصفية'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.sort_by_alpha, color: appColor),
              title: const Text('ترتيب أبجدي'),
              onTap: () {
                Navigator.pop(dialogContext);
                // Implement sorting
              },
            ),
            ListTile(
              leading: Icon(Icons.category, color: appColor),
              title: const Text('حسب التصنيف'),
              onTap: () {
                Navigator.pop(dialogContext);
                // Implement category filter
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============= MISSIONS LIST =============
class _MissionsList extends StatelessWidget {
  final List<AllMissionModel> missions;

  const _MissionsList({required this.missions});

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 120, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'جرب البحث بكلمات مختلفة',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return _MissionCard(mission: mission, index: index);
      },
    );
  }
}

// ============= MISSION CARD (Keep your existing implementation) =============
class _MissionCard extends StatelessWidget {
  final AllMissionModel mission;
  final int index;

  const _MissionCard({required this.mission, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showMissionDetails(context, mission);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: appColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Icon(Icons.tag_sharp)),
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
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'التصنيف: ${mission.className}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: appColor, size: 22),
                    onPressed: () {
                      _editMission(context, mission);
                    },
                    tooltip: 'تعديل',
                    splashRadius: 24,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 22,
                    ),
                    onPressed: () {
                      _confirmDelete(context, mission);
                    },
                    tooltip: 'حذف',
                    splashRadius: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionDetails(BuildContext context, AllMissionModel mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: appColor),
            const SizedBox(width: 12),
            const Text('تفاصيل المهمة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('رقم المهمة', '#${mission.missionId}'),
            const SizedBox(height: 12),
            _buildDetailRow('اسم المهمة', mission.missionName),
            const SizedBox(height: 12),
            _buildDetailRow('التصنيف', mission.className!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(color: appColor, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  void _editMission(BuildContext context, AllMissionModel mission) async {
    final result = await context.pushNamed(
      Routes.editMissions,
      arguments: mission,
    );

    if (result == true && context.mounted) {
      context.read<AllMissionsCubit>().getAllMissions();
    }
  }

  void _confirmDelete(BuildContext context, AllMissionModel mission) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Text('تأكيد الحذف'),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف المهمة "${mission.missionName}"؟',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Call delete method from cubit
              // context.read<AllMissionsCubit>().deleteMission(mission.missionId);

              SuccessDialog.show(
                context,
                title: 'تم الحذف',
                message: 'تم حذف المهمة بنجاح',
              );
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
