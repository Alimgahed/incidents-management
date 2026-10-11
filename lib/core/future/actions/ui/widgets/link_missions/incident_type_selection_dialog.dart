import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';

class IncidentTypeSelectionDialog extends StatefulWidget {
  final List<IncidentType> types;
  final int? selectedTypeId;
  final ValueChanged<int?> onTypeSelected;

  const IncidentTypeSelectionDialog({
    super.key,
    required this.types,
    required this.selectedTypeId,
    required this.onTypeSelected,
  });

  @override
  State<IncidentTypeSelectionDialog> createState() =>
      _IncidentTypeSelectionDialogState();
}

class _IncidentTypeSelectionDialogState
    extends State<IncidentTypeSelectionDialog> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIncidentTypeIcon(String name, String? className) {
    final text = '$name ${className ?? ''}'.toLowerCase();
    if (text.contains('سيرفر') ||
        text.contains('معلومات') ||
        text.contains('تكنولوجيا') ||
        text.contains('it')) {
      return Icons.dns_rounded;
    }
    if (text.contains('أمن') ||
        text.contains('حريق') ||
        text.contains('احتراق') ||
        text.contains('سرقة')) {
      return Icons.shield_outlined;
    }
    if (text.contains('محطة')) {
      return Icons.waves_rounded;
    }
    if (text.contains('صرف') || text.contains('صحي')) {
      return Icons.alt_route_rounded;
    }
    if (text.contains('ماسورة') || text.contains('كسر')) {
      return Icons.water_drop_rounded;
    }
    if (text.contains('هبوط') || text.contains('مياه')) {
      return Icons.water_rounded;
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTypes = widget.types.where((type) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      final name = type.incidentTypeName.toLowerCase();
      final cls = (type.className ?? '').toLowerCase();
      return name.contains(q) || cls.contains(q);
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          width: 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.78,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  // Icon box
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      color: Color(0xFF1976D2),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'اختر نوع الأزمة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2B48),
                    ),
                  ),
                  const Spacer(),
                  // Close button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Search field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن نوع الأزمة...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Items List
              Expanded(
                child: filteredTypes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Color(0xFFCBD5E1),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'لا توجد نتائج مطابقة للبحث',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredTypes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final type = filteredTypes[index];
                          final isSelected =
                              type.incidentTypeId == widget.selectedTypeId;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                widget.onTypeSelected(type.incidentTypeId);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFEFF6FF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF3B82F6)
                                        : const Color(0xFFE2E8F0),
                                    width: isSelected ? 1.6 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Right: icon box
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F1FC),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getIncidentTypeIcon(
                                          type.incidentTypeName,
                                          type.className,
                                        ),
                                        color: const Color(0xFF1976D2),
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Center: Name & Class
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            type.incidentTypeName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F2B48),
                                            ),
                                          ),
                                          if (type.className != null &&
                                              type.className!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              type.className!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Left: chevron arrow
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: isSelected
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFF94A3B8),
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Footer count
              Padding(
                padding: const EdgeInsets.only(top: 14, left: 4, right: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filteredTypes.length} نتيجة',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
