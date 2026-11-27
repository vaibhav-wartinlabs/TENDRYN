import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/features/patients/widgets/patients_common.dart';
import 'package:tendryn/features/patients/widgets/patients_desktop.dart';
import 'package:tendryn/features/patients/widgets/patients_nurse.dart';
import 'package:tendryn/features/dashboard/widgets/card_grid.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/connectivity_sync_chip.dart';

/// Tablet arrangement: date and sync chip over the heading, four summary
/// cards, search + filter, then Recent Patients as cards inside one panel.
class PatientsTablet extends StatefulWidget {
  const PatientsTablet({super.key});

  @override
  State<PatientsTablet> createState() => _PatientsTabletState();
}

class _PatientsTabletState extends State<PatientsTablet> {
  PatientsController get controller => Get.find<PatientsController>();

  PatientRecord? _selectedDoctorPatient;

  @override
  void initState() {
    super.initState();
    final requested = PatientsController.takePendingDoctorProfile();
    if (requested != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openDoctorProfile(requested);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RoleController>()) return _buildReceptionist(context);
    return Obx(
      () => switch (RoleController.to.currentRole.value) {
        ClinicRole.doctor => _selectedDoctorPatient == null
            ? _buildDoctor(context)
            : DoctorPatientProfileResponsive(
                patient: _selectedDoctorPatient!,
                onBack: _closeDoctorProfile,
              ),
        ClinicRole.nurse => const PatientsNurseTablet(),
        _ => _buildReceptionist(context),
      },
    );
  }

  Widget _buildReceptionist(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.pageMarginTablet,
        Dimensions.pageMarginTablet,
        Dimensions.pageMarginTablet,
        Dimensions.pageMarginTablet,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                Formatters.longDate(DateTime.now()),
                style: AppTextStyles.label.copyWith(color: scheme.primary),
              ),
            ),
            const ConnectivitySyncChip(),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          spacing: Dimensions.spaceMd,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Dimensions.spaceXs,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Patients',
                      style: AppTextStyles.h1.copyWith(color: scheme.onSurface),
                    ),
                  ),
                  Text(
                    'Find and manage front desk patient records.',
                    style: AppTextStyles.label.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: AppButton.primary(
                label: 'Register patient',
                onPressed: controller.registerPatient,
                expand: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.spaceLg),
        const PatientsSummary(screenType: LayoutType.tablet),
        const SizedBox(height: Dimensions.pageSectionGap),
        const PatientsToolbar(hint: 'Search name, ID or queue number'),
        const SizedBox(height: Dimensions.pageSectionGap),
        Row(
          spacing: Dimensions.spaceMd,
          children: [
            Expanded(
              child: Text(
                'Recent Patients',
                style: AppTextStyles.h2Mobile.copyWith(color: scheme.onSurface),
              ),
            ),
            AppButton.secondary(
              label: 'View Full Queue',
              onPressed: controller.openQueue,
            ),
          ],
        ),
        const SizedBox(height: Dimensions.sectionContentGap),
        Obx(() {
          final rows = controller.filtered;
          if (rows.isEmpty) return const PatientsEmptyState();
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(Dimensions.radius),
              border: Border.all(
                color: scheme.outline,
                width: Dimensions.strokeDivider,
              ),
            ),
            child: CardGrid(
              minColumnWidth: 420,
              spacing: Dimensions.spaceMd,
              children: [
                for (final p in rows)
                  _PatientCard(
                    patient: p,
                    onTap: () => controller.viewPatient(p),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDoctor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.pageMarginTablet,
        Dimensions.pageMarginTablet,
        Dimensions.pageMarginTablet,
        Dimensions.pageMarginTablet,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Patients',
                      style: AppTextStyles.h1.copyWith(color: scheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: Dimensions.spaceXs),
                  Text(
                    'Find patient records and review longitudinal care.',
                    style: AppTextStyles.label.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.spaceMd),
            SizedBox(
              width: 176,
              child: AppButton.primary(
                label: 'Open Queue',
                onPressed: controller.openQueue,
                expand: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.spaceLg),
        const PatientsToolbar(
          hint: 'Search name, ID or queue number',
          showFilter: true,
        ),
        const SizedBox(height: Dimensions.spaceLg),
        Text(
          'Patient directory',
          style: AppTextStyles.h2Mobile.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: Dimensions.spaceSm),
        Obx(() {
          final hasSearch = controller.searchQuery.value.trim().isNotEmpty;
          final rows = controller.pageEntries;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (rows.isEmpty)
                const PatientsEmptyState()
              else
                CardGrid(
                  minColumnWidth: 260,
                  spacing: Dimensions.spaceMd,
                  children: [
                    for (final patient in rows)
                      DoctorPatientDirectoryCard(
                        patient: patient,
                        showActionMenu: hasSearch,
                        onViewProfile: () => _openDoctorProfile(patient),
                      ),
                  ],
                ),
              if (!hasSearch) ...[
                const SizedBox(height: Dimensions.spaceMd),
                const DoctorPatientPagination(demoOnly: true),
              ],
            ],
          );
        }),
      ],
    );
  }

  void _openDoctorProfile(PatientRecord patient) {
    controller.setDoctorProfileOpen(true);
    setState(() => _selectedDoctorPatient = patient);
  }

  void _closeDoctorProfile() {
    controller.setDoctorProfileOpen(false);
    setState(() => _selectedDoctorPatient = null);
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});

  final PatientRecord patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [
                Text(
                  patient.status,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.feedbackInfo,
                  ),
                ),
                Text(
                  patient.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  patient.fileAndDob,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'View profile',
            style: AppTextStyles.caption.copyWith(color: scheme.primary),
          ),
        ],
      ),
    );
  }
}
