import 'package:get/get.dart';
import 'package:tendryn/core/api/api_exception.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/utils/validators.dart';
import 'package:tendryn/routes/app_routes.dart';

class LoginController extends GetxController {
  LoginController({required this._auth});

  final AuthController _auth;

  final email = ''.obs;
  final password = ''.obs;
  final obscurePassword = true.obs;
  final isLoading = false.obs;

  final emailError = RxnString();
  final passwordError = RxnString();
  final formError = RxnString();

  void toggleObscure() => obscurePassword.toggle();

  Future<void> login() async {
    if (isLoading.value) return;

    emailError.value = Validators.email(email.value);
    passwordError.value = Validators.password(password.value);
    formError.value = null;
    if (emailError.value != null || passwordError.value != null) return;

    isLoading.value = true;
    try {
      await _auth.login(email.value.trim(), password.value);
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      final error = ApiException.from(e);
      emailError.value = error.fieldErrors['email'];
      passwordError.value = error.fieldErrors['password'];
      formError.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }
}
