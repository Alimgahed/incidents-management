import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'dart:convert';
import 'package:incidents_managment/core/security/secure_storage_service.dart';
import 'package:incidents_managment/core/offline/network/cache_key.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;

  static Dio getDioInstance() {
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        // Web (dio_web_adapter): sendTimeout is only valid when the request has a body.
        sendTimeout: kIsWeb ? null : const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
        responseDecoder: (responseBytes, options, responseBody) {
          return utf8.decode(responseBytes, allowMalformed: true);
        },
      ),
    );

    // Dynamic Header Injection, Content-Type hygiene & Cache Busting
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Track start time for latency calculation
          options.extra['dio_start_time'] =
              DateTime.now().millisecondsSinceEpoch;

          final secureStorage = getIt<SecureStorageService>();
          final token = await secureStorage.getUserToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final method = options.method.toUpperCase();

          // Only attach Content-Type if request actually has a body and is not FormData.
          // In HTTP and browsers (Flutter Web), GET/HEAD or bodyless requests MUST NOT
          // send Content-Type: application/json because it triggers unnecessary CORS
          // preflight (OPTIONS) requests that fail if the endpoint does not handle OPTIONS.
          if (method == 'GET' || method == 'HEAD' || options.data == null) {
            options.headers.remove('Content-Type');
          } else if (options.data is! FormData &&
              !options.headers.containsKey('Content-Type')) {
            options.headers['Content-Type'] = 'application/json; charset=utf-8';
          }

          // Web (dio_web_adapter): sendTimeout cannot be used without a request body
          if (kIsWeb && options.data == null) {
            options.sendTimeout = null;
          }

          // Disable browser caching for GET requests on Flutter Web
          if (method == 'GET') {
            options.queryParameters['_t'] =
                DateTime.now().millisecondsSinceEpoch;
          }

          return handler.next(options);
        },
      ),
    );

    // Add retry interceptor for transient network errors
    _dio!.interceptors.add(RetryInterceptor(dio: _dio!));

    // Add in-memory cache for GET requests
    _dio!.interceptors.add(CacheInterceptor());

    // Comprehensive logging interceptor to print all request & response data
    _dio!.interceptors.add(SanitizedLoggerInterceptor());

    return _dio!;
  }
}

/// Retry interceptor with exponential back-off for transient network failures.
/// Only retries on connection timeouts, send timeouts, and network errors.
/// Does NOT retry if extra['noRetry'] == true or on intentional 4xx/5xx responses.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
    final noRetry = err.requestOptions.extra['noRetry'] == true;

    // Only retry on transient network/timeout errors, not server responses or forbidden retries
    final shouldRetry =
        !noRetry &&
        retryCount < maxRetries &&
        err.requestOptions.data is! FormData &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.sendTimeout ||
            err.type == DioExceptionType.connectionError);

    if (shouldRetry) {
      final delay = baseDelay * (1 << retryCount); // Exponential back-off
      debugPrint(
        'Retry ${retryCount + 1}/$maxRetries after ${delay.inMilliseconds}ms for ${err.requestOptions.uri}',
      );
      await Future.delayed(delay);

      err.requestOptions.extra['retryCount'] = retryCount + 1;
      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    return handler.next(err);
  }
}

/// Simple in-memory cache interceptor for GET requests.
/// Caches responses for a configurable TTL and serves them on duplicate requests.
class CacheInterceptor extends Interceptor {
  final Duration cacheDuration;
  final Map<String, _CacheEntry> _cache = {};

  CacheInterceptor({this.cacheDuration = const Duration(minutes: 2)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();

    // Clear cache on write operations to ensure subsequent GETs fetch fresh data
    if (method == 'POST' ||
        method == 'PUT' ||
        method == 'DELETE' ||
        method == 'PATCH') {
      _cache.clear();
      return handler.next(options);
    }

    // Only cache GET requests
    if (method != 'GET') {
      return handler.next(options);
    }

    // Skip cache if explicitly requested
    if (options.extra['noCache'] == true) {
      return handler.next(options);
    }

    final key = CacheKey.fromUri(options.uri);
    final entry = _cache[key];

    if (entry != null && !entry.isExpired) {
      debugPrint('Cache HIT: $key');
      return handler.resolve(
        Response(requestOptions: options, data: entry.data, statusCode: 200),
      );
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final key = CacheKey.fromUri(response.requestOptions.uri);
      _cache[key] = _CacheEntry(
        data: response.data,
        expiry: DateTime.now().add(cacheDuration),
      );
    }
    return handler.next(response);
  }

  /// Clear all cached entries (useful after mutations like POST/PUT/DELETE)
  void clearCache() => _cache.clear();
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiry;

  _CacheEntry({required this.data, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// A comprehensive logging interceptor that formats and prints all request,
/// response, and error data safely without truncation or breaking debug output.
class SanitizedLoggerInterceptor extends Interceptor {
  static const int _maxChunkLength = 950;

  /// Helper to print long messages in chunks so Flutter console doesn't truncate them
  static void _logChunked(String message) {
    final lines = message.split('\n');
    for (final line in lines) {
      if (line.length <= _maxChunkLength) {
        debugPrint(line);
      } else {
        for (int i = 0; i < line.length; i += _maxChunkLength) {
          final end = (i + _maxChunkLength < line.length)
              ? i + _maxChunkLength
              : line.length;
          debugPrint(line.substring(i, end));
        }
      }
    }
  }

  /// Safely converts dynamic request/response body into clean, readable text
  static String _formatPayload(dynamic data) {
    if (data == null) return '(empty)';
    if (data is FormData) {
      final fields = data.fields.map((e) => '${e.key}: ${e.value}').toList();
      final files = data.files
          .map((e) => '${e.key}: [File: ${e.value.filename}, ${e.value.length} bytes]')
          .toList();
      return 'FormData(fields: $fields, files: $files)';
    }
    if (data is Map || data is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    return data.toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final startTime = DateTime.now();
    options.extra['dio_start_time'] ??= startTime.millisecondsSinceEpoch;

    final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
    if (sanitizedHeaders.containsKey('Authorization')) {
      final auth = sanitizedHeaders['Authorization'].toString();
      if (auth.length > 25) {
        sanitizedHeaders['Authorization'] =
            '${auth.substring(0, 15)}... [length: ${auth.length}]';
      }
    }

    var requestBody = options.data;
    if (options.path.contains('/login') && requestBody is Map) {
      requestBody = Map<String, dynamic>.from(requestBody);
      if (requestBody.containsKey('password')) {
        requestBody['password'] = '******';
      }
    }

    final queryParams = options.queryParameters.isNotEmpty
        ? options.queryParameters.toString()
        : '(none)';

    final buf = StringBuffer();
    buf.writeln('┌── [DIO REQUEST] ──────────────────────────────────────────');
    buf.writeln('│ 🌐 METHOD:       ${options.method.toUpperCase()}');
    buf.writeln('│ 🔗 URL:          ${options.uri}');
    buf.writeln('│ 🔍 QUERY PARAMS: $queryParams');
    buf.writeln('│ 📋 HEADERS:      $sanitizedHeaders');
    if (options.contentType != null) {
      buf.writeln('│ 📦 CONTENT-TYPE: ${options.contentType}');
    }
    buf.writeln('│ 📝 BODY:');
    final bodyFormatted = _formatPayload(requestBody);
    for (final l in bodyFormatted.split('\n')) {
      buf.writeln('│    $l');
    }
    buf.writeln(
      '│ ⏱️ TIMEOUT:      connect=${options.connectTimeout?.inSeconds}s, '
      'receive=${options.receiveTimeout?.inSeconds}s, '
      'send=${options.sendTimeout?.inSeconds ?? "none"}s',
    );
    buf.write('└───────────────────────────────────────────────────────────');

    _logChunked(buf.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['dio_start_time'] as int?;
    final duration = startTime != null
        ? '${DateTime.now().millisecondsSinceEpoch - startTime}ms'
        : 'unknown';

    var responseData = response.data;
    if (response.requestOptions.path.contains('/login') &&
        responseData is Map) {
      responseData = Map<String, dynamic>.from(responseData);
      if (responseData.containsKey('token')) {
        final tok = responseData['token'].toString();
        responseData['token'] =
            '${tok.substring(0, 15)}... [length: ${tok.length}]';
      }
    }

    final buf = StringBuffer();
    buf.writeln('┌── [DIO RESPONSE] ─────────────────────────────────────────');
    buf.writeln('│ 🌐 METHOD:   ${response.requestOptions.method.toUpperCase()}');
    buf.writeln('│ 🔗 URL:      ${response.requestOptions.uri}');
    buf.writeln(
      '│ ✅ STATUS:   ${response.statusCode} ${response.statusMessage ?? ''} [Latency: $duration]',
    );
    buf.writeln('│ 📋 HEADERS:  ${response.headers.map}');
    buf.writeln('│ 📦 DATA:');
    final dataFormatted = _formatPayload(responseData);
    for (final l in dataFormatted.split('\n')) {
      buf.writeln('│    $l');
    }
    buf.write('└───────────────────────────────────────────────────────────');

    _logChunked(buf.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra['dio_start_time'] as int?;
    final duration = startTime != null
        ? '${DateTime.now().millisecondsSinceEpoch - startTime}ms'
        : 'unknown';

    final buf = StringBuffer();
    buf.writeln('┌── [DIO ERROR] ────────────────────────────────────────────');
    buf.writeln('│ 🌐 METHOD:       ${err.requestOptions.method.toUpperCase()}');
    buf.writeln('│ 🔗 URL:          ${err.requestOptions.uri}');
    buf.writeln('│ ❌ ERROR TYPE:   ${err.type}');
    buf.writeln('│ ⚠️ MESSAGE:      ${err.message}');
    buf.writeln(
      '│ 🔢 STATUS CODE:  ${err.response?.statusCode ?? "No Response"} [Latency: $duration]',
    );
    if (err.response?.headers != null) {
      buf.writeln('│ 📋 RESP HEADERS: ${err.response?.headers.map}');
    }
    if (err.response?.data != null) {
      buf.writeln('│ 📦 RESP DATA:');
      final errDataFormatted = _formatPayload(err.response?.data);
      for (final l in errDataFormatted.split('\n')) {
        buf.writeln('│    $l');
      }
    }
    buf.write('└───────────────────────────────────────────────────────────');

    _logChunked(buf.toString());
    handler.next(err);
  }
}
