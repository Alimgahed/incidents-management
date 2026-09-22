import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/add_incident_widget.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';
import 'package:latlong2/latlong.dart';

import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/widget/fields.dart';

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
    Future.microtask(() {
      context.read<MapCubit>().setCurrentLocation(
        const LatLng(30.0444, 31.2357),
      );
    });
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إضافة الأزمة بنجاح')),
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
