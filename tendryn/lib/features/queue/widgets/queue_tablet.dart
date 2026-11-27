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

/// Tablet arrangement:
/// - In Doctor mode: Header ("My Patient Queue" + "Call Next Patient"), search + filter,
///   "Patients Awaiting Consultation" header, 2-column grid of patient cards, pagination.
/// - In Receptionist mode: Header, summary cards, search + filter, 2-column queue cards.
class QueueTablet extends GetView<QueueController> {
  const QueueTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final queue = controller.queue.value;
      if (queue == null) return const SizedBox.shrink();

      final isDoctor = Get.isRegistered<RoleController>() &&
          RoleController.to.currentRole.value == ClinicRole.doctor;

      if (isDoctor) {
        final entries = controller.doctorTabletFiltered;
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Patient Queue',
                          style: AppTextStyles.h2.copyWith(
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
                  ),
                  DoctorCallNextPatientButton(
                    onPressed: controller.callNextPatient,
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.pageSectionGap),
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
              const SizedBox(height: 16),
              // =========================================================================
              // [FUTURE LAUNCH CONDITION / NO PATIENTS WAITING TOGGLE]:
              // Jab future me project launch hoga aur queue me koi patient nahi hoga:
              // - IF FALSE -> normal patient list show hogi (current behavior)
              // - IF TRUE  -> "No patients waiting" empty state (chairs + clock) show hoga
              //
              // const bool forceNoPatientsWaiting = false; // Set to true to preview or use (entries.isEmpty)
              // if (forceNoPatientsWaiting) ...[
              //   const NoPatientsWaitingEmptyState(),
              // ] else ...[
              //   // Normal patient cards
              // ]
              // =========================================================================
              if (entries.isEmpty)
                const QueueEmptyState()
              else ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 16) / 2;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final e in entries)
                          SizedBox(
                            width: itemWidth,
                            child: DoctorPatientQueueCard(
                              entry: e,
                              showBadge: e.patient != 'Sipho Dlamini',
                              onStart: () => controller.startConsultation(e),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: Dimensions.sectionContentGap),
                const DoctorPagination(),
              ],
            ],
          ),
        );
      }

      final entries = controller.filtered;
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
            const QueuePageHeader(screenType: LayoutType.tablet),
            const SizedBox(height: Dimensions.spaceLg),
            QueueSummary(queue: queue, screenType: LayoutType.tablet),
            const SizedBox(height: Dimensions.pageSectionGap),
            const QueueToolbar(),
            const SizedBox(height: Dimensions.pageSectionGap),
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
                      wide: true,
                      menu: QueueRowMenu(entry: e),
                    ),
                ],
              ),
          ],
        ),
      );
    });
  }
}
