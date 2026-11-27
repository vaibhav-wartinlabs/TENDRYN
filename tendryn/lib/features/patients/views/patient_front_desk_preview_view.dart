import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/views/dashboard_view.dart';
import 'package:tendryn/features/patients/controllers/patient_front_desk_preview_controller.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';
import 'package:tendryn/widgets/desktop/side_navigation.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

/// Responsive Front Desk Patient preview/dialogue box.
/// Automatically adapts between:
/// - Desktop (>= 1200): Right-side drawer panel over dimmed dashboard backdrop.
/// - Tablet (600..1199): Tablet layout with TabletHeader, `<` back button, sticky bottom actions, and bottom nav.
/// - Mobile (< 600): Mobile layout with `<` back button, sticky bottom actions, and bottom nav.
class PatientFrontDeskPreviewView extends GetView<PatientFrontDeskPreviewController> {
  const PatientFrontDeskPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (ResponsiveHelper.screenType(context)) {
      LayoutType.desktop => _buildDesktop(context),
      LayoutType.tablet => _buildTablet(context),
      LayoutType.mobile => _buildMobile(context),
    };
  }

  // ---------------------------------------------------------------------------
  // DESKTOP LAYOUT (Right-side Drawer over darkened dashboard)
  // ---------------------------------------------------------------------------
  Widget _buildDesktop(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Underlying dashboard visible behind the drawer
          Positioned.fill(
            child: Row(
              children: [
                AppSideNavigation(
                  destinations: NavDestinations.receptionist,
                  selectedIndex: 0,
                  onSelected: (_) {},
                ),
                const Expanded(
                  child: DashboardView(),
                ),
              ],
            ),
          ),
          // Darkened semi-transparent overlay
          Positioned.fill(
            child: GestureDetector(
              key: const Key('front_desk_preview_overlay'),
              onTap: controller.onBack,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),
          // Right-side drawer
          Align(
            alignment: Alignment.centerRight,
            child: PatientFrontDeskPreviewDrawer(
              onClose: controller.onBack,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABLET LAYOUT (TabletHeader + `<` Back button + Sticky Actions + Bottom Nav)
  // ---------------------------------------------------------------------------
  Widget _buildTablet(BuildContext context) {
    final landscape = ResponsiveHelper.isTabletLandscape(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TabletHeader(),
            Container(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.pageMarginDesktop,
                24,
                Dimensions.pageMarginDesktop,
                24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.backgroundSurface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: _buildTabletHeaderRow(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginDesktop,
                  vertical: Dimensions.spaceMd,
                ),
                child: landscape
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Dimensions.spaceLg,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildBadgesRow(),
                                const SizedBox(height: 16),
                                _buildDetailsCard(),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildRecentActivitySection(),
                                const SizedBox(height: 16),
                                AppButton.secondary(
                                  label: 'View Patient',
                                  onPressed: controller.viewPatientProfile,
                                  expand: true,
                                ),
                                const SizedBox(height: 8),
                                _buildCaptionText(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBadgesRow(),
                          const SizedBox(height: 16),
                          _buildDetailsCard(),
                          const SizedBox(height: Dimensions.pageSectionGap),
                          _buildRecentActivitySection(),
                          const SizedBox(height: 16),
                          AppButton.secondary(
                            label: 'View Patient',
                            onPressed: controller.viewPatientProfile,
                            expand: true,
                          ),
                          const SizedBox(height: 8),
                          _buildCaptionText(),
                          const SizedBox(height: 24),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildStickyActions(
        controller: controller,
        horizontal: Dimensions.pageMarginDesktop,
        vertical: Dimensions.spaceMd,
      ),
    );
  }

  Widget _buildTabletHeaderRow() {
    return Obx(() {
      final p = controller.patient.value;
      final fileNo = p.fileNumber.startsWith('#') ? p.fileNumber : '#${p.fileNumber}';
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _BackButton(onTap: controller.onBack),
          const SizedBox(width: Dimensions.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.name,
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'File $fileNo',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // MOBILE LAYOUT (SafeArea + `<` Back button + Sticky Actions + Bottom Nav)
  // ---------------------------------------------------------------------------
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundSurface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                Dimensions.pageMarginMobile,
                12,
                Dimensions.pageMarginMobile,
                12,
              ),
              child: _buildMobileHeaderRow(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginMobile,
                  vertical: Dimensions.spaceMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBadgesRow(),
                    const SizedBox(height: 16),
                    _buildDetailsCard(),
                    const SizedBox(height: Dimensions.pageSectionGap),
                    _buildRecentActivitySection(),
                    const SizedBox(height: 16),
                    AppButton.secondary(
                      label: 'View Patient',
                      onPressed: controller.viewPatientProfile,
                      expand: true,
                    ),
                    const SizedBox(height: 8),
                    _buildCaptionText(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildStickyActions(
        controller: controller,
        horizontal: Dimensions.pageMarginMobile,
        vertical: Dimensions.spaceSm + 4,
      ),
    );
  }

  Widget _buildMobileHeaderRow() {
    return Obx(() {
      final p = controller.patient.value;
      final fileNo = p.fileNumber.startsWith('#') ? p.fileNumber : '#${p.fileNumber}';
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _BackButton(onTap: controller.onBack),
          const SizedBox(width: Dimensions.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.name,
                  style: AppTextStyles.h3Mobile.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'File $fileNo',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // SHARED CONTENT CARDS
  // ---------------------------------------------------------------------------

  Widget _buildBadgesRow() {
    return Obx(() {
      final p = controller.patient.value;
      return Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _PillBadge(
            text: 'Front desk view',
            backgroundColor: AppColors.brandTint,
            textColor: AppColors.brandPrimary,
          ),
          _PillBadge(
            text: 'WhatsApp ${p.whatsAppStatus.isNotEmpty ? p.whatsAppStatus : "Active"}',
            backgroundColor: AppColors.feedbackSuccessTint,
            textColor: AppColors.feedbackSuccess,
          ),
        ],
      );
    });
  }

  Widget _buildDetailsCard() {
    return Obx(() {
      final p = controller.patient.value;
      final rawFile = p.fileNumber.replaceAll('#', '');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          border: Border.all(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(
              'Date of birth / age',
              Text(
                p.dobAndAge,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _buildDetailRow(
              'Mobile',
              Text(
                p.phone,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _buildDetailRow(
              'File number',
              Text(
                rawFile,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              isLast: true,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, Widget valueWidget, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: Dimensions.spaceSm),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Obx(() {
      final p = controller.patient.value;
      final lastVisit = p.name.contains('Nkosi') ? '14 Aug 2026' : '03 Sep 2026';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent front desk activity',
            style: AppTextStyles.label.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last visit $lastVisit · No outstanding front desk tasks',
            style: AppTextStyles.caption.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCaptionText() {
    return Text(
      'Opens the existing receptionist Patient Profile.',
      style: AppTextStyles.caption.copyWith(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DESKTOP DRAWER COMPONENT
// ---------------------------------------------------------------------------

class PatientFrontDeskPreviewDrawer extends StatelessWidget {
  const PatientFrontDeskPreviewDrawer({
    super.key,
    required this.onClose,
    this.controller,
  });

  final VoidCallback onClose;
  final PatientFrontDeskPreviewController? controller;

  @override
  Widget build(BuildContext context) {
    final effectiveController = controller ?? Get.find<PatientFrontDeskPreviewController>();

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
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
              _buildHeader(effectiveController),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderDefault,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBadgesRow(effectiveController),
                      const SizedBox(height: 16),
                      _buildDetailsCard(effectiveController),
                      const SizedBox(height: Dimensions.pageSectionGap),
                      _buildRecentActivitySection(effectiveController),
                      const SizedBox(height: 16),
                      AppButton.secondary(
                        label: 'View Patient',
                        onPressed: effectiveController.viewPatientProfile,
                        expand: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Opens the existing receptionist Patient Profile.',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildStickyActions(
                controller: effectiveController,
                horizontal: Dimensions.spaceLg,
                vertical: Dimensions.spaceMd,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PatientFrontDeskPreviewController ctrl) {
    return Obx(() {
      final p = ctrl.patient.value;
      final fileNo = p.fileNumber.startsWith('#') ? p.fileNumber : '#${p.fileNumber}';
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.spaceLg,
          Dimensions.spaceLg,
          Dimensions.spaceMd,
          Dimensions.spaceMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.name,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'File $fileNo',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('front_desk_preview_close_button'),
              icon: const Icon(AppIcons.close, size: Dimensions.iconSize, color: AppColors.textSecondary),
              tooltip: 'Close',
              onPressed: onClose,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBadgesRow(PatientFrontDeskPreviewController ctrl) {
    return Obx(() {
      final p = ctrl.patient.value;
      return Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _PillBadge(
            text: 'Front desk view',
            backgroundColor: AppColors.brandTint,
            textColor: AppColors.brandPrimary,
          ),
          _PillBadge(
            text: 'WhatsApp ${p.whatsAppStatus.isNotEmpty ? p.whatsAppStatus : "Active"}',
            backgroundColor: AppColors.feedbackSuccessTint,
            textColor: AppColors.feedbackSuccess,
          ),
        ],
      );
    });
  }

  Widget _buildDetailsCard(PatientFrontDeskPreviewController ctrl) {
    return Obx(() {
      final p = ctrl.patient.value;
      final rawFile = p.fileNumber.replaceAll('#', '');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          border: Border.all(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(
              'Date of birth / age',
              Text(
                p.dobAndAge,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _buildDetailRow(
              'Mobile',
              Text(
                p.phone,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _buildDetailRow(
              'File number',
              Text(
                rawFile,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              isLast: true,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, Widget valueWidget, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: Dimensions.spaceSm),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(PatientFrontDeskPreviewController ctrl) {
    return Obx(() {
      final p = ctrl.patient.value;
      final lastVisit = p.name.contains('Nkosi') ? '14 Aug 2026' : '03 Sep 2026';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent front desk activity',
            style: AppTextStyles.label.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last visit $lastVisit · No outstanding front desk tasks',
            style: AppTextStyles.caption.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    });
  }
}

// ---------------------------------------------------------------------------
// HELPER WIDGETS
// ---------------------------------------------------------------------------

Widget _buildStickyActions({
  required PatientFrontDeskPreviewController controller,
  required double horizontal,
  required double vertical,
}) {
  return Container(
    decoration: const BoxDecoration(
      color: AppColors.backgroundSurface,
      border: Border(
        top: BorderSide(
          color: AppColors.borderDefault,
          width: Dimensions.strokeDivider,
        ),
      ),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        child: Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: 'Add to Queue',
                onPressed: controller.addToQueue,
                expand: true,
              ),
            ),
            const SizedBox(width: Dimensions.spaceMd),
            Expanded(
              child: AppButton.primary(
                label: 'Book Appointment',
                onPressed: controller.bookAppointment,
                expand: true,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('front_desk_preview_back_button'),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
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
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusPill),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// Show the Patient Front Desk preview as a desktop overlay drawer over the current screen.
void showPatientSearchPreviewDrawer(
  BuildContext context, {
  String returnRoute = AppRoutes.dashboard,
  PatientQuickViewModel? patient,
}) {
  Get.put(PatientFrontDeskPreviewController(
    returnRoute: returnRoute,
    initialPatient: patient,
  ));

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return PatientFrontDeskPreviewDrawer(
        onClose: () {
          Navigator.of(dialogContext).pop();
        },
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
    if (Get.isRegistered<PatientFrontDeskPreviewController>()) {
      Get.delete<PatientFrontDeskPreviewController>();
    }
  });
}
