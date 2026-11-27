import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/widgets/card_grid.dart';
import 'package:tendryn/features/dashboard/widgets/queue_widgets.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/features/queue/widgets/queue_page_header.dart';
import 'package:tendryn/features/queue/widgets/queue_row_menu.dart';
import 'package:tendryn/features/queue/widgets/queue_summary.dart';
import 'package:tendryn/features/queue/widgets/queue_table.dart';
import 'package:tendryn/features/queue/widgets/queue_toolbar.dart';
import 'package:tendryn/widgets/common/app_button.dart';

/// Phone arrangement:
/// - In Doctor mode: Header ("My Patient Queue"), search + filter,
///   "Patients Awaiting Consultation", single-column patient cards, pagination,
///   and full-width "Call Next Patient" button.
/// - In Receptionist mode: Header, summary cards, search, today's queue cards, "Add Walk-in".
class QueueMobile extends GetView<QueueController> {
  const QueueMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final queue = controller.queue.value;
      if (queue == null) return const SizedBox.shrink();

      final isDoctor = Get.isRegistered<RoleController>() &&
          RoleController.to.currentRole.value == ClinicRole.doctor;

      if (isDoctor) {
        final entries = controller.pageEntries;
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Patient Queue',
                    style: AppTextStyles.h1Mobile.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View patients assigned to you and manage their consultation progress.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const QueueToolbar(
                showFilter: true,
                hint: 'Search name, ID or queue number',
              ),
              const SizedBox(height: Dimensions.pageSectionGap),
              const Text(
                'Patients Awaiting Consultation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: Dimensions.sectionContentGap),
              // =========================================================================
              // [FUTURE LAUNCH CONDITION / NO PATIENTS WAITING TOGGLE]:
              // Jab future me project launch hoga aur queue me koi patient nahi hoga:
              // - IF FALSE -> normal patient cards show honge (current behavior)
              // - IF TRUE  -> "No patients waiting" empty state (chairs + clock) show hoga
              //
              // const bool forceNoPatientsWaiting = false; // Set to true to preview or use (entries.isEmpty)
              // if (forceNoPatientsWaiting) ...[
              //   const NoPatientsWaitingEmptyState(),
              // ] else ...[
              //   // Normal patient cards & actions
              // ]
              // =========================================================================
              if (entries.isEmpty)
                const QueueEmptyState()
              else ...[
                for (final e in entries) ...[
                  DoctorPatientQueueCard(
                    entry: e,
                    onStart: () => controller.startConsultation(e),
                  ),
                  const SizedBox(height: Dimensions.sectionContentGap),
                ],
                const SizedBox(height: 8),
                const DoctorPagination(isMobile: true),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.callNextPatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Call Next Patient',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        );
      }

      final entries = controller.filtered;
      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
          children: [
            const QueuePageHeader(screenType: LayoutType.mobile),
            const SizedBox(height: Dimensions.sectionContentGap),
            QueueSummary(queue: queue, screenType: LayoutType.mobile),
            const SizedBox(height: Dimensions.sectionContentGap),
            const QueueToolbar(
              showFilter: false,
              hint: 'Search patient or queue number',
            ),
            const SizedBox(height: Dimensions.sectionContentGap),
            Text(
              'Today’s queue',
              style: AppTextStyles.h2Mobile.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: Dimensions.sectionContentGap),
            if (entries.isEmpty)
              const QueueEmptyState()
            else
              CardGrid(
                children: [
                  for (final e in entries)
                    QueueCard(
                      entry: e,
                      menu: QueueRowMenu(entry: e),
                    ),
                ],
              ),
            const SizedBox(height: Dimensions.sectionContentGap),
            AppButton.primary(
              label: 'Add Walk-in',
              onPressed: controller.addWalkIn,
              expand: true,
            ),
          ],
        ),
      );
    });
  }
}
