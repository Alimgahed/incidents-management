import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/classes/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/add_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/classes_cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_missions_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/all_incident_classes.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/widget/fields.dart';

class AddMissionsMobile extends StatefulWidget {
  const AddMissionsMobile({super.key});

  @override
  State<AddMissionsMobile> createState() => _AddMissionsMobileState();
}

class _AddMissionsMobileState extends State<AddMissionsMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: GlobalAppBar(
        onBackPress: () => context.pop(),
        title: 'إضافة مهمة - موبايل',
        leadingIcon: Icons.add_task_rounded,
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Globalheader(icon: Icons.edit_note_rounded, title: 'بيانات المهمة'),
        const SizedBox(height: 24),
        BlocBuilder<AllIncidentClasses, GetAllIncidentClassesState>(
          builder: (context, typeState) {
            return typeState.when(
              initial: () => const SizedBox.shrink(),
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel("تصنيف المهمة"),
                  const LinearProgressIndicator(color: appColor, minHeight: 2),
                  const SizedBox(height: 20),
                ],
              ),
              error: (e) => Error(),
              loaded: (types) => CustomDropdownFormField<int>(
                hintText: 'اختر تصنيف المهمة',
                iconData: Icons.category_outlined,
                items: types.map((IncidentClass type) {
                  return DropdownMenuItem<int>(
                    value: type.incidentClassId,
                    child: Text(type.incidentClassName),
                  );
                }).toList(),
                onChanged: (value) {
                  context.read<AddMissionCubit>().updateSelectedClass(value);
                },
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        buildLabel("اسم المهمة"),
        CustomTextFormField(
          hintText: 'أدخل اسم المهمة بالتفصيل',
          iconData: Icons.task_alt,
          onChanged: (value) {
            context.read<AddMissionCubit>().updateMissionName(value);
          },
        ),

        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: goldColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () {
              context.read<AddMissionCubit>().saveMission();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("حفظ البيانات", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
