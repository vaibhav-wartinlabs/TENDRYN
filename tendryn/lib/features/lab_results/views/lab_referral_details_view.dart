import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/lab_results/controllers/lab_referral_controller.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/features/lab_results/views/lab_result_details_view.dart';
import 'package:tendryn/features/lab_results/views/patient_lab_info_view.dart';
import 'package:tendryn/features/lab_results/widgets/lab_result_drawer.dart';
import 'package:tendryn/features/lab_results/widgets/record_sample_drawer.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';

/// Opens the full-page Lab Referral Details view inside AppShell:
/// - Desktop: Full page with sidebar/header, Back pill, top actions, 2-column layout.
/// - Tablet: Full page with boxed back button, 2-column cards, sticky bottom action bar.
/// - Mobile: Full page with boxed back button, 1-column cards, sticky bottom action bar.
/// Bottom navigation is hidden on mobile & tablet per user instruction.
void openLabReferralDetailsPage(
  BuildContext context, {
  required LabReferralModel referral,
  bool preferResultState = false,
}) {
  Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      settings: const RouteSettings(name: AppRoutes.labReferralDetails),
      pageBuilder: (ctx, animation, secondaryAnimation) => AppShell(
        route: AppRoutes.labReferralDetails,
        hideBottomNavigation: true,
        hideMobileHeader: true,
        child: LabReferralDetailsView(
          referral: referral,
          preferResultState: preferResultState,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

/// Full-page view for Lab Referral Details matching Figma designs:
/// - Desktop: Full page with sidebar/header, Back pill, top actions, 2-column layout.
/// - Tablet: Full page with boxed back button, 2-column cards, sticky bottom action bar.
/// - Mobile: Full page with boxed back button, 1-column cards, sticky bottom action bar.
/// Bottom navigation is hidden on mobile & tablet per user instruction.
class LabReferralDetailsView extends StatefulWidget {
  const LabReferralDetailsView({
    super.key,
    required this.referral,
    required this.onClose,
    this.onStatusChanged,
    this.preferResultState = false,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final ValueChanged<LabReferralStatus>? onStatusChanged;
  final bool preferResultState;

  @override
  State<LabReferralDetailsView> createState() => _LabReferralDetailsViewState();
}

class _LabReferralDetailsViewState extends State<LabReferralDetailsView> {
  late LabReferralModel _referral;

  VoidCallback get onClose => widget.onClose;

  @override
  void initState() {
    super.initState();
    _referral = widget.referral;
  }

  /// Resolves the latest model from [LabReferralController] when registered so
  /// recording a sample or updating status stays reflected across every entry path.
  LabReferralModel _resolveReferral() {
    if (Get.isRegistered<LabReferralController>()) {
      return LabReferralController.to.resolveReferral(
        _referral,
        preferResultState: widget.preferResultState,
      );
    }
    return _referral;
  }

  bool _hasSample(LabReferralModel current) =>
      current.status != LabReferralStatus.requested ||
      current.collectionDate != null;

  Future<void> _onRecordSampleTap(
    BuildContext context,
    LabReferralModel current,
  ) async {
    await showRecordSamplePanel(
      context,
      referral: current,
      onSampleSaved: (updated) {
        if (mounted) {
          setState(() => _referral = updated);
        }
      },
    );
  }

  void _onStatusSelected(
    LabReferralModel current,
    LabReferralStatus newStatus,
  ) {
    final bool hasChanged = newStatus != current.status;
    setState(() {
      _referral = current.copyWith(status: newStatus);
    });
    if (hasChanged) {
      if (Get.isRegistered<LabReferralController>()) {
        LabReferralController.to.updateReferralStatus(current.id, newStatus);
        LabReferralController.to.showUpdateNotice(
          patientName: current.patientName,
          testName: current.testsRequested,
          newStatus: newStatus,
        );
      }
      widget.onStatusChanged?.call(newStatus);
      onClose();
    }
  }

  void _showUpdateStatusSheetOrDialog(
    BuildContext context,
    LabReferralModel current,
  ) {
    const statuses = [
      LabReferralStatus.requested,
      LabReferralStatus.sampleTaken,
      LabReferralStatus.awaitingResult,
      LabReferralStatus.resultReceived,
    ];

    if (ResponsiveHelper.isMobile(context)) {
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: AppColors.scrim,
        builder: (ctx) => _UpdateStatusBottomSheet(
          currentStatus: current.status,
          statuses: statuses,
          onSelected: (newStatus) {
            Navigator.of(ctx).pop();
            _onStatusSelected(current, newStatus);
          },
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierColor: AppColors.scrim,
        builder: (ctx) => _UpdateStatusDialog(
          currentStatus: current.status,
          statuses: statuses,
          onSelected: (newStatus) {
            Navigator.of(ctx).pop();
            _onStatusSelected(current, newStatus);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<LabReferralController>()) {
      return Obx(() {
        final current = _resolveReferral();
        return _buildResponsiveLayout(context, current);
      });
    }
    return _buildResponsiveLayout(context, _referral);
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    LabReferralModel current,
  ) {
    if (ResponsiveHelper.isDesktop(context)) {
      return _buildDesktopLayout(context, current);
    } else if (ResponsiveHelper.isTablet(context)) {
      return _buildTabletLayout(context, current);
    } else {
      return _buildMobileLayout(context, current);
    }
  }

  // ── Shared Action Buttons ──────────────────────────────────────────────────
  Widget _buildViewPatientInfoButton(
    BuildContext context,
    LabReferralModel current, {
    required double height,
    EdgeInsetsGeometry? padding,
  }) {
    return OutlinedButton(
      onPressed: () => openPatientLabInfoPage(context, referral: current),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0, height),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
        side: const BorderSide(color: AppColors.borderDefault),
        foregroundColor: AppColors.brandPrimary,
      ),
      child: const Text(
        'View Patient Lab Information',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton(
    BuildContext context,
    LabReferralModel current, {
    required double height,
    EdgeInsetsGeometry? padding,
  }) {
    final hasSample = _hasSample(current);
    final isResultSaved = current.status == LabReferralStatus.resultReceived;
    final label = !hasSample
        ? 'Record Sample'
        : isResultSaved
            ? 'View Result'
            : 'Upload Result';

    return FilledButton(
      onPressed: () {
        if (!hasSample) {
          _onRecordSampleTap(context, current);
        } else if (isResultSaved) {
          openLabStaffResultDetailsPage(context, referral: current);
        } else {
          showUploadLabResultPanel(context, referral: current);
        }
      },
      style: FilledButton.styleFrom(
        minimumSize: Size(0, height),
        padding: padding,
        backgroundColor: AppColors.brandPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Desktop Layout ─────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(
    BuildContext context,
    LabReferralModel current,
  ) {
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
            // Top Back Pill
            _DesktopBackPill(onTap: onClose),
            const SizedBox(height: 16),

            // Header Row (Title & Subtitle on left, Action buttons on right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lab Referral Details',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review the requested tests and associated patient information.',
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
                    _buildViewPatientInfoButton(
                      context,
                      current,
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    const SizedBox(width: 12),
                    _buildPrimaryActionButton(
                      context,
                      current,
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Patient Banner Card
            _buildPatientBannerCard(context, current, isMobile: false),
            const SizedBox(height: 20),

            // 2 Columns Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column (Requested tests + Sample collection)
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _buildRequestedTestsCard(current),
                      const SizedBox(height: 20),
                      _buildSampleCollectionCard(current),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right Column (Referral information + Activity)
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildReferralInformationCard(context, current),
                      const SizedBox(height: 20),
                      _buildActivityCard(current),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Tablet Layout ──────────────────────────────────────────────────────────
  Widget _buildTabletLayout(
    BuildContext context,
    LabReferralModel current,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: Column(
        children: [
          // Scrollable Body including Header row on backgroundApp
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
                              'Lab Referral Details',
                              style: AppTextStyles.h2.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Review the requested tests and associated patient information.',
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
                  const SizedBox(height: 20),
                  _buildPatientBannerCard(context, current, isMobile: false),
                  const SizedBox(height: 16),
                  _buildRequestedTestsCard(current),
                  const SizedBox(height: 16),
                  _buildReferralInformationCard(context, current),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildSampleCollectionCard(current)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildActivityCard(current)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Fixed Bottom Action Bar
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
                    child: _buildViewPatientInfoButton(
                      context,
                      current,
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPrimaryActionButton(
                      context,
                      current,
                      height: 48,
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

  // ── Mobile Layout ──────────────────────────────────────────────────────────
  Widget _buildMobileLayout(
    BuildContext context,
    LabReferralModel current,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: Column(
        children: [
          // Mobile Top Header with Boxed Back Button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
            ),
            child: Row(
              children: [
                _BoxedBackButton(onTap: onClose, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lab Referral Details',
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

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientBannerCard(context, current, isMobile: true),
                  const SizedBox(height: 14),
                  _buildRequestedTestsCard(current),
                  const SizedBox(height: 14),
                  _buildReferralInformationCard(context, current),
                  const SizedBox(height: 14),
                  _buildSampleCollectionCard(current),
                  const SizedBox(height: 14),
                  _buildActivityCard(current),
                ],
              ),
            ),
          ),

          // Fixed Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
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
                    height: 48,
                    child: _buildPrimaryActionButton(
                      context,
                      current,
                      height: 48,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _buildViewPatientInfoButton(
                      context,
                      current,
                      height: 48,
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

  Widget _buildInteractiveStatusPill(
    BuildContext context,
    LabReferralModel current, {
    Key? pillKey,
  }) {
    return Semantics(
      button: true,
      label: 'Update status (${current.status.label})',
      child: Tooltip(
        message: 'Update status',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: pillKey,
            onTap: () => _showUpdateStatusSheetOrDialog(context, current),
            borderRadius: BorderRadius.circular(Dimensions.radiusPill),
            child: LabReferralStatusPill(status: current.status),
          ),
        ),
      ),
    );
  }

  // ── Patient Banner Card ────────────────────────────────────────────────────
  Widget _buildPatientBannerCard(
    BuildContext context,
    LabReferralModel current, {
    required bool isMobile,
  }) {
    final initials = _getInitials(current.patientName);
    final refNumber = current.referenceNumber;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F6F3),
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMobile)
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          current.patientName,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildInteractiveStatusPill(
                        context,
                        current,
                        pillKey: const Key('referral_status_pill_banner'),
                      ),
                    ],
                  )
                else
                  Text(
                    current.patientName,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  '${current.folderNumber} · Male · 42 yrs · Referral $refNumber',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 12),
            _buildInteractiveStatusPill(
              context,
              current,
              pillKey: const Key('referral_status_pill_banner'),
            ),
          ],
        ],
      ),
    );
  }

  // ── Requested Tests Card ───────────────────────────────────────────────────
  Widget _buildRequestedTestsCard(LabReferralModel current) {
    return _buildCard(
      title: 'Requested tests',
      child: Column(
        children: [
          _buildDetailRow('Test name', current.testsRequested),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Request information', 'Requested during consultation'),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Doctor\'s clinical notes', 'No clinical notes added'),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDetailRow('ICD-10 codes', 'None shared with this referral'),
          const SizedBox(height: 16),
          // Blue lock alert box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: Color(0xFF4F46E5),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Read only. Tests, diagnosis and clinical notes are managed by the requesting doctor.',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4338CA),
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

  // ── Referral Information Card ──────────────────────────────────────────────
  Widget _buildReferralInformationCard(
    BuildContext context,
    LabReferralModel current,
  ) {
    final refNumber = current.referenceNumber;
    return _buildCard(
      title: 'Referral information',
      child: Column(
        children: [
          _buildDetailRow('Referral reference', refNumber),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Requesting doctor', current.requestedBy),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Referral date', current.referralDate),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDetailRow(
            'Current status',
            _buildInteractiveStatusPill(
              context,
              current,
              pillKey: const Key('referral_status_pill_info'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sample Collection Card ─────────────────────────────────────────────────
  Widget _buildSampleCollectionCard(LabReferralModel current) {
    if (!_hasSample(current)) {
      return _buildCard(
        title: 'Sample collection',
        child: Text(
          'No sample recorded yet. Record the sample once it has been collected.',
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final date = current.collectionDate ?? '31 Oct 2026';
    final time = current.collectionTime ?? '10:15';
    final recordedBy = current.sampleRecordedBy ?? 'Lerato Mokoena (Lab Staff)';
    final notes = current.sampleNotes ?? 'Collected at lab reception.';

    return _buildCard(
      title: 'Sample collection',
      child: Column(
        children: [
          _buildDetailRow('Collection date', date),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Collection time', time),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Recorded by', recordedBy),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDetailRow('Sample notes', notes),
        ],
      ),
    );
  }

  // ── Activity Card ──────────────────────────────────────────────────────────
  Widget _buildActivityCard(LabReferralModel current) {
    final hasSample = _hasSample(current);

    final recordedName = current.sampleRecordedBy != null
        ? current.sampleRecordedBy!.replaceAll(RegExp(r'\s*\(.*?\)'), '')
        : 'Lerato Mokoena';
    final sampleDate = current.collectionDate ?? '31 Oct 2026';
    final sampleTime = current.collectionTime ?? '10:15';

    return _buildCard(
      title: 'Activity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityItem(
            title: 'Referral created by ${current.requestedBy}',
            subtitle: '${current.referralDate}, 09:40 · From consultation',
          ),
          if (hasSample) ...[
            const SizedBox(height: 16),
            _buildActivityItem(
              title: 'Sample recorded by $recordedName',
              subtitle: '$sampleDate, $sampleTime · Status: Sample Taken',
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              title: 'Status changed to Awaiting Result',
              subtitle: '$sampleDate, 10:20',
            ),
          ],
          if (current.status == LabReferralStatus.resultReceived) ...[
            const SizedBox(height: 16),
            _buildActivityItem(
              title:
                  'Result uploaded by ${current.uploadedBy ?? 'Lerato Mokoena'}',
              subtitle:
                  '${current.resultReceivedAt ?? '${current.referralDate}, 14:30'} · ${current.effectiveDocumentName}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF0F766E),
            shape: BoxShape.circle,
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
                  fontSize: 14,
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

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: value is Widget
                ? value
                : Text(
                    value.toString(),
                    textAlign: TextAlign.end,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'PT';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ── Boxed Back Button for Mobile and Tablet ─────────────────────────────────
class _BoxedBackButton extends StatelessWidget {
  const _BoxedBackButton({required this.onTap, this.size = 44});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: Icon(
              AppIcons.chevronLeft,
              size: 20,
              color: AppColors.brandPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Desktop Back Pill ────────────────────────────────────────────────────────
class _DesktopBackPill extends StatelessWidget {
  const _DesktopBackPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8F6F3),
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                AppIcons.chevronLeft,
                size: 16,
                color: AppColors.brandPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                'Back to Lab Referral',
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
    );
  }
}

// ── Update Status Dialog (Desktop & Tablet) ──────────────────────────────────
class _UpdateStatusDialog extends StatelessWidget {
  const _UpdateStatusDialog({
    required this.currentStatus,
    required this.statuses,
    required this.onSelected,
  });

  final LabReferralStatus currentStatus;
  final List<LabReferralStatus> statuses;
  final ValueChanged<LabReferralStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Status',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Select current laboratory referral status',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              ...statuses.map((status) {
                final isSelected = status == currentStatus;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => onSelected(status),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandPrimary.withOpacity(0.04)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.brandPrimary
                              : AppColors.borderDefault,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          LabReferralStatusPill(status: status),
                          const Spacer(),
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 20,
                            color: isSelected
                                ? AppColors.brandPrimary
                                : AppColors.textDisabled,
                          ),
                        ],
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

// ── Update Status Bottom Sheet (Mobile) ──────────────────────────────────────
class _UpdateStatusBottomSheet extends StatelessWidget {
  const _UpdateStatusBottomSheet({
    required this.currentStatus,
    required this.statuses,
    required this.onSelected,
  });

  final LabReferralStatus currentStatus;
  final List<LabReferralStatus> statuses;
  final ValueChanged<LabReferralStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Status',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Select current laboratory referral status',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              ...statuses.map((status) {
                final isSelected = status == currentStatus;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => onSelected(status),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandPrimary.withOpacity(0.04)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.brandPrimary
                              : AppColors.borderDefault,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          LabReferralStatusPill(status: status),
                          const Spacer(),
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 20,
                            color: isSelected
                                ? AppColors.brandPrimary
                                : AppColors.textDisabled,
                          ),
                        ],
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
