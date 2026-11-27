import 'package:dio/dio.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/core/authentication/auth_service.dart';

/// Adds the bearer token; on a 401 refreshes once, retries the request, and
/// signals session expiry if the refresh fails.
class ApiInterceptor extends Interceptor {
  ApiInterceptor({required this.session, required this.retryDio, required this.onSessionExpired});

  final SessionService session;
  final Dio retryDio;
  final void Function() onSessionExpired;

  static const _retriedKey = 'auth_retried';

  bool _isPublic(RequestOptions o) => ApiEndpoints.public.any(o.path.endsWith);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isPublic(options)) {
      final token = await session.accessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 || _isPublic(request) || request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final tokens = await session.refresh();
    if (tokens == null) {
      onSessionExpired();
      return handler.next(err);
    }

    try {
      request.extra[_retriedKey] = true;
      request.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      handler.resolve(await retryDio.fetch<dynamic>(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
