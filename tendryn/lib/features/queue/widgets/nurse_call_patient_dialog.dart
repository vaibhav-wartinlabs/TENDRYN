import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';
import 'package:tendryn/widgets/common/app_button.dart';

/// The Nurse "Call [patient]?" confirmation (Figma: desktop and tablet 480px
/// modal, phone bottom sheet). [onConfirm] runs after the dialog closes.
Future<void> showNurseCallPatientDialog(
  BuildContext context, {
  required QueueEntry entry,
  required VoidCallback onConfirm,
}) {
  void confirm(BuildContext ctx) {
    Navigator.of(ctx).pop();
    onConfirm();
  }

  if (ResponsiveHelper.isMobile(context)) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.backgroundSurface,
      barrierColor: AppColors.scrim,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius))),
      builder: (ctx) => NurseCallPatientPanel(entry: entry, sheet: true, onConfirm: () => confirm(ctx)),
    );
  }
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.scrim,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.backgroundSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(Dimensions.pageMarginTablet),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radius)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: NurseCallPatientPanel(entry: entry, sheet: false, onConfirm: () => confirm(ctx)),
      ),
    ),
  );
}

/// Heading, explanation, the three call details and Cancel / Call patient.
/// [sheet] adds the drag handle and 16px side padding of the phone design.
class NurseCallPatientPanel extends StatelessWidget {
  const NurseCallPatientPanel({super.key, required this.entry, required this.sheet, required this.onConfirm});

  final QueueEntry entry;
  final bool sheet;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final patientId = NursePatientProfile.fromQueueEntry(entry).patientId;
    final sidePadding = sheet ? Dimensions.spaceMd : Dimensions.spaceLg;
    final rows = [
      ('Queue number', entry.number),
      ('Reason for visit', entry.reason),
      ('Priority', entry.priority.label),
    ];
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (sheet)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderDefault,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            Container(
              height: sheet ? 48 : 88,
              padding: EdgeInsets.only(left: sidePadding, right: sheet ? 0 : 20),
              decoration: sheet
                  ? null
                  : const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
                    ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'Call ${entry.patient}?',
                          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Queue ${entry.number} · $patientId',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    constraints: const BoxConstraints.tightFor(width: Dimensions.touchTarget, height: Dimensions.touchTarget),
                    icon: const Icon(AppIcons.close, size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(sidePadding, Dimensions.spaceLg, sidePadding, sheet ? Dimensions.spaceLg : Dimensions.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Dimensions.spaceMd,
                children: [
                  Text(
                    '${entry.patient} will be called to the triage room. Their queue status will change to With Nurse.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                  ),
                  Column(
                    children: [
                      for (final (i, row) in rows.indexed)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.spaceSm),
                          decoration: BoxDecoration(
                            border: i < rows.length - 1
                                ? const Border(
                                    bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
                                  )
                                : null,
                          ),
                          child: Row(
                            spacing: Dimensions.spaceMd,
                            children: [
                              Expanded(
                                child: Text(row.$1, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                              ),
                              Flexible(
                                child: Text(
                                  row.$2,
                                  style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceLg),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
              ),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                      expand: true,
                    ),
                  ),
                  Expanded(
                    child: AppButton.primary(
                      label: 'Call patient',
                      onPressed: onConfirm,
                      expand: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
