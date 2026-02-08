import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:latlong2/latlong.dart';

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
            const Expanded(child: _MapWidget()),
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
          _buildTypeDropdown(),
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
                  _submit(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return BlocBuilder<AllIncidentTypeCubit, GetAllIncidentTypeState>(
      builder: (context, state) {
        return state.when(
          loading: () => const CircularProgressIndicator(),
          initial: () => const SizedBox.shrink(),
          error: (_) => const Text('خطأ في تحميل الأنواع'),
          loaded: (types) => CustomDropdownFormField<int>(
            hintText: 'نوع الأزمة',
            items: types
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e.incidentTypeId,
                    child: Text(e.incidentTypeName),
                  ),
                )
                .toList(),
            onChanged: (value) => selectedTypeId = value,
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (selectedTypeId == null || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى ملء جميع الحقول')));
      return;
    }

    final location = context.read<MapCubit>().state.selectedLocation;

    context.read<AddIncidentCubit>().submitIncident(
      severity: selectedSeverity!,
      typeId: selectedTypeId!,
      branchId: selectedBranchId!,
      description: descriptionController.text,
      notes: notesController.text.isEmpty ? null : notesController.text,

      location: location,
    );
  }
}

class _MapWidget extends StatelessWidget {
  const _MapWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: state.selectedLocation,
                initialZoom: state.zoom,
                onTap: (_, point) {
                  context.read<MapCubit>().setLocation(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.crisis_management',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: state.selectedLocation,
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.location_on,
                        color: warningColor,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _buildMapOverlay(context, state),
          ],
        );
      },
    );
  }

  Widget _buildMapOverlay(BuildContext context, MapState state) {
    return Positioned(
      top: 24,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: appColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "موقع الأزمة",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "انقر على الخريطة لتحديد الموقع",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.read<MapCubit>().setCurrentLocation(
                    LatLng(30.0444, 31.2357),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: appColor, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.my_location, color: appColor, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
