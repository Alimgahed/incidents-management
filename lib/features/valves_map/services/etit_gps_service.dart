import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/network/dio_factory.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/security/secure_storage_service.dart';
import '../models/etit_vehicle_model.dart';

/// Read-only client for ETIT GPS Fleet Management & Live Tracking.
///
/// * Mobile/Desktop: talks to ETIT directly and manages the session cookies.
/// * Web: browsers block cross-origin calls and the `Cookie` header, so all
///   calls go through the local dev proxy or backend proxy (`/fleet/proxy`),
///   which owns the ETIT session (login + cookies + auto re-login).
class EtitGpsService {
  static final EtitGpsService _instance = EtitGpsService.internal();
  factory EtitGpsService() => _instance;
  @visibleForTesting
  EtitGpsService.internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            if (kDebugMode) print('Token retrieval error for fleet call: $e');
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Resolves the authenticated shared application Dio (with all app interceptors attached).
  Dio get _backendDio {
    if (getIt.isRegistered<Dio>()) {
      return getIt<Dio>();
    }
    return DioFactory.getDioInstance();
  }

  /// Safely retrieves the current user's JWT token across Web & Mobile platforms.
  static Future<String?> _getToken() async {
    try {
      if (getIt.isRegistered<SecureStorageService>()) {
        final token = await getIt<SecureStorageService>().getUserToken();
        if (token != null && token.isNotEmpty) return token;
      }
    } catch (_) {}
    try {
      final token = await SharedPreferencesHelper.getData<String>('user_token');
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    return null;
  }

  static String get _backendProxy =>
      '${ApiConstants.baseUrl}${ApiConstants.fleetProxy}?url=';
  static const String _fmsBase = 'https://etit-fms.etit-eg.com';
  static const String _gpsBase = 'https://fms-gps.etit-eg.com';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      responseType: ResponseType.plain,
      validateStatus: (status) => status != null && status < 600,
    ),
  );

  /// Cookie jar shared by both ETIT hosts (mobile/desktop only).
  final Map<String, String> _jar = {};
  DateTime? _lastLoginTime;
  String? _cachedAllCodes;

  /// In-flight deduplication futures to prevent duplicate concurrent requests.
  Future<List<EtitVehicleModel>>? _inFlightVehicles;
  Future<Map<String, Map<String, dynamic>>>? _inFlightLiveCoords;

  String _url(String target) =>
      kIsWeb ? '$_backendProxy${Uri.encodeComponent(target)}' : target;

  String get _cookieHeader =>
      _jar.entries.map((e) => '${e.key}=${e.value}').join('; ');

  void _storeCookies(Response res) {
    for (final c in res.headers['set-cookie'] ?? const <String>[]) {
      final kv = c.split(';').first;
      final i = kv.indexOf('=');
      if (i > 0) _jar[kv.substring(0, i).trim()] = kv.substring(i + 1);
    }
  }

  Map<String, dynamic> _headers({
    String? contentType,
    String? referer,
    String? token,
  }) {
    final h = <String, dynamic>{};
    if (contentType != null) h['Content-Type'] = contentType;
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    if (!kIsWeb) {
      h['X-Requested-With'] = 'XMLHttpRequest';
      // On web the proxy adds cookies/referer; browsers forbid setting them.
      if (_jar.isNotEmpty) h['Cookie'] = _cookieHeader;
      if (referer != null) h['Referer'] = referer;
    }
    return h;
  }

  /// Logs in using the same ASP.NET AJAX async postback the ETIT site uses.
  Future<bool> login({
    String username = 'water.menia',
    String password = 'Mec@2026',
  }) async {
    if (kIsWeb) {
      // The proxy logs in automatically on the first request.
      _lastLoginTime = DateTime.now();
      return true;
    }
    try {
      _jar.clear();
      final page = await _dio.get('$_fmsBase/');
      _storeCookies(page);
      final html = page.data.toString();
      final viewState =
          RegExp(
            r'id="__VIEWSTATE" value="([^"]*)"',
          ).firstMatch(html)?.group(1) ??
          '';
      final viewStateGen =
          RegExp(
            r'id="__VIEWSTATEGENERATOR" value="([^"]*)"',
          ).firstMatch(html)?.group(1) ??
          '';

      final form = {
        'ScriptManager1': r'UpdatePanel1|lg_AltairLogin$LoginButton',
        '__EVENTTARGET': r'lg_AltairLogin$LoginButton',
        '__EVENTARGUMENT': '',
        '__VIEWSTATE': viewState,
        '__VIEWSTATEGENERATOR': viewStateGen,
        r'lg_AltairLogin$UserName': username,
        r'lg_AltairLogin$Password': password,
        'lg_AltairLogin_RadW_SendEmail_ClientState': '',
        r'TokenWindow$C$txt_token': '',
        'TokenWindow_ClientState': '',
        'NotAuthorizedWindow_ClientState': '',
        'RadWindowManager2_ClientState': '',
        '__ASYNCPOST': 'true',
        'RadAJAXControlID': 'RadAjaxManager1',
      };

      final res = await _dio.post(
        '$_fmsBase/',
        data: form,
        options: Options(
          contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
          headers: {
            ..._headers(referer: '$_fmsBase/'),
            'X-MicrosoftAjax': 'Delta=true',
          },
        ),
      );
      _storeCookies(res);

      // Success = ETIT answers with a pageRedirect to an internal page.
      final body = res.data.toString();
      final ok =
          RegExp(
            r'pageRedirect\|\|[^|]*WebPages',
            caseSensitive: false,
          ).hasMatch(body) &&
          !body.contains('ErrorPage');
      if (!ok) {
        if (kDebugMode) print('ETIT login failed: ${res.data.toString()}');
        return false;
      }

      // Initialise the GPS site session.
      final maps = await _dio.get(
        '$_gpsBase/WebPages/Maps.aspx',
        options: Options(
          headers: _headers(
            referer: '$_fmsBase/WebPages/Transporters/List.aspx',
          ),
        ),
      );
      _storeCookies(maps);
      _cachedAllCodes = _extractAllCodes(maps.data.toString());

      _lastLoginTime = DateTime.now();
      if (kDebugMode) print('ETIT login OK');
      return true;
    } catch (e) {
      if (kDebugMode) print('ETIT Login Error: $e');
      return false;
    }
  }

  Future<void> _ensureAuthenticated() async {
    final last = _lastLoginTime;
    if (last == null || DateTime.now().difference(last).inMinutes > 20) {
      await login();
    }
  }

  String? _extractAllCodes(String html) {
    final m =
        RegExp(
          r'hdn_NAllTransporterCOdes"[^>]*value="([^"]+)"',
        ).firstMatch(html) ??
        RegExp(
          r'value="([^"]+)"[^>]*hdn_NAllTransporterCOdes',
        ).firstMatch(html);
    return m?.group(1);
  }

  /// 1. Fleet vehicles list (plates, branches, types, device IMEI).
  /// Deduplicates concurrent calls when `searchKeyword` is null/empty.
  Future<List<EtitVehicleModel>> getVehicles({
    int pageIndex = 1,
    int pageSize = 100,
    String? searchKeyword,
    bool throwOnError = false,
  }) async {
    final canDedupe = (searchKeyword == null || searchKeyword.isEmpty);
    if (canDedupe && _inFlightVehicles != null) {
      return _inFlightVehicles!;
    }

    final future = _fetchVehiclesInternal(
      searchKeyword: searchKeyword,
      throwOnError: throwOnError,
    );
    if (canDedupe) {
      _inFlightVehicles = future.whenComplete(() => _inFlightVehicles = null);
    }
    return future;
  }

  Future<List<EtitVehicleModel>> _fetchVehiclesInternal({
    String? searchKeyword,
    required bool throwOnError,
  }) async {
    // 1. Try fetching from Backend fleet vehicles API first using the shared app Dio
    try {
      final dio = _backendDio;
      final backendRes = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.fleetVehicles}',
      );
      if (backendRes.statusCode == 200 && backendRes.data != null) {
        final dynamic raw = backendRes.data;
        final decoded = raw is String ? jsonDecode(raw) : raw;
        if (decoded is List) {
          final list = decoded
              .map((r) => EtitVehicleModel.fromJson(r as Map<String, dynamic>))
              .toList();
          if (searchKeyword != null && searchKeyword.trim().isNotEmpty) {
            final kw = searchKeyword.trim().toLowerCase();
            return list
                .where(
                  (v) =>
                      v.plateNumber.toLowerCase().contains(kw) ||
                      v.code.toLowerCase().contains(kw) ||
                      (v.allocation ?? '').toLowerCase().contains(kw),
                )
                .toList();
          }
          return list;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Backend /fleet/vehicles not reached, trying ETIT direct: $e');
      }
    }

    await _ensureAuthenticated();
    try {
      final token = await _getToken();
      Future<List<EtitVehicleModel>> fetchPage(int page) async {
        final payload = {
          'transpoterCriteria': {
            'SubId': '',
            'StuffId': '',
            'TransporterCodeName': searchKeyword ?? '',
            'TransporterId': '',
            'TransporterTypeId': '',
            'TransporterGroupID': '',
            'LandmarkId': '',
            'ManufacturerId': '',
            'ProductionYearID': '',
            'BranchID': '',
            'SubBranchID': '',
            'NextExaminationDate': '',
            'LicenseExpiryDate': '',
            'InsuranceEndDate': '',
            'EntranceDate': '',
            'TransporterBrand': '',
            'DasboardGPsStatus': '',
            'IsdasboardGPsStatus': 0,
            'TransporterStatus': '',
            'Category': '',
            'ChassisNumber': '',
            'EntranceDateBeforeAfter': '',
            'InsuranceEndDateBeforeAfter': '',
            'LicenseExpiryDateBeforeAfter': '',
            'NextExaminationDateBeforAfter': '',
            'PageCount': 0,
            'PageIndex': page,
            'PageSize': 100,
            'TotalTransCount': 0,
            'TransporterIdList': [],
          },
        };

        final res = await _dio.post(
          _url(
            '$_fmsBase/WebPages/Transporters/List.aspx/GetAllTransporterBySearchCriteria',
          ),
          data: jsonEncode(payload),
          options: Options(
            headers: _headers(
              contentType: kIsWeb
                  ? 'text/plain;charset=UTF-8'
                  : 'application/json; charset=UTF-8',
              referer: '$_fmsBase/WebPages/Transporters/List.aspx',
              token: token,
            ),
          ),
        );

        if (res.statusCode != 200) {
          if (kDebugMode) {
            print('ETIT vehicles HTTP ${res.statusCode}: ${res.data}');
          }
          if (throwOnError) {
            throw DioException.badResponse(
              statusCode: res.statusCode ?? 500,
              requestOptions: res.requestOptions,
              response: res,
            );
          }
          return [];
        }

        final outer = jsonDecode(res.data.toString()) as Map<String, dynamic>;
        final inner = jsonDecode(outer['d'].toString()) as Map<String, dynamic>;
        final rows = inner['rows'] as List? ?? [];
        return rows
            .map((r) => EtitVehicleModel.fromJson(r as Map<String, dynamic>))
            .toList();
      }

      // Fetch page 1 and page 2 in parallel (total 162 vehicles, max 100 per request)
      final results = await Future.wait([fetchPage(1), fetchPage(2)]);
      return [...results[0], ...results[1]];
    } catch (e) {
      if (kDebugMode) print('Error fetching ETIT vehicles: $e');
      if (throwOnError) rethrow;
      return [];
    }
  }

  /// 2. Live GPS coordinates keyed by vehicle ID.
  /// Deduplicates concurrent calls.
  Future<Map<String, Map<String, dynamic>>> getLiveCoordinates({
    bool throwOnError = false,
  }) async {
    if (_inFlightLiveCoords != null) {
      return _inFlightLiveCoords!;
    }
    final future = _fetchLiveCoordinatesInternal(throwOnError: throwOnError);
    _inFlightLiveCoords = future.whenComplete(() => _inFlightLiveCoords = null);
    return future;
  }

  Future<Map<String, Map<String, dynamic>>> _fetchLiveCoordinatesInternal({
    required bool throwOnError,
  }) async {
    // 1. Try fetching from Backend live API first using the shared app Dio
    try {
      final dio = _backendDio;
      final backendRes = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.fleetLive}',
      );
      if (backendRes.statusCode == 200 && backendRes.data != null) {
        final dynamic raw = backendRes.data;
        final decoded = raw is String ? jsonDecode(raw) : raw;
        if (decoded is Map) {
          final result = <String, Map<String, dynamic>>{};
          decoded.forEach((key, value) {
            if (value is Map) {
              result[key.toString()] = Map<String, dynamic>.from(value);
            }
          });
          return result;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Backend /fleet/live not reached, trying ETIT direct: $e');
      }
    }

    await _ensureAuthenticated();
    try {
      final token = await _getToken();
      if (_cachedAllCodes == null || _cachedAllCodes!.isEmpty) {
        final maps = await _dio.get(
          _url('$_gpsBase/WebPages/Maps.aspx'),
          options: Options(
            headers: _headers(
              referer: '$_fmsBase/WebPages/Transporters/List.aspx',
              token: token,
            ),
          ),
        );
        if (!kIsWeb) _storeCookies(maps);
        _cachedAllCodes = _extractAllCodes(maps.data.toString());
      }
      if (_cachedAllCodes == null) {
        if (kDebugMode) {
          print('ETIT: could not read vehicle codes from Maps.aspx');
        }
        return {};
      }

      final res = await _dio.post(
        _url('$_gpsBase/WebPages/GetTransportersSpeedStatus.aspx'),
        data: 'ids_speedlimits=${Uri.encodeComponent(_cachedAllCodes!)}||1',
        options: Options(
          headers: _headers(
            contentType: 'application/x-www-form-urlencoded',
            referer: '$_gpsBase/WebPages/Maps.aspx',
            token: token,
          ),
        ),
      );

      // Response format: ids*speeds*statuses*longitudes*latitudes*dates*...*deviceCodes
      final par = res.data.toString().split('*');
      if (par.length < 5) return {};
      final ids = par[0].split(',');
      final speeds = par[1].split(',');
      final statuses = par[2].split(',');
      final lons = par[3].split(',');
      final lats = par[4].split(',');
      final dates = par.length > 5 ? par[5].split(',') : const <String>[];
      final devCodes = par.length > 20 ? par[20].split(',') : const <String>[];

      final coords = <String, Map<String, dynamic>>{};
      for (var i = 0; i < ids.length; i++) {
        final id = ids[i].trim();
        if (id.isEmpty) continue;
        final lat = i < lats.length ? double.tryParse(lats[i].trim()) : null;
        final lon = i < lons.length ? double.tryParse(lons[i].trim()) : null;
        coords[id] = {
          'lat': (lat != null && lat != 0) ? lat : null,
          'lon': (lon != null && lon != 0) ? lon : null,
          'speed': i < speeds.length
              ? double.tryParse(speeds[i].trim()) ?? 0.0
              : 0.0,
          'status': i < statuses.length ? statuses[i].trim() : '',
          'lastUpdate': i < dates.length ? dates[i].trim() : '',
          'deviceCode': i < devCodes.length ? devCodes[i].trim() : '',
        };
      }
      return coords;
    } catch (e) {
      if (kDebugMode) print('Error fetching live GPS coords: $e');
      if (throwOnError) rethrow;
      return {};
    }
  }

  /// 3. Vehicles merged with their live coordinates.
  Future<List<EtitVehicleModel>> getVehiclesWithLiveTracking() async {
    // 1. Try fetching directly from Backend fleet tracking (single cached O(1) call) using shared app Dio
    try {
      final dio = _backendDio;
      final backendRes = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.fleetTracking}',
      );
      if (backendRes.statusCode == 200 && backendRes.data != null) {
        final dynamic raw = backendRes.data;
        final decoded = raw is String ? jsonDecode(raw) : raw;
        if (decoded is List) {
          return decoded
              .map((r) => EtitVehicleModel.fromJson(r as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Backend /fleet/tracking not reached, falling back to separate calls: $e',
        );
      }
    }

    final results = await Future.wait([getVehicles(), getLiveCoordinates()]);
    final vehicles = results[0] as List<EtitVehicleModel>;
    final live = results[1] as Map<String, Map<String, dynamic>>;
    return mergeVehiclesWithLiveMap(vehicles, live);
  }

  /// Forces backend cache refresh and re-fetch from ETIT.
  Future<bool> forceBackendRefresh() async {
    try {
      final dio = _backendDio;
      final res = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.fleetRefresh}',
      );
      return res.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('forceBackendRefresh error: $e');
      return false;
    }
  }

  /// Pure helper to merge vehicle metadata with live telematics map in O(N) time.
  List<EtitVehicleModel> mergeVehiclesWithLiveMap(
    List<EtitVehicleModel> baseVehicles,
    Map<String, Map<String, dynamic>> live,
  ) {
    return baseVehicles.map((v) {
      final loc = live[v.id];
      if (loc == null) return v;
      final liveImei = (loc['deviceCode'] as String?)?.trim() ?? '';
      final effectiveImei =
          (v.deviceCode == null || v.deviceCode!.trim().isEmpty) &&
              liveImei.isNotEmpty
          ? liveImei
          : v.deviceCode;
      return v.copyWith(
        latitude: loc['lat'] as double?,
        longitude: loc['lon'] as double?,
        speed: loc['speed'] as double?,
        statusCode: loc['status'] as String?,
        lastUpdate: loc['lastUpdate'] as String?,
        deviceCode: effectiveImei,
      );
    }).toList();
  }
}
