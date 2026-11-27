import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/patients/controllers/patient_quick_view_controller.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/connectivity_sync_chip.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';
import 'package:tendryn/features/patients/widgets/assign_practitioner_dropdown.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Single unified responsive Patient Quick View component.
/// Automatically adapts between:
/// - Desktop (>= 1200): Centered responsive page layout (or overlay drawer when invoked via [showPatientQuickViewDrawer]).
/// - Tablet (600..1199): Centered responsive page layout with header and sticky bottom actions.
/// - Mobile (< 600): Mobile full-page layout with back bar and bottom nav.
class PatientQuickView extends GetView<PatientQuickViewController> {
  const PatientQuickView({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (ResponsiveHelper.screenType(context)) {
      LayoutType.desktop => _buildDesktop(context),
      LayoutType.tablet => _buildTablet(context),
      LayoutType.mobile => _buildMobile(context),
    };
  }

  // ---------------------------------------------------------------------------
  // DESKTOP LAYOUT (Consistent centered layout matching tablet)
  // ---------------------------------------------------------------------------
  Widget _buildDesktop(BuildContext context) => _buildTablet(context);

  // ---------------------------------------------------------------------------
  // TABLET & DESKTOP FULL-PAGE LAYOUT
  // ---------------------------------------------------------------------------
  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TabletHeader(),
            _buildTabletSubheader(context),
            Expanded(
              // Full viewport width (like Billing's tablet page); no desktop-style cap.
              child: SingleChildScrollView(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginDesktop,
                  vertical: Dimensions.spaceLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPatientHeaderCard(isDesktop: false),
                    const SizedBox(height: Dimensions.spaceMd),
                    _buildPatientDetailsCard(),
                    const SizedBox(height: Dimensions.spaceMd),
                    Obx(() => controller.isDropdownVisible.value
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: Dimensions.spaceLg),
                            child: KeyedSubtree(
                              key: controller.assignKey,
                              child: AssignPractitionerDropdown(controller: controller),
                            ),
                          )
                        : const SizedBox.shrink()),
                    _buildExplanatoryText(),
                    const SizedBox(height: Dimensions.spaceLg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
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
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.isTabletLandscape(context)
                    ? double.infinity
                    : 840,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginDesktop,
                  vertical: Dimensions.spaceMd,
                ),
                child: _buildActionButtons(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletSubheader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginDesktop),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
      ),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: Dimensions.spaceMd),
          Expanded(
            child: Text(
              'Patient Quick View',
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const ConnectivitySyncChip(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE LAYOUT (Full-page mobile layout matching imageprototype3)
  // ---------------------------------------------------------------------------
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      appBar: _buildMobileTopBar(context),
      body: SingleChildScrollView(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.pageMarginMobile,
          vertical: Dimensions.spaceSm + 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPatientHeaderCard(isDesktop: false),
            const SizedBox(height: Dimensions.spaceMd),
            _buildPatientDetailsCard(),
            const SizedBox(height: Dimensions.spaceMd),
            Obx(() => controller.isDropdownVisible.value
                ? Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.spaceLg),
                    child: KeyedSubtree(
                      key: controller.assignKey,
                      child: AssignPractitionerDropdown(controller: controller),
                    ),
                  )
                : const SizedBox.shrink()),
            _buildExplanatoryText(),
            const SizedBox(height: Dimensions.spaceSm),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
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
            padding: const EdgeInsets.fromLTRB(
              Dimensions.pageMarginMobile,
              Dimensions.spaceSm + 2,
              Dimensions.pageMarginMobile,
              Dimensions.spaceSm + 2,
            ),
            child: _buildActionButtons(),
          ),
        ),
      ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginMobile),
              child: Row(
                children: [
                  _buildBackButton(),
                  const SizedBox(width: Dimensions.spaceMd),
                  Expanded(
                    child: Text(
                      'Patient Quick View',
                      style: AppTextStyles.h3Mobile.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Tooltip(
      message: 'Back',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('quick_view_back_button'),
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          onTap: controller.onBack,
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

  // ---------------------------------------------------------------------------
  // SHARED PRESENTATIONAL CARDS & SUBCOMPONENTS
  // ---------------------------------------------------------------------------

  /// Card 1: Patient Information Card (mint/brand tint background)
  Widget _buildPatientHeaderCard({required bool isDesktop}) {
    return Obx(() {
      final p = controller.patient.value;
      return Container(
        padding: const EdgeInsets.all(Dimensions.spaceMd + 2),
        decoration: BoxDecoration(
          color: AppColors.brandTint,
          borderRadius: BorderRadius.circular(Dimensions.radius),
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
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Dimensions.spaceXs),
                  Text(
                    'File ${p.fileNumber} · ${p.phone}',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(Dimensions.radiusPill),
                  border: Border.all(
                    color: AppColors.feedbackSuccess.withValues(alpha: 0.3),
                    width: Dimensions.strokeDivider,
                  ),
                ),
                child: Text(
                  'WhatsApp ${p.whatsAppStatus}',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.feedbackSuccess,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Card 2: Patient Details Card (white card with 1px border and pill badges)
  Widget _buildPatientDetailsCard() {
    return Obx(() {
      final p = controller.patient.value;
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.spaceMd + 4,
          vertical: Dimensions.spaceMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(Dimensions.radius),
          border: Border.all(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('DOB / age', Text(
              p.dobAndAge,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            )),
            _buildDetailRow('Queue', _buildPillBadge(
              p.queueNumber,
              backgroundColor: AppColors.brandTint,
              textColor: AppColors.brandPrimary,
            )),
            _buildDetailRow('Arrived', Text(
              p.arrivedTime,
              style: AppTextStyles.tabular(AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
            )),
            _buildDetailRow('Waiting', Text(
              p.waitingDuration,
              style: AppTextStyles.tabular(AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
            )),
            _buildDetailRow('Visit reason', Text(
              p.visitReason,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            )),
            _buildDetailRow('Priority', _buildPillBadge(
              p.priority,
              backgroundColor: AppColors.brandTint,
              textColor: AppColors.brandPrimary,
            )),
            _buildDetailRow('Status', _buildPillBadge(
              p.status,
              backgroundColor: AppColors.brandTint,
              textColor: AppColors.brandPrimary,
            )),
            _buildDetailRow('Practitioner', Text(
              p.practitioner,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            )),
            _buildDetailRow('WhatsApp', _buildPillBadge(
              p.whatsAppStatus,
              backgroundColor: AppColors.feedbackSuccessTint,
              textColor: AppColors.feedbackSuccess,
            ), isLast: true),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, Widget valueWidget, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 13),
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

  Widget _buildPillBadge(
    String text, {
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusPill),
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildExplanatoryText() {
    return Text(
      'Manage Queue opens the existing Queue destination. View Patient opens the existing receptionist Patient Profile.',
      style: AppTextStyles.caption.copyWith(
        fontSize: 13,
        height: 1.45,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final isDropdownVisible = controller.isDropdownVisible.value;
      final isAssignMode = controller.isAssignMode.value;

      return Row(
        children: [
          Expanded(
            child: AppButton.secondary(
              label: isAssignMode ? 'Add to Queue' : 'Manage Queue',
              onPressed: isAssignMode ? controller.addToQueue : controller.manageQueue,
            ),
          ),
          const SizedBox(width: Dimensions.spaceMd),
          Expanded(
            child: AppButton.primary(
              label: isDropdownVisible ? 'Save Assignment' : 'Assign Practitioner',
              onPressed: isDropdownVisible ? controller.saveAssignment : controller.startAssignment,
            ),
          ),
        ],
      );
    });
  }


}

/// Desktop-only overlay drawer for Patient Quick View.
/// Shown via [showPatientQuickViewDrawer] — no route navigation needed,
/// so the underlying dashboard stays completely untouched.
class PatientQuickViewDrawer extends StatelessWidget {
  const PatientQuickViewDrawer({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    // Controller is registered by the caller before showing this overlay.
    final controller = Get.find<PatientQuickViewController>();
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
                  _buildHeader(controller),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderDefault,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.all(Dimensions.spaceLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPatientHeaderCard(controller),
                          const SizedBox(height: Dimensions.spaceMd),
                          _buildPatientDetailsCard(controller),
                          const SizedBox(height: Dimensions.spaceMd),
                          Obx(() => controller.isDropdownVisible.value
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: Dimensions.spaceLg),
                                  child: KeyedSubtree(
                                    key: controller.assignKey,
                                    child: AssignPractitionerDropdown(controller: controller),
                                  ),
                                )
                              : const SizedBox.shrink()),
                          _buildExplanatoryText(),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(Dimensions.spaceLg),
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundSurface,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.borderDefault,
                          width: Dimensions.strokeDivider,
                        ),
                      ),
                    ),
                    child: _buildActionButtons(controller),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHeader(PatientQuickViewController controller) {
    return Obx(() {
      final p = controller.patient.value;
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
                    'Patient Quick View',
                    style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: Dimensions.spaceXs),
                  Text(
                    '${p.queueNumber} · ${p.name} · File ${p.fileNumber}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('quick_view_close_button'),
              icon: const Icon(AppIcons.close, size: Dimensions.iconSize, color: AppColors.textSecondary),
              tooltip: 'Close',
              onPressed: onClose,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPatientHeaderCard(PatientQuickViewController controller) {
    return Obx(() {
      final p = controller.patient.value;
      return Container(
        padding: const EdgeInsets.all(Dimensions.spaceMd + 2),
        decoration: BoxDecoration(
          color: AppColors.brandTint,
          borderRadius: BorderRadius.circular(Dimensions.radius),
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
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Dimensions.spaceXs),
                  Text(
                    'File ${p.fileNumber} · ${p.phone}',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(Dimensions.radiusPill),
                border: Border.all(
                  color: AppColors.feedbackSuccess.withValues(alpha: 0.3),
                  width: Dimensions.strokeDivider,
                ),
              ),
              child: Text(
                'WhatsApp ${p.whatsAppStatus}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.feedbackSuccess,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPatientDetailsCard(PatientQuickViewController controller) {
    return Obx(() {
      final p = controller.patient.value;
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.spaceMd + 4,
          vertical: Dimensions.spaceMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(Dimensions.radius),
          border: Border.all(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('DOB / age', Text(
              p.dobAndAge,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            )),
            _buildDetailRow('Queue', _buildPillBadge(
              p.queueNumber,
              backgroundColor: AppColors.brandTint,
              textColor: AppColors.brandPrimary,
            )),
            _buildDetailRow('Arrived', Text(
              p.arrivedTime,
              style: AppTextStyles.tabular(AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
            )),
            _buildDetailRow('Waiting', Text(
              p.waitingDuration,
              style: AppTextStyles.tabular(AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
            )),
            _buildDetailRow('Visit reason', Text(
              p.visitReason,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            )),
            _buildDetailRow('Priority', _buildPillBadge(
              p.priority,
              backgroundColor: AppColors.brandTint,
              textColor: AppColors.brandPrimary,
            )),
            _buildDetailRow('Status', _buildPillBadge(
              p.status,
              backgroundColor: AppColors.brandTint,
              textColor: AppColors.brandPrimary,
            )),
            _buildDetailRow('Practitioner', Text(
              p.practitioner,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            )),
            _buildDetailRow('WhatsApp', _buildPillBadge(
              p.whatsAppStatus,
              backgroundColor: AppColors.feedbackSuccessTint,
              textColor: AppColors.feedbackSuccess,
            ), isLast: true),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, Widget valueWidget, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 13),
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

  Widget _buildPillBadge(
    String text, {
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusPill),
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildExplanatoryText() {
    return Text(
      'Manage Queue opens the existing Queue destination. View Patient opens the existing receptionist Patient Profile.',
      style: AppTextStyles.caption.copyWith(
        fontSize: 13,
        height: 1.45,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildActionButtons(PatientQuickViewController controller) {
    return Obx(() {
      final isDropdownVisible = controller.isDropdownVisible.value;
      final isAssignMode = controller.isAssignMode.value;

      return Row(
        children: [
          Expanded(
            child: AppButton.secondary(
              label: isAssignMode ? 'Add to Queue' : 'Manage Queue',
              onPressed: isAssignMode ? controller.addToQueue : controller.manageQueue,
            ),
          ),
          const SizedBox(width: Dimensions.spaceMd),
          Expanded(
            child: AppButton.primary(
              label: isDropdownVisible ? 'Save Assignment' : 'Assign Practitioner',
              onPressed: isDropdownVisible ? controller.saveAssignment : controller.startAssignment,
            ),
          ),
        ],
      );
    });
  }
}

/// Show the Patient Quick View as a desktop overlay drawer.
/// Dashboard or Queue underneath stays completely untouched — no rebuild, no state change.
void showPatientQuickViewDrawer(
  BuildContext context, {
  bool startInAssignMode = false,
  String returnRoute = AppRoutes.dashboard,
  PatientQuickViewModel? patient,
}) {
  // Register controller for overlay lifetime
  Get.put(PatientQuickViewController(
    startInAssignMode: startInAssignMode,
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
      return PatientQuickViewDrawer(
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
    // Cleanup controller when drawer closes
    if (Get.isRegistered<PatientQuickViewController>()) {
      Get.delete<PatientQuickViewController>();
    }
  });
}
