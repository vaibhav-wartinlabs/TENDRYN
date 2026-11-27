import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/connectivity_sync_chip.dart';

const _pageSubtitle =
    'Manage today’s arrivals and see each patient’s place in care.';
const _addWalkInWidth = 178.0;

/// Top of the Queue page. Desktop: heading, date selector and Add Walk-in on
/// one row. Tablet: date + sync chip above the heading, Add Walk-in beside it.
/// Mobile: compact heading with a date and count line (Add Walk-in sits at the
/// end of the list).
class QueuePageHeader extends GetView<QueueController> {
  const QueuePageHeader({super.key, required this.screenType});

  final LayoutType screenType;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimensions.spaceXs,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Queue',
            style:
                (screenType == LayoutType.mobile
                        ? AppTextStyles.h1Mobile
                        : AppTextStyles.h1)
                    .copyWith(color: scheme.onSurface),
          ),
        ),
        Text(
          _pageSubtitle,
          style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
    final addWalkIn = SizedBox(
      width: _addWalkInWidth,
      child: AppButton.primary(
        label: 'Add Walk-in',
        onPressed: controller.addWalkIn,
        expand: true,
      ),
    );

    switch (screenType) {
      case LayoutType.desktop:
        return Row(
          spacing: Dimensions.spaceMd,
          children: [
            Expanded(child: heading),
            const QueueDateSelector(),
            addWalkIn,
          ],
        );
      case LayoutType.tablet:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.dateLabel,
                      style: AppTextStyles.label.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
                const ConnectivitySyncChip(),
              ],
            ),
            Row(
              spacing: Dimensions.spaceMd,
              children: [
                Expanded(child: heading),
                addWalkIn,
              ],
            ),
          ],
        );
      case LayoutType.mobile:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Queue',
                style: AppTextStyles.h1Mobile.copyWith(color: scheme.onSurface),
              ),
            ),
            Obx(
              () => Text(
                '${controller.shortDateLabel} · ${controller.queue.value?.patientsWaiting ?? 0} patients currently in queue',
                style: AppTextStyles.label.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
    }
  }
}

/// Bordered date box; tapping it picks another day (today and the past 30 days).
class QueueDateSelector extends GetView<QueueController> {
  const QueueDateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(Dimensions.radiusControl);
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: scheme.outline,
          width: Dimensions.strokeDivider,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: () => _pick(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.controlX,
            vertical: Dimensions.controlY,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Dimensions.componentGap,
            children: [
              Icon(
                AppIcons.calendarDays,
                size: Dimensions.iconSize,
                color: scheme.onSurface,
              ),
              Obx(
                () => Text(
                  controller.dateLabel,
                  style: AppTextStyles.label.copyWith(color: scheme.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: DateUtils.dateOnly(controller.selectedDate.value),
      firstDate: today.subtract(const Duration(days: 30)),
      lastDate: today,
    );
    if (picked != null) controller.selectDate(picked);
  }
}
