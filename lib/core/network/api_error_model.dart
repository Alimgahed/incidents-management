import 'package:json_annotation/json_annotation.dart';

part 'api_error_model.g.dart';

@JsonSerializable()
class ApiErrorModel {
  final String? error;

  ApiErrorModel({this.error});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    final extracted = json['error'] ??
        json['message'] ??
        json['msg'] ??
        json['detail'];
    return ApiErrorModel(
      error: extracted?.toString() ?? _$ApiErrorModelFromJson(json).error,
    );
  }

  Map<String, dynamic> toJson() => _$ApiErrorModelToJson(this);
}
