import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/patients/controllers/register_patient_controller.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/app_shell.dart';
import 'package:tendryn/widgets/common/app_text_field.dart';
import 'package:tendryn/widgets/common/connectivity_banner.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

const _subtitle = 'Create a front desk patient record.';
const _derivesNote = 'SA ID validation derives personal details automatically.';

/// Register Patient (no validation for now). Desktop shows one page of sections inside the
/// navigation shell; tablet and mobile show dedicated full-screen forms without the bottom nav bar.
class RegisterPatientView extends GetView<RegisterPatientController> {
  const RegisterPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(controller: controller),
      tablet: _buildTablet(context),
      desktop: AppShell(route: AppRoutes.patients, child: _Desktop(controller: controller)),
    );
  }

  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TabletHeader(),
            const ConnectivityBanner(),
            Expanded(child: _Tablet(controller: controller)),
          ],
        ),
      ),
    );
  }
}

enum _Density { desktop, tablet, mobile }

// ---------------------------------------------------------------------------
// Desktop
// ---------------------------------------------------------------------------

class _Desktop extends StatelessWidget {
  const _Desktop({required this.controller});

  final RegisterPatientController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final f = _Fields(controller);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                hoverColor: AppColors.brandTint,
                splashColor: Colors.transparent,
                highlightColor: AppColors.brandTint,
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                    return AppColors.brandTint;
                  }
                  return Colors.transparent;
                }),
                onTap: controller.cancel,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Dimensions.spaceSm,
                    children: [
                      Icon(AppIcons.arrowLeft, size: Dimensions.iconSize, color: scheme.primary),
                      Text(controller.backLabel, style: AppTextStyles.label.copyWith(color: scheme.primary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.pageSectionGap),
          Semantics(header: true, child: Text('Register Patient', style: AppTextStyles.h1.copyWith(color: scheme.onSurface))),
          const SizedBox(height: Dimensions.spaceXs),
          Text('Create a front desk patient record. SA ID validation derives personal details automatically.', style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: Dimensions.pageSectionGap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Dimensions.spaceMd,
            children: [
              _Section(
                title: 'Identification',
                subtitle: _identificationNote,
                density: _Density.desktop,
                children: [
                  _Row(spacing: 12, children: [f.saId(), f.passport()]),
                  _Row(spacing: 12, children: [f.firstName(), f.surname(), f.dateOfBirth(), f.gender()]),
                ],
              ),
              _Section(
                title: 'Contact',
                subtitle: _contactNote,
                density: _Density.desktop,
                children: [
                  _Row(spacing: 16, children: [f.mobile(), f.whatsApp()]),
                  f.address(),
                ],
              ),
              _Section(title: 'Next of Kin', subtitle: _kinNote, density: _Density.desktop, children: [f.nextOfKin()]),
              _Section(
                title: 'Health Alerts',
                subtitle: _healthNote,
                density: _Density.desktop,
                children: [
                  _Row(spacing: 16, children: [f.allergies(), f.chronic()]),
                ],
              ),
              _Section(title: 'POPIA Consent', subtitle: _consentNote, density: _Density.desktop, children: [f.consents(_Density.desktop)]),
              _Actions(controller: controller, leftLabel: 'Cancel', rightLabel: 'Register Patient', onLeft: controller.cancel, onRight: controller.register, gap: 10),
            ],
          ),
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

  final RegisterPatientController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final f = _Fields(controller);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.pageMarginDesktop,
              Dimensions.spaceMd,
              Dimensions.pageMarginDesktop,
              Dimensions.spaceMd,
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
                    spacing: Dimensions.spaceXs,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Register Patient',
                          style: AppTextStyles.h2.copyWith(color: scheme.onSurface),
                        ),
                      ),
                      Text(
                        '$_subtitle $_derivesNote',
                        style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                      ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Dimensions.pageSectionGap,
                  children: [
                    _Section(
                      title: 'Identification',
                      subtitle: _identificationNote,
                      density: _Density.tablet,
                      children: [
                        _Row(spacing: 16, children: [f.saId(), f.passport()]),
                        _Row(spacing: 16, children: [f.firstName(), f.surname()]),
                        _Row(spacing: 16, children: [f.dateOfBirth(), f.gender()]),
                      ],
                    ),
                    _Section(
                      title: 'Contact',
                      subtitle: _contactNote,
                      density: _Density.tablet,
                      children: [
                        _Row(spacing: 16, children: [f.mobile(), f.whatsApp()]),
                        f.address(),
                      ],
                    ),
                    _Section(title: 'Next of Kin', subtitle: _kinNote, density: _Density.tablet, children: [f.nextOfKin()]),
                    _Section(
                      title: 'Health Alerts',
                      subtitle: _healthNote,
                      density: _Density.tablet,
                      children: [
                        _Row(spacing: 16, children: [f.allergies(), f.chronic()]),
                      ],
                    ),
                    _Section(title: 'POPIA Consent', subtitle: _consentNote, density: _Density.tablet, children: [f.consents(_Density.tablet)]),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginDesktop, vertical: Dimensions.spaceMd),
              decoration: BoxDecoration(color: scheme.surface, border: Border(top: BorderSide(color: scheme.outline))),
              child: _Actions(controller: controller, leftLabel: 'Cancel', rightLabel: 'Register Patient', onLeft: controller.cancel, onRight: controller.register, gap: 12, leftWidth: 299),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile (three steps)
// ---------------------------------------------------------------------------

class _Mobile extends StatelessWidget {
  const _Mobile({required this.controller});

  final RegisterPatientController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = controller;
    final f = _Fields(c);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: Dimensions.mobileHeaderHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginMobile),
                child: Row(
                  spacing: Dimensions.spaceSm,
                  children: [
                    _BackButton(onTap: c.back),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Semantics(header: true, child: Text('Register Patient', style: AppTextStyles.h2Mobile.copyWith(color: scheme.onSurface))),
                          Text(_subtitle, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, Dimensions.spaceXs, Dimensions.pageMarginMobile, 12),
              child: Obx(() {
                final step = c.step.value;
                return Column(
                  spacing: Dimensions.spaceSm,
                  children: [
                    Row(
                      spacing: Dimensions.spaceSm,
                      children: [
                        Expanded(child: Text(RegisterPatientController.stepTitles[step - 1], style: AppTextStyles.label.copyWith(color: scheme.onSurface))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.badgePaddingX, vertical: Dimensions.badgePaddingY),
                          decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
                          child: Text('Step $step of ${RegisterPatientController.stepCount}', style: AppTextStyles.label.copyWith(color: scheme.primary)),
                        ),
                      ],
                    ),
                    Row(
                      spacing: Dimensions.spaceXs,
                      children: [
                        for (var i = 1; i <= RegisterPatientController.stepCount; i++)
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(color: i <= step ? scheme.primary : scheme.outline, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              }),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, Dimensions.spaceXs, Dimensions.pageMarginMobile, 12),
                child: Obx(() {
                  switch (c.step.value) {
                    case 1:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12,
                        children: [
                          Text(_derivesNote, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                          _Section(
                            title: 'Identification',
                            subtitle: _identificationNote,
                            density: _Density.mobile,
                            children: [
                              f.saId(),
                              f.passport(),
                              _Row(spacing: 8, children: [f.firstName(), f.surname()]),
                              _Row(spacing: 8, children: [f.dateOfBirth(), f.gender()]),
                            ],
                          ),
                        ],
                      );
                    case 2:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12,
                        children: [
                          _Section(title: 'Contact', subtitle: _contactNote, density: _Density.mobile, children: [f.mobile(), f.whatsApp(), f.address()]),
                          _Section(title: 'Next of Kin', subtitle: _kinNote, density: _Density.mobile, children: [f.nextOfKin()]),
                        ],
                      );
                    default:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 12,
                        children: [
                          _Section(title: 'Health Alerts', subtitle: _healthNote, density: _Density.mobile, children: [f.allergies(), f.chronic()]),
                          _Section(title: 'POPIA Consent', subtitle: _consentNote, density: _Density.mobile, children: [f.consents(_Density.mobile)]),
                        ],
                      );
                  }
                }),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginMobile, vertical: 12),
                decoration: BoxDecoration(color: scheme.surface, border: Border(top: BorderSide(color: scheme.outline))),
                child: Obx(() {
                  final step = c.step.value;
                  return _Actions(
                    controller: c,
                    leftLabel: step == 2 ? 'Back' : 'Cancel',
                    rightLabel: step == RegisterPatientController.stepCount ? 'Register Patient' : 'Continue',
                    onLeft: step == 2 ? c.back : c.cancel,
                    onRight: c.next,
                    gap: Dimensions.spaceSm,
                    leftWidth: 112,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Copy
// ---------------------------------------------------------------------------

const _identificationNote = 'SA ID validation can derive details for confirmation. Passport or asylum document are supported alternatives.';
const _contactNote = 'Front desk contact and address for correspondence.';
const _kinNote = 'Optional — emergency contact for this patient.';
const _healthNote = 'Front desk capture only — this is not a clinical record.';
const _consentNote = 'Receptionist must confirm verbal acknowledgement before saving this record.';

// ---------------------------------------------------------------------------
// Fields
// ---------------------------------------------------------------------------

/// The form's controls, built once per layout so every layout edits the same state.
class _Fields {
  _Fields(this.c);

  final RegisterPatientController c;

  Widget _text(String label, TextEditingController controller, String hint, {TextInputType? keyboard, ValueChanged<String>? onChanged}) => AppTextField(
    label: label,
    hint: hint,
    controller: controller,
    keyboardType: keyboard,
    onChanged: onChanged,
  );

  Widget saId() => _text('SA ID Number', c.saId, 'e.g. 9106180045081', keyboard: TextInputType.number, onChanged: c.onSaIdChanged);
  Widget passport() => _text('Passport / Asylum Document', c.passport, 'Alternative document number');
  Widget firstName() => _text('First Name', c.firstName, 'Nomvula');
  Widget surname() => _text('Surname', c.surname, 'Dlamini');
  Widget mobile() => _text('Mobile Number', c.mobile, '082 555 0194', keyboard: TextInputType.phone);
  Widget whatsApp() => _text('WhatsApp Number', c.whatsApp, '082 555 0194', keyboard: TextInputType.phone);
  Widget address() => _text('Residential Address', c.address, '24 Madiba Street, Johannesburg');
  Widget nextOfKin() => _text('Name · Relationship · Contact Number', c.nextOfKin, 'Sibongile Dlamini · Sister · 083 555 0082');
  Widget allergies() => _text('Known Allergies', c.allergies, 'No known allergies');
  Widget chronic() => _text('Chronic Conditions', c.chronic, 'None declared');

  Widget dateOfBirth() => Builder(
    builder: (context) => Obx(
      () => _PickerField(
        label: 'Date of Birth',
        value: c.dateOfBirthLabel,
        hint: '18 Jun 1991',
        icon: AppIcons.calendar,
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: c.dateOfBirth.value ?? DateTime(now.year - 30),
            firstDate: DateTime(1900),
            lastDate: now,
          );
          if (picked != null) c.pickDateOfBirth(picked);
        },
      ),
    ),
  );

  Widget gender() => Obx(
    () => PopupMenuButton<String>(
      tooltip: 'Gender',
      position: PopupMenuPosition.under,
      onSelected: c.pickGender,
      itemBuilder: (_) => [
        for (final g in RegisterPatientController.genders) PopupMenuItem(value: g, height: Dimensions.touchTarget, child: Text(g, style: AppTextStyles.label)),
      ],
      child: _PickerField(label: 'Gender', value: c.gender.value ?? '', hint: 'Select', icon: AppIcons.chevronDown),
    ),
  );

  /// The two confirmations; both are required.
  Widget consents(_Density density) => Obx(
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConsentRow(
          density: density,
          checked: c.popiaConsent.value,
          label: 'Patient consents to collection and processing of personal information under POPIA',
          onTap: c.popiaConsent.toggle,
        ),
        _ConsentRow(
          density: density,
          checked: c.detailsVerified.value,
          label: 'Details supplied are accurate and verified against identity document',
          onTap: c.detailsVerified.toggle,
        ),
      ],
    ),
  );
}

/// A date or dropdown that looks like a text field: label above, 48px box,
/// trailing icon.
class _PickerField extends StatelessWidget {
  const _PickerField({required this.label, required this.value, required this.hint, required this.icon, this.onTap});

  final String label;
  final String value;
  final String hint;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(Dimensions.radiusControl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: scheme.onSurface)),
        const SizedBox(height: Dimensions.componentGap),
        InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            height: Dimensions.touchTarget,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: radius,
              border: Border.all(color: scheme.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? hint : value,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(color: value.isEmpty ? scheme.onSurfaceVariant : scheme.onSurface),
                  ),
                ),
                Icon(icon, size: 16, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({required this.density, required this.checked, required this.label, required this.onTap});

  final _Density density;
  final bool checked;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final desktop = density == _Density.desktop;
    final size = desktop ? 18.0 : 20.0;
    final box = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: checked ? scheme.primary : scheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: checked ? scheme.primary : scheme.outline),
      ),
      child: checked ? Icon(AppIcons.check, size: size - 6, color: scheme.onPrimary) : null,
    );
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: desktop ? 24 : Dimensions.touchTarget),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: desktop ? 4 : 0),
          child: Row(
            crossAxisAlignment: density == _Density.mobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (desktop) box else SizedBox.square(dimension: Dimensions.touchTarget, child: Center(child: box)),
              SizedBox(width: desktop ? 10 : Dimensions.spaceSm),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: density == _Density.mobile ? 12 : 0),
                  child: Text(label, style: AppTextStyles.body.copyWith(color: scheme.onSurface)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout helpers
// ---------------------------------------------------------------------------

/// Titled card of fields. Desktop pads 20, tablet 24, phone 12.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.subtitle, required this.density, required this.children});

  final String title;
  final String subtitle;
  final _Density density;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mobile = density == _Density.mobile;
    final padding = switch (density) {
      _Density.desktop => 20.0,
      _Density.tablet => Dimensions.cardInner,
      _Density.mobile => 12.0,
    };
    final gap = mobile ? 8.0 : 16.0;
    return AppCard(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: gap,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimensions.spaceXs,
            children: [
              Text(title, style: (mobile ? AppTextStyles.h3Mobile : AppTextStyles.h3).copyWith(color: scheme.onSurface)),
              Text(subtitle, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Fields side by side at equal width.
class _Row extends StatelessWidget {
  const _Row({required this.spacing, required this.children});

  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: spacing,
    children: [for (final child in children) Expanded(child: child)],
  );
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.controller,
    required this.leftLabel,
    required this.rightLabel,
    required this.onLeft,
    required this.onRight,
    required this.gap,
    this.leftWidth,
  });

  final RegisterPatientController controller;
  final String leftLabel;
  final String rightLabel;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final double gap;

  /// Fixed width for the left button; equal halves when null.
  final double? leftWidth;

  @override
  Widget build(BuildContext context) {
    final left = AppButton.secondary(label: leftLabel, onPressed: onLeft, expand: true);
    return Row(
      spacing: gap,
      children: [
        leftWidth == null ? Expanded(child: left) : SizedBox(width: leftWidth, child: left),
        Expanded(
          child: Obx(() => AppButton.primary(label: rightLabel, onPressed: controller.isSubmitting.value ? null : onRight, expand: true)),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Back',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          hoverColor: AppColors.brandTint,
          splashColor: Colors.transparent,
          highlightColor: AppColors.brandTint,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
              return AppColors.brandTint;
            }
            return Colors.transparent;
          }),
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
                  border: Border.all(
                    color: AppColors.borderDefault,
                    width: Dimensions.strokeDivider,
                  ),
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
      ),
    );
  }
}
