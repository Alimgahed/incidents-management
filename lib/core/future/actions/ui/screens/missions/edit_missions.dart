import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/design_system/app_design_system.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/classes/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/classes_cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/edit_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_missions_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/all_incident_classes.dart';
import 'package:flutter/services.dart';
import 'package:incidents_managment/core/future/mobile/ui/theme/mobile_system_bars.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class EditMissions extends StatefulWidget {
  final AllMissionModel? mission;

  const EditMissions({super.key, this.mission});

  @override
  State<EditMissions> createState() => _EditMissionsState();
}

class _EditMissionsState extends State<EditMissions> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final editCubit = context.read<EditMissionsCubit>();
    if (widget.mission != null && editCubit.id == 0) {
      editCubit.id = widget.mission!.missionId!;
      editCubit.selectedClassId = widget.mission!.classId;
      editCubit.missionName.text = widget.mission!.missionName;
    }
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<EditMissionsCubit>().saveMission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final editCubit = context.read<EditMissionsCubit>();
    final isMobile = AppBreakpoints.isMobile(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: MobileSystemBars.standard,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: BlocConsumer<EditMissionsCubit, AddMissionsState>(
            listener: (context, state) {
              state.whenOrNull(
                success: () {
                  getIt<AllMissionsCubit>().getAllMissions();
                  SuccessDialog.show(
                    context,
                    title: 'تم التعديل',
                    message: "تم حفظ تعديلات المهمة بنجاح",
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(true);
                      }
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
            builder: (context, state) {
              final isLoading = state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              );

              return Column(
                children: [
                  if (isMobile)
                    _buildHeaderBanner(context)
                  else
                    AppWorkspaceHeader(
                      title: 'تعديل بيانات المهمة',
                      subtitle: 'تحديث بيانات المهمة وتوصيفها القياسي في المنظومة',
                      icon: Icons.edit_note_rounded,
                      onBack: () => Navigator.of(context).maybePop(),
                      backTooltip: 'العودة لسجل المهام',
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 16 : 32,
                        isMobile ? 16 : 32,
                        isMobile ? 16 : 32,
                        40,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Container(
                            padding: EdgeInsets.all(isMobile ? 20 : 28),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderLg,
                              border: Border.all(color: AppColors.border),
                              boxShadow: AppShadows.subtle,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.edit_note_rounded,
                                          color: AppColors.accent,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'بيانات المهمة القياسية',
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
                                  buildLabel("تصنيف المهمة *"),
                                  const SizedBox(height: 6),
                                  BlocBuilder<AllIncidentClasses, GetAllIncidentClassesState>(
                                    builder: (context, typeState) {
                                      return typeState.when(
                                        initial: () => const SizedBox.shrink(),
                                        loading: () => const LinearProgressIndicator(
                                          color: AppColors.accent,
                                          minHeight: 3,
                                        ),
                                        error: (e) => AppErrorState(
                                          compact: true,
                                          message: 'تعذر تحميل التصنيفات',
                                          onRetry: () => context
                                              .read<AllIncidentClasses>()
                                              .getAllIncidentClasses(),
                                        ),
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
                                  buildLabel("اسم وتوصيف المهمة *"),
                                  const SizedBox(height: 6),
                                  CustomTextFormField(
                                    controller: editCubit.missionName,
                                    hintText: 'أدخل اسم وتفاصيل المهمة...',
                                    iconData: Icons.task_alt,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _handleSave(),
                                  ),

                                  const SizedBox(height: 32),

                                  // 3. Save & Cancel Actions
                                  Row(
                                    children: [
                                      if (!isMobile) ...[
                                        OutlinedButton(
                                          onPressed: isLoading
                                              ? null
                                              : () => Navigator.of(context).maybePop(),
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(120, 52),
                                            side: const BorderSide(color: AppColors.border),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: const Text(
                                            'إلغاء',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Expanded(
                                        child: CustomButton(
                                          text: "حفظ التعديلات",
                                          height: 52,
                                          borderRadius: 14,
                                          backgroundColor: AppColors.accent,
                                          borderColor: AppColors.accent,
                                          isLoading: isLoading,
                                          onPressed: _handleSave,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
