import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/patients/controllers/patient_edit_controller.dart';
import 'package:tendryn/features/patients/widgets/patient_details_cards.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/app_shell.dart';
import 'package:tendryn/widgets/common/app_text_field.dart';
import 'package:tendryn/widgets/common/sync_chip.dart';

/// Edit Patient Details. Desktop and tablet sit inside the navigation shell
/// (Patients stays selected); the phone is a focused page with sticky actions.
class PatientEditView extends GetView<PatientEditController> {
  const PatientEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(controller: controller),
      tablet: AppShell(route: AppRoutes.patients, child: _Tablet(controller: controller)),
      desktop: AppShell(route: AppRoutes.patients, child: _Desktop(controller: controller)),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop
// ---------------------------------------------------------------------------

class _Desktop extends StatelessWidget {
  const _Desktop({required this.controller});

  final PatientEditController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = controller;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                onTap: c.onBack,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Dimensions.spaceSm,
                    children: [
                      Icon(AppIcons.arrowLeft, size: Dimensions.iconSize, color: scheme.primary),
                      Text('Back to patient profile', style: AppTextStyles.label.copyWith(color: scheme.primary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.pageSectionGap),
          Semantics(header: true, child: Text('Edit patient details', style: AppTextStyles.h1.copyWith(color: scheme.onSurface))),
          const SizedBox(height: 2),
          Text(
            'Update contact and next of kin information for ${c.patient.fileNumber}.',
            style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: Dimensions.pageSectionGap),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle('Identity'),
                const SizedBox(height: 2),
                Text('Identity fields are verified against the patient document.', style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: Dimensions.spaceMd),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Dimensions.sectionContentGap,
                  children: [
                    Expanded(child: _ReadOnlyField(label: 'First name', value: c.firstName)),
                    Expanded(child: _ReadOnlyField(label: 'Surname', value: c.surname)),
                    Expanded(child: _ReadOnlyField(label: 'Date of birth', value: c.patient.dateOfBirth)),
                  ],
                ),
                const SizedBox(height: Dimensions.spaceLg),
                _SectionTitle('Contact'),
                const SizedBox(height: Dimensions.spaceSm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Dimensions.sectionContentGap,
                  children: [
                    Expanded(child: _MobileField(controller: c)),
                    Expanded(child: _AddressField(controller: c)),
                  ],
                ),
                const SizedBox(height: Dimensions.spaceLg),
                _SectionTitle('Next of kin'),
                const SizedBox(height: Dimensions.spaceSm),
                _NextOfKinField(controller: c),
                const SizedBox(height: Dimensions.spaceLg),
                const _ConsentNote(title: 'POPIA consent already recorded', message: 'Edit only verified front desk details. A change to identity or consent requires a separate verification step.'),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.pageSectionGap),
          _Actions(controller: c, saveLabel: 'Save changes'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet
// ---------------------------------------------------------------------------

class _Tablet extends StatelessWidget {
  const _Tablet({required this.controller});

  final PatientEditController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(bottom: BorderSide(color: scheme.outline)),
            ),
            child: Row(
              spacing: 12,
              children: [
                _BackButton(onTap: c.onBack),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      'Edit patient details',
                      style: AppTextStyles.h2.copyWith(color: scheme.onSurface),
                    ),
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
                PatientIdentityCard(patient: c.patient, trailing: const SyncChip(state: SyncState.synced, label: 'Active record')),
                const SizedBox(height: Dimensions.spaceLg),
                AppCard(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionTitle('Contact', mobile: true),
                      const SizedBox(height: Dimensions.spaceMd),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Dimensions.sectionContentGap,
                        children: [
                          Expanded(child: _MobileField(controller: c)),
                          Expanded(
                            child: AppTextField(label: 'WhatsApp number', controller: c.whatsApp, keyboardType: TextInputType.phone),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.sectionContentGap),
                      _AddressField(controller: c),
                      const SizedBox(height: Dimensions.spaceLg),
                      _SectionTitle('Next of kin', mobile: true),
                      const SizedBox(height: Dimensions.spaceMd),
                      _NextOfKinField(controller: c),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.spaceMd),
                const _ConsentNote(title: 'POPIA consent recorded', message: 'Identity or consent changes require separate verification. Save verified contact details only.'),
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
            child: _Actions(controller: c, saveLabel: 'Save changes'),
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

  final PatientEditController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = controller;
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
                    _BackButton(onTap: c.onBack),
                    Expanded(child: Semantics(header: true, child: Text('Edit patient details', style: AppTextStyles.h2Mobile.copyWith(color: scheme.onSurface)))),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, 0, Dimensions.pageMarginMobile, Dimensions.spaceMd),
                children: [
                  PatientIdentityCard(patient: c.patient, caption: 'Active patient record'),
                  const SizedBox(height: Dimensions.spaceLg),
                  AppCard(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SectionTitle('Contact', mobile: true),
                        const SizedBox(height: Dimensions.spaceMd),
                        _MobileField(controller: c),
                        const SizedBox(height: Dimensions.spaceMd),
                        _AddressField(controller: c),
                        const SizedBox(height: Dimensions.spaceLg),
                        _SectionTitle('Next of kin', mobile: true),
                        const SizedBox(height: Dimensions.spaceMd),
                        _NextOfKinField(controller: c),
                        const SizedBox(height: Dimensions.spaceLg),
                        const _ConsentNote(title: 'POPIA consent recorded', message: 'Identity or consent changes require separate verification. Save verified contact details only.', large: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginMobile, vertical: 12),
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
              child: _Actions(controller: c, saveLabel: 'Save Details'),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.mobile = false});

  final String text;
  final bool mobile;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: (mobile ? AppTextStyles.h3Mobile : AppTextStyles.h3).copyWith(color: Theme.of(context).colorScheme.onSurface),
  );
}

class _ReadOnlyField extends StatefulWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  State<_ReadOnlyField> createState() => _ReadOnlyFieldState();
}

class _ReadOnlyFieldState extends State<_ReadOnlyField> {
  late final _text = TextEditingController(text: widget.value);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppTextField(label: widget.label, controller: _text, enabled: false);
}

class _MobileField extends StatelessWidget {
  const _MobileField({required this.controller});

  final PatientEditController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => AppTextField(label: 'Mobile number', controller: controller.mobile, keyboardType: TextInputType.phone, errorText: controller.mobileError.value),
  );
}

class _AddressField extends StatelessWidget {
  const _AddressField({required this.controller});

  final PatientEditController controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => AppTextField(label: 'Residential address', controller: controller.address, errorText: controller.addressError.value),
  );
}

class _NextOfKinField extends StatelessWidget {
  const _NextOfKinField({required this.controller});

  final PatientEditController controller;

  @override
  Widget build(BuildContext context) => AppTextField(label: 'Name · relationship · mobile', controller: controller.nextOfKin);
}

class _ConsentNote extends StatelessWidget {
  const _ConsentNote({required this.title, required this.message, this.large = false});

  final String title;
  final String message;

  /// Phone: 16px message text.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(Dimensions.radiusControl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          Text(title, style: AppTextStyles.label.copyWith(color: scheme.primary)),
          Text(message, style: (large ? AppTextStyles.body : AppTextStyles.label).copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Cancel + save, side by side at equal width.
class _Actions extends StatelessWidget {
  const _Actions({required this.controller, required this.saveLabel});

  final PatientEditController controller;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(child: AppButton.secondary(label: 'Cancel', onPressed: controller.onBack, expand: true)),
        Expanded(child: AppButton.primary(label: saveLabel, onPressed: controller.save, expand: true)),
      ],
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
                child: Icon(AppIcons.chevronLeft, size: Dimensions.iconSize, color: scheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
