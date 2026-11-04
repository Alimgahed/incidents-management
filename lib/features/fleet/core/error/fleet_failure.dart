import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

enum FleetErrorType {
  network,
  timeout,
  proxyUnavailable,
  authentication,
  server,
  parsing,
  empty,
  unknown,
}

/// Sanitized, immutable domain error for the ETIT GPS Fleet module.
/// Never exposes cookies, passwords, session IDs, tokens, or raw server stack traces.
class FleetFailure extends Equatable {
  final FleetErrorType type;
  final String message;
  final int? statusCode;

  const FleetFailure({
    required this.type,
    required this.message,
    this.statusCode,
  });

  factory FleetFailure.fromException(Object error) {
    if (error is FleetFailure) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const FleetFailure(
            type: FleetErrorType.timeout,
            message:
                'انتهت مهلة الاتصال بخادم تتبع الأسطول. يرجى التحقق من جودة الاتصال والمحاولة مرة أخرى.',
          );
        case DioExceptionType.connectionError:
          return const FleetFailure(
            type: FleetErrorType.proxyUnavailable,
            message:
                'تعذر الوصول إلى خدمة ربط تتبع الأسطول (ETIT Proxy). تأكد من تشغيل خدمة الربط أو الاتصال بالشبكة.',
          );
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          if (code == 401 || code == 403) {
            return FleetFailure(
              type: FleetErrorType.authentication,
              statusCode: code,
              message:
                  'انتهت صلاحية جلسة الاتصال بمنظومة التتبع. جاري إعادة التوثيق تلقائياً.',
            );
          }
          if (code != null && code >= 500) {
            return FleetFailure(
              type: FleetErrorType.server,
              statusCode: code,
              message:
                  'خادم منظومة التتبع (ETIT) يواجه ضغطاً مؤقتاً (رمز الحالة: $code). يرجى المحاولة بعد قليل.',
            );
          }
          return FleetFailure(
            type: FleetErrorType.server,
            statusCode: code,
            message: 'تعذر استلام بيانات الأسطول من الخادم.',
          );
        case DioExceptionType.cancel:
          return const FleetFailure(
            type: FleetErrorType.network,
            message: 'تم إلغاء الطلب السابق لتحميل بيانات أحدث.',
          );
        default:
          return const FleetFailure(
            type: FleetErrorType.network,
            message:
                'حدث خطأ في الاتصال بالشبكة أثناء جلب بيانات الأسطول. يرجى المحاولة مرة أخرى.',
          );
      }
    }

    if (error is FormatException) {
      return const FleetFailure(
        type: FleetErrorType.parsing,
        message: 'تعذر قراءة صيغة البيانات الواردة من خادم التتبع.',
      );
    }

    return const FleetFailure(
      type: FleetErrorType.unknown,
      message: 'حدث خطأ غير متوقع أثناء تحديث بيانات الأسطول.',
    );
  }

  bool get isRetryable =>
      type == FleetErrorType.network ||
      type == FleetErrorType.timeout ||
      type == FleetErrorType.proxyUnavailable ||
      type == FleetErrorType.server ||
      type == FleetErrorType.authentication;

  @override
  List<Object?> get props => [type, message, statusCode];
}
