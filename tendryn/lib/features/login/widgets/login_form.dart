import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/login/controllers/login_controller.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_text_field.dart';

class LoginForm extends GetView<LoginController> {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = controller.isLoading.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Email',
            hint: 'name@clinic.com',
            enabled: !busy,
            errorText: controller.emailError.value,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onChanged: controller.email.call,
          ),
          const SizedBox(height: Dimensions.spaceMd),
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            enabled: !busy,
            errorText: controller.passwordError.value,
            obscure: controller.obscurePassword.value,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onChanged: controller.password.call,
            onSubmitted: (_) => controller.login(),
            suffix: IconButton(
              tooltip: controller.obscurePassword.value ? 'Show password' : 'Hide password',
              icon: Icon(controller.obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
              onPressed: controller.toggleObscure,
            ),
          ),
          if (controller.formError.value != null) ...[
            const SizedBox(height: Dimensions.spaceMd),
            Text(controller.formError.value!, style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: Dimensions.spaceLg),
          AppButton.primary(label: 'Sign in', isLoading: busy, onPressed: controller.login, expand: true),
        ],
      );
    });
  }
}
