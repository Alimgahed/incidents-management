import 'package:flutter/material.dart';
import 'package:incidents_managment/core/design_system/app_design_system.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_type_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_type_states.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class AddIncidentTypeWeb extends StatefulWidget {
  const AddIncidentTypeWeb({super.key});

  @override
  State<AddIncidentTypeWeb> createState() => _AddIncidentTypeWebState();
}

class _AddIncidentTypeWebState extends State<AddIncidentTypeWeb> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AddIncidentTypeCubit, AddIncidentTypeState>(
        listener: (context, state) {
          state.whenOrNull(
            success: () {
              getIt<AllIncidentTypeCubit>().getAllIncidentTypes();
              SuccessDialog.show(
                context,
                title: 'تم بنجاح',
                message: "تمت إضافة نوع الأزمة بنجاح",
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
          // Breadcrumbs & Title
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'العودة لقائمة الأنواع',
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
                          "أنواع الأزمات",
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
                        "إضافة نوع جديد",
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
                    "إضافة نوع أزمة جديد",
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
            label: const Text('العودة للقائمة'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "المعلومات الأساسية",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "يرجى إدخال البيانات الرئيسية لتعريف الأزمة في النظام.",
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 32),
          const SharedIncidentTypeForm(isWeb: true),
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
                label: "حفظ نوع الأزمة",
                icon: Icons.check_rounded,
                isLoading: isLoading,
                onPressed: () =>
                    context.read<AddIncidentTypeCubit>().saveIncidentType(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
