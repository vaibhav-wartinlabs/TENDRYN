import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
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
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Phone arrangement: a single column of compact cards and text-link actions.
class DashboardMobile extends GetView<DashboardController> {
  const DashboardMobile({super.key});

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
            padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
            children: [
              const DashboardPageHeader(screenType: LayoutType.mobile),
              const SizedBox(height: Dimensions.spaceMd),
              DashboardKpis(summary: summary, screenType: LayoutType.mobile),
              const SizedBox(height: Dimensions.pageSectionGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Patients awaiting consultation',
                      style: AppTextStyles.h2Mobile.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
              for (final (index, item) in DoctorQueueItemData.items.indexed) ...[
                DoctorQueueCardWidget(item: item),
                if (index < DoctorQueueItemData.items.length - 1)
                  const SizedBox(height: Dimensions.sectionContentGap),
              ],
              const SizedBox(height: Dimensions.pageSectionGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Today’s appointments',
                      style: AppTextStyles.h2Mobile.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
              for (final (index, item) in DoctorAppointmentItemData.items.indexed) ...[
                DoctorAppointmentCardWidget(item: item),
                if (index < DoctorAppointmentItemData.items.length - 1)
                  const SizedBox(height: Dimensions.sectionContentGap),
              ],
              const SizedBox(height: Dimensions.pageSectionGap),
              AttentionSection(
                items: summary.attention,
                screenType: LayoutType.mobile,
              ),
              const SizedBox(height: Dimensions.pageSectionGap),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    ),
                  ),
                  onPressed: () => AppNavigation.goTo(AppRoutes.queue),
                  child: const Text(
                    'View Patient Queue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.sectionContentGap),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
          children: [
            const DashboardPageHeader(screenType: LayoutType.mobile),
            const SizedBox(height: Dimensions.sectionContentGap),
            DashboardKpis(summary: summary, screenType: LayoutType.mobile),
            const SizedBox(height: Dimensions.sectionContentGap),
            DashboardSectionHeader(
              title: 'Live Queue',
              actionLabel: 'View Full Queue',
              onAction: controller.openQueue,
            ),
            const SizedBox(height: Dimensions.sectionContentGap),
            CardGrid(
              children: [
                for (final e in summary.queue)
                  QueueCard(entry: e, menu: _menu(e)),
              ],
            ),
            const SizedBox(height: Dimensions.sectionContentGap),
            DashboardSectionHeader(
              title: 'Today’s Appointments',
              summary: AppointmentCounts(summary: summary.appointments),
              actionLabel: 'View All',
              onAction: controller.openAppointments,
            ),
            const SizedBox(height: Dimensions.sectionContentGap),
            CardGrid(
              children: [
                for (final a in summary.appointments.items)
                  AppointmentCard(appointment: a),
              ],
            ),
            const SizedBox(height: Dimensions.sectionContentGap),
            const QuickActionsSection(),
            const SizedBox(height: Dimensions.sectionContentGap),
            AttentionSection(
              items: summary.attention,
              screenType: LayoutType.mobile,
            ),
          ],
        ),
      );
    });
  }
}
