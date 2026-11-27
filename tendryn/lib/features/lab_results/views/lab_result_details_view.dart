import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/lab_results/controllers/lab_referral_controller.dart';
import 'package:tendryn/features/lab_results/controllers/lab_result_details_controller.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/features/lab_results/models/lab_result_model.dart';
import 'package:tendryn/features/lab_results/views/lab_referral_details_view.dart';
import 'package:tendryn/features/lab_results/views/patient_lab_info_view.dart';
import 'package:tendryn/features/lab_results/widgets/lab_result_drawer.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';

class LabResultDetailsView extends GetView<LabResultDetailsController> {
  const LabResultDetailsView({super.key});

  // =======================================================================
  // NO DOCUMENT ATTACHED STATE TOGGLE (Desktop, Tablet, & Mobile):
  // Set [hasNoDocumentAttached = true] to preview the "No document attached" state.
  // When `false` (default), normal populated view with attachments is shown.
  // =======================================================================
  static const bool hasNoDocumentAttached = false;

  // =======================================================================
  // DOCUMENT LOAD ERROR STATE TOGGLE (Desktop, Tablet, & Mobile):
  // Set [hasDocumentLoadError = true] to preview "Document could not be loaded" state.
  // When `false` (default), normal populated view with report viewer is shown.
  // =======================================================================
  static const bool hasDocumentLoadError = false;

  @override
  Widget build(BuildContext context) {
    final isLabStaff =
        Get.isRegistered<RoleController>() &&
        RoleController.to.currentRole.value == ClinicRole.labStaff;
    final args = Get.arguments;
    if (isLabStaff && args is! LabResultModel) {
      final referral = _extractLabStaffReferral(args);
      if (referral != null) {
        return AppShell(
          route: AppRoutes.labResults,
          hideBottomNavigation: true,
          hideMobileHeader: true,
          child: _LabStaffResultDetailsView(
            referral: referral,
            onClose: controller.onBack,
          ),
        );
      }
    }

    return const ResponsiveLayout(
      mobile: _MobileView(),
      tablet: AppShell(
        route: AppRoutes.labResults,
        hideBottomNavigation: true,
        child: _TabletView(),
      ),
      desktop: AppShell(
        route: AppRoutes.labResults,
        child: _DesktopView(),
      ),
    );
  }

  static LabReferralModel? _extractLabStaffReferral(Object? args) {
    if (args is LabReferralModel) return args;
    if (args is Map<String, dynamic> && args['referral'] is LabReferralModel) {
      return args['referral'] as LabReferralModel;
    }
    if (Get.isRegistered<LabReferralController>()) {
      final ctrl = LabReferralController.to;
      if (ctrl.labStaffResults.isNotEmpty) return ctrl.labStaffResults.first;
      if (ctrl.referrals.isNotEmpty) return ctrl.referrals.first;
    }
    return null;
  }
}

// ============================================================================
// Desktop View (2-Column Grid)
// ============================================================================

class _DesktopView extends GetView<LabResultDetailsController> {
  const _DesktopView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.pageMarginDesktop,
            vertical: 24,
          ),
          child: Obx(() {
            final result = controller.result.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BackButton(onTap: controller.onBack),
                const SizedBox(height: 18),
                _DesktopPageHeader(
                  onViewProfile: controller.onViewPatientProfile,
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 44,
                      child: Column(
                        children: [
                          _PatientCard(result: result),
                          const SizedBox(height: 18),
                          _LabResultInfoCard(
                            result: result,
                            onViewReferral: () =>
                                controller.onViewReferral(context),
                          ),
                          const SizedBox(height: 18),
                          _DoctorReviewCard(
                            result: result,
                            onRecordReview: () =>
                                controller.onRecordReview(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 56,
                      child: _ResultDocumentCard(
                        selectedAttachmentIndex:
                            controller.selectedAttachmentIndex.value,
                        onSelectAttachment: controller.selectAttachment,
                        hasNoDocumentAttached:
                            LabResultDetailsView.hasNoDocumentAttached,
                        hasDocumentLoadError:
                            LabResultDetailsView.hasDocumentLoadError,
                        onRetryLoad: controller.onRetryDocumentLoad,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ============================================================================
// Tablet View (Image 2 Match: Side-by-side Patient + Lab Result, Full-width Docs, Fixed Header & Bottom)
// ============================================================================

class _TabletView extends GetView<LabResultDetailsController> {
  const _TabletView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: Column(
        children: [
          // Fixed Top Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.pageMarginTablet,
              vertical: 14,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _BoxedBackButton(onTap: controller.onBack),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lab Result Details',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Review the patient's laboratory report and related clinical information.",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginTablet,
                vertical: 20,
              ),
              child: Obx(() {
                final result = controller.result.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row with Patient Card & Lab Result Card
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _PatientCard(result: result)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _LabResultInfoCard(
                            result: result,
                            onViewReferral: () =>
                                controller.onViewReferral(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Result Document Card (Full Width)
                    _ResultDocumentCard(
                      selectedAttachmentIndex:
                          controller.selectedAttachmentIndex.value,
                      onSelectAttachment: controller.selectAttachment,
                      hasNoDocumentAttached:
                          LabResultDetailsView.hasNoDocumentAttached,
                      hasDocumentLoadError:
                          LabResultDetailsView.hasDocumentLoadError,
                      onRetryLoad: controller.onRetryDocumentLoad,
                    ),
                    const SizedBox(height: 18),

                    // Doctor Review Card (Full Width)
                    _DoctorReviewCard(
                      result: result,
                      onRecordReview: () => controller.onRecordReview(context),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
      // Fixed Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.pageMarginTablet,
          vertical: 14,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: _ViewPatientProfileButton(
            onPressed: controller.onViewPatientProfile,
            isFullWidth: true,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Mobile View (Image 1 Match: Stacked Cards, Boxed Back Button, Fixed Header & Bottom)
// ============================================================================

class _MobileView extends GetView<LabResultDetailsController> {
  const _MobileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginMobile,
                vertical: 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
              ),
              child: Row(
                children: [
                  _BoxedBackButton(onTap: controller.onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lab Result Details',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginMobile,
                  vertical: 16,
                ),
                child: Obx(() {
                  final result = controller.result.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Patient Card
                      _PatientCard(result: result),
                      const SizedBox(height: 16),

                      // 2. Lab Result Card
                      _LabResultInfoCard(
                        result: result,
                        onViewReferral: () =>
                            controller.onViewReferral(context),
                      ),
                      const SizedBox(height: 16),

                      // 3. Result Document Card
                      _ResultDocumentCard(
                        selectedAttachmentIndex:
                            controller.selectedAttachmentIndex.value,
                        onSelectAttachment: controller.selectAttachment,
                        hasNoDocumentAttached:
                            LabResultDetailsView.hasNoDocumentAttached,
                        hasDocumentLoadError:
                            LabResultDetailsView.hasDocumentLoadError,
                        onRetryLoad: controller.onRetryDocumentLoad,
                      ),
                      const SizedBox(height: 16),

                      // 4. Doctor Review Card
                      _DoctorReviewCard(
                        result: result,
                        onRecordReview: () => controller.onRecordReview(context),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      // Fixed Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.pageMarginMobile,
          vertical: 14,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: _ViewPatientProfileButton(
            onPressed: controller.onViewPatientProfile,
            isFullWidth: true,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Subcomponents
// ============================================================================

class _BoxedBackButton extends StatelessWidget {
  const _BoxedBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandTint,
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.controlX,
            vertical: 14,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                AppIcons.arrowLeft,
                size: Dimensions.iconSize,
                color: AppColors.brandPrimary,
              ),
              const SizedBox(width: Dimensions.spaceSm),
              Text(
                'Back to Lab Results',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.brandPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopPageHeader extends StatelessWidget {
  const _DesktopPageHeader({required this.onViewProfile});

  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lab Result Details',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Review the patient's laboratory report and related clinical information.",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _ViewPatientProfileButton(onPressed: onViewProfile),
      ],
    );
  }
}

class _ViewPatientProfileButton extends StatelessWidget {
  const _ViewPatientProfileButton({
    required this.onPressed,
    this.isFullWidth = false,
  });

  final VoidCallback onPressed;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: Size(isFullWidth ? double.infinity : 0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: const Text(
        'View Patient Profile',
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}


class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.result});

  final LabResultModel result;

  @override
  Widget build(BuildContext context) {
    return _DetailsCardContainer(
      title: 'Patient',
      child: Column(
        children: [
          _KeyValuePairRow(label: 'Patient name', value: result.patientName),
          const SizedBox(height: 12),
          _KeyValuePairRow(label: 'Folder no.', value: '#${result.folderNumber.replaceAll('#', '')}'),
          const SizedBox(height: 12),
          _KeyValuePairRow(label: 'ID number', value: result.idNumber),
          const SizedBox(height: 12),
          _KeyValuePairRow(
            label: 'Age · Sex · DOB',
            value: '${result.age} · ${result.gender} · DOB ${result.dob}',
          ),
          const SizedBox(height: 12),
          _KeyValuePairRow(label: 'Allergies', value: result.allergies),
        ],
      ),
    );
  }
}

class _LabResultInfoCard extends StatelessWidget {
  const _LabResultInfoCard({
    required this.result,
    required this.onViewReferral,
  });

  final LabResultModel result;
  final VoidCallback onViewReferral;

  @override
  Widget build(BuildContext context) {
    return _DetailsCardContainer(
      title: 'Lab result',
      trailing: InkWell(
        onTap: onViewReferral,
        borderRadius: BorderRadius.circular(4),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            'View referral',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brandPrimary,
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          _KeyValuePairRow(label: 'Test / Investigation', value: result.testName),
          const SizedBox(height: 12),
          _KeyValuePairRow(label: 'Result received', value: result.resultReceivedDate),
          const SizedBox(height: 12),
          _KeyValuePairRow(label: 'Laboratory', value: result.laboratory),
          const SizedBox(height: 12),
          _KeyValuePairRow(label: 'Requested by', value: result.orderingDoctor),
          const SizedBox(height: 12),
          _KeyValuePairRow(label: 'Related referral', value: result.relatedReferral),
        ],
      ),
    );
  }
}

class _DoctorReviewCard extends StatelessWidget {
  const _DoctorReviewCard({
    required this.result,
    required this.onRecordReview,
  });

  final LabResultModel result;
  final VoidCallback onRecordReview;

  @override
  Widget build(BuildContext context) {
    final isAwaiting = result.status == LabReviewStatus.awaitingReview;

    return _DetailsCardContainer(
      title: 'Doctor review',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isAwaiting ? const Color(0xFFFFF4E5) : const Color(0xFFECFDF3),
          borderRadius: BorderRadius.circular(Dimensions.radiusPill),
        ),
        child: Text(
          isAwaiting ? 'Awaiting review' : 'Reviewed',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isAwaiting ? const Color(0xFFD97706) : const Color(0xFF15803D),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAwaiting
                ? 'This result has not been reviewed. Results are only marked as reviewed when you record a review.'
                : 'Reviewed by ${result.reviewedBy ?? "Doctor"} on ${result.reviewedAt ?? "recorded date"}. Action: ${result.reviewAction ?? "Completed"}.',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onRecordReview,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.brandPrimary,
                side: const BorderSide(color: AppColors.borderDefault),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
              ),
              child: Text(
                isAwaiting ? 'Record Review' : 'Update Review',
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDocumentCard extends StatelessWidget {
  const _ResultDocumentCard({
    required this.selectedAttachmentIndex,
    required this.onSelectAttachment,
    this.hasNoDocumentAttached = false,
    this.hasDocumentLoadError = false,
    this.onRetryLoad,
  });

  final int selectedAttachmentIndex;
  final ValueChanged<int> onSelectAttachment;

  /// When `true`, displays the "No document attached" warning banner state
  /// matching the alternative designs for Desktop, Tablet, and Mobile.
  final bool hasNoDocumentAttached;

  /// When `true`, displays the "Document could not be loaded" error banner state
  /// with "Try again" action matching Desktop, Tablet, and Mobile mockups.
  final bool hasDocumentLoadError;

  final VoidCallback? onRetryLoad;

  @override
  Widget build(BuildContext context) {
    // =========================================================================
    // "NO DOCUMENT ATTACHED" STATE PREVIEW:
    // If [hasNoDocumentAttached] is true, renders amber alert box.
    // =========================================================================
    if (hasNoDocumentAttached) {
      return _buildNoDocumentCard();
    }

    final isMobile = ResponsiveHelper.isMobile(context);
    final isPdf = selectedAttachmentIndex == 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Result document + 2 attachments or mobile 'Try again'
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Result document',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              if (hasDocumentLoadError && isMobile)
                InkWell(
                  onTap: onRetryLoad ?? () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Try again',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                )
              else if (!hasDocumentLoadError)
                const Text(
                  '2 attachments',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Content: Load Error Box OR Big Document Viewer
          if (hasDocumentLoadError)
            _buildDocumentLoadErrorBox(context, isMobile: isMobile)
          else
            _buildBigDocumentViewer(isPdf: isPdf),

          const SizedBox(height: 16),

          // Attachment Thumbnails Selector
          Row(
            children: [
              _AttachmentThumbnail(
                label: 'Report · PDF',
                tag: 'PDF',
                isSelected: selectedAttachmentIndex == 0,
                onTap: () => onSelectAttachment(0),
              ),
              const SizedBox(width: 12),
              _AttachmentThumbnail(
                label: 'Photo · JPG',
                tag: 'IMG',
                isSelected: selectedAttachmentIndex == 1,
                onTap: () => onSelectAttachment(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // HELPER / REFERENCE: "DOCUMENT COULD NOT BE LOADED" ERROR BOX
  // Displays red alert box with "Try again" button (Desktop/Tablet) or link (Mobile).
  // =========================================================================
  Widget _buildDocumentLoadErrorBox(
    BuildContext context, {
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.errorAlertBorder),
      ),
      child: isMobile
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document could not be loaded',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.safetyCriticalText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'The report file failed to open. Check your connection and try again.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Document could not be loaded',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.safetyCriticalText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'The report file failed to open. Check your connection and try again.',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: onRetryLoad ?? () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.brandPrimary,
                    side: const BorderSide(color: AppColors.borderDefault),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Try again',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // =========================================================================
  // HELPER: NORMAL BIG DOCUMENT VIEWER CONTAINER
  // =========================================================================
  Widget _buildBigDocumentViewer({required bool isPdf}) {
    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F6),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Document Icon Card
            Container(
              width: 72,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderDefault),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPdf ? Icons.description_outlined : Icons.image_outlined,
                      size: 20,
                      color: const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPdf ? 'PDF' : 'IMG',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPdf
                  ? 'Laboratory report · page 1 of 2'
                  : 'Specimen photograph · page 1 of 1',
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Placeholder only no report content shown in design',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER / REFERENCE: "NO DOCUMENT ATTACHED" CARD
  // Matches desktop, tablet, and mobile mockups with an amber warning box.
  // =========================================================================
  Widget _buildNoDocumentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Result document',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9EE),
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: const Color(0xFFF5D58A)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No document attached',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This result was received without a report file. Contact the laboratory, or check again later.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF4B5563),
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

class _AttachmentThumbnail extends StatelessWidget {
  const _AttachmentThumbnail({
    required this.label,
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String tag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 86,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsCardContainer extends StatelessWidget {
  const _DetailsCardContainer({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _KeyValuePairRow extends StatelessWidget {
  const _KeyValuePairRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FUTURE USE REFERENCE CODE / COMMENTS:
// Below are pre-built reference widgets and snippets for alternative states
// requested by design. You can easily toggle them via the static flags at the
// top of [LabResultDetailsView] (`hasNoDocumentAttached` or `hasDocumentLoadError`),
// or copy-paste these commented templates anywhere needed.
// ============================================================================

/*
// ----------------------------------------------------------------------------
// STATE 1: NO DOCUMENT ATTACHED (Desktop, Tablet, & Mobile)
// ----------------------------------------------------------------------------
// Usage: Replace the normal Result Document card with this widget when no
// file is available for the lab result.
//
class NoDocumentAttachedCard extends StatelessWidget {
  const NoDocumentAttachedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Result document',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9EE),
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: const Color(0xFFF5D58A)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No document attached',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This result was received without a report file. Contact the laboratory, or check again later.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF4B5563),
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

// ----------------------------------------------------------------------------
// STATE 2: DOCUMENT COULD NOT BE LOADED (Desktop, Tablet, & Mobile)
// ----------------------------------------------------------------------------
// Usage: Show this error state when network or storage fails to load report.
// Desktop & Tablet feature an inline "Try again" button inside the alert box.
// Mobile features a "Try again" action link in the card header.
//
class DocumentLoadErrorCard extends StatelessWidget {
  const DocumentLoadErrorCard({
    super.key,
    required this.isMobile,
    required this.selectedAttachmentIndex,
    required this.onSelectAttachment,
    required this.onRetry,
  });

  final bool isMobile;
  final int selectedAttachmentIndex;
  final ValueChanged<int> onSelectAttachment;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Result document',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              // On mobile, "Try again" action is in the header
              if (isMobile)
                InkWell(
                  onTap: onRetry,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Try again',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Error Alert Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.errorAlertBorder),
            ),
            child: isMobile
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Document could not be loaded',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.safetyCriticalText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'The report file failed to open. Check your connection and try again.',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Document could not be loaded',
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.safetyCriticalText,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'The report file failed to open. Check your connection and try again.',
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFamily,
                                fontSize: 13,
                                height: 1.4,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: onRetry,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.brandPrimary,
                          side: const BorderSide(color: AppColors.borderDefault),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusControl,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Try again',
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),

          // Attachment Selector Buttons
          Row(
            children: [
              _AttachmentThumbnail(
                label: 'Report · PDF',
                tag: 'PDF',
                isSelected: selectedAttachmentIndex == 0,
                onTap: () => onSelectAttachment(0),
              ),
              const SizedBox(width: 12),
              _AttachmentThumbnail(
                label: 'Photo · JPG',
                tag: 'IMG',
                isSelected: selectedAttachmentIndex == 1,
                onTap: () => onSelectAttachment(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/

/// Opens the read-only Lab Staff Lab Result Details view inside [AppShell]:
/// - Desktop: Sidebar (`Result` active), `< Back to Result` pill, top actions, 2-column grid.
/// - Tablet: Header with `<`, patient banner, details + document preview cards, fixed bottom CTA bar.
/// - Mobile: Compact header with `<`, stacked cards + Activity card, fixed vertical CTA bar.
/// Bottom navigation is hidden on Tablet and Mobile.
void openLabStaffResultDetailsPage(
  BuildContext context, {
  required LabReferralModel referral,
  String? documentName,
  bool openedFromDetails = false,
}) {
  final effectiveReferral =
      documentName != null && documentName.isNotEmpty
          ? referral.copyWith(uploadedDocumentName: documentName)
          : referral;

  Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      settings: const RouteSettings(name: AppRoutes.labResultDetails),
      pageBuilder: (ctx, animation, secondaryAnimation) => AppShell(
        route: AppRoutes.labResults,
        hideBottomNavigation: true,
        hideMobileHeader: true,
        child: _LabStaffResultDetailsView(
          referral: effectiveReferral,
          documentNameOverride: documentName,
          onClose: () {
            if (openedFromDetails) {
              final hasLabResultsRoute = Get.routeTree.routes.any(
                (r) => r.name == AppRoutes.labResults,
              );
              if (hasLabResultsRoute) {
                AppNavigation.goTo(AppRoutes.labResults);
                return;
              }
            }
            Navigator.of(ctx).pop();
          },
        ),
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

class _LabStaffResultDetailsView extends StatelessWidget {
  const _LabStaffResultDetailsView({
    required this.referral,
    required this.onClose,
    this.documentNameOverride,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final String? documentNameOverride;

  LabReferralModel _resolveReferral() {
    LabReferralModel current = referral;
    if (Get.isRegistered<LabReferralController>()) {
      final ctrl = LabReferralController.to;
      final fromResults = ctrl.labStaffResults.firstWhereOrNull(
        (r) => r.id == referral.id,
      );
      final fromReferrals = ctrl.referrals.firstWhereOrNull(
        (r) => r.id == referral.id,
      );
      current = fromResults ?? fromReferrals ?? referral;
    }
    if (documentNameOverride != null &&
        documentNameOverride!.isNotEmpty &&
        (current.uploadedDocumentName == null ||
            current.uploadedDocumentName!.isEmpty)) {
      current = current.copyWith(uploadedDocumentName: documentNameOverride);
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildFor(LabReferralModel current) => ResponsiveLayout(
      mobile: _LabStaffMobileView(referral: current, onClose: onClose),
      tablet: _LabStaffTabletView(referral: current, onClose: onClose),
      desktop: _LabStaffDesktopView(referral: current, onClose: onClose),
    );

    if (Get.isRegistered<LabReferralController>()) {
      return Obx(() => buildFor(_resolveReferral()));
    }
    return buildFor(_resolveReferral());
  }
}

class _LabStaffDesktopView extends StatelessWidget {
  const _LabStaffDesktopView({
    required this.referral,
    required this.onClose,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.pageMarginDesktop,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabStaffBackPill(onTap: onClose),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lab Result Details',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View the uploaded laboratory document and its referral details.',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewPatientLabInfoButton(
                      onPressed: () => openPatientLabInfoPage(
                        context,
                        referral: referral,
                        activeSidebarRoute: AppRoutes.labResults,
                        backLabel: 'Back to Result Details',
                        preferResultState: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ViewRelatedReferralButton(
                      onPressed: () => openLabReferralDetailsPage(
                        context,
                        referral: referral,
                        preferResultState: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _LabStaffPatientBanner(referral: referral, isMobile: false),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _LabStaffResultInfoCard(referral: referral),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 6,
                  child: _LabStaffResultDocumentCard(referral: referral),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabStaffTabletView extends StatelessWidget {
  const _LabStaffTabletView({
    required this.referral,
    required this.onClose,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginTablet,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _BoxedBackButton(onTap: onClose),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lab Result Details',
                              style: AppTextStyles.h2.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'View the uploaded laboratory document and its referral details.',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _LabStaffPatientBanner(referral: referral, isMobile: false),
                  const SizedBox(height: 16),
                  _LabStaffResultInfoCard(referral: referral),
                  const SizedBox(height: 16),
                  _LabStaffResultDocumentCard(referral: referral),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.pageMarginTablet,
              vertical: 14,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderDefault)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: _ViewPatientLabInfoButton(
                      height: Dimensions.buttonMinHeight,
                      onPressed: () => openPatientLabInfoPage(
                        context,
                        referral: referral,
                        activeSidebarRoute: AppRoutes.labResults,
                        backLabel: 'Back to Result Details',
                        preferResultState: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ViewRelatedReferralButton(
                      height: Dimensions.buttonMinHeight,
                      onPressed: () => openLabReferralDetailsPage(
                        context,
                        referral: referral,
                        preferResultState: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabStaffMobileView extends StatelessWidget {
  const _LabStaffMobileView({
    required this.referral,
    required this.onClose,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginMobile,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _BoxedBackButton(onTap: onClose),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Lab Result Details',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LabStaffPatientBanner(referral: referral, isMobile: true),
                  const SizedBox(height: 14),
                  _LabStaffResultInfoCard(referral: referral),
                  const SizedBox(height: 14),
                  _LabStaffActivityCard(referral: referral),
                  const SizedBox(height: 14),
                  _LabStaffResultDocumentCard(referral: referral),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderDefault)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _ViewRelatedReferralButton(
                      height: Dimensions.buttonMinHeight,
                      onPressed: () => openLabReferralDetailsPage(
                        context,
                        referral: referral,
                        preferResultState: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: _ViewPatientLabInfoButton(
                      height: Dimensions.buttonMinHeight,
                      onPressed: () => openPatientLabInfoPage(
                        context,
                        referral: referral,
                        activeSidebarRoute: AppRoutes.labResults,
                        backLabel: 'Back to Result Details',
                        preferResultState: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabStaffBackPill extends StatelessWidget {
  const _LabStaffBackPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back to Result',
      child: Material(
        color: const Color(0xFFE8F6F3),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ExcludeSemantics(
                  child: Icon(
                    AppIcons.chevronLeft,
                    size: 16,
                    color: AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Back to Result',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewPatientLabInfoButton extends StatelessWidget {
  const _ViewPatientLabInfoButton({
    required this.onPressed,
    this.height = 44,
  });

  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, height),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: const Text('View Patient Lab Information'),
    );
  }
}

class _ViewRelatedReferralButton extends StatelessWidget {
  const _ViewRelatedReferralButton({
    required this.onPressed,
    this.height = 44,
  });

  final VoidCallback onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(0, height),
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        textStyle: const TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: const Text('View Related Referral'),
    );
  }
}

class _LabStaffPatientBanner extends StatelessWidget {
  const _LabStaffPatientBanner({
    required this.referral,
    required this.isMobile,
  });

  final LabReferralModel referral;
  final bool isMobile;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Container(
              width: isMobile ? 42 : 46,
              height: isMobile ? 42 : 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6F3),
                borderRadius: isMobile
                    ? BorderRadius.circular(10)
                    : BorderRadius.circular(Dimensions.radiusPill),
              ),
              child: Text(
                _initials(referral.patientName),
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      referral.patientName,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    LabReferralStatusPill(status: referral.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${referral.folderNumber} · Male · 42 yrs · Referral ${referral.referenceNumber}',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: isMobile ? 12.5 : 13,
                    color: AppColors.textSecondary,
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

class _LabStaffResultInfoCard extends StatelessWidget {
  const _LabStaffResultInfoCard({required this.referral});

  final LabReferralModel referral;

  @override
  Widget build(BuildContext context) {
    final hasResult =
        referral.status == LabReferralStatus.resultReceived ||
        (referral.uploadedDocumentName != null &&
            referral.uploadedDocumentName!.isNotEmpty);
    final receivedText = hasResult
        ? (referral.resultReceivedAt ?? '${referral.referralDate}, 14:30')
        : 'Pending upload';
    final uploadedByText = hasResult
        ? (referral.uploadedBy ?? 'Lerato Mokoena')
        : 'Pending';

    return _DetailsCardContainer(
      title: 'Result information',
      child: Column(
        children: [
          _InfoDividerRow(label: 'Patient', value: referral.patientName),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _InfoDividerRow(label: 'Patient ID', value: referral.folderNumber),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _InfoDividerRow(
            label: 'Requested test',
            value: referral.testsRequested,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _InfoDividerRow(
            label: 'Requesting doctor',
            value: referral.requestedBy,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _InfoDividerRow(label: 'Referral date', value: referral.referralDate),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _InfoDividerRow(label: 'Result received', value: receivedText),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _InfoDividerRow(label: 'Uploaded by', value: uploadedByText),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              children: [
                const Text(
                  'Doctor review',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusPill,
                        ),
                      ),
                      child: const Text(
                        'Doctor review pending',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: const Text(
              'Clinical review is completed by the requesting doctor.',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1D4ED8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDividerRow extends StatelessWidget {
  const _InfoDividerRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabStaffActivityCard extends StatelessWidget {
  const _LabStaffActivityCard({required this.referral});

  final LabReferralModel referral;

  @override
  Widget build(BuildContext context) {
    final hasResult =
        referral.status == LabReferralStatus.resultReceived ||
        (referral.uploadedDocumentName != null &&
            referral.uploadedDocumentName!.isNotEmpty);
    final uploadedByText = referral.uploadedBy ?? 'Lerato Mokoena';
    final receivedAt =
        referral.resultReceivedAt ?? '${referral.referralDate}, 14:30';

    return _DetailsCardContainer(
      title: 'Activity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActivityRow(
            title: 'Referral created by ${referral.requestedBy}',
            subtitle: '${referral.referralDate}, 09:40 · From consultation',
          ),
          if (hasResult) ...[
            const SizedBox(height: 14),
            _ActivityRow(
              title: 'Result uploaded by $uploadedByText',
              subtitle: '$receivedAt · ${referral.effectiveDocumentName}',
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Container(
            margin: const EdgeInsets.only(top: 5),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.brandPrimary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabStaffResultDocumentCard extends StatefulWidget {
  const _LabStaffResultDocumentCard({required this.referral});

  final LabReferralModel referral;

  @override
  State<_LabStaffResultDocumentCard> createState() =>
      _LabStaffResultDocumentCardState();
}

class _LabStaffResultDocumentCardState
    extends State<_LabStaffResultDocumentCard> {
  String? _selectedFileName;
  String? _validationError;
  LabReferralModel? _localSavedReferral;

  static const _reportLineFactors = <double>[
    0.96,
    0.72,
    0.90,
    0.84,
    0.58,
    0.92,
    0.66,
    0.80,
    0.70,
    0.94,
    0.52,
    0.62,
  ];

  @override
  void didUpdateWidget(covariant _LabStaffResultDocumentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.referral.status == LabReferralStatus.resultReceived) {
      _selectedFileName = null;
      _validationError = null;
    }
    if (oldWidget.referral.id != widget.referral.id) {
      _selectedFileName = null;
      _validationError = null;
      _localSavedReferral = null;
    }
  }

  Future<void> _pickFile() async {
    final chosen = await showReportFilePicker(
      context,
      referral: widget.referral,
    );
    if (chosen != null && mounted) {
      setState(() {
        _selectedFileName = chosen;
        _validationError = null;
      });
    }
  }

  void _handleSavePdf() {
    if (_selectedFileName == null || _selectedFileName!.isEmpty) {
      setState(() {
        _validationError = 'Please choose a PDF, JPG, or PNG file to upload.';
      });
      return;
    }
    final saved = saveUploadedLabResult(
      widget.referral,
      fileName: _selectedFileName!,
    );
    if (mounted) {
      setState(() {
        _localSavedReferral = saved;
        _selectedFileName = null;
        _validationError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _localSavedReferral ?? widget.referral;
    final hasResult =
        current.status == LabReferralStatus.resultReceived ||
        (current.uploadedDocumentName != null &&
            current.uploadedDocumentName!.isNotEmpty);

    if (!hasResult) {
      return _buildUploadPdfCard(context, current);
    }

    final docName = current.effectiveDocumentName;
    final docType = LabReferralModel.documentTypeLabel(docName);
    final receivedAt =
        current.resultReceivedAt ?? '${current.referralDate}, 14:30';
    final isImage = docType != 'PDF document';

    return _DetailsCardContainer(
      title: 'Result document',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F6F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isImage
                          ? Icons.image_outlined
                          : Icons.description_outlined,
                      size: 20,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docName,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$docType · Uploaded $receivedAt',
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
          const SizedBox(height: 14),
          _buildReportPreviewBox(_reportLineFactors),
        ],
      ),
    );
  }

  Widget _buildUploadPdfCard(BuildContext context, LabReferralModel current) {
    final hasFile = _selectedFileName != null;
    final hasError = _validationError != null;
    final borderColor = hasError
        ? AppColors.fieldErrorBorder
        : const Color(0xFFCBD5E1);
    final dropzoneBg = hasError
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF8FAFA);

    return _DetailsCardContainer(
      title: 'Result document',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasFile) ...[
            _buildSelectedFileRow(_selectedFileName!),
            const SizedBox(height: 12),
            _buildReportPreviewBox(const [0.72, 0.85, 0.62, 0.78, 0.90, 0.68]),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ExcludeSemantics(
                    child: Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Will be attached to ${current.patientName} (${current.folderNumber}) · ${current.referenceNumber} · ${current.testsRequested}.',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D4ED8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            CustomPaint(
              painter: LabDashedRRectPainter(
                color: borderColor,
                radius: Dimensions.radiusControl,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: dropzoneBg,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F6F3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.file_upload_outlined,
                          size: 22,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Upload laboratory result PDF',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Accepted formats: PDF, JPG, PNG',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _pickFile,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(140, 44),
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.brandPrimary,
                        side: const BorderSide(color: AppColors.borderDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusControl,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Choose File',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (hasError) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const ExcludeSemantics(
                  child: Icon(
                    Icons.error_outline,
                    size: 15,
                    color: AppColors.safetyCriticalText,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _validationError!,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12.5,
                      color: AppColors.safetyCriticalText,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _handleSavePdf,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, Dimensions.buttonMinHeight),
                backgroundColor: AppColors.brandPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
              ),
              child: const Text(
                'Upload Result',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFileRow(String fileName) {
    final docType = LabReferralModel.documentTypeLabel(fileName);
    final isImage = docType != 'PDF document';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isImage ? Icons.image_outlined : Icons.description_outlined,
                size: 20,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  docType,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove file',
            onPressed: () {
              setState(() {
                _selectedFileName = null;
                _validationError = null;
              });
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.fieldErrorBorder,
            ),
            constraints: const BoxConstraints.tightFor(
              width: 44,
              height: 44,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportPreviewBox(List<double> lineFactors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9F8),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Laboratory report',
                style: AppTextStyles.label.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ...List.generate(lineFactors.length, (index) {
                final isLast = index == lineFactors.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: lineFactors[index],
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EBE9),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}


