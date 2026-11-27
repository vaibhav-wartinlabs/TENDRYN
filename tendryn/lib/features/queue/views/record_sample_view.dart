import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/queue/controllers/record_sample_controller.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';
import 'package:tendryn/features/queue/views/nurse_triage_view.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_button.dart';

/// Opens the Nurse "Record Sample" form for [detail]'s referral (Figma: desktop
/// drawer, phone sheet, tablet full page). It opens over the Lab Referral
/// Details, so Cancel or back returns there.
void showNurseRecordSample(BuildContext context, LabReferralDetail detail) {
  // A fresh form for each opening (the controller is removed when it closes).
  Get.delete<RecordSampleController>(force: true);
  final controller = Get.put(RecordSampleController(detail: detail));
  showNurseRecordPanel(
    context,
    title: 'Record Sample',
    subtitle: detail.subtitle,
    body: RecordSampleForm(controller: controller),
    drawerFooter: (close) => _SampleFooter(controller: controller, onCancel: close),
    sheetFooter: (close) => _SampleFooter(controller: controller, onCancel: close),
    openPage: () => Get.toNamed(AppRoutes.nurseRecordSample, arguments: {'detail': detail}),
    onClosed: () => Get.delete<RecordSampleController>(force: true),
  );
}

/// Cancel and Save Sample (48px). Save is disabled while a submission runs.
class RecordSampleFooter extends StatelessWidget {
  const RecordSampleFooter({super.key, required this.controller, required this.onCancel});

  final RecordSampleController controller;
  final VoidCallback onCancel;

  Future<void> _handleSave(BuildContext context) async {
    final updated = await controller.submit();
    if (updated == null) return;
    onCancel();
    if (!context.mounted) return;
    if (ResponsiveHelper.isTablet(context)) {
      if (Get.currentRoute == AppRoutes.nurseRecordSample) {
        Get.offNamed(AppRoutes.nurseLabReferral, arguments: {'detail': updated});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        spacing: 12,
        children: [
          Expanded(child: AppButton.secondary(label: 'Cancel', onPressed: onCancel, expand: true)),
          Expanded(
            child: AppButton.primary(
              label: 'Save Sample',
              onPressed: controller.isSaving.value ? null : () => _handleSave(context),
              isLoading: controller.isSaving.value,
              expand: true,
            ),
          ),
        ],
      ),
    );
  }
}

typedef _SampleFooter = RecordSampleFooter;

/// Referral context, then the "Sample collection" fields.
class RecordSampleForm extends StatelessWidget {
  const RecordSampleForm({super.key, required this.controller});

  final RecordSampleController controller;

  @override
  Widget build(BuildContext context) {
    final detail = controller.detail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Dimensions.spaceMd,
      children: [
        ReferralContextPanel(detail: detail),
        Text(
          'Sample collection',
          style: AppTextStyles.h3Mobile.copyWith(fontSize: 16, height: 24 / 16, color: AppColors.textPrimary),
        ),
        Obx(
          () => _SampleField(
            label: 'Sample collection date',
            error: controller.dateError.value,
            child: _FieldBox(
              text: controller.dateLabel,
              hasError: controller.dateError.value != null,
              onTap: () => controller.pickDate(context),
              semanticsLabel: 'Sample collection date, ${controller.dateLabel}',
            ),
          ),
        ),
        Obx(
          () => _SampleField(
            label: 'Sample collection time',
            error: controller.timeError.value,
            child: _FieldBox(
              text: controller.timeLabel,
              hasError: controller.timeError.value != null,
              onTap: () => controller.pickTime(context),
              semanticsLabel: 'Sample collection time, ${controller.timeLabel}',
            ),
          ),
        ),
        Obx(
          () => _SampleField(
            label: 'Sample collection status',
            error: controller.statusError.value,
            child: PopupMenuButton<String>(
              tooltip: 'Sample collection status',
              position: PopupMenuPosition.under,
              onSelected: controller.selectStatus,
              itemBuilder: (_) => [
                for (final s in RecordSampleController.statuses) PopupMenuItem(value: s, child: Text(s)),
              ],
              child: _FieldBox(
                text: controller.status.value ?? 'Select status',
                hasError: controller.statusError.value != null,
                trailing: const Icon(AppIcons.chevronDown, size: 18, color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Label above a field (12px) and its inline error below.
class _SampleField extends StatelessWidget {
  const _SampleField({required this.label, required this.child, this.error});

  final String label;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Dimensions.spaceSm,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
        child,
        if (error != null)
          Semantics(
            liveRegion: true,
            child: Text(error!, style: AppTextStyles.caption.copyWith(color: AppColors.safetyCriticalText)),
          ),
      ],
    );
  }
}

/// The 48px bordered field: value text, optional trailing icon, tappable when [onTap] is given.
class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.text, required this.hasError, this.onTap, this.trailing, this.semanticsLabel});

  final String text;
  final bool hasError;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: AppColors.backgroundSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: BorderSide(
            color: hasError ? AppColors.fieldErrorBorder : AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX),
            alignment: Alignment.centerLeft,
            child: Row(
              spacing: Dimensions.componentGap,
              children: [
                Expanded(child: Text(text, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary))),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tablet Record Sample page: the form with Cancel / Save Sample above the nav.
/// The controller comes from the route; leaving the page disposes it.
class NurseRecordSamplePage extends StatelessWidget {
  const NurseRecordSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecordSampleController>();
    return NurseRecordPage(
      title: 'Record Sample',
      subtitle: controller.detail.subtitle,
      titleStyle: AppTextStyles.h3,
      body: RecordSampleForm(controller: controller),
      bottom: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginTablet),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.backgroundSurface,
          border: Border(top: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
        ),
        child: _SampleFooter(controller: controller, onCancel: Get.back),
      ),
    );
  }
}
