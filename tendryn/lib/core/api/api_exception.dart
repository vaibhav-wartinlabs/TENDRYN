import 'package:dio/dio.dart';

enum ApiErrorType { network, unauthorized, validation, server, unexpected }

/// The only error type the rest of the app deals with. Everything thrown by
/// Dio or the parser is converted here via [ApiException.from].
class ApiException implements Exception {
  const ApiException(this.type, this.message, {this.statusCode, this.fieldErrors = const {}});

  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  const ApiException.network() : this(ApiErrorType.network, 'Network unavailable. Check your connection.');
  const ApiException.unexpected() : this(ApiErrorType.unexpected, 'Something went wrong. Please try again.');

  factory ApiException.from(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      if (error.error is ApiException) return error.error! as ApiException;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return const ApiException.network();
        case DioExceptionType.badResponse:
          return ApiException._fromResponse(error.response);
        case DioExceptionType.unknown:
          // Socket-level failures (offline, DNS, refused) land here.
          return error.error is Exception ? const ApiException.network() : const ApiException.unexpected();
        case DioExceptionType.cancel:
        case DioExceptionType.badCertificate:
        case DioExceptionType.transformTimeout:
          return const ApiException.unexpected();
      }
    }
    return const ApiException.unexpected();
  }

  factory ApiException._fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode;
    final data = response?.data;
    final serverMessage = data is Map<String, dynamic> ? data['message'] as String? : null;

    if (status == 401) {
      return ApiException(ApiErrorType.unauthorized, serverMessage ?? 'Please sign in again.', statusCode: status);
    }
    if (status == 400 || status == 422) {
      final raw = data is Map<String, dynamic> ? data['errors'] : null;
      final fields = raw is Map ? raw.map((k, v) => MapEntry('$k', '$v')) : <String, String>{};
      return ApiException(
        ApiErrorType.validation,
        serverMessage ?? 'Please check the entered values.',
        statusCode: status,
        fieldErrors: fields,
      );
    }
    return ApiException(ApiErrorType.server, serverMessage ?? 'Request failed (${status ?? 'unknown'}).', statusCode: status);
  }

  bool get isUnauthorized => type == ApiErrorType.unauthorized;

  @override
  String toString() => 'ApiException($type, $message)';
}
