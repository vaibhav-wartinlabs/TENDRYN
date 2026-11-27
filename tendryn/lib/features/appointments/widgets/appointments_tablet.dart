import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/features/appointments/widgets/appointments_common.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/connectivity_sync_chip.dart';

/// Tablet: date and sync chip over the heading, three summary cards, the view
/// toggle with a filter button, the day strip and the day's appointment cards.
class AppointmentsTablet extends GetView<AppointmentsController> {
  const AppointmentsTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final heading = Semantics(header: true, child: Text('Appointments', style: AppTextStyles.h1.copyWith(color: scheme.onSurface)));
    final book = AppButton.primary(label: 'Book appointment', onPressed: controller.bookAppointment, expand: true);
    final manage = AppButton.secondary(label: 'Manage availability', onPressed: controller.manageAvailability, expand: true);
    return ListView(
      padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginTablet, Dimensions.pageMarginTablet, Dimensions.pageMarginTablet, Dimensions.pageMarginTablet),
      children: [
        Row(
          children: [
            Expanded(child: Obx(() => Text(controller.selectedDateLabel.replaceFirst(' ', ', '), style: AppTextStyles.label.copyWith(color: scheme.primary)))),
            const ConnectivitySyncChip(),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Dimensions.statusX,
                children: [
                  heading,
                  Row(spacing: Dimensions.statusX, children: [Expanded(child: book), Expanded(child: manage)]),
                ],
              );
            }
            return Row(
              spacing: Dimensions.statusX,
              children: [
                Expanded(child: heading),
                SizedBox(width: 172, child: book),
                SizedBox(width: 172, child: manage),
              ],
            );
          },
        ),
        const SizedBox(height: Dimensions.spaceLg),
        const AppointmentsSummary(screenType: LayoutType.tablet),
        const SizedBox(height: Dimensions.pageSectionGap),
        const Row(
          children: [
            ToolbarBar(child: AppointmentsModeToggle()),
            Spacer(),
            PractitionerFilterButton(),
          ],
        ),
        const SizedBox(height: Dimensions.pageSectionGap),
        const DayStrip(screenType: LayoutType.tablet),
        const SizedBox(height: Dimensions.spaceMd),
        const AppointmentList(wide: true),
      ],
    );
  }
}
