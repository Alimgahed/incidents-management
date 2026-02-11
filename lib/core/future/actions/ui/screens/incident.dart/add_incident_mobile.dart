import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/add_incident_widget.dart';
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

class _AddIncidentMobileScreenState
    extends State<AddIncidentMobileScreen> {
  final TextEditingController descriptionController =
      TextEditingController();
  final TextEditingController notesController =
      TextEditingController();

  int? selectedTypeId;
  int? selectedSeverity;
  int? selectedBranchId;

  @override
  void initState() {
    super.initState();

    /// Load types

    /// Set default location on open
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إرسال بلاغ"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<AddIncidentCubit, AddIncidentStates>(
          listener: (context, state) {
            state.whenOrNull(
              success: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('تم إرسال البلاغ بنجاح')),
                );
              },
              error: (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(e.error ?? 'حدث خطأ')),
                );
              },
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [

                /// ================= MAP =================
                const SizedBox(
                  height: 260,
                  child: IncidentMapWidget(),
                ),

                const SizedBox(height: 20),

                /// ================= TYPE =================
                IncidentTypeDropdown(
                  selectedValue: selectedTypeId,
                  onChanged: (v) {
                
                      selectedTypeId = v;
              
                  },
                ),

                const SizedBox(height: 16),

                /// ================= SEVERITY =================
                CustomDropdownFormField(
                  value: selectedSeverity,
                  hintText: 'درجة الخطورة',
                  items: const [
                    DropdownMenuItem(
                        value: 1, child: Text('منخفض')),
                    DropdownMenuItem(
                        value: 2, child: Text('متوسطة')),
                    DropdownMenuItem(
                        value: 3, child: Text('مرتفعة')),
                    DropdownMenuItem(
                        value: 4, child: Text('حرجة')),
                  ],
                  onChanged: (v) =>
                      setState(() => selectedSeverity = v),
                ),

                const SizedBox(height: 16),

                /// ================= BRANCH =================
                CustomDropdownFormField(
                  value: selectedBranchId,
                  hintText: 'الفرع',
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('المنيا')),
               DropdownMenuItem(value: 2, child: Text('المنيا الجديدة')),
               DropdownMenuItem(value: 3, child: Text('سمالوط')),
               DropdownMenuItem(value: 4, child: Text('مطاي')),
               DropdownMenuItem(value: 5, child: Text('بني مزار')),
               DropdownMenuItem(value: 6, child: Text('مغاغة')),
               DropdownMenuItem(value: 7, child: Text('العدوة')),
               DropdownMenuItem(value: 8, child: Text('أبو قرقاص')),
               DropdownMenuItem(value: 9, child: Text('ملاوي')),
              DropdownMenuItem(value: 10, child: Text('ديرمواس')),
                  ],
                  onChanged: (v) =>
                      setState(() => selectedBranchId = v),
                ),

                const SizedBox(height: 16),

                /// ================= DESCRIPTION =================
                CustomTextFormField(
                  controller:
                      descriptionController,
                  hintText:
                      "اشرح الحالة بالتفصيل...",
                  maxLines: 4,
                ),

                const SizedBox(height: 16),

                /// ================= NOTES =================
                CustomTextFormField(
                  controller: notesController,
                  hintText:
                      "ملاحظات إضافية (اختياري)",
                  useValidator: false,
                  maxLines: 3,
                ),

                const SizedBox(height: 30),

                /// ================= SUBMIT =================
                BlocBuilder<
                    AddIncidentCubit,
                    AddIncidentStates>(
                  builder: (context, state) {
                    return CustomButton(
                      text: state.maybeWhen(
                        loading: () =>
                            'جاري الإرسال...',
                        orElse: () =>
                            'إرسال البلاغ',
                      ),
                      onPressed: _submit,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (selectedTypeId == null ||
        selectedSeverity == null ||
        selectedBranchId == null ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(
        content: Text('يرجى ملء جميع الحقول'),
      ));
      return;
    }

    final location =
        context.read<MapCubit>().state.selectedLocation;

    final model = CurrentIncidentModel(
      currentIncidentTypeId: selectedTypeId!,
      currentIncidentSeverity: selectedSeverity!,
      branchId: selectedBranchId!,
      currentIncidentDescription:
          descriptionController.text,
      currentIncidentNotes:
          notesController.text.isEmpty
              ? null
              : notesController.text,
      currentIncidentXAxis:
          location.latitude,
      currentIncidentYAxis:
          location.longitude,
    );

    context
        .read<AddIncidentCubit>()
        .submitIncident(model: model);
  }
}








/// =
