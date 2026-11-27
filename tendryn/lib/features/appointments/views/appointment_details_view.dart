import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_icon_button.dart';
import 'package:tendryn/widgets/common/connectivity_sync_chip.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';
import 'package:tendryn/widgets/desktop/side_navigation.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/features/patients/views/patient_quick_view.dart';

// -----------------------------------------------------------------------------
// Model
// -----------------------------------------------------------------------------

/// Data model representing an appointment's full detail view.
class AppointmentDetailsModel {
  const AppointmentDetailsModel({
    required this.patient,
    required this.fileNumber,
    required this.date,
    required this.time,
    required this.practitioner,
    required this.visitType,
    required this.status,
    required this.arrival,
    required this.explanatoryText,
  });

  final String patient;
  final String fileNumber;
  final String date;
  final String time;
  final String practitioner;
  final String visitType;
  final String status;
  final String arrival;
  final String explanatoryText;

  /// Default mock matching the prototype design (Lindiwe Ndlovu).
  static const AppointmentDetailsModel lindiweNdlovu = AppointmentDetailsModel(
    patient: 'Lindiwe Ndlovu',
    fileNumber: 'File #PT-001746 · 083 ••• ••18',
    date: 'Tuesday 29 September 2026',
    time: '14:00',
    practitioner: 'Dr Thandi Maseko',
    visitType: 'Follow-up',
    status: 'Checked In',
    arrival: '13:52',
    explanatoryText:
        'This appointment is already checked in. No Check In action is shown.',
  );

  /// Factory constructor to convert from Dashboard [AppointmentEntry].
  factory AppointmentDetailsModel.fromEntry(AppointmentEntry entry) {
    final isCheckedIn = entry.status == AppointmentStatus.checkedIn;
    final fileNum =
        '#PT-00${(entry.patient.hashCode.abs() % 9000 + 1000).toString()}';
    return AppointmentDetailsModel(
      patient: entry.patient,
      fileNumber: 'File $fileNum · 083 ••• ••18',
      date: 'Tuesday 29 September 2026',
      time: entry.time,
      practitioner: entry.practitioner,
      visitType: entry.visitType,
      status: entry.status.label,
      arrival: isCheckedIn ? '13:52' : '-',
      explanatoryText: isCheckedIn
          ? 'This appointment is already checked in. No Check In action is shown.'
          : 'Appointment scheduled for ${entry.time}.',
    );
  }
}

// -----------------------------------------------------------------------------
// Controller
// -----------------------------------------------------------------------------

/// GetX controller for Appointment Details.
class AppointmentDetailsController extends GetxController {
  AppointmentDetailsController({
    AppointmentEntry? initialAppointment,
    AppointmentDetailsModel? initialDetails,
  }) : details = (initialDetails ??
                (initialAppointment != null
                    ? AppointmentDetailsModel.fromEntry(initialAppointment)
                    : AppointmentDetailsModel.lindiweNdlovu))
            .obs;

  final Rx<AppointmentDetailsModel> details;
  final RxInt selectedNavIndex = 0.obs;

  void onBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.dashboard);
    }
  }

  void onViewPatient() {
    final patientVm = _resolvePatient();
    final context = Get.context;

    if (context != null && ResponsiveHelper.usesDrawer(context)) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      final rootContext = Get.context ?? context;
      showPatientQuickViewDrawer(
        rootContext,
        patient: patientVm,
        returnRoute: AppRoutes.dashboard,
      );
    } else {
      Get.toNamed(
        AppRoutes.patientQuickView,
        arguments: {
          'patient': patientVm,
          'returnRoute': AppRoutes.dashboard,
        },
      );
    }
  }

  PatientQuickViewModel _resolvePatient() {
    final name = details.value.patient.trim();
    if (Get.isRegistered<DashboardController>()) {
      final queueItems =
          Get.find<DashboardController>().summary.value?.queue ?? [];
      final match = queueItems.firstWhereOrNull(
        (q) => q.patient.toLowerCase() == name.toLowerCase(),
      );
      if (match != null) {
        return PatientQuickViewModel.fromQueueEntry(match);
      }
    }
    final fileMatch =
        RegExp(r'#PT-[0-9]+').firstMatch(details.value.fileNumber);
    final fileNum = fileMatch?.group(0) ?? '#PT-001746';
    final phoneMatch =
        RegExp(r'\d{3}\s*•••\s*••\d{2}').firstMatch(details.value.fileNumber);
    final phoneNum = phoneMatch?.group(0) ?? '083 ••• ••18';

    return PatientQuickViewModel.forPatient(
      name: details.value.patient,
      fileNumber: fileNum,
      phone: phoneNum,
      practitioner: details.value.practitioner,
      visitReason: details.value.visitType,
      status: details.value.status,
      arrivedTime:
          details.value.arrival != '-' ? details.value.arrival : '13:52',
    );
  }

  void onViewInAppointments() {
    AppNotice.unavailable('View in Appointments');
  }

  void onNavSelected(int index) {
    selectedNavIndex.value = index;
    final destinations = NavDestinations.receptionist;
    if (index >= 0 && index < destinations.length) {
      Get.offNamed(destinations[index].route);
    }
  }
}

// -----------------------------------------------------------------------------
// Unified Responsive View (Mobile, Tablet, Desktop)
// -----------------------------------------------------------------------------

/// Single unified responsive Appointment Details component.
class AppointmentDetailsView extends GetView<AppointmentDetailsController> {
  const AppointmentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (ResponsiveHelper.screenType(context)) {
      LayoutType.desktop => _buildDesktop(context),
      LayoutType.tablet => _buildTablet(context),
      LayoutType.mobile => _buildMobile(context),
    };
  }

  // ---------------------------------------------------------------------------
  // Desktop Layout (Full Page fallback showing overlay drawer)
  // ---------------------------------------------------------------------------
  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: [
                AppSideNavigation(
                  destinations: NavDestinations.receptionist,
                  selectedIndex: 0,
                  onSelected: (_) => controller.onBack(),
                ),
                Expanded(
                  child: Container(color: AppColors.backgroundApp),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: controller.onBack,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withValues(alpha: 0.45)),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: AppointmentDetailsDrawer(onClose: controller.onBack),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tablet Layout
  // ---------------------------------------------------------------------------
  Widget _buildTablet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(Dimensions.tabletHeaderHeight),
        child: TabletHeader(),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.pageMarginDesktop,
              vertical: Dimensions.spaceMd,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: scheme.outline,
                  width: Dimensions.strokeDivider,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildBackSquareButton(context, onTap: controller.onBack),
                const SizedBox(width: Dimensions.spaceMd),
                Text(
                  'Appointment Details',
                  style: AppTextStyles.h2.copyWith(color: scheme.onSurface),
                ),
                const Spacer(),
                const ConnectivitySyncChip(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
              child: ResponsiveHelper.isTabletLandscape(context)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Dimensions.spaceLg,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _AppointmentPatientCard(controller: controller),
                        ),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AppointmentInfoCard(controller: controller),
                              const SizedBox(height: Dimensions.spaceMd),
                              _AppointmentExplanatoryText(controller: controller),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AppointmentPatientCard(controller: controller),
                            const SizedBox(height: Dimensions.spaceLg),
                            _AppointmentInfoCard(controller: controller),
                            const SizedBox(height: Dimensions.spaceMd),
                            _AppointmentExplanatoryText(controller: controller),
                            const SizedBox(height: Dimensions.spaceXl),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AppointmentBottomActions(
        controller: controller,
        isTablet: true,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile Layout
  // ---------------------------------------------------------------------------
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      appBar: _buildMobileTopBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.pageMarginMobile,
          vertical: Dimensions.spaceSm + 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AppointmentPatientCard(controller: controller),
            const SizedBox(height: Dimensions.spaceMd),
            _AppointmentInfoCard(controller: controller),
            const SizedBox(height: Dimensions.spaceMd),
            _AppointmentExplanatoryText(controller: controller),
            const SizedBox(height: Dimensions.spaceSm),
          ],
        ),
      ),
      bottomNavigationBar: _AppointmentBottomActions(controller: controller),
    );
  }

  PreferredSizeWidget _buildMobileTopBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSurface,
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderDefault,
              width: Dimensions.strokeDivider,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: Dimensions.spaceSm),
                _buildBackSquareButton(context, onTap: controller.onBack),
                const SizedBox(width: Dimensions.spaceSm),
                Expanded(
                  child: Text(
                    'Appointment Details',
                    style: AppTextStyles.h2Mobile.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildBackSquareButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Back',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          child: SizedBox.square(
            dimension: Dimensions.touchTarget,
            child: Center(
              child: Container(
                width: Dimensions.touchTarget,
                height: Dimensions.touchTarget,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border.all(
                    color: scheme.outline,
                    width: Dimensions.strokeDivider,
                  ),
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
                child: Icon(
                  AppIcons.chevronLeft,
                  size: Dimensions.iconSize,
                  color: scheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Desktop Drawer Component
// -----------------------------------------------------------------------------

/// The overlay drawer used on desktop displays.
class AppointmentDetailsDrawer extends StatelessWidget {
  const AppointmentDetailsDrawer({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentDetailsController>();
    return Material(
      elevation: 16,
      shadowColor: Colors.black45,
      child: Container(
        width: Dimensions.drawerWidth,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.backgroundSurface,
          border: Border(
            left: BorderSide(
              color: AppColors.borderDefault,
              width: Dimensions.strokeDivider,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.spaceLg,
                vertical: Dimensions.spaceMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment Details',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(
                          () => Text(
                            '${controller.details.value.date} · ${controller.details.value.time}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppIconButton(
                    icon: AppIcons.close,
                    tooltip: 'Close',
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderDefault,
            ),
            // Drawer body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AppointmentPatientCard(controller: controller),
                    const SizedBox(height: Dimensions.spaceLg),
                    _AppointmentInfoCard(controller: controller, isDesktop: true),
                    const SizedBox(height: Dimensions.spaceLg),
                    _AppointmentExplanatoryText(controller: controller),
                  ],
                ),
              ),
            ),
            // Drawer footer buttons
            _AppointmentBottomActions(controller: controller, isDesktopDrawer: true),
          ],
        ),
      ),
    );
  }
}

/// Helper function to display the drawer on Desktop overlay.
void showAppointmentDetailsDrawer(
  BuildContext context, {
  AppointmentEntry? appointment,
  AppointmentDetailsModel? details,
}) {
  Get.put(
    AppointmentDetailsController(
      initialAppointment: appointment,
      initialDetails: details,
    ),
  );

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: AppointmentDetailsDrawer(
          onClose: () => Navigator.of(dialogContext).pop(),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(
        position: slideAnimation,
        child: child,
      );
    },
  ).then((_) {
    if (Get.isRegistered<AppointmentDetailsController>()) {
      Get.delete<AppointmentDetailsController>();
    }
  });
}

// -----------------------------------------------------------------------------
// Shared Sub-widgets
// -----------------------------------------------------------------------------

class _AppointmentPatientCard extends StatelessWidget {
  const _AppointmentPatientCard({required this.controller});

  final AppointmentDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(
          color: AppColors.brandTint,
          width: Dimensions.strokeDivider,
        ),
      ),
      child: Obx(() {
        final details = controller.details.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              details.patient,
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.brandHover,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              details.fileNumber,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _AppointmentInfoCard extends StatelessWidget {
  const _AppointmentInfoCard({
    required this.controller,
    this.isDesktop = false,
  });

  final AppointmentDetailsController controller;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final content = Obx(() {
      final d = controller.details.value;
      const rowSpacing = SizedBox(height: Dimensions.sectionContentGap);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRow('Date', d.date),
          rowSpacing,
          _buildRow('Time', d.time),
          rowSpacing,
          _buildRow('Practitioner', d.practitioner),
          rowSpacing,
          _buildRow('Visit type', d.visitType),
          rowSpacing,
          _buildRowWithWidget(
            'Status',
            isDesktop
                ? Text(
                    d.status,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.feedbackSuccess,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.spaceSm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.feedbackSuccessTint,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusPill),
                    ),
                    child: Text(
                      d.status,
                      style: AppTextStyles.micro.copyWith(
                        color: AppColors.feedbackSuccess,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          rowSpacing,
          _buildRow('Arrival / check-in', d.arrival),
        ],
      );
    });

    if (isDesktop) {
      // Desktop: No surrounding box or border, rows sit directly on drawer background
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      );
    }

    // Tablet & Mobile: Box container, but NO underlines/dividers between rows
    return Container(
      padding: const EdgeInsets.all(Dimensions.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(
          color: AppColors.borderDefault,
          width: Dimensions.strokeDivider,
        ),
      ),
      child: content,
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRowWithWidget(String label, Widget widget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        widget,
      ],
    );
  }
}

class _AppointmentExplanatoryText extends StatelessWidget {
  const _AppointmentExplanatoryText({required this.controller});

  final AppointmentDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Text(
        controller.details.value.explanatoryText,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

class _AppointmentBottomActions extends StatelessWidget {
  const _AppointmentBottomActions({
    required this.controller,
    this.isDesktopDrawer = false,
    this.isTablet = false,
  });

  final AppointmentDetailsController controller;
  final bool isDesktopDrawer;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    if (isDesktopDrawer) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.spaceMd),
        decoration: const BoxDecoration(
          color: AppColors.backgroundSurface,
          border: Border(
            top: BorderSide(
              color: AppColors.borderDefault,
              width: Dimensions.strokeDivider,
            ),
          ),
        ),
        child: _buildButtons(),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: isTablet
              ? const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginDesktop,
                  vertical: Dimensions.spaceMd,
                )
              : const EdgeInsets.fromLTRB(
                  Dimensions.pageMarginMobile,
                  Dimensions.spaceSm + 2,
                  Dimensions.pageMarginMobile,
                  Dimensions.spaceSm + 2,
                ),
          child: _buildButtons(),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton.secondary(
            label: 'View Patient',
            onPressed: controller.onViewPatient,
          ),
        ),
        const SizedBox(width: Dimensions.spaceMd),
        Expanded(
          child: AppButton.primary(
            label: 'View in Appointments',
            onPressed: controller.onViewInAppointments,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Check In Patient Modal & Bottom Sheet (Single unified implementation)
// -----------------------------------------------------------------------------

/// Opens the responsive Check In Patient modal:
/// - Desktop / Tablet: Centered modal dialog with darkened backdrop.
/// - Mobile: Bottom sheet sliding from bottom with drag handle.
void showCheckInPatientModal(
  BuildContext context, {
  required AppointmentEntry appointment,
}) {
  final isMobile = ResponsiveHelper.isMobile(context);

  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xA30F1F1D),
      builder: (dialogContext) => _CheckInBottomSheet(appointment: appointment),
    );
  } else {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0xA30F1F1D),
      builder: (dialogContext) => _CheckInDialog(appointment: appointment),
    );
  }
}

/// Desktop and Tablet centered modal dialog.
class _CheckInDialog extends StatelessWidget {
  const _CheckInDialog({required this.appointment});

  final AppointmentEntry appointment;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Material(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            elevation: 8,
            shadowColor: const Color(0x33000000),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _CheckInFormContent(appointment: appointment),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile bottom sheet container.
class _CheckInBottomSheet extends StatelessWidget {
  const _CheckInBottomSheet({required this.appointment});

  final AppointmentEntry appointment;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.borderDefault,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: _CheckInFormContent(appointment: appointment),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared form content for Check In Dialog and Bottom Sheet.
class _CheckInFormContent extends StatefulWidget {
  const _CheckInFormContent({required this.appointment});

  final AppointmentEntry appointment;

  @override
  State<_CheckInFormContent> createState() => _CheckInFormContentState();
}

class _CheckInFormContentState extends State<_CheckInFormContent> {
  QueuePriority selectedPriority = QueuePriority.routine;
  bool isDropdownOpen = false;
  bool sendWhatsApp = false;
  bool patientConsent = true;
  bool isCheckingIn = false;

  void _handleCheckIn() async {
    setState(() {
      isCheckingIn = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().completeCheckIn(
        appointment: widget.appointment,
        priority: selectedPriority,
        sendWhatsApp: sendWhatsApp,
      );
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    Get.closeAllSnackbars();
    Get.snackbar(
      'Checked in',
      '${widget.appointment.patient} has been added to today’s live queue.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientFirstName = widget.appointment.patient.split(' ').first;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title + Close Icon
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check in patient?',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Add this appointment to today’s live queue.',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              child: SizedBox.square(
                dimension: Dimensions.touchTarget,
                child: Center(
                  child: Icon(
                    AppIcons.close,
                    size: Dimensions.iconSize,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Patient Card (Mint background)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.brandTint,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(
              color: AppColors.brandTint,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appointment.patient,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.appointment.practitioner} · ${widget.appointment.visitType}',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.appointment.time,
                style: AppTextStyles.tabular(AppTextStyles.h2).copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.sectionContentGap),

        // Dynamic Explanatory Text
        Text(
          'Check-in adds $patientFirstName to today’s live queue and inherits ${widget.appointment.practitioner} as practitioner. Routine is selected by default.',
          style: AppTextStyles.caption.copyWith(
            fontSize: 13.5,
            height: 1.45,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Priority label
        Text(
          'Priority',
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),

        // Priority Dropdown Field
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownOpen = !isDropdownOpen;
            });
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(
                color: isDropdownOpen
                    ? AppColors.brandPrimary
                    : AppColors.borderDefault,
                width: isDropdownOpen ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedPriority.label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _priorityTextColor(selectedPriority),
                  ),
                ),
                Icon(
                  isDropdownOpen
                      ? AppIcons.chevronUp
                      : AppIcons.chevronDown,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),

        // Dropdown Items (shown when open)
        if (isDropdownOpen) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildPriorityOption(
                  priority: QueuePriority.routine,
                  textColor: AppColors.textPrimary,
                ),
                const Divider(
                    height: 1, thickness: 1, color: AppColors.backgroundApp),
                _buildPriorityOption(
                  priority: QueuePriority.urgent,
                  textColor: AppColors.feedbackWarning,
                ),
                const Divider(
                    height: 1, thickness: 1, color: AppColors.backgroundApp),
                _buildPriorityOption(
                  priority: QueuePriority.emergency,
                  textColor: AppColors.triageRed,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Send WhatsApp Switch
        GestureDetector(
          onTap: () {
            setState(() {
              sendWhatsApp = !sendWhatsApp;
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 24,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: sendWhatsApp
                      ? AppColors.brandPrimary
                      : AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(Dimensions.radius),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: sendWhatsApp
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send WhatsApp queue updates',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sendWhatsApp
                          ? 'WhatsApp-enabled. Confirm patient consent below.'
                          : 'Off by default until patient consent is confirmed.',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Patient Consent Checkbox (shown when WhatsApp toggle is ON)
        if (sendWhatsApp) ...[
          const SizedBox(height: Dimensions.sectionContentGap),
          GestureDetector(
            onTap: () {
              setState(() {
                patientConsent = !patientConsent;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 2, right: 10),
                  decoration: BoxDecoration(
                    color: patientConsent
                        ? AppColors.brandPrimary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: patientConsent
                          ? AppColors.brandPrimary
                          : AppColors.borderDefault,
                      width: 1.5,
                    ),
                  ),
                  child: patientConsent
                      ? const Icon(AppIcons.check,
                          size: 13, color: Colors.white)
                      : null,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient consented to WhatsApp queue updates',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Queue information only — never clinical information.',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Checking In Banner (visible during processing)
        if (isCheckingIn) ...[
          const SizedBox(height: Dimensions.sectionContentGap),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.brandTint,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(
                color: AppColors.brandTint,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Checking in... Please keep this window open.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: Dimensions.pageSectionGap),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Cancel',
                onPressed: isCheckingIn
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isCheckingIn
                  ? Container(
                      height: Dimensions.buttonMinHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundApp,
                        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                      ),
                      child: Text(
                        'Checking in...',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : AppButton.primary(
                      label: 'Check In',
                      onPressed: _handleCheckIn,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityOption({
    required QueuePriority priority,
    required Color textColor,
  }) {
    final isSelected = selectedPriority == priority;
    return InkWell(
      onTap: () {
        setState(() {
          selectedPriority = priority;
          isDropdownOpen = false;
        });
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandTint : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: priority == QueuePriority.routine ? const Radius.circular(7) : Radius.zero,
            bottom: priority == QueuePriority.emergency ? const Radius.circular(7) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Text(
              priority.label,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected && priority == QueuePriority.routine
                    ? AppColors.textPrimary
                    : textColor,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(AppIcons.check,
                  size: 15, color: AppColors.brandPrimary),
            ],
          ],
        ),
      ),
    );
  }

  Color _priorityTextColor(QueuePriority priority) {
    switch (priority) {
      case QueuePriority.routine:
        return AppColors.textPrimary;
      case QueuePriority.urgent:
        return AppColors.feedbackWarning;
      case QueuePriority.emergency:
        return AppColors.triageRed;
    }
  }
}
