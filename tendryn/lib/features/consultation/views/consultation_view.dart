import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/consultation/controllers/consultation_controller.dart';
import 'package:tendryn/features/consultation/models/consultation_record.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/features/patients/widgets/patients_desktop.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_action_menu.dart';

/// Consultations directory view showing consultation records, status, and management.
class ConsultationView extends StatefulWidget {
  const ConsultationView({super.key});

  @override
  State<ConsultationView> createState() => _ConsultationViewState();
}

class _ConsultationViewState extends State<ConsultationView> {
  late final ConsultationController controller;
  PatientRecord? _selectedPatient;
  String? _selectedStatus;

  void _openPatientProfile(ConsultationRecord record) {
    controller.setProfileOpen(true);
    setState(() {
      _selectedPatient = _resolvePatientRecord(record);
      _selectedStatus = record.status.label;
    });
  }

  void _closePatientProfile() {
    controller.setProfileOpen(false);
    setState(() {
      _selectedPatient = null;
      _selectedStatus = null;
    });
  }

  PatientRecord _resolvePatientRecord(ConsultationRecord record) {
    if (Get.isRegistered<PatientsController>()) {
      final match = Get.find<PatientsController>().patients.firstWhereOrNull(
        (p) => p.name.toLowerCase() == record.patientName.toLowerCase(),
      );
      if (match != null) return match;
    }
    final seedMatch = PatientsController.seed.firstWhereOrNull(
      (p) => p.name.toLowerCase() == record.patientName.toLowerCase(),
    );
    if (seedMatch != null) return seedMatch;

    return PatientRecord(
      name: record.patientName,
      fileNumber: 'SWC-10492',
      dateOfBirth: '12 Oct 1985',
      mobile: '082 ••• ••14',
      lastVisit: record.visit,
      queueNumber: record.consultationNumber.isNotEmpty
          ? record.consultationNumber
          : 'Q-004',
      careFlags: 'Asthma',
    );
  }

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ConsultationController>()) {
      controller = Get.find<ConsultationController>();
    } else {
      controller = Get.put(ConsultationController());
    }
    if (!Get.isRegistered<PatientsController>()) {
      Get.lazyPut<PatientsController>(() => PatientsController());
    }
  }

  @override
  void dispose() {
    controller.setProfileOpen(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPatient != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _closePatientProfile();
        },
        child: DoctorPatientProfileResponsive(
          patient: _selectedPatient!,
          status: _selectedStatus,
          backLabel: 'Back to consultations',
          returnRoute: AppRoutes.consultations,
          onBack: _closePatientProfile,
        ),
      );
    }

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final horizontalPadding = isMobile
        ? Dimensions.pageMarginMobile
        : (isTablet
              ? Dimensions.pageMarginTablet
              : Dimensions.pageMarginDesktop);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isMobile
              ? Dimensions.pageMarginMobile
              : Dimensions.pageMarginTablet,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──────────────────────────────────────────────────
            _buildHeader(context),
            const SizedBox(height: 24),

            // ── Search & Filter Bar ─────────────────────────────────────────
            _buildSearchAndFilterBar(context),
            const SizedBox(height: 24),

            // ── Consultation Records ────────────────────────────────────────
            if (isDesktop)
              _buildDesktopRecordsCard(context)
            else
              _buildMobileAndTabletContent(context),
            const SizedBox(height: Dimensions.pageSectionGap),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consultations',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: isMobile ? 26 : 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage drafts, signed notes, and follow-up actions.',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context) {
    return Row(
      children: [
        // Search Input
        Expanded(
          child: Container(
            height: Dimensions.buttonMinHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search Patients or consultation...',
                hintStyle: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  color: AppColors.textDisabled,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  AppIcons.search,
                  size: 18,
                  color: AppColors.textDisabled,
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(
                      AppIcons.close,
                      size: Dimensions.iconSize,
                      color: AppColors.textDisabled,
                    ),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.onSearchChanged('');
                    },
                  );
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Filter button
        PopupMenuButton<String>(
          tooltip: 'Filter records',
          onSelected: controller.setFilter,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            side: const BorderSide(color: AppColors.borderDefault),
          ),
          color: Colors.white,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'All', child: Text('All statuses')),
            const PopupMenuItem(
              value: 'In progress',
              child: Text('In progress'),
            ),
            const PopupMenuItem(value: 'Draft', child: Text('Draft')),
            const PopupMenuItem(value: 'Signed', child: Text('Signed')),
          ],
          child: Container(
            width: Dimensions.buttonMinHeight,
            height: Dimensions.buttonMinHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: const Icon(
              AppIcons.filter,
              size: Dimensions.iconSize,
              color: AppColors.brandPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Desktop Table Card ────────────────────────────────────────────────────
  Widget _buildDesktopRecordsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Title
            const Padding(
              padding: EdgeInsets.all(Dimensions.sectionPadding),
              child: Text(
                'Consultation records',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),

            // Table / Content
            Obx(() {
              final records = controller.pagedRecords;

              if (records.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  alignment: Alignment.center,
                  child: const Text(
                    'No consultations found',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  const minWidth = 760.0;
                  if (constraints.maxWidth < minWidth) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: minWidth,
                        child: _buildTable(records),
                      ),
                    );
                  }
                  return _buildTable(records);
                },
              );
            }),

            // Table Footer with Pagination
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<ConsultationRecord> records) {
    return Column(
      children: [
        // Header Row
        Container(
          height: Dimensions.tableHeaderHeight,
          padding:
              const EdgeInsets.symmetric(horizontal: Dimensions.sectionPadding),
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
                  'Visit',
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
                  'Status',
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
                  'Last updated',
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
                    'Actions',
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

        // Record Rows
        for (final record in records) _buildRecordRow(record),
      ],
    );
  }

  Widget _buildRecordRow(ConsultationRecord record) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.sectionPadding,
        vertical: Dimensions.tableRowVerticalPadding,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          // Patient
          Expanded(
            child: Text(
              record.patientName,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Visit
          Expanded(
            child: Text(
              record.visit,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Status
          Expanded(
            child: Text(
              record.status.label,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Last Updated
          Expanded(
            child: Text(
              record.lastUpdated,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Actions
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _ConsultationActionMenu(
                record: record,
                onViewProfile: _openPatientProfile,
                onStartConsultation: () =>
                    AppNavigation.goToConsultationWorkspace(
                      returnRoute: AppRoutes.consultations,
                      patient: _resolvePatientRecord(record),
                      status: record.status.label,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile & Tablet Cards View ───────────────────────────────────────────
  Widget _buildMobileAndTabletContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultation records',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isTabletGrid = constraints.maxWidth >= 600;
            final itemWidth = isTabletGrid
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;

            return Obx(() {
              final records = isTabletGrid
                  ? controller.pagedRecords
                  : controller.filteredRecords;

              if (records.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radius),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: const Text(
                    'No consultations found',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final record in records)
                        SizedBox(
                          width: itemWidth,
                          child: _buildConsultationCard(record),
                        ),
                    ],
                  ),
                  // Pagination footer on tablet ONLY (hidden on mobile per user instruction)
                  if (isTabletGrid) ...[
                    const SizedBox(height: 24),
                    _buildFooter(padding: EdgeInsets.zero),
                  ],
                ],
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildConsultationCard(ConsultationRecord record) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Patient Name + Status Badge on left, 3-Dots pinned to far right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        record.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(record.status),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ConsultationActionMenu(
                record: record,
                onViewProfile: _openPatientProfile,
                onStartConsultation: () =>
                    AppNavigation.goToConsultationWorkspace(
                      returnRoute: AppRoutes.consultations,
                      patient: _resolvePatientRecord(record),
                      status: record.status.label,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visit Line
          Text(
            'Visit: ${record.visit}',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          // Last updated Line
          Text(
            'Last updated: ${record.lastUpdated}',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ConsultationRecordStatus status) {
    final Color bgColor;
    final Color textColor;

    switch (status) {
      case ConsultationRecordStatus.inProgress:
        bgColor = AppColors.feedbackSuccessTint;
        textColor = AppColors.brandPrimary;
        break;
      case ConsultationRecordStatus.draft:
        bgColor = AppColors.feedbackWarningTint;
        textColor = AppColors.feedbackWarning;
        break;
      case ConsultationRecordStatus.signed:
        bgColor = AppColors.feedbackInfoTint;
        textColor = AppColors.feedbackInfo;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  // ── Pagination Footer ─────────────────────────────────────────────────────
  Widget _buildFooter({EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: Dimensions.sectionPadding,
            vertical: 18,
          ),
      child: Obx(() {
        final total = controller.totalRecords;
        final current = controller.currentPage.value;
        final totalPages = controller.totalPages;

        final showingText = total == 0
            ? 'Showing 0 consultations'
            : 'Showing 1–$total of $total consultations';

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 420;

            final paginationControls = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Previous Button
                InkWell(
                  onTap: current > 1 ? controller.previousPage : null,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  child: Container(
                    height: Dimensions.buttonMinHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusControl,
                      ),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: current > 1
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Active Page Number Box
                Container(
                  width: Dimensions.touchTarget,
                  height: Dimensions.touchTarget,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusControl,
                    ),
                  ),
                  child: Text(
                    '$current',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Next Button
                InkWell(
                  onTap: current < totalPages ? controller.nextPage : null,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  child: Container(
                    height: Dimensions.buttonMinHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusControl,
                      ),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: current < totalPages
                            ? AppColors.brandPrimary
                            : AppColors.textDisabled,
                      ),
                    ),
                  ),
                ),
              ],
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showingText,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  paginationControls,
                ],
              );
            }

            return Row(
              children: [
                Text(
                  showingText,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                paginationControls,
              ],
            );
          },
        );
      }),
    );
  }
}

/// Three-dots action popup menu with centered green text and light green hover effect.
class _ConsultationActionMenu extends StatelessWidget {
  const _ConsultationActionMenu({
    required this.record,
    required this.onViewProfile,
    required this.onStartConsultation,
  });

  final ConsultationRecord record;
  final ValueChanged<ConsultationRecord> onViewProfile;
  final VoidCallback onStartConsultation;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
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
        tooltip: 'Actions',
        elevation: 6,
        shadowColor: const Color(0x1F000000),
        surfaceTintColor: Colors.transparent,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 196),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        onSelected: (value) {
          if (value == 'view_profile') {
            onViewProfile(record);
          } else if (value == 'start_consultation') {
            onStartConsultation();
          }
        },
        itemBuilder: (context) => [
          const AppActionMenuItem<String>(
            value: 'view_profile',
            label: 'View profile',
            alignment: Alignment.center,
          ),
          const AppActionMenuItem<String>(
            value: 'start_consultation',
            label: 'Start consultation',
            alignment: Alignment.center,
          ),
        ],
        child: const AppActionsBoxButton(icon: AppIcons.rowMenu),
      ),
    );
  }
}
