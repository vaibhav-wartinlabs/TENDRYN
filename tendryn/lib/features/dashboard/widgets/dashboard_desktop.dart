import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/dashboard/widgets/appointment_widgets.dart';
import 'package:tendryn/features/dashboard/widgets/attention_section.dart';
import 'package:tendryn/features/dashboard/widgets/dashboard_kpis.dart';
import 'package:tendryn/features/dashboard/widgets/dashboard_page_header.dart';
import 'package:tendryn/features/dashboard/widgets/queue_widgets.dart';
import 'package:tendryn/features/dashboard/widgets/quick_actions_section.dart';

import 'package:tendryn/core/role/role_controller.dart';

/// Desktop arrangement: one full-width column of sections (the shared
/// sidebar and top bar come from the shell). Tables replace the cards.
class DashboardDesktop extends GetView<DashboardController> {
  const DashboardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.summary.value;
      if (summary == null) return const SizedBox.shrink();

      final isDoctor = Get.isRegistered<RoleController>() &&
          RoleController.to.currentRole.value == ClinicRole.doctor;

      if (isDoctor) {
        return ListView(
          padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
          children: [
            const DashboardPageHeader(screenType: LayoutType.desktop),
            const SizedBox(height: Dimensions.spaceLg),
            DashboardKpis(summary: summary, screenType: LayoutType.desktop),
            const SizedBox(height: Dimensions.spaceLg),
            const DoctorQueueTable(),
            const SizedBox(height: Dimensions.spaceLg),
            const DoctorAppointmentsTable(),
            const SizedBox(height: Dimensions.spaceLg),
            AttentionSection(
              items: summary.attention,
              screenType: LayoutType.desktop,
            ),
          ],
        );
      }

      return ListView(
        padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
        children: [
          const DashboardPageHeader(screenType: LayoutType.desktop),
          const SizedBox(height: Dimensions.spaceLg),
          DashboardKpis(summary: summary, screenType: LayoutType.desktop),
          const SizedBox(height: Dimensions.spaceLg),
          LiveQueueTable(entries: summary.queue),
          const SizedBox(height: Dimensions.spaceLg),
          AppointmentsTable(summary: summary.appointments),
          const SizedBox(height: Dimensions.spaceLg),
          const QuickActionsSection(),
          const SizedBox(height: Dimensions.spaceLg),
          AttentionSection(
            items: summary.attention,
            screenType: LayoutType.desktop,
          ),
        ],
      );
    });
  }
}
