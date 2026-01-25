import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/classes/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/classes_cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/edit_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_missions_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/all_incident_classes.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

import 'package:incidents_managment/core/widget/fields.dart';

class EditMissions extends StatelessWidget {
  final AllMissionModel? mission;

  const EditMissions({super.key, this.mission});

  @override
  Widget build(BuildContext context) {
    final editCubit = context.read<EditMissionsCubit>();
    if (mission != null) {
      editCubit.id = mission!.missionId!;
      editCubit.selectedClassId = mission!.classId;
      editCubit.missionName.text = mission!.missionName;
    }
    return Scaffold(
      appBar: GlobalAppBar(
        onBackPress: () => context.pop(),
        title: 'تعديل مهمة',
        leadingIcon: Icons.edit_note_rounded,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: // Inside your build method or a BlocListener
        BlocListener<EditMissionsCubit, AddMissionsState>(
          listener: (context, state) {
            state.whenOrNull(
              loading: () {
                // Show loading overlay or indicator
              },
              success: () {
                // Use the professional Success Dialog we created!
                SuccessDialog.show(
                  context,
                  title: 'تم',

                  message: "تم تعديل المهمة بنجاح",
                  onPressed: () {
                    context.pop();
                    Navigator.pop(context, true);
                  },
                );
              },
              error: (message) {
                ErrorDialog.show(
                  context,
                  title: "خطأ",
                  message: message.error ?? "حدث خطأ ما",
                );
              },
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              const Globalheader(
                icon: Icons.edit_note_rounded,
                title: 'بيانات المهمة ',
              ),
              const SizedBox(height: 24),

              // 1. Incident Classification Dropdown
              BlocBuilder<AllIncidentClasses, GetAllIncidentClassesState>(
                builder: (context, typeState) {
                  return typeState.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLabel("تصنيف المهمة"),
                        const LinearProgressIndicator(minHeight: 2),
                        const SizedBox(height: 20),
                      ],
                    ),
                    error: (e) => buildErrorState(),
                    loaded: (types) => CustomDropdownFormField<int>(
                      hintText: 'اختر تصنيف المهمة',
                      value: editCubit.selectedClassId,
                      iconData: Icons.category_outlined,
                      items: types.map((IncidentClass type) {
                        return DropdownMenuItem<int>(
                          value: type.incidentClassId,
                          child: Text(type.incidentClassName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        context.read<EditMissionsCubit>().updateSelectedClass(
                          value,
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 2. Incident Name Field
              buildLabel("اسم المهمة"),
              CustomTextFormField(
                controller: editCubit.missionName,
                hintText: 'أدخل اسم المهمة بالتفصيل',
                iconData: Icons.warning_amber_outlined,
              ),

              const SizedBox(height: 40),

              // 3. Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CustomButton(
                  text: "حفظ البيانات",
                  onPressed: () {
                    context.read<EditMissionsCubit>().saveMission();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
