import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/appointments/controllers/appointment_detail_controller.dart';

/// Wording and action of one confirmation shown over Appointment Details.
class _Spec {
  const _Spec({required this.title, required this.body, required this.keep, required this.keepMobile, required this.confirm, required this.confirmMobile, required this.danger, required this.onConfirm});

  final String title;
  final String body;
  final String keep;
  final String keepMobile;
  final String confirm;
  final String confirmMobile;

  /// Red confirm button (cancel) instead of the brand one (no-show).
  final bool danger;
  final void Function(AppointmentDetailController) onConfirm;
}

final _cancel = _Spec(
  title: 'Cancel appointment?',
  body: 'This will mark the visit as cancelled. No other appointment will be changed.',
  keep: 'Keep appointment',
  keepMobile: 'Keep Appointment',
  confirm: 'Cancel appointment',
  confirmMobile: 'Cancel appointment',
  danger: true,
  onConfirm: (c) => c.confirmCancel(),
);

final _noShow = _Spec(
  title: 'Mark as no-show?',
  body: 'Confirm that the patient did not attend this booked visit.',
  keep: 'Keep booked',
  keepMobile: 'Keep Booked',
  confirm: 'Mark no-show',
  confirmMobile: 'Mark No Show',
  danger: false,
  onConfirm: (c) => c.confirmNoShow(),
);

/// Cancel appointment confirmation. Nothing changes until the user confirms.
Future<void> showCancelAppointment(BuildContext context, AppointmentDetailController controller) => _show(context, controller, _cancel);

/// Mark as no-show confirmation. Nothing changes until the user confirms.
Future<void> showNoShowAppointment(BuildContext context, AppointmentDetailController controller) => _show(context, controller, _noShow);

/// A centred modal on tablet and desktop, a bottom sheet on phones.
Future<void> _show(BuildContext context, AppointmentDetailController controller, _Spec spec) {
  if (ResponsiveHelper.isMobile(context)) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundSurface,
      barrierColor: const Color(0xA30F1F1D),
      showDragHandle: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius))),
      builder: (_) => _Sheet(controller: controller, spec: spec),
    );
  }
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x850F1F1D),
    builder: (_) => _Modal(controller: controller, spec: spec),
  );
}

/// `Tuesday 29 Sep · 11:00 · Dr Thandi Maseko`
String _when(AppointmentDetailController c) {
  final parts = c.dateLabel.split(' ');
  return '${parts[0]} ${parts[1]} ${parts[2].substring(0, 3)} · ${c.entry.time} · ${c.entry.practitioner}';
}

class _Modal extends StatelessWidget {
  const _Modal({required this.controller, required this.spec});

  final AppointmentDetailController controller;
  final _Spec spec;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Dialog(
      backgroundColor: AppColors.backgroundSurface,
      elevation: 0,
      insetPadding: const EdgeInsets.all(Dimensions.spaceMd),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radius), side: const BorderSide(color: AppColors.borderDefault)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(23),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(header: true, child: Text(spec.title, style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary))),
              const SizedBox(height: 10),
              // Two lines tall in every variant, so the summary sits at the same height.
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Text(spec.body, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: Dimensions.pageSectionGap),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.gridHeader, borderRadius: BorderRadius.circular(Dimensions.radiusControl)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(c.patient, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                    Text(_when(c), style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                    Text(c.visitType, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              _Buttons(controller: c, spec: spec, keepLabel: spec.keep, confirmLabel: spec.confirm, keepFlex: 212, confirmFlex: 228, gap: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.controller, required this.spec});

  final AppointmentDetailController controller;
  final _Spec spec;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.borderDefault, borderRadius: BorderRadius.circular(4)))),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Dimensions.spaceMd,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Semantics(header: true, child: Text(spec.title, style: AppTextStyles.h2Mobile.copyWith(color: AppColors.textPrimary))),
                            Text(spec.body, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        constraints: const BoxConstraints.tightFor(width: Dimensions.touchTarget, height: Dimensions.touchTarget),
                        onPressed: Get.back,
                        icon: const Icon(AppIcons.close, size: Dimensions.iconSize, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.gridHeader, borderRadius: BorderRadius.circular(Dimensions.radiusControl)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 9,
                      children: [
                        Text(c.patient, style: AppTextStyles.bodyMedium.copyWith(fontSize: 18, color: AppColors.textPrimary)),
                        Text(_when(c), style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                        Text(c.visitType, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(Dimensions.spaceMd),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderDefault))),
              child: _Buttons(controller: c, spec: spec, keepLabel: spec.keepMobile, confirmLabel: spec.confirmMobile, keepFlex: 175, confirmFlex: 172, gap: 10),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keep | Confirm. Confirm is blocked while the action is running, so it can't
/// be submitted twice.
class _Buttons extends StatelessWidget {
  const _Buttons({required this.controller, required this.spec, required this.keepLabel, required this.confirmLabel, required this.keepFlex, required this.confirmFlex, required this.gap});

  final AppointmentDetailController controller;
  final _Spec spec;
  final String keepLabel;
  final String confirmLabel;
  final int keepFlex;
  final int confirmFlex;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Obx(() {
      final busy = c.isSubmitting.value;
      final spinnerColor = spec.danger ? AppColors.safetyCriticalText : AppColors.textOnBrand;
      final child = busy ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor)) : Text(confirmLabel, maxLines: 1, overflow: TextOverflow.ellipsis);
      final onPressed = busy ? null : () => spec.onConfirm(c);
      return Row(
        spacing: gap,
        children: [
          Expanded(flex: keepFlex, child: OutlinedButton(onPressed: busy ? null : Get.back, child: Text(keepLabel, maxLines: 1, overflow: TextOverflow.ellipsis))),
          Expanded(
            flex: confirmFlex,
            child: spec.danger
                ? OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.safetyCriticalBackground,
                      foregroundColor: AppColors.safetyCriticalText,
                      disabledBackgroundColor: AppColors.safetyCriticalBackground,
                      side: const BorderSide(color: AppColors.safetyCriticalText),
                    ),
                    child: child,
                  )
                : FilledButton(onPressed: onPressed, child: child),
          ),
        ],
      );
    });
  }
}
