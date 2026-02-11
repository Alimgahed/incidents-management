import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';
import 'package:incidents_managment/core/widget/fields.dart';

/// ================= TYPE DROPDOWN =================
class IncidentTypeDropdown extends StatelessWidget {
  final int? selectedValue;
  final ValueChanged<int?> onChanged;

  const IncidentTypeDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllIncidentTypeCubit, GetAllIncidentTypeState>(
      builder: (context, state) {
        return state.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          initial: () => const SizedBox.shrink(),
          error: (_) =>
              const Text('خطأ في تحميل الأنواع'),
          loaded: (types) => CustomDropdownFormField<int>(
            value: selectedValue,
            hintText: 'نوع الأزمة',
            items: types
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e.incidentTypeId,
                    child: Text(e.incidentTypeName),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}

/// ================= MAP WIDGET =================
class IncidentMapWidget extends StatefulWidget {
  const IncidentMapWidget({super.key});

  @override
  State<IncidentMapWidget> createState() =>
      _IncidentMapWidgetState();
}

class _IncidentMapWidgetState
    extends State<IncidentMapWidget> {

  @override
  void initState() {
    super.initState();

    /// Set default location when screen opens
    Future.microtask(() {
      context.read<MapCubit>().setCurrentLocation(
            const LatLng(30.0444, 31.2357),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        return Column(
          children: [
            _mapHeader(context),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        state.selectedLocation,
                    initialZoom: state.zoom,
                    onTap: (_, point) {
                      context
                          .read<MapCubit>()
                          .setLocation(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const [
                        'a',
                        'b',
                        'c'
                      ],
                      userAgentPackageName:
                          'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point:
                              state.selectedLocation,
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.location_on,
                            color: warningColor,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _mapHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.08),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on,
              color: appColor),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "حدد موقع الأزمة على الخريطة",
              style: TextStyle(
                  fontWeight:
                      FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.my_location,
                color: appColor),
            onPressed: () {
              context
                  .read<MapCubit>()
                  .setCurrentLocation(
                    const LatLng(
                        30.0444, 31.2357),
                  );
            },
          )
        ],
      ),
    );
  }
}
