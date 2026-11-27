import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Route middleware: unauthenticated users are sent to login.
class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    return auth.isAuthenticated ? null : const RouteSettings(name: AppRoutes.login);
  }
}
