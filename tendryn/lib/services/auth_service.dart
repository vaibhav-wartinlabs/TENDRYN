import 'package:get/get.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/models/user.dart';
import 'package:tendryn/features/login/models/login_request.dart';
import 'package:tendryn/features/login/models/login_response.dart';
import 'package:tendryn/services/api_service.dart';

/// Auth API calls only. Token storage is SessionService; state is AuthController.
class AuthService extends GetxService {
  AuthService({required this._api});

  final ApiService _api;

  Future<LoginResponse> login({required String email, required String password}) async {
    final response = await _api.client.post(
      ApiEndpoints.login,
      body: LoginRequest(email: email, password: password).toJson(),
      parse: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<User> fetchCurrentUser() async {
    final response = await _api.client.get(
      ApiEndpoints.me,
      parse: (json) => User.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<void> logout() async {
    await _api.client.post(ApiEndpoints.logout, parse: (_) {});
  }
}
