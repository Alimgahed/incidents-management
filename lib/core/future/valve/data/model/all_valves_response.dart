import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';

part 'all_valves_response.g.dart';

class _IntListConverter implements JsonConverter<List<int>, Object?> {
  const _IntListConverter();

  @override
  List<int> fromJson(Object? json) {
    if (json is! List) return const [];
    return json.whereType<num>().map((e) => e.toInt()).toList();
  }

  @override
  Object? toJson(List<int> object) => object;
}

class _StringListConverter implements JsonConverter<List<String>, Object?> {
  const _StringListConverter();

  @override
  List<String> fromJson(Object? json) {
    if (json is! List) return const [];
    return json.whereType<String>().toList();
  }

  @override
  Object? toJson(List<String> object) => object;
}

@JsonSerializable()
class AllValvesResponse extends Equatable {
  @JsonKey(defaultValue: <ValveModel>[])
  final List<ValveModel> data;
  final ValvePagination? pagination;
  final ValveFilterOptions? filters;

  const AllValvesResponse({
    this.data = const [],
    this.pagination,
    this.filters,
  });

  factory AllValvesResponse.fromJson(Map<String, dynamic> json) =>
      _$AllValvesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AllValvesResponseToJson(this);

  @override
  List<Object?> get props => [data, pagination, filters];
}

@JsonSerializable()
class ValvePagination extends Equatable {
  final int? page;
  @JsonKey(name: 'page_size')
  final int? pageSize;
  final int? total;
  @JsonKey(name: 'total_pages')
  final int? totalPages;

  const ValvePagination({
    this.page,
    this.pageSize,
    this.total,
    this.totalPages,
  });

  factory ValvePagination.fromJson(Map<String, dynamic> json) =>
      _$ValvePaginationFromJson(json);

  Map<String, dynamic> toJson() => _$ValvePaginationToJson(this);

  @override
  List<Object?> get props => [page, pageSize, total, totalPages];
}

@JsonSerializable()
class ValveFilterOptions extends Equatable {
  @JsonKey(name: 'valve_types', defaultValue: <ValveTypeOption>[])
  final List<ValveTypeOption> valveTypes;
  @_StringListConverter()
  @JsonKey(defaultValue: <String>[])
  final List<String> statuses;
  @_IntListConverter()
  @JsonKey(defaultValue: <int>[])
  final List<int> diameters;
  @_IntListConverter()
  @JsonKey(name: 'pipe_diameters', defaultValue: <int>[])
  final List<int> pipeDiameters;
  @_StringListConverter()
  @JsonKey(defaultValue: <String>[])
  final List<String> directions;
  @_IntListConverter()
  @JsonKey(name: 'in_service_years', defaultValue: <int>[])
  final List<int> inServiceYears;

  const ValveFilterOptions({
    this.valveTypes = const [],
    this.statuses = const [],
    this.diameters = const [],
    this.pipeDiameters = const [],
    this.directions = const [],
    this.inServiceYears = const [],
  });

  factory ValveFilterOptions.fromJson(Map<String, dynamic> json) =>
      _$ValveFilterOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$ValveFilterOptionsToJson(this);

  @override
  List<Object?> get props => [
        valveTypes,
        statuses,
        diameters,
        pipeDiameters,
        directions,
        inServiceYears,
      ];
}

@JsonSerializable()
class ValveTypeOption extends Equatable {
  final int? id;
  final String? name;

  const ValveTypeOption({this.id, this.name});

  factory ValveTypeOption.fromJson(Map<String, dynamic> json) =>
      _$ValveTypeOptionFromJson(json);

  Map<String, dynamic> toJson() => _$ValveTypeOptionToJson(this);

  @override
  List<Object?> get props => [id, name];
}

class MapBounds extends Equatable {
  final double latMin;
  final double latMax;
  final double longMin;
  final double longMax;

  const MapBounds({
    required this.latMin,
    required this.latMax,
    required this.longMin,
    required this.longMax,
  });

  @override
  List<Object?> get props => [latMin, latMax, longMin, longMax];
}
