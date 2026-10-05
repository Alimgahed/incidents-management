import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/add_incident_widget.dart';

import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';

class AddIncidentMobileScreen extends StatefulWidget {
  const AddIncidentMobileScreen({super.key});

  @override
  State<AddIncidentMobileScreen> createState() =>
      _AddIncidentMobileScreenState();
}

class _AddIncidentMobileScreenState extends State<AddIncidentMobileScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    notesController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "إضافة أزمة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: appColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: BlocListener<AddIncidentCubit, AddIncidentStates>(
          listener: (context, state) {
            state.whenOrNull(
              success: () {
                final queued = context
                    .read<AddIncidentCubit>()
                    .lastSubmissionQueued;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      queued
                          ? 'تم حفظ البلاغ محلياً وسيُرسل عند عودة الاتصال.'
                          : 'تم إضافة الأزمة بنجاح',
                    ),
                  ),
                );
              },
              error: (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.error ?? 'حدث خطأ')));
              },
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 300, child: IncidentMapWidget()),
                    const SizedBox(height: 20),
                    SharedIncidentForm(
                      descriptionController: descriptionController,
                      notesController: notesController,
                      addressController: addressController,
                      isWeb: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
