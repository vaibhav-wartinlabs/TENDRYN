import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/features/patients/widgets/patients_desktop.dart';
import 'package:tendryn/features/patients/widgets/patients_common.dart';
import 'package:tendryn/features/patients/widgets/patients_nurse.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';

/// Phone arrangement: compact heading, four summary cards, search, a single
/// column of patient cards and a full-width Add patient button.
class PatientsMobile extends StatefulWidget {
  const PatientsMobile({super.key});

  @override
  State<PatientsMobile> createState() => _PatientsMobileState();
}

class _PatientsMobileState extends State<PatientsMobile> {
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
        ClinicRole.nurse => const PatientsNurseMobile(),
        _ => _buildReceptionist(context),
      },
    );
  }

  Widget _buildReceptionist(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Patients',
            style: AppTextStyles.h1Mobile.copyWith(color: scheme.onSurface),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Find and manage front desk patient records.',
          style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: Dimensions.sectionContentGap),
        const PatientsSummary(screenType: LayoutType.mobile),
        const SizedBox(height: Dimensions.sectionContentGap),
        const PatientsToolbar(
          hint: 'Search patient or queue number',
          showFilter: false,
        ),
        const SizedBox(height: Dimensions.sectionContentGap),
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent patients',
                style: AppTextStyles.h2Mobile.copyWith(color: scheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: controller.openQueue,
              child: const Text('View Full Queue'),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.sectionContentGap),
        Obx(() {
          final rows = controller.filtered;
          if (rows.isEmpty) return const PatientsEmptyState();
          return Column(
            spacing: Dimensions.spaceMd,
            children: [
              for (final p in rows)
                _PatientCard(
                  patient: p,
                  onTap: () => controller.viewPatient(p),
                ),
            ],
          );
        }),
        const SizedBox(height: Dimensions.sectionContentGap),
        AppButton.primary(
          label: 'Add patient',
          onPressed: controller.registerPatient,
          expand: true,
        ),
      ],
    );
  }

  Widget _buildDoctor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final hasSearch = controller.searchQuery.value.trim().isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Patients',
                    style: AppTextStyles.h1Mobile.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.spaceXs),
                Text(
                  'Find patient records and review longitudinal care.',
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Dimensions.spaceMd),
                const PatientsToolbar(
                  hint: 'Search name, ID or queue number',
                  showFilter: true,
                ),
                const SizedBox(height: Dimensions.spaceMd),
                Text(
                  'Patient directory',
                  style: AppTextStyles.h2Mobile.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: Dimensions.spaceSm),
                Obx(() {
                  final rows = controller.pageEntries;
                  if (rows.isEmpty) return const PatientsEmptyState();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Dimensions.spaceSm,
                    children: [
                      for (final patient in rows)
                        DoctorPatientDirectoryCard(
                          patient: patient,
                          showActionMenu: hasSearch,
                          onViewProfile: () => _openDoctorProfile(patient),
                        ),
                    ],
                  );
                }),
                if (!hasSearch) ...[
                  const SizedBox(height: Dimensions.spaceMd),
                  const DoctorPatientPagination(
                    showRange: false,
                    demoOnly: true,
                  ),
                  const SizedBox(height: Dimensions.spaceMd),
                  AppButton.primary(
                    label: 'Open Queue',
                    onPressed: controller.openQueue,
                    expand: true,
                  ),
                  const SizedBox(height: Dimensions.spaceSm),
                ],
              ],
            ),
          ),
          if (hasSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.pageMarginMobile,
                Dimensions.spaceSm,
                Dimensions.pageMarginMobile,
                Dimensions.spaceSm,
              ),
              child: AppButton.primary(
                label: 'Open Queue',
                onPressed: controller.openQueue,
                expand: true,
              ),
            ),
        ],
      );
    });
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
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.spaceMd,
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 3,
          children: [
            Text(
              patient.status,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.feedbackInfo,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    patient.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  'View',
                  style: AppTextStyles.label.copyWith(color: scheme.primary),
                ),
              ],
            ),
            Text(
              patient.fileAndDob,
              style: AppTextStyles.label.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
