import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/features/appointments/widgets/appointments_common.dart';
import 'package:tendryn/widgets/common/app_button.dart';

/// Phone: compact heading, summary cards, view toggle with a filter button,
/// the day strip, appointment cards and the two actions at the end.
class AppointmentsMobile extends GetView<AppointmentsController> {
  const AppointmentsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
      children: [
        Semantics(header: true, child: Text('Appointments', style: AppTextStyles.h1Mobile.copyWith(color: scheme.onSurface))),
        const SizedBox(height: Dimensions.spaceXs),
        Obx(() => Text('${controller.selectedDateLabel} · day list', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant))),
        const SizedBox(height: Dimensions.sectionContentGap),
        const AppointmentsSummary(screenType: LayoutType.mobile),
        const SizedBox(height: Dimensions.sectionContentGap),
        const Row(
          spacing: Dimensions.statusX,
          children: [
            Expanded(child: ToolbarBar(child: AppointmentsModeToggle(expand: true, spacing: 12))),
            PractitionerFilterButton(),
          ],
        ),
        const SizedBox(height: Dimensions.sectionContentGap),
        Obx(() => controller.mode.value == AppointmentsMode.doctor ? const Padding(padding: EdgeInsets.only(bottom: Dimensions.sectionContentGap), child: DayStrip(screenType: LayoutType.mobile)) : const SizedBox.shrink()),
        const AppointmentList(),
        const SizedBox(height: Dimensions.spaceLg),
        AppButton.primary(label: 'Book appointment', onPressed: controller.bookAppointment, expand: true),
        const SizedBox(height: Dimensions.spaceSm),
        AppButton.secondary(label: 'Manage availability', onPressed: controller.manageAvailability, expand: true),
      ],
    );
  }
}
