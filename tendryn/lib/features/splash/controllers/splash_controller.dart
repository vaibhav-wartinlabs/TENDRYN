import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/app_service.dart';

/// Startup sequence: app initialisation, session restore, first real route.
class SplashController extends GetxController {
  SplashController({required this._app, required this._auth});

  final AppService _app;
  final AuthController _auth;

  @override
  void onReady() {
    super.onReady();
    _start();
  }

  Future<void> _start() async {
    await _app.initialize();
    await _auth.restoreSession();
    Get.offAllNamed(_auth.isAuthenticated ? AppRoutes.dashboard : AppRoutes.login);
  }
}
