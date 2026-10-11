import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_cubit.dart';

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
              final queued = context
                  .read<AddIncidentCubit>()
                  .lastSubmissionQueued;
              if (getIt.isRegistered<IncidentMapCubit>()) {
                getIt<IncidentMapCubit>().refresh();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    queued
                        ? 'تم حفظ البلاغ محلياً وسيُرسل عند عودة الاتصال.'
                        : 'تم إرسال البلاغ بنجاح',
                  ),
                ),
              );
              // Clear fields for subsequent submissions
              descriptionController.clear();
              notesController.clear();
              addressController.clear();

              // Switch to dashboard tab so the user sees the new incident immediately
              Future.delayed(const Duration(milliseconds: 300), () {
                if (context.mounted) {
                  try {
                    context.read<HomeCubit>().changeState(0);
                  } catch (_) {}
                }
              });
            },
            error: (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.error ?? 'حدث خطأ')));
            },
          );
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28),
              child: SharedIncidentForm(
                descriptionController: descriptionController,
                notesController: notesController,
                addressController: addressController,
                isWeb: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    notesController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
