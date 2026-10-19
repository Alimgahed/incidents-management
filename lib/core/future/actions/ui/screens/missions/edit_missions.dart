import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/classes/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/classes_cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/edit_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_missions_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/all_incident_classes.dart';
import 'package:flutter/services.dart';
import 'package:incidents_managment/core/future/mobile/ui/theme/mobile_system_bars.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class EditMissions extends StatelessWidget {
  final AllMissionModel? mission;

  const EditMissions({super.key, this.mission});

  @override
  Widget build(BuildContext context) {
    final editCubit = context.read<EditMissionsCubit>();
    if (mission != null && editCubit.id == 0) {
      editCubit.id = mission!.missionId!;
      editCubit.selectedClassId = mission!.classId;
      editCubit.missionName.text = mission!.missionName;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: MobileSystemBars.standard,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
        body: BlocListener<EditMissionsCubit, AddMissionsState>(
          listener: (context, state) {
            state.whenOrNull(
              success: () {
                SuccessDialog.show(
                  context,
                  title: 'تم التعديل',
                  message: "تم حفظ تعديلات المهمة بنجاح",
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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Banner
                _buildHeaderBanner(context),

                // Form Content Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E56A0).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.edit_note_rounded,
                                color: Color(0xFF1E56A0),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'تعديل بيانات المهمة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 1. Classification
                        buildLabel("تصنيف المهمة"),
                        const SizedBox(height: 6),
                        BlocBuilder<AllIncidentClasses, GetAllIncidentClassesState>(
                          builder: (context, typeState) {
                            return typeState.when(
                              initial: () => const SizedBox.shrink(),
                              loading: () => const LinearProgressIndicator(
                                color: Color(0xFF1E56A0),
                                minHeight: 3,
                              ),
                              error: (e) => const Text('تعذر تحميل التصنيفات'),
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
                                  context
                                      .read<EditMissionsCubit>()
                                      .updateSelectedClass(value);
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // 2. Mission Name
                        buildLabel("اسم وتوصيف المهمة"),
                        const SizedBox(height: 6),
                        CustomTextFormField(
                          controller: editCubit.missionName,
                          hintText: 'أدخل اسم وتفاصيل المهمة...',
                          iconData: Icons.task_alt,
                        ),

                        const SizedBox(height: 32),

                        // 3. Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B64F2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              context.read<EditMissionsCubit>().saveMission();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "حفظ التعديلات",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F3B6C),
        image: DecorationImage(
          image: AssetImage('assets/images/header_banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A2240).withValues(alpha: 0.94),
              const Color(0xFF0F3866).withValues(alpha: 0.88),
              const Color(0xFF164780).withValues(alpha: 0.97),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo (Right in RTL)
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.water_drop_rounded,
                          color: appColor,
                          size: 28,
                        ),
                      ),
                    ),

                    // Back Button (Left in RTL)
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'تعديل المهمة',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'تحديث بيانات المهمة وتوصيفها القياسي',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
