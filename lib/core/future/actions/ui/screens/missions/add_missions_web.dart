import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/design_system/app_design_system.dart';
import 'package:incidents_managment/core/future/actions/data/models/classes/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/add_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/classes_cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_missions_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/all_incident_classes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/widget/shimmer/screen_shimmers.dart';

class AddMissionsWeb extends StatefulWidget {
  const AddMissionsWeb({super.key});

  @override
  State<AddMissionsWeb> createState() => _AddMissionsWebState();
}

class _AddMissionsWebState extends State<AddMissionsWeb> {
  final _formKey = GlobalKey<FormState>();

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AddMissionCubit>().saveMission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AddMissionCubit, AddMissionsState>(
        listener: (context, state) {
          state.whenOrNull(
            success: () {
              getIt<AllMissionsCubit>().getAllMissions();
              SuccessDialog.show(
                context,
                title: 'تم بنجاح',
                message: "تمت إضافة المهمة بنجاح",
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
              _buildStickyHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBasicInfoCard(context, isLoading),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button + Breadcrumbs & Title
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'العودة لسجل المهام',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceSubtle,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderSm,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Text(
                          "الرئيسية",
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.chevron_left,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Text(
                          "المهام",
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.chevron_left,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        "إضافة مهمة جديدة",
                        style: TextStyle(
                          color: appColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "إضافة مهمة قياسية",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('العودة للمهام'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "تفاصيل المهمة",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "حدد تصنيف المهمة واسمها الوصفي لتسهيل تعيينها لاحقاً.",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: BlocBuilder<
                    AllIncidentClasses,
                    GetAllIncidentClassesState
                  >(
                    builder: (context, typeState) {
                      return typeState.when(
                        initial: () =>
                            const ShimmerInput(height: 52, showLabel: true),
                        loading: () =>
                            const ShimmerInput(height: 52, showLabel: true),
                        error: (e) => AppErrorState(
                          compact: true,
                          message: 'تعذر تحميل تصنيفات المهام',
                          onRetry: () => context
                              .read<AllIncidentClasses>()
                              .getAllIncidentClasses(),
                        ),
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
                              onChanged: (value) => context
                                  .read<AddMissionCubit>()
                                  .updateSelectedClass(value),
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
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSave(),
                        onChanged: (value) => context
                            .read<AddMissionCubit>()
                            .updateMissionName(value),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text(
                    "إلغاء",
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                AppActionButton(
                  label: "إنشاء المهمة",
                  icon: Icons.check_rounded,
                  isLoading: isLoading,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
