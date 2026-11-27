import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/features/patients/widgets/patients_common.dart';
import 'package:tendryn/features/patients/widgets/patients_nurse.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_action_menu.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';

/// Desktop arrangement matching the Figma/screenshot design:
/// Header + "Register patient" button, 3 KPI cards, search + filter bar,
/// "Recent patients" table with Patient/File/DOB/Mobile/Last visit/Status columns,
/// and a pagination footer.
class PatientsDesktop extends StatefulWidget {
  const PatientsDesktop({super.key});

  @override
  State<PatientsDesktop> createState() => _PatientsDesktopState();
}

class _PatientsDesktopState extends State<PatientsDesktop> {
  PatientsController get controller => Get.find<PatientsController>();

  PatientRecord? _selectedDoctorPatient;

  @override
  void initState() {
    super.initState();
    final requested = PatientsController.takePendingDoctorProfile();
    if (requested != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedDoctorPatient = requested);
      });
    }
  }

  static const _colStyle = TextStyle(
    fontFamily: AppTextStyles.bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RoleController>()) return _buildReceptionist(context);
    return Obx(
      () => switch (RoleController.to.currentRole.value) {
        ClinicRole.doctor => _selectedDoctorPatient == null
            ? _buildDoctor(context)
            : DoctorPatientProfileResponsive(
                patient: _selectedDoctorPatient!,
                onBack: () => setState(() => _selectedDoctorPatient = null),
              ),
        ClinicRole.nurse => const PatientsNurseDesktop(),
        _ => _buildReceptionist(context),
      },
    );
  }

  Widget _buildReceptionist(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.pageMarginDesktop,
        Dimensions.pageMarginDesktop,
        Dimensions.pageMarginDesktop,
        Dimensions.pageMarginDesktop,
      ),
      children: [
        // ── Header row ──────────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: const Text(
                      'Patients',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find and manage front desk patient records.',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Register patient button
            InkWell(
              onTap: controller.registerPatient,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              child: Container(
                height: Dimensions.buttonMinHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.controlX,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
                child: const Text(
                  'Register patient',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ── 3 KPI cards ─────────────────────────────────────────────────────
        const PatientsSummary(screenType: LayoutType.desktop),

        const SizedBox(height: 24),

        // ── Search + filter bar ──────────────────────────────────────────────
        const PatientsToolbar(hint: 'Search name, file number, ID or mobile'),

        const SizedBox(height: 24),

        // ── Recent patients heading and table ────────────────────────────────
        Obx(() {
          final rows = controller.pageEntries;
          final current = controller.page.value;
          final count = controller.pageCount;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius),
              border: Border.all(color: AppColors.borderDefault, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.sectionPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent patients',
                          style: AppTextStyles.h3.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        controller.rangeLabel.replaceFirst('Showing ', ''),
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Column labels sit on the app background, below the white title band.
                Container(
                  height: Dimensions.tableHeaderHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundApp,
                    border: Border(
                      top: BorderSide(color: AppColors.borderDefault, width: 1),
                      bottom: BorderSide(color: AppColors.borderDefault, width: 1),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text('Patient', style: _colStyle),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('File', style: _colStyle),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('DOB', style: _colStyle),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text('Mobile', style: _colStyle),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text('Last visit', style: _colStyle),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text('Status', style: _colStyle),
                      ),
                    ],
                  ),
                ),

                // Data rows
                if (rows.isEmpty)
                  const PatientsEmptyState()
                else
                  for (final p in rows)
                    _PatientRow(
                      patient: p,
                      onView: () => controller.viewPatient(p),
                    ),

                // Pagination footer
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.rangeLabel,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          // Previous chevron
                          _PaginationChevron(
                            icon: Icons.chevron_left,
                            enabled: current > 1,
                            onTap: current > 1
                                ? () => controller.goToPage(current - 1)
                                : null,
                          ),
                          const SizedBox(width: 4),
                          // Page number pills
                          for (var i = 1; i <= count; i++)
                            _PagePill(
                              page: i,
                              selected: i == current,
                              onTap: () => controller.goToPage(i),
                            ),
                          const SizedBox(width: 4),
                          // Next chevron
                          _PaginationChevron(
                            icon: Icons.chevron_right,
                            enabled: current < count,
                            onTap: current < count
                                ? () => controller.goToPage(current + 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
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
        Dimensions.pageMarginDesktop,
        Dimensions.pageMarginDesktop,
        Dimensions.pageMarginDesktop,
        Dimensions.pageMarginDesktop,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                    style: AppTextStyles.body.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.spaceMd),
            AppButton.primary(
              label: 'Open Queue',
              onPressed: controller.openQueue,
            ),
          ],
        ),
        const SizedBox(height: Dimensions.spaceLg),
        const PatientsToolbar(
          hint: 'Search name, ID or queue number',
          showFilter: true,
        ),
        const SizedBox(height: Dimensions.spaceLg),
        Obx(() {
          final rows = controller.pageEntries;
          final hasSearch = controller.searchQuery.value.trim().isNotEmpty;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius),
              border: Border.all(color: AppColors.borderDefault, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.sectionPadding),
                  child: Text(
                    'Patient directory',
                    style: AppTextStyles.h3.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (rows.isEmpty)
                  const PatientsEmptyState()
                else
                  _buildDoctorPatientTable(context, rows),
                if (!hasSearch) ...[
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderDefault,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.sectionPadding,
                      vertical: 18,
                    ),
                    child: DoctorPatientPagination(),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDoctorPatientTable(
    BuildContext context,
    List<PatientRecord> rows,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 760.0;
        final table = Column(
          children: [
            // Header Row
            Container(
              height: Dimensions.tableHeaderHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.sectionPadding,
              ),
              decoration: const BoxDecoration(
                color: AppColors.backgroundApp,
                border: Border(
                  top: BorderSide(color: AppColors.borderDefault, width: 1),
                  bottom: BorderSide(color: AppColors.borderDefault, width: 1),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Patient',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Folder number',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Last visit',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Care flags',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Action',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Data Rows
            for (final patient in rows)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.sectionPadding,
                  vertical: Dimensions.tableRowVerticalPadding,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderDefault),
                  ),
                ),
                child: Row(
                  children: [
                    // Patient
                    Expanded(
                      child: Text(
                        patient.name,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // Folder number
                    Expanded(
                      child: Text(
                        patient.fileNumber,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    // Last visit
                    Expanded(
                      child: Text(
                        patient.lastVisit,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    // Care flags
                    Expanded(
                      child: Text(
                        patient.careFlags ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    // Action
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _DoctorPatientActionMenu(
                          patient: patient,
                          onViewProfile: (p) =>
                              setState(() => _selectedDoctorPatient = p),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );

        if (constraints.maxWidth < minWidth) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: minWidth, child: table),
          );
        }
        return table;
      },
    );
  }
}

class _DoctorPatientActionMenu extends StatefulWidget {
  const _DoctorPatientActionMenu({
    required this.patient,
    required this.onViewProfile,
  });

  final PatientRecord patient;
  final ValueChanged<PatientRecord> onViewProfile;

  @override
  State<_DoctorPatientActionMenu> createState() =>
      _DoctorPatientActionMenuState();
}

class _DoctorPatientActionMenuState extends State<_DoctorPatientActionMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: Color(0x1F000000),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Actions for ${widget.patient.name}',
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 6,
        shadowColor: const Color(0x1F000000),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        constraints: const BoxConstraints.tightFor(width: 212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        onSelected: (action) {
          if (action == 'profile') {
            widget.onViewProfile(widget.patient);
          } else {
            AppNavigation.goToConsultationWorkspace(
              returnRoute: AppRoutes.patients,
              patient: widget.patient,
            );
          }
        },
        itemBuilder: (_) => [
          const AppActionMenuItem<String>(
            value: 'profile',
            label: 'View Profile',
            alignment: Alignment.center,
          ),
          const AppActionMenuItem<String>(
            value: 'consultation',
            label: 'Start Consultation',
            alignment: Alignment.center,
          ),
        ],
        child: const AppActionsBoxButton(icon: Icons.more_vert),
      ),
    );
  }
}

/// Doctor-only desktop profile opened from the Patients directory action menu.
/// Kept in this file so front-desk and existing patient profile flows stay intact.
class DoctorPatientProfileResponsive extends StatelessWidget {
  const DoctorPatientProfileResponsive({
    super.key,
    required this.patient,
    required this.onBack,
    this.backLabel = 'Back to Patients',
    this.returnRoute = AppRoutes.patients,
    this.status,
  });

  final PatientRecord patient;
  final VoidCallback onBack;
  final String backLabel;
  final String returnRoute;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return switch (ResponsiveHelper.screenType(context)) {
      LayoutType.mobile => _buildMobile(context),
      LayoutType.tablet => _buildTablet(context),
      LayoutType.desktop => _buildDesktop(context),
    };
  }

  Widget _buildDesktop(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final folder = patient.fileNumber;
    final profileMeta = patient.name == 'John Smith'
        ? '52 / Male  ·  DOB 12 Mar 1974  ·  ID: 740312 5021 087  ·  Folder: #$folder  ·  +27 82 555 0143'
        : 'DOB not recorded  ·  Folder: #$folder  ·  Last visit: ${patient.lastVisit}  ·  ${patient.mobile}';
    final initials = patient.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.pageMarginDesktop,
        Dimensions.pageMarginDesktop,
        Dimensions.pageMarginDesktop,
        Dimensions.pageMarginDesktop,
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              onTap: onBack,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.controlX,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Dimensions.spaceSm,
                  children: [
                    Icon(
                      AppIcons.arrowLeft,
                      size: Dimensions.iconSize,
                      color: scheme.primary,
                    ),
                    Text(
                      backLabel,
                      style: AppTextStyles.label.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.pageSectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Patient profile',
                      style: AppTextStyles.h1.copyWith(color: scheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: Dimensions.spaceXs),
                  Text(
                    'Review ${patient.name}’s history before starting the consultation.',
                    style: AppTextStyles.body.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.spaceMd),
            AppButton.primary(
              label: 'Start Consultation',
              onPressed: () => AppNavigation.goToConsultationWorkspace(
                returnRoute: returnRoute,
                patient: patient,
                status: status,
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.spaceLg),
        AppCard(
          padding: const EdgeInsets.all(Dimensions.spaceMd),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(Dimensions.radius),
                ),
                child: Text(
                  initials,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: Dimensions.spaceSm,
                      runSpacing: Dimensions.spaceXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          patient.name,
                          style: AppTextStyles.h3.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        _ProfileBadge(
                          label: patient.queueNumber ?? 'Q015',
                          foreground: scheme.primary,
                          background: scheme.primaryContainer,
                        ),
                        const _ProfileBadge(
                          label: 'Urgent',
                          foreground: AppColors.feedbackWarning,
                          background: AppColors.feedbackWarningTint,
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.spaceXs),
                    Text(
                      profileMeta,
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.spaceMd),
              Container(
                width: 144,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.spaceMd,
                  vertical: Dimensions.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  border: Border.all(color: scheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REASON FOR VISIT',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      patient.name == 'John Smith'
                          ? 'Follow-up'
                          : 'Not recorded',
                      style: AppTextStyles.label.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.spaceLg),
        _CriticalAlert(careFlag: patient.careFlags),
        const SizedBox(height: Dimensions.spaceLg),
        const _PreviousConsultations(),
        const SizedBox(height: Dimensions.spaceLg),
        _profilePair(
          context,
          const _DiagnosisPanel(),
          const _PrescriptionPanel(),
        ),
        const SizedBox(height: Dimensions.spaceLg),
        _profilePair(context, const _VitalsPanel(), const _LabResultsPanel()),
        const SizedBox(height: Dimensions.spaceLg),
        const _TimelinePanel(),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.pageMarginMobile,
            vertical: 12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.borderDefault),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Semantics(
                button: true,
                label: backLabel,
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusControl,
                  ),
                  child: Container(
                    width: Dimensions.touchTarget,
                    height: Dimensions.touchTarget,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusControl,
                      ),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Center(
                      child: Icon(
                        AppIcons.chevronLeft,
                        size: Dimensions.iconSize,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.spaceMd),
              Expanded(
                child: Text(
                  'Patient profile',
                  style: AppTextStyles.h2Mobile.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
            children: [
              _ResponsivePatientIdentityCard(patient: patient),
              const SizedBox(height: Dimensions.spaceSm),
              _CriticalAlert(careFlag: patient.careFlags, compact: true),
              const SizedBox(height: Dimensions.spaceMd),
              Text(
                'Previous consultations',
                style: AppTextStyles.h3Mobile.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: Dimensions.spaceSm),
              const _PreviousConsultationCards(),
              const SizedBox(height: Dimensions.spaceSm),
              const DoctorPatientPagination(showRange: false, demoOnly: true),
              const SizedBox(height: Dimensions.spaceMd),
              const _DiagnosisPanel(),
              const SizedBox(height: Dimensions.spaceSm),
              const _PrescriptionPanel(),
              const SizedBox(height: Dimensions.spaceSm),
              const _VitalsPanel(columns: 2),
              const SizedBox(height: Dimensions.spaceSm),
              const _LabResultsPanel(),
              const SizedBox(height: Dimensions.spaceSm),
              const _TimelinePanel(),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: _StickyConsultationAction(
            mobile: true,
            returnRoute: returnRoute,
            patient: patient,
            status: status,
          ),
        ),
      ],
    );
  }

  Widget _buildTablet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.pageMarginTablet,
            vertical: 12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.borderDefault),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Semantics(
                button: true,
                label: backLabel,
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(
                    Dimensions.radiusControl,
                  ),
                  child: Container(
                    width: Dimensions.touchTarget,
                    height: Dimensions.touchTarget,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusControl,
                      ),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Center(
                      child: Icon(
                        AppIcons.chevronLeft,
                        size: Dimensions.iconSize,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.spaceMd),
              Expanded(
                child: Text(
                  'Patient profile',
                  style: AppTextStyles.h2.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(Dimensions.pageMarginTablet),
            children: [
              _ResponsivePatientIdentityCard(patient: patient),
              const SizedBox(height: Dimensions.spaceMd),
              _CriticalAlert(careFlag: patient.careFlags),
              const SizedBox(height: Dimensions.spaceLg),
              Text(
                'Previous consultations',
                style: AppTextStyles.h3.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: Dimensions.spaceMd),
              const _PreviousConsultationCards(),
              const SizedBox(height: Dimensions.spaceSm),
              const Align(
                alignment: Alignment.centerRight,
                child: DoctorPatientPagination(
                  showRange: false,
                  demoOnly: true,
                  alignment: Alignment.centerRight,
                ),
              ),
              const SizedBox(height: Dimensions.spaceLg),
              _profilePair(
                context,
                const _DiagnosisPanel(),
                const _PrescriptionPanel(),
              ),
              const SizedBox(height: Dimensions.spaceLg),
              const _VitalsPanel(columns: 2),
              const SizedBox(height: Dimensions.spaceLg),
              _profilePair(
                context,
                const _LabResultsPanel(),
                const _TimelinePanel(),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: _StickyConsultationAction(
            mobile: false,
            returnRoute: returnRoute,
            patient: patient,
            status: status,
          ),
        ),
      ],
    );
  }

  Widget _profilePair(BuildContext context, Widget first, Widget second) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              first,
              const SizedBox(height: Dimensions.spaceLg),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: Dimensions.spaceLg),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _ResponsivePatientIdentityCard extends StatelessWidget {
  const _ResponsivePatientIdentityCard({required this.patient});

  final PatientRecord patient;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isJohn = patient.name == 'John Smith';
    final initials = patient.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
                child: Text(
                  initials,
                  style: AppTextStyles.label.copyWith(color: scheme.primary),
                ),
              ),
              const SizedBox(width: Dimensions.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: AppTextStyles.label.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isJohn ? '52 / Male' : 'Demographic details not recorded',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.spaceXs),
              _ProfileBadge(
                label: patient.queueNumber ?? 'Q015',
                foreground: scheme.primary,
                background: scheme.primaryContainer,
              ),
              const SizedBox(width: Dimensions.spaceXs),
              const _ProfileBadge(
                label: 'Urgent',
                foreground: AppColors.feedbackWarning,
                background: AppColors.feedbackWarningTint,
              ),
            ],
          ),
          const SizedBox(height: Dimensions.spaceSm),
          const Divider(height: 1),
          const SizedBox(height: Dimensions.spaceSm),
          _ProfileMetaRow(
            label: 'Date of birth',
            value: isJohn ? '12 Mar 1974' : patient.dateOfBirth,
          ),
          const SizedBox(height: Dimensions.spaceXs),
          _ProfileMetaRow(
            label: 'ID',
            value: isJohn ? '740312 5021 087' : 'Not recorded',
          ),
          const SizedBox(height: Dimensions.spaceXs),
          _ProfileMetaRow(label: 'Folder', value: '#${patient.fileNumber}'),
          const SizedBox(height: Dimensions.spaceXs),
          _ProfileMetaRow(
            label: 'Phone',
            value: isJohn ? '+27 82 555 0143' : patient.mobile,
          ),
          const SizedBox(height: Dimensions.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.spaceSm,
              vertical: Dimensions.spaceSm,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: _ProfileMetaRow(
              label: 'Reason for visit',
              value: isJohn ? 'Follow-up' : 'Not recorded',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetaRow extends StatelessWidget {
  const _ProfileMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StickyConsultationAction extends StatelessWidget {
  const _StickyConsultationAction({
    required this.mobile,
    this.returnRoute = AppRoutes.patients,
    this.patient,
    this.status,
  });

  final bool mobile;
  final String returnRoute;
  final PatientRecord? patient;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        mobile ? Dimensions.pageMarginMobile : Dimensions.pageMarginDesktop,
        Dimensions.spaceSm,
        mobile ? Dimensions.pageMarginMobile : Dimensions.pageMarginDesktop,
        Dimensions.spaceSm,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      child: AppButton.primary(
        label: 'Start Consultation',
        onPressed: () => AppNavigation.goToConsultationWorkspace(
          returnRoute: returnRoute,
          patient: patient,
          status: status,
        ),
        expand: true,
      ),
    );
  }
}

class _PreviousConsultationCards extends StatelessWidget {
  const _PreviousConsultationCards();

  static const _items = [
    (
      '14 Aug 2026',
      'Dr. Maya Naidoo',
      'General check-up',
      'R51 Headache (example)',
    ),
    (
      '02 May 2026',
      'Dr. Thandi Nkosi',
      'Minor injury',
      'G44.2 Tension-type headache (example)',
    ),
    ('18 Jan 2026', 'Dr. Maya Naidoo', 'Acute cough', 'J20.9 Acute bronchitis'),
    ('18 Jan 2026', 'Dr. Maya Naidoo', 'Acute cough', 'J20.9 Acute bronchitis'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 520;
        final cardWidth = twoColumns
            ? (constraints.maxWidth - Dimensions.spaceMd) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: Dimensions.spaceMd,
          runSpacing: Dimensions.spaceMd,
          children: [
            for (final item in _items)
              SizedBox(
                width: cardWidth,
                child: _PreviousConsultationCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _PreviousConsultationCard extends StatelessWidget {
  const _PreviousConsultationCard({required this.item});

  final (String, String, String, String) item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.$1,
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const _ProfileBadge(
                label: 'Signed',
                foreground: AppColors.brandPrimary,
                background: AppColors.brandTint,
              ),
            ],
          ),
          const Divider(height: 18),
          _ConsultationMetaRow(label: 'Clinician', value: item.$2),
          const SizedBox(height: Dimensions.spaceXs),
          _ConsultationMetaRow(label: 'Reason', value: item.$3),
          const SizedBox(height: Dimensions.spaceXs),
          _ConsultationMetaRow(label: 'Diagnosis', value: item.$4),
        ],
      ),
    );
  }
}

class _ConsultationMetaRow extends StatelessWidget {
  const _ConsultationMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Dimensions.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: foreground),
      ),
    );
  }
}

class _CriticalAlert extends StatelessWidget {
  const _CriticalAlert({required this.careFlag, this.compact = false});

  final String? careFlag;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final alert = careFlag == null || careFlag == '—'
        ? 'No critical allergy recorded'
        : careFlag == 'Penicillin allergy'
        ? 'Allergy: Penicillin (anaphylaxis)'
        : careFlag;
    final alertHeading = careFlag == 'Penicillin allergy'
        ? 'CRITICAL ALERT'
        : 'CARE FLAG';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.spaceMd,
        vertical: Dimensions.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.safetyCriticalBackground.withValues(alpha: .42),
        border: Border.all(
          color: AppColors.safetyCriticalText.withValues(alpha: .3),
        ),
        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$alertHeading  ·  $alert',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.safetyCriticalText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Chronic: none recorded (illustrative)',
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.safetyCriticalText,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusControl,
                    ),
                  ),
                  child: const Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$alertHeading  ·  $alert',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.safetyCriticalText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Chronic: none recorded (illustrative)',
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PreviousConsultations extends StatelessWidget {
  const _PreviousConsultations();

  static const _rows = [
    [
      '14 Aug 2026',
      'Dr. Maya Naidoo',
      'General check-up',
      'R51 Headache (example)',
      'Signed',
    ],
    [
      '02 May 2026',
      'Dr. Thandi Nkosi',
      'Minor injury',
      'G44.2 Tension-type headache (example)',
      'Signed',
    ],
    [
      '18 Jan 2026',
      'Dr. Maya Naidoo',
      'Acute cough',
      'J20.9 Acute bronchitis',
      'Signed',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const flexes = [11, 15, 18, 25, 8];
    const headings = ['Date', 'Clinician', 'Reason', 'Diagnosis', 'Status'];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.spaceMd,
        Dimensions.spaceMd,
        Dimensions.spaceMd,
        Dimensions.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Previous consultations',
            style: AppTextStyles.bodyMedium.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: Dimensions.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.spaceSm),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: Row(
              children: [
                for (var i = 0; i < headings.length; i++)
                  Expanded(
                    flex: flexes[i],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        headings[i],
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (var rowIndex = 0; rowIndex < _rows.length; rowIndex++) ...[
            Row(
              children: [
                for (
                  var colIndex = 0;
                  colIndex < _rows[rowIndex].length;
                  colIndex++
                )
                  Expanded(
                    flex: flexes[colIndex],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: Dimensions.spaceMd,
                      ),
                      child: Text(
                        _rows[rowIndex][colIndex],
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
            if (rowIndex < _rows.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: Dimensions.spaceSm),
          child,
        ],
      ),
    );
  }
}

class _DiagnosisPanel extends StatelessWidget {
  const _DiagnosisPanel();

  @override
  Widget build(BuildContext context) {
    return const _ProfilePanel(
      title: 'Existing diagnoses',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileDetailLine(
            title: 'R51 · Headache (example code)',
            detail: 'Chronic · since 2019',
          ),
          Divider(height: 20),
          _ProfileDetailLine(
            title: 'G44.2 · Tension-type headache (example code)',
            detail: 'Chronic · since 2021',
          ),
        ],
      ),
    );
  }
}

class _PrescriptionPanel extends StatelessWidget {
  const _PrescriptionPanel();

  @override
  Widget build(BuildContext context) {
    return const _ProfilePanel(
      title: 'Previous prescriptions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileDetailLine(
            title: 'Paracetamol 500 mg',
            detail: '1 tablet as needed · 5 days · 14 Aug 2026',
          ),
          Divider(height: 20),
          _ProfileDetailLine(
            title: 'Ibuprofen 200 mg',
            detail: '1 tablet as needed · 5 days · 14 Aug 2026',
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailLine extends StatelessWidget {
  const _ProfileDetailLine({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.label.copyWith(color: scheme.onSurface),
          ),
          Text(
            detail,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalsPanel extends StatelessWidget {
  const _VitalsPanel({this.columns = 4});

  final int columns;

  static const _values = [
    ('BP', '142/90', 'mmHg'),
    ('Pulse', '78', 'bpm'),
    ('Temp', '36.7', '°C'),
    ('SpO₂', '98', '%'),
    ('Weight', '91.2', 'kg'),
    ('Height', '178', 'cm'),
    ('BMI', '28.8', 'kg/m²'),
    ('Glucose', '8.4', 'mmol/L'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _ProfilePanel(
      title: 'Latest vitals',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: columns == 2
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              'Today 09:10 · Nurse Khanyile',
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.spaceSm),
          LayoutBuilder(
            builder: (context, constraints) {
              final gapsWidth = Dimensions.spaceSm * (columns - 1);
              final tileWidth = (constraints.maxWidth - gapsWidth) / columns;
              return Wrap(
                spacing: Dimensions.spaceSm,
                runSpacing: Dimensions.spaceSm,
                children: [
                  for (final value in _values)
                    SizedBox(
                      width: tileWidth,
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.spaceSm),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusControl,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              value.$1,
                              style: AppTextStyles.caption.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: '${value.$2} ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: scheme.onSurface,
                                ),
                                children: [
                                  TextSpan(
                                    text: value.$3,
                                    style: AppTextStyles.caption.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LabResultsPanel extends StatelessWidget {
  const _LabResultsPanel();

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.screenType(context) == LayoutType.mobile;
    return _ProfilePanel(
      title: 'Lab results',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isMobile) ...[
            const _ProfileDetailLine(
              title: 'Full blood count · Reviewed',
              detail: 'Above target (<7.0%) · 10 Aug 2026',
            ),
            const Divider(height: 20),
            const _ProfileDetailLine(
              title: 'No results flagged',
              detail: '10 Aug 2026',
            ),
          ] else
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ProfileDetailLine(
                    title: 'Full blood count · Reviewed',
                    detail: 'Above target (<7.0%) · 10 Aug 2026',
                  ),
                ),
                SizedBox(width: Dimensions.spaceSm),
                Expanded(
                  child: _ProfileDetailLine(
                    title: 'No results flagged',
                    detail: '10 Aug 2026',
                  ),
                ),
              ],
            ),
          const Divider(height: 20),
          const _ProfileDetailLine(
            title: 'eGFR · 84 mL/min',
            detail: 'Normal · 10 Aug 2026',
          ),
        ],
      ),
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel();

  static const _events = [
    ('14 Aug 2026', 'Previous visit · General check-up'),
    ('10 Aug 2026', 'Lab results received · Full blood count'),
    ('02 May 2026', 'Previous visit · Minor injury'),
    ('18 Jan 2026', 'Acute bronchitis · Azithromycin (penicillin avoided)'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _ProfilePanel(
      title: 'Patient timeline',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final event in _events)
            Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.spaceSm),
              child: Row(
                children: [
                  Container(
                    width: Dimensions.stateDot,
                    height: Dimensions.stateDot,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: Dimensions.spaceSm),
                  SizedBox(
                    width: 112,
                    child: Text(
                      event.$1,
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      event.$2,
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Individual table row ─────────────────────────────────────────────────────
class _PatientRow extends StatelessWidget {
  const _PatientRow({required this.patient, required this.onView});

  final PatientRecord patient;
  final VoidCallback onView;

  bool get _isInQueue => patient.queueNumber != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDefault, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Patient name
          Expanded(
            flex: 5,
            child: Text(
              patient.name,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // File number
          Expanded(
            flex: 4,
            child: Text(
              patient.fileNumber,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // DOB
          Expanded(
            flex: 4,
            child: Text(
              patient.dateOfBirth,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Mobile
          Expanded(
            flex: 5,
            child: Text(
              patient.mobile,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Last visit
          Expanded(
            flex: 4,
            child: Text(
              patient.lastVisit,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Status + View →
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    patient.status,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _isInQueue
                          ? AppColors.feedbackInfo
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onView,
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'View →',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pagination helpers ───────────────────────────────────────────────────────
class _PagePill extends StatelessWidget {
  const _PagePill({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final int page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Dimensions.touchTarget,
        height: Dimensions.touchTarget,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PaginationChevron extends StatelessWidget {
  const _PaginationChevron({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Dimensions.touchTarget,
        height: Dimensions.touchTarget,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: Dimensions.iconSize,
          color: enabled ? AppColors.textSecondary : AppColors.textDisabled,
        ),
      ),
    );
  }
}
