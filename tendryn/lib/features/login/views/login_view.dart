import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/features/login/controllers/login_controller.dart';
import 'package:tendryn/features/login/widgets/login_panels.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveLayout(
          mobile: const LoginFormPanel(),
          tablet: const Center(child: Card(child: LoginFormPanel(padding: Dimensions.spaceXl))),
          desktop: const Row(
            children: [
              Expanded(child: LoginBrandPanel()),
              Expanded(child: LoginFormPanel()),
            ],
          ),
        ),
      ),
    );
  }
}
