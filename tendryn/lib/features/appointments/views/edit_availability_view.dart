import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/appointments/controllers/availability_controller.dart';
import 'package:tendryn/features/appointments/controllers/edit_availability_controller.dart';
import 'package:tendryn/features/appointments/models/availability_schedule.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/app_shell.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

/// Edit availability: working hours, leave and public holidays for the chosen
/// practitioner, ending in Cancel / Save availability. Desktop sits inside the
/// navigation shell; tablet and phone are focused pages without the bottom bar.
class EditAvailabilityView extends GetView<EditAvailabilityController> {
  const EditAvailabilityView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(controller: controller),
      tablet: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(children: [const TabletHeader(), Expanded(child: _Tablet(controller: controller))]),
        ),
      ),
      desktop: AppShell(route: AppRoutes.appointments, child: _Desktop(controller: controller)),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop
// ---------------------------------------------------------------------------

class _Desktop extends StatelessWidget {
  const _Desktop({required this.controller});

  final EditAvailabilityController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
        children: [
          _BackPill(onTap: controller.cancel),
          const SizedBox(height: Dimensions.pageSectionGap),
          Semantics(header: true, child: Text('Edit availability', style: AppTextStyles.h1.copyWith(color: scheme.onSurface))),
          const SizedBox(height: Dimensions.spaceXs),
          Text('${controller.practitioner.name} · update hours, leave, and public holidays.', style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: Dimensions.pageSectionGap),
          _FormCard(controller: controller, wide: true),
          const SizedBox(height: Dimensions.pageSectionGap),
          _Actions(controller: controller, gap: Dimensions.spaceMd),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet (no dedicated frame: the desktop form, stacked when narrow)
// ---------------------------------------------------------------------------

class _Tablet extends StatelessWidget {
  const _Tablet({required this.controller});

  final EditAvailabilityController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.pageMarginDesktop,
              vertical: Dimensions.spaceMd,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(bottom: BorderSide(color: scheme.outline)),
            ),
            child: Row(
              spacing: 12,
              children: [
                _BackButton(onTap: controller.cancel),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(header: true, child: Text('Edit availability', style: AppTextStyles.h2.copyWith(color: scheme.onSurface))),
                      Text('${controller.practitioner.name} · update hours, leave, and public holidays.', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.pageMarginDesktop,
                Dimensions.spaceMd,
                Dimensions.pageMarginDesktop,
                Dimensions.spaceMd,
              ),
              children: [
                LayoutBuilder(builder: (context, c) => _FormCard(controller: controller, wide: c.maxWidth >= 720)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(top: BorderSide(color: scheme.outline)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.pageMarginDesktop,
              vertical: Dimensions.spaceMd,
            ),
            child: _Actions(controller: controller, gap: Dimensions.spaceSm),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile
// ---------------------------------------------------------------------------

class _Mobile extends StatelessWidget {
  const _Mobile({required this.controller});

  final EditAvailabilityController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = controller;
    final p = c.practitioner;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: Dimensions.mobileHeaderHeight,
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(bottom: BorderSide(color: scheme.outline)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginMobile),
                child: Row(
                  spacing: Dimensions.spaceSm,
                  children: [
                    _BackButton(onTap: c.cancel),
                    Expanded(child: Semantics(header: true, child: Text('Edit Availability', style: AppTextStyles.h2Mobile.copyWith(color: scheme.onSurface)))),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, 0, Dimensions.pageMarginMobile, Dimensions.spaceMd),
                children: [
                  Container(
                    height: 80,
                    padding: const EdgeInsets.all(Dimensions.spaceMd),
                    decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(Dimensions.radius), border: Border.all(color: scheme.outline)),
                    child: Row(
                      spacing: 12,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: scheme.surface, shape: BoxShape.circle),
                          child: Text(p.initials, style: AppTextStyles.label.copyWith(color: scheme.primary)),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 2,
                            children: [
                              Text(p.name, style: AppTextStyles.h3Mobile.copyWith(color: scheme.onSurface)),
                              Text(p.summary, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Icon(AppIcons.circleCheck, size: 20, color: scheme.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.spaceMd),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(19, 17, 19, 19),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Working hours', style: AppTextStyles.h3.copyWith(color: scheme.onSurface)),
                        const SizedBox(height: Dimensions.spaceXs),
                        Text(AvailabilityController.slotLabel, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: Dimensions.pageSectionGap),
                        _HoursEditor(controller: c),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(19, 17, 19, 19),
                    child: _LeaveEditor(controller: c, mobile: true),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(19, 17, 19, 19),
                    child: _HolidaysBlock(gap: 10),
                  ),
                  const SizedBox(height: Dimensions.spaceMd),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(top: BorderSide(color: scheme.outline)),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.pageMarginMobile,
                    vertical: Dimensions.spaceSm + 4,
                  ),
                  child: _Actions(controller: c, gap: Dimensions.spaceSm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

/// Working hours on the left, a divider, leave and public holidays on the right
/// (stacked when [wide] is false).
class _FormCard extends StatelessWidget {
  const _FormCard({required this.controller, required this.wide});

  final EditAvailabilityController controller;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hours = Padding(
      padding: const EdgeInsets.fromLTRB(19, 17, 19, 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Working hours', style: AppTextStyles.h3.copyWith(color: scheme.onSurface)),
          const SizedBox(height: 12),
          _HoursEditor(controller: controller),
        ],
      ),
    );
    final side = Padding(
      padding: EdgeInsets.fromLTRB(wide ? 27 : 19, wide ? 19 : 17, 27, 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LeaveEditor(controller: controller, mobile: false),
          const SizedBox(height: 43),
          _HolidaysBlock(gap: 29),
        ],
      ),
    );
    return Container(
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(Dimensions.radius), border: Border.all(color: scheme.outline)),
      child: wide
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 579, child: hours),
                  VerticalDivider(width: 1, thickness: 1, color: scheme.outline),
                  Expanded(flex: 404, child: side),
                ],
              ),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [hours, Divider(height: 1, thickness: 1, color: scheme.outline), side]),
    );
  }
}

/// Monday–Friday rows with tappable start and end times; weekends read Closed.
class _HoursEditor extends StatelessWidget {
  const _HoursEditor({required this.controller});

  final EditAvailabilityController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final days = controller.days;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 2,
        children: [
          for (final (i, d) in days.indexed)
            Container(
              height: 56,
              padding: const EdgeInsets.fromLTRB(14, 0, 15, 0),
              decoration: BoxDecoration(color: i.isOdd ? AppColors.gridHeader : scheme.surface, borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  Expanded(child: Text(d.day, style: AppTextStyles.label.copyWith(color: scheme.onSurface))),
                  _TimeChip(label: 'Start time, ${d.day}', value: d.start, width: 72, options: controller.startOptions(i), onPicked: (t) => controller.setStart(i, t)),
                  const SizedBox(width: 10),
                  _TimeChip(label: 'End time, ${d.day}', value: d.end, width: 81, options: controller.endOptions(i), onPicked: (t) => controller.setEnd(i, t)),
                ],
              ),
            ),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: days.length.isEven ? scheme.surface : AppColors.gridHeader, borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Saturday / Sunday', style: AppTextStyles.label.copyWith(color: scheme.onSurface))),
                Expanded(child: Text('Closed', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant))),
              ],
            ),
          ),
        ],
      );
    });
  }
}

/// A 30px time button; opens the half-hour times it may take.
class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.value, required this.width, required this.options, required this.onPicked});

  final String label;
  final String value;
  final double width;
  final List<String> options;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      tooltip: label,
      padding: EdgeInsets.zero,
      color: scheme.surface,
      elevation: 4,
      initialValue: value,
      constraints: const BoxConstraints(maxHeight: 320),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusControl), side: BorderSide(color: scheme.outline)),
      onSelected: onPicked,
      itemBuilder: (_) => [for (final t in options) PopupMenuItem(value: t, height: 40, child: Text(t, style: AppTextStyles.label))],
      child: Container(
        width: width,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(Dimensions.radiusControl), border: Border.all(color: scheme.outline)),
        child: Text(value, style: AppTextStyles.label.copyWith(color: scheme.primary)),
      ),
    );
  }
}

/// Leave date and duration. The phone variant adds the "Full day" pill beside the title.
class _LeaveEditor extends StatelessWidget {
  const _LeaveEditor({required this.controller, required this.mobile});

  final EditAvailabilityController controller;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = controller;
    Text label(String text) => Text(text, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final duration = c.leaveDuration.value;
          return Row(
            children: [
              Expanded(child: Text('Leave and blocked time', style: (mobile ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600) : AppTextStyles.h3).copyWith(color: scheme.onSurface))),
              if (mobile)
                Container(
                  width: 77,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.warningSoftBackground, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
                  child: Text(duration, style: AppTextStyles.caption.copyWith(color: AppColors.warningSoftText)),
                ),
            ],
          );
        }),
        SizedBox(height: mobile ? 22 : 20),
        label('Leave date'),
        const SizedBox(height: 13),
        Obx(
          () => _Select(
            text: c.leaveDateLabel,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(context: context, initialDate: c.leaveDate.value, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 2));
              if (picked != null) c.setLeaveDate(picked);
            },
          ),
        ),
        const SizedBox(height: 13),
        label('Duration'),
        const SizedBox(height: 13),
        Obx(
          () => PopupMenuButton<String>(
            tooltip: 'Duration',
            padding: EdgeInsets.zero,
            color: scheme.surface,
            elevation: 4,
            position: PopupMenuPosition.under,
            initialValue: c.leaveDuration.value,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusControl), side: BorderSide(color: scheme.outline)),
            onSelected: c.setLeaveDuration,
            itemBuilder: (_) => [for (final d in AvailabilitySchedule.leaveDurations) PopupMenuItem(value: d, height: Dimensions.touchTarget, child: Text(d, style: AppTextStyles.label))],
            child: _Select(text: c.leaveDuration.value),
          ),
        ),
      ],
    );
  }
}

/// 44px box with centred brand-coloured text, used for the date and duration.
class _Select extends StatelessWidget {
  const _Select({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(Dimensions.radiusControl);
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: scheme.outline)),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: SizedBox(height: 44, child: Center(child: Text(text, style: AppTextStyles.label.copyWith(color: scheme.primary)))),
      ),
    );
  }
}

class _HolidaysBlock extends StatelessWidget {
  const _HolidaysBlock({required this.gap});

  final double gap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: [
        Text('Public holidays', style: AppTextStyles.h3.copyWith(color: scheme.onSurface)),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.gridHeader, borderRadius: BorderRadius.circular(Dimensions.radiusControl)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text('Heritage Day', style: AppTextStyles.label.copyWith(color: scheme.onSurface)),
              Text('24 September · closed', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
        Text('Saving updates the free-slot view for this practitioner.', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

/// Cancel and Save availability, equal width, 48px.
class _Actions extends StatelessWidget {
  const _Actions({required this.controller, required this.gap});

  final EditAvailabilityController controller;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: gap,
      children: [
        Expanded(child: SizedBox(height: Dimensions.buttonMinHeight, child: OutlinedButton(onPressed: controller.cancel, child: const Text('Cancel')))),
        Expanded(
          child: Obx(() => SizedBox(height: Dimensions.buttonMinHeight, child: FilledButton(onPressed: controller.isSaving.value ? null : controller.save, child: const Text('Save availability')))),
        ),
      ],
    );
  }
}

class _BackPill extends StatelessWidget {
  const _BackPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Dimensions.spaceSm,
              children: [
                Icon(AppIcons.arrowLeft, size: Dimensions.iconSize, color: scheme.primary),
                Text('Back to availability', style: AppTextStyles.label.copyWith(color: scheme.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Back',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          onTap: onTap,
          child: SizedBox.square(
            dimension: Dimensions.touchTarget,
            child: Center(
              child: Container(
                width: Dimensions.touchTarget,
                height: Dimensions.touchTarget,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  border: Border.all(color: scheme.outline),
                ),
                child: Icon(AppIcons.chevronLeft, size: 20, color: scheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
