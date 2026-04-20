import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'valve.g.dart';

@JsonSerializable()
class ValveModel extends Equatable {
  final double? depth;
  final int? diameter;
  final String? direction;
  final int? id;
  @JsonKey(name: 'in_service_year')
  final int? inServiceYear;
  final double? lat;
  final double? long;
  @JsonKey(name: 'num_of_turns')
  final int? numOfTurns;
  @JsonKey(name: 'pipe_diameter')
  final int? pipeDiameter;
  final String? position;
  final String? status;
  @JsonKey(name: 'valve_type')
  final ValveType? valveType;
  @JsonKey(name: 'valve_type_id')
  final int? valveTypeId;

  const ValveModel({
    this.depth,
    this.diameter,
    this.direction,
    this.id,
    this.inServiceYear,
    this.lat,
    this.long,
    this.numOfTurns,
    this.pipeDiameter,
    this.position,
    this.status,
    this.valveType,
    this.valveTypeId,
  });

  factory ValveModel.fromJson(Map<String, dynamic> json) => _$ValveModelFromJson(json);

  Map<String, dynamic> toJson() => _$ValveModelToJson(this);

  @override
  List<Object?> get props => [
        depth,
        diameter,
        direction,
        id,
        inServiceYear,
        lat,
        long,
        numOfTurns,
        pipeDiameter,
        position,
        status,
        valveType,
        valveTypeId,
      ];
}

@JsonSerializable()
class ValveType extends Equatable {
  final String? abbreviation;
  final int? id;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  @JsonKey(name: 'name_en')
  final String? nameEn;

  const ValveType({
    this.abbreviation,
    this.id,
    this.nameAr,
    this.nameEn,
  });

  factory ValveType.fromJson(Map<String, dynamic> json) => _$ValveTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ValveTypeToJson(this);

  @override
  List<Object?> get props => [abbreviation, id, nameAr, nameEn];
}