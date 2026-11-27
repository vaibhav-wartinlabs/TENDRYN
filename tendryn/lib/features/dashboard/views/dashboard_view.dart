import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/dashboard/widgets/dashboard_desktop.dart';
import 'package:tendryn/features/dashboard/widgets/dashboard_mobile.dart';
import 'package:tendryn/features/dashboard/widgets/dashboard_tablet.dart';
import 'package:tendryn/widgets/common/status_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StatusView(
        controller: controller,
        onRetry: controller.load,
        builder: (_) => const ResponsiveLayout(
          mobile: DashboardMobile(),
          tablet: DashboardTablet(),
          desktop: DashboardDesktop(),
        ),
      ),
    );
  }
}
