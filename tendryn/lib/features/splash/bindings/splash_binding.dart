import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/features/splash/controllers/splash_controller.dart';
import 'package:tendryn/services/app_service.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController(app: Get.find<AppService>(), auth: Get.find<AuthController>()));
  }
}
