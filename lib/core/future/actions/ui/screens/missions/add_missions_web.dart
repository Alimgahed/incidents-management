import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/classes/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/add_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/classes_cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_missions_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/all_incident_classes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/widget/fields.dart';

class AddMissionsWeb extends StatefulWidget {
  const AddMissionsWeb({super.key});

  @override
  State<AddMissionsWeb> createState() => _AddMissionsWebState();
}

class _AddMissionsWebState extends State<AddMissionsWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Professional subtle background
      body: BlocListener<AddMissionCubit, AddMissionsState>(
        listener: (context, state) {
          state.whenOrNull(
            success: () {
              SuccessDialog.show(context, title: 'تم', message: "تمت إضافة المهمة بنجاح");
            },
            error: (message) {
              ErrorDialog.show(context, title: "خطأ", message: message.error ?? "حدث خطأ ما");
            },
          );
        },
        child: Column(
          children: [
            _buildStickyHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfoCard(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Breadcrumbs & Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("الرئيسية", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_left, size: 16, color: Colors.grey)),
                  Text("المهام", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_left, size: 16, color: Colors.grey)),
                  const Text("إضافة مهمة جديدة", style: TextStyle(color: appColor, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              const Text("إضافة مهمة قياسية", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("تفاصيل المهمة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          const Text("حدد تصنيف المهمة واسمها الوصفي لتسهيل تعيينها لاحقاً.", style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BlocBuilder<AllIncidentClasses, GetAllIncidentClassesState>(
                  builder: (context, typeState) {
                    return typeState.when(
                      initial: () => const SizedBox.shrink(),
                      loading: () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel("تصنيف المهمة *"),
                          const LinearProgressIndicator(color: appColor),
                        ],
                      ),
                      error: (e) => const Text('Error'),
                      loaded: (types) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel("تصنيف المهمة *"),
                          CustomDropdownFormField<int>(
                            hintText: 'اختر التصنيف المطابق للمهمة',
                            iconData: Icons.folder_outlined,
                            items: types.map((IncidentClass type) {
                              return DropdownMenuItem<int>(
                                value: type.incidentClassId,
                                child: Text(type.incidentClassName),
                              );
                            }).toList(),
                            onChanged: (value) => context.read<AddMissionCubit>().updateSelectedClass(value),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildLabel("اسم المهمة *"),
                    CustomTextFormField(
                      hintText: 'مثال: إخلاء المبنى، تأمين الموقع...',
                      iconData: Icons.assignment_outlined,
                      onChanged: (value) => context.read<AddMissionCubit>().updateMissionName(value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("إلغاء", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  backgroundColor: goldColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => context.read<AddMissionCubit>().saveMission(),
                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                label: const Text("إنشاء المهمة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
