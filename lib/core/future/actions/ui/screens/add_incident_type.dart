import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/add_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_type_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/all_incident_classes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

import 'package:incidents_managment/core/widget/fields.dart';

class AddIncidentType extends StatelessWidget {
  const AddIncidentType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'إضافة نوع أزمة',
        leadingIcon: Icons.add_circle_outline,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: // Inside your build method or a BlocListener
        BlocListener<AddIncidentTypeCubit, AddIncidentTypeState>(
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
                  message: "تمت إضافة نوع الأزمة بنجاح",
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
                title: 'بيانات الأزمة ',
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
                        _buildLabel("تصنيف الأزمة"),
                        const LinearProgressIndicator(minHeight: 2),
                        const SizedBox(height: 20),
                      ],
                    ),
                    error: (e) => _buildErrorState(),
                    loaded: (types) => CustomDropdownFormField<int>(
                      hintText: 'اختر تصنيف الأزمة',
                      iconData: Icons.category_outlined,
                      items: types.map((IncidentClass type) {
                        return DropdownMenuItem<int>(
                          value: type.incidentClassId,
                          child: Text(type.incidentClassName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        context
                            .read<AddIncidentTypeCubit>()
                            .updateSelectedClass(value);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 2. Incident Name Field
              _buildLabel("اسم الأزمة"),
              CustomTextFormField(
                hintText: 'أدخل اسم الأزمة بالتفصيل',
                iconData: Icons.warning_amber_outlined,
                onChanged: (value) {
                  context.read<AddIncidentTypeCubit>().updateIncidentName(
                    value,
                  );
                },
              ),

              const SizedBox(height: 40),

              // 3. Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CustomButton(
                  text: "حفظ البيانات",
                  onPressed: () {
                    context.read<AddIncidentTypeCubit>().saveIncidentType();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to keep code clean
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          SizedBox(width: 8),
          Text('خطأ في تحميل البيانات', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
