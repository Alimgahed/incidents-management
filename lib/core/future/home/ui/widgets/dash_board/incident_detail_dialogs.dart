import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/update_statues.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:latlong2/latlong.dart';

void showStatusSelector(
  BuildContext context,
  CurrentIncidentWithMissions mission,
  int incidentId,
  UpdateStatuesCubit cubit,
) {
  int selectedStatus = mission.currentIncidentMissionStatus ?? 1;

  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: StatefulBuilder(
          builder: (statefulContext, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit, color: appColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'تغيير حالة المهمة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: appColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildDialogLabel('حالة المهمة'),
                _buildDialogDropdown(
                  value: selectedStatus,
                  icon: Icons.sync_alt,
                  items: allStatuses
                      .map(
                        (statusId) => DropdownMenuItem(
                          value: statusId,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: getStatusColor(statusId),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(getStatusArabicLabel(statusId)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedStatus = v!),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          
                          // Optimistically update the UI so it doesn't wait for server response/socket broadcast
                          context.read<IncidentMapCubit>().optimisticUpdateMission(
                            incidentId: incidentId,
                            missionId: mission.currentIncidentMissionId!,
                            newStatus: selectedStatus,
                          );

                          cubit.updateStatues(
                            incidentid: incidentId,
                            missionid: mission.currentIncidentMissionId!,
                            statusid: selectedStatus,
                            orderid: mission.currentIncidentMissionOrder ?? 0,
                          );
                        },
                        child: const Text(
                          'حفظ التغييرات',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

void showEditDialog(
  BuildContext context,
  CurrentIncidentModel incident,
  EditIncidentCubit cubit,
) {
  int selectedStatus = incident.currentIncidentStatus!;
  int selectedSeverity = incident.currentIncidentSeverity!;

  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: StatefulBuilder(
          builder: (statefulContext, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit, color: appColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'تعديل بيانات الأزمة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: appColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildDialogLabel('حالة الأزمة'),
                _buildDialogDropdown(
                  value: selectedStatus,
                  icon: Icons.sync_alt,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('تم التبليغ')),
                    DropdownMenuItem(value: 2, child: Text('تم الارسال')),
                    DropdownMenuItem(value: 3, child: Text('قيد التنفيذ')),
                    DropdownMenuItem(value: 4, child: Text('قيد الانتظار')),
                    DropdownMenuItem(value: 5, child: Text('قيد المراجعة')),
                    DropdownMenuItem(value: 6, child: Text('تم حلها')),
                    DropdownMenuItem(value: 7, child: Text('تم الرفض')),
                  ],
                  onChanged: (v) => setState(() => selectedStatus = v!),
                ),
                const SizedBox(height: 20),
                _buildDialogLabel('درجة الخطورة'),
                _buildDialogDropdown(
                  value: selectedSeverity,
                  icon: Icons.priority_high,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('منخفضة')),
                    DropdownMenuItem(value: 2, child: Text('متوسطة')),
                    DropdownMenuItem(value: 3, child: Text('عالية')),
                    DropdownMenuItem(value: 4, child: Text('حرجة')),
                  ],
                  onChanged: (v) => setState(() => selectedSeverity = v!),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          
                          // Optimistically update the UI so it doesn't wait for server response/socket broadcast
                          context.read<IncidentMapCubit>().optimisticUpdateIncident(
                            incidentId: incident.currentIncidentId!,
                            newStatus: selectedStatus,
                            newSeverity: selectedSeverity,
                          );

                          cubit.submitIncident(
                            id: incident.currentIncidentId!,
                            status: selectedStatus,
                            severity: selectedSeverity,
                            typeId: incident.currentIncidentTypeId!,
                            branchId: incident.branchId!,
                            location: LatLng(
                              incident.currentIncidentXAxis ?? 0,
                              incident.currentIncidentYAxis ?? 0,
                            ),
                            description:
                                incident.currentIncidentDescription ?? '',
                            notes: incident.currentIncidentNotes,
                            address: incident.address,
                          );
                        },
                        child: const Text(
                          'حفظ التغييرات',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

Widget _buildDialogLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
    ),
  );
}

Widget _buildDialogDropdown({
  required int value,
  required IconData icon,
  required List<DropdownMenuItem<int>> items,
  required ValueChanged<int?> onChanged,
}) {
  return DropdownButtonFormField<int>(
    initialValue: value,
    icon: Icon(Icons.arrow_drop_down, color: accentColor),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: accentColor, size: 20),
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
    ),
    items: items,
    onChanged: onChanged,
  );
}
