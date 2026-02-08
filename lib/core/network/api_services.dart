import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/actions/data/models/classes/all_incident_classes.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_missions/incident_mission.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
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
  @POST(ApiConstants.addMissions)
  Future<dynamic> addMission(@Body() AllMissionModel mission);
  @GET(ApiConstants.allMissions)
  Future<List<AllMissionModel>> getAllMissions();
  @POST(ApiConstants.editMissions)
  Future<dynamic> editMission(
    @Path("id") int id,
    @Body() AllMissionModel mission,
  );
  @POST(ApiConstants.addIncidentMission)
  Future<dynamic> addIncidentMission(
    @Body() IncidentMission incidentMissionData,
  );
  @POST(ApiConstants.addcurrentincdient)
  Future<dynamic> addCurrentIncident(@Body() CurrentIncidentModel incident);
  @POST(ApiConstants.editcurrentincdient)
  Future<dynamic> editCurrentIncident(
    @Path("id") int id,
    @Body() CurrentIncidentModel incident,
  );
  @POST(ApiConstants.editcurrentmissions)
  Future<dynamic> editCurrentMission(
    @Path("id1") int id1,
    @Path("id2") int id2,
    @Path("id3") int id3,
    @Body() Map<String, dynamic> data,
  );
}
