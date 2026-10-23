import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'branch_model.g.dart';

@JsonSerializable()
class BranchModel extends Equatable {
  @JsonKey(name: 'branch_id')
  final int branchId;

  @JsonKey(name: 'branch_name')
  final String branchName;

  @JsonKey(name: 'lat')
  final double? lat;

  @JsonKey(name: 'long')
  final double? long;

  const BranchModel({
    required this.branchId,
    required this.branchName,
    this.lat,
    this.long,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      _$BranchModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchModelToJson(this);

  @override
  List<Object?> get props => [branchId, branchName, lat, long];
}
