import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/appointments/controllers/reschedule_controller.dart';
import 'package:tendryn/features/appointments/models/appointment_entry.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_shell.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

const _note = 'Only free slots within working hours are offered. The original visit remains until you save.';

enum _Layout { drawer, tablet, mobile }

/// Reschedule appointment as a page: tablet and phone (no bottom bar). On
/// desktop the Appointment Details page opens [showRescheduleDrawer] instead.
class RescheduleView extends GetView<RescheduleController> {
  const RescheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(controller: controller),
      tablet: Scaffold(
        backgroundColor: AppColors.backgroundApp,
        body: SafeArea(
          bottom: false,
          child: Column(children: [const TabletHeader(), Expanded(child: _Wide(controller: controller))]),
        ),
      ),
      desktop: AppShell(route: AppRoutes.appointments, child: _Wide(controller: controller)),
    );
  }
}

/// Opens the drawer over Appointment Details (desktop). Completes with the
/// rescheduled [AppointmentEntry], or null when the original is kept.
Future<AppointmentEntry?> showRescheduleDrawer(BuildContext context, AppointmentEntry entry) {
  final controller = RescheduleController(entry);
  return showGeneralDialog<AppointmentEntry>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x850F1F1D),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, _, _) => _Drawer(controller: controller),
    transitionBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

// ---------------------------------------------------------------------------
// Desktop drawer
// ---------------------------------------------------------------------------

class _Drawer extends StatelessWidget {
  const _Drawer({required this.controller});

  final RescheduleController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: AppColors.backgroundSurface,
        child: SizedBox(
          width: Dimensions.drawerWidth,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 22, 20, 16),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderDefault))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(header: true, child: Text('Reschedule appointment', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary))),
                          const SizedBox(height: 4),
                          Text('Choose a free slot for ${c.patient}.', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(tooltip: 'Close', onPressed: c.keepOriginal, icon: const Icon(AppIcons.close, size: Dimensions.iconSize, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.spaceLg),
                  child: _Form(controller: c, layout: _Layout.drawer),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceLg, vertical: Dimensions.spaceMd),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderDefault))),
                child: _Actions(controller: c, keepLabel: 'Keep original', saveLabel: 'Save new time', keepFlex: 150, saveFlex: 262),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet / desktop page
// ---------------------------------------------------------------------------

class _Wide extends StatelessWidget {
  const _Wide({required this.controller});

  final RescheduleController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.pageMarginDesktop,
              vertical: Dimensions.spaceMd,
            ),
            decoration: const BoxDecoration(
              color: AppColors.backgroundSurface,
              border: Border(
                bottom: BorderSide(color: AppColors.borderDefault),
              ),
            ),
            child: Row(
              spacing: 12,
              children: [
                _BackButton(onTap: c.keepOriginal),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Semantics(header: true, child: Text('Reschedule appointment', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary))),
                      Text('Choose a free slot for ${c.patient}.', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.pageMarginDesktop,
                Dimensions.spaceMd,
                Dimensions.pageMarginDesktop,
                Dimensions.spaceMd,
              ),
              child: _Form(controller: c, layout: _Layout.tablet),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSurface,
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
          boxShadow: [
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
            child: _Actions(
              controller: c,
              keepLabel: 'Keep Original',
              saveLabel: 'Save New Time',
              keepFlex: 1,
              saveFlex: 1,
              gap: Dimensions.spaceMd,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Phone
// ---------------------------------------------------------------------------

class _Mobile extends StatelessWidget {
  const _Mobile({required this.controller});

  final RescheduleController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: Dimensions.mobileHeaderHeight,
              decoration: const BoxDecoration(
                color: AppColors.backgroundSurface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginMobile),
                child: Row(
                  spacing: Dimensions.spaceSm,
                  children: [
                    _BackButton(onTap: c.keepOriginal),
                    Expanded(child: Semantics(header: true, child: Text('Reschedule appointment', style: AppTextStyles.h2Mobile.copyWith(color: AppColors.textPrimary)))),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, 0, Dimensions.pageMarginMobile, Dimensions.spaceMd),
                child: _Form(controller: c, layout: _Layout.mobile),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginMobile, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.backgroundSurface,
                border: Border(top: BorderSide(color: AppColors.borderDefault)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: _Actions(controller: c, keepLabel: 'Keep Original', saveLabel: 'Save New Time', keepFlex: 169, saveFlex: 184, gap: 8),
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

/// Keep original | Save new time. Save is blocked while a save is running, so
/// it can't be submitted twice; without a chosen slot it shows a message.
class _Actions extends StatelessWidget {
  const _Actions({required this.controller, required this.keepLabel, required this.saveLabel, required this.keepFlex, required this.saveFlex, this.gap = 12});

  final RescheduleController controller;
  final String keepLabel;
  final String saveLabel;
  final int keepFlex;
  final int saveFlex;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Obx(
      () => Row(
        spacing: gap,
        children: [
          Expanded(flex: keepFlex, child: AppButton.secondary(label: keepLabel, onPressed: c.isSaving.value ? null : c.keepOriginal, expand: true)),
          Expanded(flex: saveFlex, child: AppButton.primary(label: saveLabel, onPressed: c.save, isLoading: c.isSaving.value, expand: true)),
        ],
      ),
    );
  }
}

/// Patient, practitioner, date, slots and the change note.
class _Form extends StatelessWidget {
  const _Form({required this.controller, required this.layout});

  final RescheduleController controller;
  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final mobile = layout == _Layout.mobile;
    final drawer = layout == _Layout.drawer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PatientCard(controller: c, large: !drawer),
        SizedBox(height: drawer ? 21 : (mobile ? Dimensions.spaceMd : 24)),
        _Field(
          label: 'Practitioner',
          child: Obx(
            () => PopupMenuButton<String>(
              tooltip: 'Practitioner',
              padding: EdgeInsets.zero,
              color: AppColors.backgroundSurface,
              elevation: 4,
              position: PopupMenuPosition.under,
              initialValue: c.practitioner.value,
              constraints: BoxConstraints(minWidth: drawer ? 424 : 280),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusControl), side: const BorderSide(color: AppColors.borderDefault)),
              onSelected: c.setPractitioner,
              itemBuilder: (_) => [for (final p in RescheduleController.practitioners) PopupMenuItem(value: p, height: Dimensions.touchTarget, child: Text(p, style: AppTextStyles.body))],
              child: _Select(text: c.practitioner.value),
            ),
          ),
        ),
        SizedBox(height: drawer ? 21 : Dimensions.spaceMd),
        _Field(
          label: 'Date',
          child: Obx(
            () => _Select(
              text: c.dateLabel,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: c.date.value,
                  firstDate: RescheduleController.firstDate,
                  lastDate: RescheduleController.lastDate,
                  selectableDayPredicate: (d) => d.weekday <= DateTime.friday,
                );
                if (picked != null) c.setDate(picked);
              },
            ),
          ),
        ),
        SizedBox(height: drawer ? 21 : Dimensions.spaceMd),
        Text('Available slots', style: AppTextStyles.label.copyWith(color: mobile ? AppColors.textPrimary : AppColors.textSecondary)),
        SizedBox(height: mobile ? 8 : 12),
        _Slots(controller: c, layout: layout),
        Obx(
          () => c.missingSlot.value
              ? Padding(padding: const EdgeInsets.only(top: 8), child: Text('Choose a time slot to save the new time.', style: AppTextStyles.caption.copyWith(color: AppColors.safetyCriticalText)))
              : const SizedBox.shrink(),
        ),
        if (!mobile) ...[
          SizedBox(height: drawer ? 21 : 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(Dimensions.radiusControl)),
            child: Text(_note, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ],
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.controller, required this.large});

  final RescheduleController controller;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(Dimensions.radiusControl), border: Border.all(color: AppColors.brandPrimary)),
      child: Row(
        spacing: 12,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.backgroundSurface, shape: BoxShape.circle),
            child: Text(c.initials, style: AppTextStyles.label.copyWith(color: AppColors.brandPrimary)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(c.patient, maxLines: 1, overflow: TextOverflow.ellipsis, style: (large ? AppTextStyles.bodyMedium : AppTextStyles.label).copyWith(color: AppColors.textPrimary)),
                Text(c.patientLine, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(AppIcons.circleCheck, size: 20, color: AppColors.brandPrimary),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 6,
    children: [Text(label, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)), child],
  );
}

/// 48px field with brand border and a chevron, for practitioner and date.
class _Select extends StatelessWidget {
  const _Select({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Dimensions.radiusControl);
    return Material(
      color: AppColors.backgroundSurface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: const BorderSide(color: AppColors.brandPrimary)),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: Dimensions.touchTarget,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary))),
              const Icon(AppIcons.chevronDown, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Time choices. Drawer and tablet list free times only; the phone also shows
/// taken times as disabled chips.
class _Slots extends StatelessWidget {
  const _Slots({required this.controller, required this.layout});

  final RescheduleController controller;
  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final mobile = layout == _Layout.mobile;
    return Obx(() {
      final selected = c.selectedTime.value;
      // Read the observables here so the grid follows practitioner and date.
      final times = [for (final t in RescheduleController.candidateTimes) if (mobile || c.isFree(t)) t];
      if (c.freeTimes.isEmpty) {
        return Text('No free slots for this practitioner on this date.', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary));
      }
      return LayoutBuilder(
        builder: (context, box) {
          final columns = switch (layout) {
            _Layout.drawer => 3,
            _Layout.tablet => 4,
            _Layout.mobile => 4,
          };
          final gap = mobile ? ((box.maxWidth - columns * 72) / (columns - 1)).clamp(0.0, 23.0) : 8.0;
          final width = mobile ? 72.0 : (box.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: mobile ? 8 : 12,
            children: [
              for (final t in times)
                _SlotChip(time: t, width: width, compact: mobile, free: c.isFree(t), selected: t == selected, onTap: () => c.selectTime(t)),
            ],
          );
        },
      );
    });
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.time, required this.width, required this.compact, required this.free, required this.selected, required this.onTap});

  final String time;
  final double width;

  /// Phone: 64×32 chip inside a 72×48 touch area.
  final bool compact;
  final bool free;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    BoxBorder? border;
    if (compact) {
      background = selected ? AppColors.brandPrimary : (free ? AppColors.brandTint : AppColors.backgroundApp);
      foreground = selected ? AppColors.textOnBrand : (free ? AppColors.brandPrimary : AppColors.textDisabled);
    } else {
      background = selected ? AppColors.brandTint : AppColors.backgroundSurface;
      foreground = AppColors.brandPrimary;
      border = Border.all(color: AppColors.borderDefault);
    }
    final chip = Container(
      width: compact ? 64 : width,
      height: compact ? 32 : 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, border: border, borderRadius: BorderRadius.circular(compact ? 3 : Dimensions.radiusControl)),
      child: Text(time, style: AppTextStyles.label.copyWith(color: foreground)),
    );
    return Semantics(
      button: true,
      selected: selected,
      enabled: free,
      label: free ? time : '$time, unavailable',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: free ? onTap : null,
        child: compact ? SizedBox(width: width, height: Dimensions.touchTarget, child: Center(child: chip)) : chip,
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: const Icon(
                AppIcons.chevronLeft,
                size: Dimensions.iconSize,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
