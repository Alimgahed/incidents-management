import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/add_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/missions/missions_card.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class AllMissions extends StatelessWidget {
  const AllMissions({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AllMissionsCubit>()..getAllMissions(),
        ),
        BlocProvider(create: (_) => getIt<AddMissionCubit>()),
      ],
      child: Stack(
        children: [
          Column(
            children: [
              _SearchAndFilterBar(),
              Expanded(
                child: BlocBuilder<AllMissionsCubit, GetAllMissionState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => BuildEmptyState(
                        title: 'لا توجد مهام حالياً',
                        message: 'ابدأ بإضافة مهمة جديدة',
                      ),

                      loading: () => const Loadding(),
                      loaded: (missions) => _MissionsList(missions: missions),
                      error: (message) => Error(),
                    );
                  },
                ),
              ),
            ],
          ),
          CustomFloatingButton(
            routeName: Routes.addMissions,
            text: "إضافة مهمة جديدة",
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

class _MissionsList extends StatelessWidget {
  final List<AllMissionModel> missions;

  const _MissionsList({required this.missions});

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return BuildEmptyState(
        title: 'لا توجد مهام مطابقة',
        message: 'حاول تعديل معايير البحث أو التصفية',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return MissionCard(mission: mission, index: index);
      },
    );
  }
}
