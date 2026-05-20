import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'package:incidents_managment/core/security/secure_storage_service.dart';
import 'package:incidents_managment/core/security/session_manager.dart';

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
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Dynamic Header Injection & 401 Error Interception
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final secureStorage = getIt<SecureStorageService>();
          final token = await secureStorage.getUserToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Trigger global force logout via SessionManager on 401 Unauthorized
            final sessionManager = getIt<SessionManager>();
            await sessionManager.logout(sessionExpired: true);
          }
          return handler.next(error);
        },
      ),
    );

    // Add retry interceptor for transient network errors
    _dio!.interceptors.add(RetryInterceptor(dio: _dio!));

    // Add in-memory cache for GET requests
    _dio!.interceptors.add(CacheInterceptor());

    // Add Sanitized Logging Interceptor (debug mode only)
    if (kDebugMode) {
      _dio!.interceptors.add(SanitizedLoggerInterceptor());
    }

    return _dio!;
  }
}

/// Retry interceptor with exponential back-off for transient network failures.
/// Only retries on connection timeouts, send timeouts, and network errors.
/// Does NOT retry on 4xx/5xx server errors (those are intentional responses).
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

    // Only retry on transient network/timeout errors, not server responses
    final shouldRetry = retryCount < maxRetries &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.sendTimeout ||
            err.type == DioExceptionType.connectionError);

    if (shouldRetry) {
      final delay = baseDelay * (1 << retryCount); // Exponential back-off
      if (kDebugMode) {
        debugPrint('Retry ${retryCount + 1}/$maxRetries after ${delay.inMilliseconds}ms for ${err.requestOptions.uri}');
      }
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
    // Only cache GET requests
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    // Skip cache if explicitly requested
    if (options.extra['noCache'] == true) {
      return handler.next(options);
    }

    final key = options.uri.toString();
    final entry = _cache[key];

    if (entry != null && !entry.isExpired) {
      if (kDebugMode) {
        debugPrint('Cache HIT: $key');
      }
      return handler.resolve(
        Response(
          requestOptions: options,
          data: entry.data,
          statusCode: 200,
        ),
      );
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final key = response.requestOptions.uri.toString();
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

/// A custom logging interceptor that automatically strips authorization headers 
/// and redacts sensitive request parameters in standard debugPrint output.
class SanitizedLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
    if (sanitizedHeaders.containsKey('Authorization')) {
      sanitizedHeaders['Authorization'] = '[REDACTED_BEARER_TOKEN]';
    }

    var requestBody = options.data;
    if (options.path.contains('/login') && requestBody is Map) {
      requestBody = Map<String, dynamic>.from(requestBody);
      if (requestBody.containsKey('password')) {
        requestBody['password'] = '[REDACTED_PASSWORD]';
      }
    }

    debugPrint('--> Dio Request: ${options.method} ${options.uri}');
    debugPrint('Headers: $sanitizedHeaders');
    if (requestBody != null) {
      debugPrint('Body: $requestBody');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('<-- Dio Response (${response.statusCode}): ${response.requestOptions.uri}');
    // Strip user token from logged response body on login endpoint
    var responseData = response.data;
    if (response.requestOptions.path.contains('/login') && responseData is Map) {
      responseData = Map<String, dynamic>.from(responseData);
      if (responseData.containsKey('token')) {
        responseData['token'] = '[REDACTED_JWT_TOKEN]';
      }
    }
    debugPrint('Response Data: $responseData');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('<-- Dio Error: ${err.message} [Code: ${err.response?.statusCode}]');
    if (err.response?.data != null) {
      debugPrint('Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}
