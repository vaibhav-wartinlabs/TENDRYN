import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/features/splash/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Touching the controller makes the lazy binding instantiate it.
    controller;
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
