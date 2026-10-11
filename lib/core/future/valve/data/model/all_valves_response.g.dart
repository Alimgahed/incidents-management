// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_valves_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllValvesResponse _$AllValvesResponseFromJson(
  Map<String, dynamic> json,
) => AllValvesResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => ValveModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  pagination: json['pagination'] == null
      ? null
      : ValvePagination.fromJson(json['pagination'] as Map<String, dynamic>),
  filters: json['filters'] == null
      ? null
      : ValveFilterOptions.fromJson(json['filters'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AllValvesResponseToJson(AllValvesResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'pagination': instance.pagination,
      'filters': instance.filters,
    };

ValvePagination _$ValvePaginationFromJson(Map<String, dynamic> json) =>
    ValvePagination(
      page: (json['page'] as num?)?.toInt(),
      pageSize: (json['page_size'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      totalPages: (json['total_pages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ValvePaginationToJson(ValvePagination instance) =>
    <String, dynamic>{
      'page': instance.page,
      'page_size': instance.pageSize,
      'total': instance.total,
      'total_pages': instance.totalPages,
    };

ValveFilterOptions _$ValveFilterOptionsFromJson(Map<String, dynamic> json) =>
    ValveFilterOptions(
      valveTypes:
          (json['valve_types'] as List<dynamic>?)
              ?.map((e) => ValveTypeOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statuses: json['statuses'] == null
          ? []
          : const _StringListConverter().fromJson(json['statuses']),
      diameters: json['diameters'] == null
          ? []
          : const _IntListConverter().fromJson(json['diameters']),
      pipeDiameters: json['pipe_diameters'] == null
          ? []
          : const _IntListConverter().fromJson(json['pipe_diameters']),
      directions: json['directions'] == null
          ? []
          : const _StringListConverter().fromJson(json['directions']),
      inServiceYears: json['in_service_years'] == null
          ? []
          : const _IntListConverter().fromJson(json['in_service_years']),
    );

Map<String, dynamic> _$ValveFilterOptionsToJson(
  ValveFilterOptions instance,
) => <String, dynamic>{
  'valve_types': instance.valveTypes,
  'statuses': const _StringListConverter().toJson(instance.statuses),
  'diameters': const _IntListConverter().toJson(instance.diameters),
  'pipe_diameters': const _IntListConverter().toJson(instance.pipeDiameters),
  'directions': const _StringListConverter().toJson(instance.directions),
  'in_service_years': const _IntListConverter().toJson(instance.inServiceYears),
};

ValveTypeOption _$ValveTypeOptionFromJson(Map<String, dynamic> json) =>
    ValveTypeOption(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$ValveTypeOptionToJson(ValveTypeOption instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
