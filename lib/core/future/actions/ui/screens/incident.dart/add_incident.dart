import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:latlong2/latlong.dart';

class AddIncidentScreen extends StatefulWidget {
  const AddIncidentScreen({super.key});

  @override
  State<AddIncidentScreen> createState() => _AddIncidentScreenState();
}

class _AddIncidentScreenState extends State<AddIncidentScreen> {
  final TextEditingController descriptionController = TextEditingController();
  int? selectedTypeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: 'تفاصيل الأزمة',
        leadingIcon: Icons.info_outline,
      ),
      body: BlocListener<AddIncidentCubit, AddIncidentStates>(
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
          CustomTextFormField(
            controller: descriptionController,
            hintText: "اشرح الحالة بالتفصيل...",
            maxLines: 6,
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
      typeId: selectedTypeId!,
      description: descriptionController.text,
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
                  userAgentPackageName: 'com.incidents.management',
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
