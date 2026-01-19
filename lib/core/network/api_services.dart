import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/actions/data/models/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/data/models/all_incident_type.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'package:retrofit/retrofit.dart';
part 'api_services.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;
  @GET(ApiConstants.allIncidentTypes)
  Future<List<IncidentType>> getAllIncidentTypes();
  @GET(ApiConstants.addincidentType)
  Future<List<IncidentClass>> getAllIncidentClasses();
  @POST(ApiConstants.addincidentType)
  Future<dynamic> addIncidentType(@Body() IncidentType incidentType);
}
