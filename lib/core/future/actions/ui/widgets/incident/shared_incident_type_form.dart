import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/classes/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/classes_cubit/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/logic/states/all_incident_classes.dart';
import 'package:incidents_managment/core/widget/fields.dart';

class SharedIncidentTypeForm extends StatelessWidget {
  final bool isWeb;

  const SharedIncidentTypeForm({super.key, this.isWeb = false});

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeField = BlocBuilder<AllIncidentClasses, GetAllIncidentClassesState>(
      builder: (context, typeState) {
        return typeState.when(
          initial: () => const SizedBox.shrink(),
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("تصنيف الأزمة *"),
              const LinearProgressIndicator(minHeight: 2, color: appColor),
              if (!isWeb) const SizedBox(height: 20),
            ],
          ),
          error: (e) => const Text('Error'),
          loaded: (types) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWeb) _buildLabel("تصنيف الأزمة *"), // Mobile already has label inside _buildForm in original, but actually it had it!
              // Wait, looking at mobile code, it had `buildLabel("تصنيف الأزمة")` before the LinearProgressIndicator, 
              // but for the loaded state it didn't have it because CustomDropdownFormField might not have it. Let's just add it.
              if (!isWeb) _buildLabel("تصنيف الأزمة"),
              CustomDropdownFormField<int>(
                hintText: 'اختر تصنيف الأزمة',
                iconData: Icons.category_outlined,
                items: types.map((IncidentClass type) {
                  return DropdownMenuItem<int>(
                    value: type.incidentClassId,
                    child: Text(type.incidentClassName),
                  );
                }).toList(),
                onChanged: (value) {
                  context.read<AddIncidentTypeCubit>().updateSelectedClass(value);
                },
              ),
            ],
          ),
        );
      },
    );

    final nameField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(isWeb ? "اسم الأزمة *" : "اسم الأزمة"),
        CustomTextFormField(
          hintText: 'أدخل اسم الأزمة بالتفصيل',
          iconData: isWeb ? Icons.text_fields_rounded : Icons.warning_amber_outlined,
          onChanged: (value) {
            context.read<AddIncidentTypeCubit>().updateIncidentName(value);
          },
        ),
      ],
    );

    if (isWeb) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: typeField),
          const SizedBox(width: 32),
          Expanded(child: nameField),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          typeField,
          const SizedBox(height: 20),
          nameField,
        ],
      );
    }
  }
}
