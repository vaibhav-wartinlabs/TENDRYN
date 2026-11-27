import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/patients/controllers/patient_details_controller.dart';
import 'package:tendryn/features/patients/widgets/patient_details_cards.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';
import 'package:tendryn/widgets/common/sync_chip.dart';

/// Patient Details. Desktop and tablet sit inside the navigation shell (Patients
/// stays selected); the phone is a focused full page with sticky actions.
class PatientDetailsView extends GetView<PatientDetailsController> {
  const PatientDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(controller: controller),
      tablet: AppShell(route: AppRoutes.patients, hideBottomNavigation: true, child: _Tablet(controller: controller)),
      desktop: AppShell(route: AppRoutes.patients, child: _Desktop(controller: controller)),
    );
  }
}

const _activeRecord = SyncChip(state: SyncState.synced, label: 'Active record');

class _Desktop extends StatelessWidget {
  const _Desktop({required this.controller});

  final PatientDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                onTap: controller.onBack,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Dimensions.spaceSm,
                    children: [
                      Icon(AppIcons.arrowLeft, size: Dimensions.iconSize, color: scheme.primary),
                      Text('Back to Patients', style: AppTextStyles.label.copyWith(color: scheme.primary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.pageSectionGap),
          Semantics(header: true, child: Text('Patient profile', style: AppTextStyles.h1.copyWith(color: scheme.onSurface))),
          const SizedBox(height: 2),
          Obx(() => Text('Front desk record · ${controller.patient.value.name}', style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant))),
          const SizedBox(height: Dimensions.pageSectionGap),
          Row(
            children: [
              Expanded(child: Obx(() => PatientTitleGroup(patient: controller.patient.value))),
              _activeRecord,
              const SizedBox(width: 12),
              Icon(AppIcons.more, size: Dimensions.iconSize, color: scheme.onSurface),
            ],
          ),
          const SizedBox(height: Dimensions.spaceLg),
          PatientDetailCards(controller: controller),
          const SizedBox(height: Dimensions.spaceLg),
          PatientDetailActions(controller: controller),
        ],
      ),
    );
  }
}

class _Tablet extends StatelessWidget {
  const _Tablet({required this.controller});

  final PatientDetailsController controller;

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
                _BackButton(onTap: controller.onBack),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      'Patient profile',
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
                Row(
                  children: [
                    Expanded(child: Obx(() => PatientTitleGroup(patient: controller.patient.value))),
                    _activeRecord,
                  ],
                ),
                const SizedBox(height: Dimensions.spaceLg),
                PatientDetailCards(
                  controller: controller,
                  twoColumns: ResponsiveHelper.isTabletLandscape(context),
                ),
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
            child: PatientDetailActions(controller: controller),
          ),
        ),
      ),
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile({required this.controller});

  final PatientDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                    _BackButton(onTap: controller.onBack),
                    Expanded(child: Semantics(header: true, child: Text('Patient profile', style: AppTextStyles.h2Mobile.copyWith(color: scheme.onSurface)))),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, 0, Dimensions.pageMarginMobile, Dimensions.spaceMd),
                children: [
                  Obx(() => PatientIdentityCard(patient: controller.patient.value, caption: 'Active patient record')),
                  const SizedBox(height: Dimensions.spaceLg),
                  PatientDetailCards(controller: controller, gap: 12),
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
              child: PatientDetailActions(controller: controller, gap: 12),
            ),
          ],
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
                child: Icon(AppIcons.chevronLeft, size: Dimensions.iconSize, color: scheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
