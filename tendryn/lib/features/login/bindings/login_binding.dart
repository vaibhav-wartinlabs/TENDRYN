import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/features/login/controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(auth: Get.find<AuthController>()));
  }
}
