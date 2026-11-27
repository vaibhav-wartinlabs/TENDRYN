import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/dashboard/widgets/appointment_widgets.dart';
import 'package:tendryn/features/dashboard/widgets/attention_section.dart';
import 'package:tendryn/features/dashboard/widgets/card_grid.dart';
import 'package:tendryn/features/dashboard/widgets/dashboard_kpis.dart';
import 'package:tendryn/features/dashboard/widgets/dashboard_page_header.dart';
import 'package:tendryn/features/dashboard/widgets/dashboard_section_header.dart';
import 'package:tendryn/features/dashboard/widgets/queue_widgets.dart';
import 'package:tendryn/features/dashboard/widgets/quick_actions_section.dart';
import 'package:tendryn/features/queue/widgets/queue_row_menu.dart';

import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/utils/app_notice.dart';

/// Tablet arrangement: card lists instead of tables (two columns on wide
/// tablets), a 2x2 quick-action grid, and bordered section buttons.
class DashboardTablet extends GetView<DashboardController> {
  const DashboardTablet({super.key});

  Widget _menu(QueueEntry e) => QueueRowMenu(
    entry: e,
    onViewPatient: controller.viewPatient,
    onAssignPractitioner: controller.assignPractitioner,
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.summary.value;
      if (summary == null) return const SizedBox.shrink();

      final isDoctor = Get.isRegistered<RoleController>() &&
          RoleController.to.currentRole.value == ClinicRole.doctor;
      final scheme = Theme.of(context).colorScheme;

      if (isDoctor) {
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.pageMarginTablet,
              Dimensions.pageMarginTablet,
              Dimensions.pageMarginTablet,
              Dimensions.pageMarginTablet,
            ),
            children: [
              const DashboardPageHeader(screenType: LayoutType.tablet),
              const SizedBox(height: Dimensions.pageSectionGap),
              DashboardKpis(summary: summary, screenType: LayoutType.tablet),
              const SizedBox(height: Dimensions.pageSectionGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Patients awaiting consultation',
                    style: AppTextStyles.h2Mobile.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  InkWell(
                    onTap: () => AppNotice.unavailable('Queue'),
                    child: Text(
                      'View all',
                      style: AppTextStyles.label.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.sectionContentGap),
              CardGrid(
                minColumnWidth: 260,
                children: [
                  for (final item in DoctorQueueItemData.tabletItems)
                    DoctorQueueCardWidget(item: item),
                ],
              ),
              const SizedBox(height: Dimensions.pageSectionGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today’s appointments',
                    style: AppTextStyles.h2Mobile.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  InkWell(
                    onTap: () => AppNotice.unavailable('Appointments'),
                    child: Text(
                      'View all',
                      style: AppTextStyles.label.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.sectionContentGap),
              CardGrid(
                minColumnWidth: 260,
                children: [
                  for (final item in DoctorAppointmentItemData.tabletItems)
                    DoctorAppointmentCardWidget(item: item),
                ],
              ),
              const SizedBox(height: Dimensions.pageSectionGap),
              AttentionSection(
                items: summary.attention,
                screenType: LayoutType.tablet,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.pageMarginTablet,
            Dimensions.pageMarginTablet,
            Dimensions.pageMarginTablet,
            Dimensions.pageMarginTablet,
          ),
          children: [
            const DashboardPageHeader(screenType: LayoutType.tablet),
            const SizedBox(height: Dimensions.pageSectionGap),
            DashboardKpis(summary: summary, screenType: LayoutType.tablet),
            const SizedBox(height: Dimensions.pageSectionGap),
            DashboardSectionHeader(
              title: 'Live Queue',
              titleStyle: AppTextStyles.h2Mobile,
              actionLabel: 'View Full Queue',
              outlinedAction: true,
              onAction: controller.openQueue,
            ),
            const SizedBox(height: Dimensions.sectionContentGap),
            CardGrid(
              children: [
                for (final e in summary.queue)
                  QueueCard(entry: e, wide: true, menu: _menu(e)),
              ],
            ),
            const SizedBox(height: Dimensions.pageSectionGap),
            DashboardSectionHeader(
              title: 'Today’s Appointments',
              summary: AppointmentCounts(
                summary: summary.appointments,
                inline: true,
              ),
              actionLabel: 'View All',
              outlinedAction: true,
              onAction: controller.openAppointments,
            ),
            const SizedBox(height: Dimensions.sectionContentGap),
            CardGrid(
              children: [
                for (final a in summary.appointments.items)
                  AppointmentCard(appointment: a, wide: true),
              ],
            ),
            const SizedBox(height: Dimensions.pageSectionGap),
            QuickActionsSection(
              columns: 2,
              titleStyle: AppTextStyles.h2Mobile,
              hintStyle: AppTextStyles.label,
            ),
            const SizedBox(height: Dimensions.pageSectionGap),
            AttentionSection(
              items: summary.attention,
              screenType: LayoutType.tablet,
            ),
          ],
        ),
      );
    });
  }
}
