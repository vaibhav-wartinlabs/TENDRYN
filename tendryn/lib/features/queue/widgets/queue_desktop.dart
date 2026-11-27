import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/features/queue/widgets/queue_page_header.dart';
import 'package:tendryn/features/queue/widgets/queue_summary.dart';
import 'package:tendryn/features/queue/widgets/queue_table.dart';
import 'package:tendryn/features/queue/widgets/queue_toolbar.dart';

/// Desktop arrangement:
/// - In Doctor mode: Header ("My Patient Queue" + "Call Next Patient"), search + filter,
///   then "Patients Awaiting Consultation" table with its footer.
/// - In Receptionist mode: Header, summary cards, search + filter, today's queue table.
class QueueDesktop extends GetView<QueueController> {
  const QueueDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final queue = controller.queue.value;
      if (queue == null) return const SizedBox.shrink();

      final isDoctor = Get.isRegistered<RoleController>() &&
          RoleController.to.currentRole.value == ClinicRole.doctor;

      if (isDoctor) {
        return ListView(
          padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Patient Queue',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View patients assigned to you and manage their consultation progress.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                DoctorCallNextPatientButton(
                  onPressed: controller.callNextPatient,
                  customIcon: const DoctorCallIcon(),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spaceLg),
            const QueueToolbar(
              showFilter: true,
              hint: 'Search name, ID or queue number',
            ),
            const SizedBox(height: Dimensions.spaceLg),
            const DoctorQueueTableWidget(),
          ],
        );
      }

      return ListView(
        padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
        children: [
          const QueuePageHeader(screenType: LayoutType.desktop),
          const SizedBox(height: Dimensions.spaceLg),
          QueueSummary(queue: queue, screenType: LayoutType.desktop),
          const SizedBox(height: Dimensions.spaceLg),
          const QueueToolbar(),
          const SizedBox(height: Dimensions.spaceLg),
          const QueueTable(),
          const QueuePagination(),
        ],
      );
    });
  }
}
