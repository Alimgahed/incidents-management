import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/user_management_filter_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/user_management_filter_state.dart';

class UserFiltersPanel extends StatefulWidget {
  final List<ActiveUser> rawUsers;

  const UserFiltersPanel({super.key, required this.rawUsers});

  @override
  State<UserFiltersPanel> createState() => _UserFiltersPanelState();
}

class _UserFiltersPanelState extends State<UserFiltersPanel> {
  final TextEditingController _empCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<String> _getDistinct(String? Function(ActiveUser) selector) {
    return widget.rawUsers
        .map(selector)
        .where((s) => s != null && s.isNotEmpty)
        .map((s) => s!)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> _getDistinctClasses() {
    final classes = <String>{};
    for (final user in widget.rawUsers) {
      if (user.userClasses != null) {
        for (final userClass in user.userClasses!) {
          if (userClass.classInfo?.className != null) {
            classes.add(userClass.classInfo!.className!);
          }
        }
      }
    }
    return classes.toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<UserManagementFilterCubit>().state;
    _empCodeController.text = state.empCode;
    _nameController.text = state.name;
  }

  @override
  void dispose() {
    _empCodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserManagementFilterCubit, UserManagementFilterState>(
      listener: (context, state) {
        if (state.empCode != _empCodeController.text) {
          _empCodeController.text = state.empCode;
        }
        if (state.name != _nameController.text) {
          _nameController.text = state.name;
        }
      },
      builder: (context, state) {
        final activeFiltersCount = (state.empCode.isNotEmpty ? 1 : 0) +
            (state.name.isNotEmpty ? 1 : 0) +
            (state.status != null ? 1 : 0) +
            (state.authorityName != null ? 1 : 0) +
            (state.groupName != null ? 1 : 0) +
            (state.sectorName != null ? 1 : 0) +
            (state.className != null ? 1 : 0);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, color: Color(0xFF1B4F8A), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'فلترة المستخدمين',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4F8A),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade600),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Row 1: Text Inputs
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'الاسم (اسم الموظف)',
                            icon: Icons.person_outline,
                            controller: _nameController,
                            onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(name: val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'كود الموظف',
                            icon: Icons.numbers,
                            controller: _empCodeController,
                            onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(empCode: val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Row 2: Dropdowns
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final isMobile = width < 600;
                        if (isMobile) {
                          return Column(
                            children: [
                              _buildDropdown(
                                label: 'حالة المستخدم',
                                icon: Icons.badge_outlined,
                                value: state.status,
                                items: ['نشط', 'غير نشط'],
                                onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(status: val, clearStatus: val == null),
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                label: 'الصلاحية مستوى الصلاحية',
                                icon: Icons.shield_outlined,
                                value: state.authorityName,
                                items: _getDistinct((u) => u.authorityName),
                                onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(authorityName: val, clearAuthorityName: val == null),
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                label: 'المجموعة',
                                icon: Icons.groups_outlined,
                                value: state.groupName,
                                items: _getDistinct((u) => u.groupName),
                                onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(groupName: val, clearGroupName: val == null),
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                label: 'الإدارة / القطاع',
                                icon: Icons.domain,
                                value: state.sectorName,
                                items: _getDistinct((u) => u.sectorManagementName),
                                onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(sectorName: val, clearSectorName: val == null),
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                label: 'الفئة / التصنيف',
                                icon: Icons.category_outlined,
                                value: state.className,
                                items: _getDistinctClasses(),
                                onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(className: val, clearClassName: val == null),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                label: 'حالة المستخدم',
                                icon: Icons.badge_outlined,
                                value: state.status,
                                items: ['نشط', 'غير نشط'],
                                onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(status: val, clearStatus: val == null),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                label: 'الصلاحية مستوى الصلاحية',
                                icon: Icons.shield_outlined,
                                value: state.authorityName,
                                items: _getDistinct((u) => u.authorityName),
                                onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(authorityName: val, clearAuthorityName: val == null),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                label: 'المجموعة',
                                icon: Icons.groups_outlined,
                                value: state.groupName,
                                items: _getDistinct((u) => u.groupName),
                                onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(groupName: val, clearGroupName: val == null),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                label: 'الإدارة / القطاع',
                                icon: Icons.domain,
                                value: state.sectorName,
                                items: _getDistinct((u) => u.sectorManagementName),
                                onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(sectorName: val, clearSectorName: val == null),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                label: 'الفئة / التصنيف',
                                icon: Icons.category_outlined,
                                value: state.className,
                                items: _getDistinctClasses(),
                                onChanged: (val) => context.read<UserManagementFilterCubit>().updateFilters(className: val, clearClassName: val == null),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Actions
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'فلاتر نشطة: $activeFiltersCount',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.read<UserManagementFilterCubit>().resetFilters();
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('إعادة تعيين'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () {
                            // Already applying automatically, but this can close keyboard or do something else if needed
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('تطبيق الفلاتر'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4F8A),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1B4F8A)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'ابحث ب${label.replaceAll("(", "").replaceAll(")", "")}...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1B4F8A)),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1B4F8A)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('الكل', style: TextStyle(fontSize: 13, color: Colors.black87)),
              ),
              icon: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.keyboard_arrow_down, size: 18),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('الكل', style: TextStyle(fontSize: 13, color: Colors.black87)),
                  ),
                ),
                ...items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(item, style: const TextStyle(fontSize: 13)),
                    ),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
