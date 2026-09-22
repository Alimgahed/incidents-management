import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/add_incident_widget.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';
import 'package:incidents_managment/core/widget/fields.dart';

class AddIncidentScreen extends StatefulWidget {
  const AddIncidentScreen({super.key});

  @override
  State<AddIncidentScreen> createState() => _AddIncidentScreenState();
}

class _AddIncidentScreenState extends State<AddIncidentScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AddIncidentCubit>()),
        BlocProvider(create: (_) => getIt<MapCubit>()),
        BlocProvider(
          create: (_) => getIt<AllIncidentTypeCubit>()..getAllIncidentTypes(),
        ),
      ],
      child: BlocListener<AddIncidentCubit, AddIncidentStates>(
        listener: (context, state) {
          state.whenOrNull(
            success: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال البلاغ بنجاح')),
              );
            },
            error: (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.error ?? 'حدث خطأ')));
            },
          );
        },
        child: Row(
          children: [
            _buildForm(context),
            const Expanded(child: IncidentMapWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      width: 420,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SharedIncidentForm(
          descriptionController: descriptionController,
          notesController: notesController,
          addressController: addressController,
          isWeb: true,
        ),
      ),
    );
  }
}
