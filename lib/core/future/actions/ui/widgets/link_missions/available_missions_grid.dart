import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/link_missions_filter_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/link_missions_filter_state.dart';

class AvailableMissionsGrid extends StatefulWidget {
  final List<AllMissionModel> allMissions;
  final Function(int, String) onMissionAdd;
  final int Function(int) getMissionCount;

  const AvailableMissionsGrid({
    super.key,
    required this.allMissions,
    required this.onMissionAdd,
    required this.getMissionCount,
  });

  @override
  State<AvailableMissionsGrid> createState() => _AvailableMissionsGridState();
}

class _AvailableMissionsGridState extends State<AvailableMissionsGrid> {
  final TextEditingController _searchController = TextEditingController();

  List<String> _getDistinctClasses() {
    return widget.allMissions
        .map((e) => e.className)
        .where((s) => s != null && s.isNotEmpty)
        .map((s) => s!)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header and Filters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.library_add_check, color: Color(0xFF1B4F8A), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'المهمات المتاحة للربط',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F8A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'اختر من المهام المتاحة أدناه لإضافتها إلى هذا النوع من الأزمات',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              BlocBuilder<LinkMissionsFilterCubit, LinkMissionsFilterState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      // Search
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => context.read<LinkMissionsFilterCubit>().updateFilters(searchName: val),
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'بحث عن مهمة...',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              suffixIcon: const Icon(Icons.filter_list, size: 18),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Dropdown Category
                      Expanded(
                        flex: 1,
                        child: _buildDropdown(
                          label: 'الفئة',
                          value: state.className,
                          items: _getDistinctClasses(),
                          onChanged: (val) => context.read<LinkMissionsFilterCubit>().updateFilters(className: val, clearClassName: val == null),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Grid
        BlocBuilder<LinkMissionsFilterCubit, LinkMissionsFilterState>(
          builder: (context, state) {
            final filteredMissions = context.read<LinkMissionsFilterCubit>().filterMissions(widget.allMissions);
            
            if (filteredMissions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: Text('لا توجد مهام تطابق البحث', style: TextStyle(color: Colors.grey)),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 3.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredMissions.length,
                  itemBuilder: (context, index) {
                    final mission = filteredMissions[index];
                    final count = widget.getMissionCount(mission.missionId!);
                    return _buildAvailableMissionCard(mission, count);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text('الكل ($label)', style: const TextStyle(fontSize: 13)),
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('الكل ($label)', style: const TextStyle(fontSize: 13)),
            ),
            ...items.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 13)),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAvailableMissionCard(AllMissionModel mission, int selectionCount) {
    Color getIconColor(String? className) {
      if (className == null) return Colors.indigo;
      if (className.contains('مياه')) return Colors.blue;
      if (className.contains('صرف')) return Colors.purple;
      if (className.contains('طرق')) return Colors.green;
      if (className.contains('كهرباء') || className.contains('طاقة')) return Colors.red;
      if (className.contains('صحة') || className.contains('سلامة')) return Colors.teal;
      return Colors.orange;
    }

    final color = getIconColor(mission.className);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Left Add Button
          InkWell(
            onTap: () => widget.onMissionAdd(mission.missionId!, mission.missionName),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.shade50,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.blue, size: 20),
                  if (selectionCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$selectionCount',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mission.missionName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  mission.className != null ? 'الفئة: ${mission.className}' : 'بدون فئة',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.assignment, color: color, size: 24),
          ),
        ],
      ),
    );
  }
}
