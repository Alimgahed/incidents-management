import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_type_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_type_states.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class AddIncidentTypeMobile extends StatefulWidget {
  const AddIncidentTypeMobile({super.key});

  @override
  State<AddIncidentTypeMobile> createState() => _AddIncidentTypeMobileState();
}

class _AddIncidentTypeMobileState extends State<AddIncidentTypeMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: const GlobalAppBar(
        title: 'إضافة نوع أزمة - موبايل',
        leadingIcon: Icons.add_circle_outline,
      ),
      body: BlocListener<AddIncidentTypeCubit, AddIncidentTypeState>(
        listener: (context, state) {
          state.whenOrNull(
            success: () {
              SuccessDialog.show(context, title: 'تم', message: "تمت إضافة نوع الأزمة بنجاح");
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
        const Globalheader(icon: Icons.edit_note_rounded, title: 'بيانات الأزمة الأساسية'),
        const SizedBox(height: 24),
        const SharedIncidentTypeForm(isWeb: false),

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
              context.read<AddIncidentTypeCubit>().saveIncidentType();
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
