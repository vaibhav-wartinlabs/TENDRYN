import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/patients/controllers/patient_details_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';

/// Patient name over the file number.
class PatientTitleGroup extends StatelessWidget {
  const PatientTitleGroup({super.key, required this.patient});

  final PatientRecord patient;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimensions.spaceXs,
      children: [
        Text(patient.name, style: AppTextStyles.h2.copyWith(color: scheme.onSurface)),
        Text('File #${patient.fileNumber}', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

/// Patient Information and Front Desk Activity cards, shared by all layouts.
class PatientDetailCards extends StatelessWidget {
  const PatientDetailCards({super.key, required this.controller, this.gap = Dimensions.spaceLg, this.twoColumns = false});

  final PatientDetailsController controller;
  final double gap;
  final bool twoColumns;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.patient.value;
      final information = _DetailCard(
          title: 'Patient Information',
          rows: [
            ('Date of birth', p.dateOfBirth),
            ('Mobile', p.mobile),
            ('Address', p.address),
            ('Next of kin', p.nextOfKin),
            ('POPIA consent', PatientDetailsController.popiaConsent),
          ],
        );
      final activity = _DetailCard(
          title: 'Front Desk Activity',
          rows: [
            ('Current queue', controller.currentQueue),
            ('Last visit', p.lastVisit),
            ('Appointment', PatientDetailsController.appointment),
          ],
        );
      if (twoColumns) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: gap,
          children: [Expanded(child: information), Expanded(child: activity)],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: gap,
        children: [information, activity],
      );
    });
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Dimensions.componentGap,
        children: [
          Text(title, style: AppTextStyles.h3.copyWith(color: scheme.onSurface)),
          for (final (label, value) in rows)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimensions.spaceMd,
              children: [
                Text(label, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                Expanded(child: Text(value, textAlign: TextAlign.right, style: AppTextStyles.label.copyWith(color: scheme.onSurface))),
              ],
            ),
        ],
      ),
    );
  }
}

/// Edit details + View queue, side by side at equal width.
class PatientDetailActions extends StatelessWidget {
  const PatientDetailActions({super.key, required this.controller, this.gap = 12});

  final PatientDetailsController controller;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: gap,
      children: [
        Expanded(child: AppButton.secondary(label: 'Edit details', onPressed: controller.editDetails, expand: true)),
        Expanded(child: AppButton.primary(label: 'View queue', onPressed: controller.viewQueue, expand: true)),
      ],
    );
  }
}

/// Tinted identity card (name, file number · DOB, optional trailing widget or
/// a caption line) shown at the top of the phone and tablet screens.
class PatientIdentityCard extends StatelessWidget {
  const PatientIdentityCard({super.key, required this.patient, this.caption, this.trailing});

  final PatientRecord patient;

  /// Small line under the file number (phone).
  final String? caption;

  /// Right-hand widget (tablet).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimensions.spaceXs,
              children: [
                Text(patient.name, style: AppTextStyles.h3Mobile.copyWith(color: scheme.onSurface)),
                Text('File #${patient.fileNumber} · ${patient.dateOfBirth}', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                if (caption != null) Text(caption!, style: AppTextStyles.caption.copyWith(color: scheme.primary)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
