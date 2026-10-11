import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/link_missions/incident_type_selection_dialog.dart';

class LinkMissionsHeader extends StatelessWidget {
  final int? selectedTypeId;
  final ValueChanged<int?> onTypeSelected;

  const LinkMissionsHeader({
    super.key,
    required this.selectedTypeId,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon on the right (RTL left visually, but Row direction is RTL)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.layers, color: Color(0xFF1B4F8A), size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ربط المهام بالأزمة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'حدد المهام المطلوبة لهذا النوع من الأزمات',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Dropdown for type selection
          BlocBuilder<AllIncidentTypeCubit, GetAllIncidentTypeState>(
            builder: (context, state) {
              return state.maybeWhen(
                loaded: (types) {
                  IncidentType? selectedType;
                  if (selectedTypeId != null) {
                    try {
                      selectedType = types.firstWhere((t) => t.incidentTypeId == selectedTypeId);
                    } catch (_) {}
                  }

                  return InkWell(
                    onTap: () {
                      _showTypeSelectionDialog(context, types);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selectedType != null) ...[
                                  Text(
                                    'النوع المحدد',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedType.incidentTypeName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (selectedType.className != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'الفئة: ${selectedType.className}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueGrey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ] else ...[
                                  const Text(
                                    'اختر نوع الأزمة...',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'يرجى تحديد نوع الأزمة أولاً',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.water_drop_outlined, color: Colors.blue, size: 28),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () => const CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTypeSelectionDialog(BuildContext context, List<IncidentType> types) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return IncidentTypeSelectionDialog(
          types: types,
          selectedTypeId: selectedTypeId,
          onTypeSelected: onTypeSelected,
        );
      },
    );
  }
}
