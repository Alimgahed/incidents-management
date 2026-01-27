import 'package:dio/dio.dart';

import 'package:incidents_managment/core/network/api_constants.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;

  static Dio getDioInstance() {
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 🔥 Add dynamic headers via interceptor
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers.addAll({
            // "Authorization": token,
            // "refresh_token": refreshToken,
          });

          return handler.next(options);
        },
      ),
    );

    // Add LogInterceptor for network debugging
    _dio!.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    return _dio!;
  }
}
