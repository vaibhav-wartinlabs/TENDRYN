import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/api/api_client.dart';
import 'package:tendryn/core/api/api_interceptor.dart';
import 'package:tendryn/core/api/mock_interceptor.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/authentication/auth_service.dart';
import 'package:tendryn/core/constants/app_config.dart';

/// Builds and owns the Dio instance; exposes the typed [client] to feature services.
class ApiService extends GetxService {
  ApiService({required this._session}){
    _dio = createBaseDio();
    _dio.interceptors.add(
      ApiInterceptor(
        session: _session,
        retryDio: _dio,
        // Looked up lazily: AuthController itself depends on this service.
        onSessionExpired: () => Get.find<AuthController>().handleSessionExpired(),
      ),
    );
    client = ApiClient(_dio);
  }

  final SessionService _session;
  late final Dio _dio;
  late final ApiClient client;

  /// Interceptor-free Dio (used for token refresh so it can't recurse).
  static Dio createBaseDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
    if (AppConfig.useMockApi) dio.interceptors.add(MockInterceptor());
    return dio;
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}
