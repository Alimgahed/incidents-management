import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/add_incident_widget.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/widget/fields.dart';

class AddIncidentScreen extends StatefulWidget {
  const AddIncidentScreen({super.key});

  @override
  State<AddIncidentScreen> createState() => _AddIncidentScreenState();
}

class _AddIncidentScreenState extends State<AddIncidentScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  int? selectedTypeId;
  int? selectedSeverity;
  int? selectedBranchId;

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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          IncidentTypeDropdown(onChanged: (value) {
            selectedTypeId = value;
          }, selectedValue: selectedTypeId,),
          const SizedBox(height: 20),
          CustomDropdownFormField(
            items: [
              const DropdownMenuItem(value: 1, child: Text('منخفض')),
              const DropdownMenuItem(value: 2, child: Text('متوسطة')),
              const DropdownMenuItem(value: 3, child: Text('مرتفعة')),
              const DropdownMenuItem(value: 4, child: Text('حرجة')),
            ],
            hintText: 'درجة الخطورة',
            onChanged: (value) => selectedSeverity = value,
          ),
          SizedBox(height: 20),
          CustomDropdownFormField(
            items: [
              const DropdownMenuItem(value: 1, child: Text('المنيا')),
              const DropdownMenuItem(value: 2, child: Text('المنيا الجديدة')),
              const DropdownMenuItem(value: 3, child: Text('سمالوط')),
              const DropdownMenuItem(value: 4, child: Text('مطاي')),
              const DropdownMenuItem(value: 5, child: Text('بني مزار')),
              const DropdownMenuItem(value: 6, child: Text('مغاغة')),
              const DropdownMenuItem(value: 7, child: Text('العدوة')),
              const DropdownMenuItem(value: 8, child: Text('أبو قرقاص')),
              const DropdownMenuItem(value: 9, child: Text('ملاوي')),
              const DropdownMenuItem(value: 10, child: Text('ديرمواس')),
            ],
            hintText: 'الفرع',
            onChanged: (value) {
              selectedBranchId = value;
            },
          ),
          SizedBox(height: 20),

          CustomTextFormField(
            controller: descriptionController,
            hintText: "اشرح الحالة بالتفصيل...",
            maxLines: 6,
          ),
          SizedBox(height: 20),

          CustomTextFormField(
            controller: notesController,
            hintText: "ملاحظات إضافية (اختياري)",
            useValidator: false,
            maxLines: 3,
          ),
          const Spacer(),
          BlocBuilder<AddIncidentCubit, AddIncidentStates>(
            builder: (context, state) {
              return CustomButton(
                text: state.maybeWhen(
                  loading: () => 'جاري الإرسال...',
                  orElse: () => 'إرسال البلاغ',
                ),
                onPressed: () {
                  context.read<AddIncidentCubit>().submitIncident(model:  CurrentIncidentModel(
                    currentIncidentTypeId: selectedTypeId!,
                    currentIncidentSeverity: selectedSeverity!,
                    branchId: selectedBranchId!,
                    currentIncidentXAxis: context.read<MapCubit>().state.selectedLocation.latitude,
                    currentIncidentYAxis: context.read<MapCubit>().state.selectedLocation.longitude,
                    currentIncidentDescription: descriptionController.text,
                    currentIncidentNotes: notesController.text.isEmpty ? null : notesController.text,
                  ),);
                },
              );
            },
          ),
        ],
      ),
    );
  }

}