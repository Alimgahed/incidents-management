import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';

import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:latlong2/latlong.dart';

class AddIncidentScreen extends StatelessWidget {
  const AddIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: 'تفاصيل الأزمة',
        leadingIcon: Icons.info_outline,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Row(
        children: [
          _buildFormSidebar(context),
          Expanded(child: _MapWidget()),
        ],
      ),
    );
  }

  Widget _buildFormSidebar(BuildContext context) {
    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: BlocBuilder<AddIncidentCubit, AddIncidentState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Globalheader(
                        icon: Icons.info_outline,
                        title: 'تفاصيل البلاغ',
                      ),
                      const SizedBox(height: 24),
                      _buildIncidentTypeDropdown(context, state),
                      const SizedBox(height: 20),
                      _buildAddressField(context, state),
                      const SizedBox(height: 20),
                      _buildDescriptionField(context, state),
                    ],
                  ),
                ),
              ),
              _buildSubmitButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIncidentTypeDropdown(
    BuildContext context,
    AddIncidentState state,
  ) {
    return BlocBuilder<AllIncidentTypeCubit, GetAllIncidentTypeState>(
      builder: (context, typeState) {
        return typeState.when(
          loading: () => CustomDropdownFormField<int>(
            value: null,
            items: const [
              DropdownMenuItem<int>(
                value: null,
                child: Text('جاري التحميل...'),
              ),
            ],
            onChanged: null,
            labelText: 'نوع الأزمة',
          ),
          initial: () => const SizedBox.shrink(),
          loaded: (types) => CustomDropdownFormField<int>(
            value: state.selectedTypeId != null
                ? int.tryParse(state.selectedTypeId!)
                : null,
            hintText: 'اختر نوع الأزمة',
            iconData: Icons.category_outlined,
            items: types
                .map(
                  (IncidentType type) => DropdownMenuItem<int>(
                    value: type.incidentTypeId,
                    child: Text(type.incidentTypeName),
                  ),
                )
                .toList(),
            onChanged: (value) {
              // context.read<AddIncidentCubit>().setSelectedType(value?.toString());
            },
          ),
          error: (e) => Text(
            'خطأ في تحميل أنواع الأزمات',
            style: TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }

  Widget _buildAddressField(BuildContext context, AddIncidentState state) {
    return CustomTextFormField(
      controller: TextEditingController(text: state.address),
      iconData: Icons.location_city_outlined,
      hintText: "مثال: شارع الجمهورية، المنيا",
      maxLines: 1,
      onChanged: (value) {
        context.read<AddIncidentCubit>().setAddress(value);
      },
    );
  }

  Widget _buildDescriptionField(BuildContext context, AddIncidentState state) {
    return CustomTextFormField(
      controller: TextEditingController(text: state.description),
      iconData: Icons.description_outlined,
      hintText: "اشرح الحالة بالتفصيل هنا...",
      maxLines: 6,
      onChanged: (value) {
        context.read<AddIncidentCubit>().setDescription(value);
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CustomButton(
        text: 'إرسال البلاغ',
        onPressed: () {
          // Handle submit
        },
      ),
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
