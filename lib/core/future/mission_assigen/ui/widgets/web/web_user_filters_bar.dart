import 'package:flutter/material.dart';

class WebUserFiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String? selectedAuthority;
  final ValueChanged<String?> onAuthorityChanged;
  final List<String> authorities;

  final String? selectedSector;
  final ValueChanged<String?> onSectorChanged;
  final List<String> sectors;

  final String? selectedGroup;
  final ValueChanged<String?> onGroupChanged;
  final List<String> groups;

  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;

  final VoidCallback onResetFilters;

  const WebUserFiltersBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedAuthority,
    required this.onAuthorityChanged,
    required this.authorities,
    required this.selectedSector,
    required this.onSectorChanged,
    required this.sectors,
    required this.selectedGroup,
    required this.onGroupChanged,
    required this.groups,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: "البحث والفلاتر" + "إعادة تعيين الفلاتر"
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF2563EB),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'البحث والفلاتر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              // Reset filters button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onResetFilters,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'إعادة تعيين الفلاتر',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Field
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو رقم الموظف أو الوظيفة...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4-Column Dropdowns Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 650;
              if (isTight) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FilterDropdown(
                            label: 'الوظيفة',
                            icon: Icons.work_outline_rounded,
                            value: selectedAuthority,
                            items: authorities,
                            onChanged: onAuthorityChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterDropdown(
                            label: 'الإدارة',
                            icon: Icons.apartment_outlined,
                            value: selectedSector,
                            items: sectors,
                            onChanged: onSectorChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterDropdown(
                            label: 'الفرع / المجموعة',
                            icon: Icons.groups_outlined,
                            value: selectedGroup,
                            items: groups,
                            onChanged: onGroupChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterDropdown(
                            label: 'الحالة',
                            icon: Icons.person_outline_rounded,
                            value: selectedStatus,
                            items: const ['متاح', 'غير متاح'],
                            onChanged: onStatusChanged,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      label: 'الوظيفة',
                      icon: Icons.work_outline_rounded,
                      value: selectedAuthority,
                      items: authorities,
                      onChanged: onAuthorityChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterDropdown(
                      label: 'الإدارة',
                      icon: Icons.apartment_outlined,
                      value: selectedSector,
                      items: sectors,
                      onChanged: onSectorChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterDropdown(
                      label: 'الفرع / المجموعة',
                      icon: Icons.groups_outlined,
                      value: selectedGroup,
                      items: groups,
                      onChanged: onGroupChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterDropdown(
                      label: 'الحالة',
                      icon: Icons.person_outline_rounded,
                      value: selectedStatus,
                      items: const ['متاح', 'غير متاح'],
                      onChanged: onStatusChanged,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF64748B)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value != null ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: const Text(
                'الكل',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'الكل',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...items.map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
