import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/add_incident_widget.dart';

class SharedIncidentForm extends StatefulWidget {
  final TextEditingController descriptionController;
  final TextEditingController notesController;
  final TextEditingController addressController;
  final bool isWeb;

  const SharedIncidentForm({
    super.key,
    required this.descriptionController,
    required this.notesController,
    required this.addressController,
    this.isWeb = false,
  });

  @override
  State<SharedIncidentForm> createState() => _SharedIncidentFormState();
}

class _SharedIncidentFormState extends State<SharedIncidentForm> {
  int? selectedTypeId;
  int? selectedSeverity;
  int? selectedBranchId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IncidentTypeDropdown(
          selectedValue: selectedTypeId,
          onChanged: (v) {
            setState(() {
              selectedTypeId = v;
            });
          },
        ),
        const SizedBox(height: 16),
        CustomDropdownFormField(
          value: selectedSeverity,
          hintText: 'درجة الخطورة',
          items: const [
            DropdownMenuItem(value: 1, child: Text('منخفض')),
            DropdownMenuItem(value: 2, child: Text('متوسطة')),
            DropdownMenuItem(value: 3, child: Text('مرتفعة')),
            DropdownMenuItem(value: 4, child: Text('حرجة')),
          ],
          onChanged: (v) {
            setState(() {
              selectedSeverity = v;
            });
          },
        ),
        const SizedBox(height: 16),
        CustomDropdownFormField(
          value: selectedBranchId,
          hintText: 'الفرع',
          items: const [
            DropdownMenuItem(value: 1, child: Text('ديوان عام الشركة')),
            DropdownMenuItem(value: 213, child: Text('المنيا')),
            DropdownMenuItem(value: 373, child: Text('المنيا الجديدة')),
            DropdownMenuItem(value: 173, child: Text('سمالوط')),
            DropdownMenuItem(value: 133, child: Text('مطاي')),
            DropdownMenuItem(value: 93, child: Text('بني مزار')),
            DropdownMenuItem(value: 53, child: Text('مغاغة')),
            DropdownMenuItem(value: 13, child: Text('العدوة')),
            DropdownMenuItem(value: 253, child: Text('أبو قرقاص')),
            DropdownMenuItem(value: 293, child: Text('ملوي')),
            DropdownMenuItem(value: 333, child: Text('ديرمواس')),
          ],
          onChanged: (v) {
            setState(() {
              selectedBranchId = v;
            });
          },
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: widget.descriptionController,
          hintText: "اشرح الحالة بالتفصيل...",
          maxLines: widget.isWeb ? 6 : 4,
        ),
        const SizedBox(height: 16),
        BlocListener<MapCubit, MapState>(
          listenWhen: (previous, current) => previous.address != current.address,
          listener: (context, state) {
            if (state.address != null) {
              widget.addressController.text = state.address!;
            }
          },
          child: CustomTextFormField(
            controller: widget.addressController,
            hintText: "العنوان بالتفصيل",
            useValidator: false,
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: widget.notesController,
          hintText: "ملاحظات إضافية (اختياري)",
          useValidator: false,
          maxLines: widget.isWeb ? 4 : 3,
        ),
        const SizedBox(height: 30),
        BlocBuilder<AddIncidentCubit, AddIncidentStates>(
          builder: (context, state) {
            return CustomButton(
              text: state.maybeWhen(
                loading: () => 'جاري الإرسال...',
                orElse: () => 'إرسال البلاغ',
              ),
              onPressed: () => _submit(context),
            );
          },
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    if (selectedTypeId == null || selectedSeverity == null || selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول المطلوبة')),
      );
      return;
    }

    if (widget.descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء كتابة وصف الأزمة')),
      );
      return;
    }

    final location = context.read<MapCubit>().state.selectedLocation;
    
    context.read<AddIncidentCubit>().submitIncident(
      model: CurrentIncidentModel(
        currentIncidentTypeId: selectedTypeId!,
        currentIncidentSeverity: selectedSeverity!,
        branchId: selectedBranchId!,
        currentIncidentXAxis: location.latitude,
        currentIncidentYAxis: location.longitude,
        currentIncidentDescription: widget.descriptionController.text.trim(),
        currentIncidentNotes: widget.notesController.text.trim().isEmpty ? null : widget.notesController.text.trim(),
        address: widget.addressController.text.trim().isEmpty ? null : widget.addressController.text.trim(),
      ),
    );
  }
}
