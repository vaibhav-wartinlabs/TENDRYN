import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/lab_results/controllers/lab_referral_controller.dart';
import 'package:tendryn/features/lab_results/controllers/lab_results_controller.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/features/lab_results/models/lab_result_model.dart';
import 'package:tendryn/features/lab_results/views/lab_result_details_view.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';

/// States for the Record Review flow.
enum RecordReviewDrawerState {
  /// Initial form state with review summary, notes field, and "Mark as Reviewed" action (Image 1).
  initial,

  /// Error state when review saving failed, preserving notes with "Try Again" action (Image 3).
  saveError,

  /// Success state showing confirmation banner and single "Done" action (Image 2).
  reviewed,
}

/// Opens the Record Review UI matching mockups 1:1 across all platforms:
/// - On Mobile: Modal Bottom Sheet with top drag handle pill, backdrop scrim, and sticky action bar.
/// - On Tablet: Full Page inside AppShell with top TabletHeader, boxed back button, sticky action bar, and bottom nav.
/// - On Desktop: Right-side Slide-in Drawer with backdrop scrim and sticky action bar.
void showLabResultDrawer(
  BuildContext context, {
  required LabResultModel result,
  int initialTabIndex = 0,
  ValueChanged<LabResultModel>? onReviewed,
  bool simulateSaveError = false,
  RecordReviewDrawerState? initialState,
}) {
  final isMobile = ResponsiveHelper.isMobile(context);
  final isTablet = ResponsiveHelper.isTablet(context);

  if (isMobile) {
    // Mobile: Modal Bottom Sheet with rounded top corners & drag handle matching mobile mockup
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.90,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: LabResultDrawer(
              result: result,
              initialTabIndex: initialTabIndex,
              onClose: () => Navigator.of(ctx).pop(),
              onReviewed: onReviewed,
              simulateSaveError: simulateSaveError,
              initialState: initialState,
              isMobileSheet: true,
            ),
          ),
        ),
      ),
    );
    return;
  }

  if (isTablet) {
    // Tablet: Full Page inside AppShell with top TabletHeader without slide transition
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (ctx, animation, secondaryAnimation) => AppShell(
          route: AppRoutes.labResults,
          hideBottomNavigation: true,
          child: TabletRecordReviewView(
            result: result,
            onClose: () => Navigator.of(ctx).pop(),
            onReviewed: onReviewed,
            simulateSaveError: simulateSaveError,
            initialState: initialState,
          ),
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    return;
  }

  // Desktop: Slide-in Drawer from right
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 16,
          shadowColor: Colors.black45,
          child: Container(
            width: Dimensions.drawerWidth,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(
                  color: AppColors.borderDefault,
                  width: Dimensions.strokeDivider,
                ),
              ),
            ),
            child: LabResultDrawer(
              result: result,
              initialTabIndex: initialTabIndex,
              onClose: () => Navigator.of(dialogContext).pop(),
              onReviewed: onReviewed,
              simulateSaveError: simulateSaveError,
              initialState: initialState,
              isMobileSheet: false,
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      );
      return SlideTransition(position: slideAnimation, child: child);
    },
  );
}

// ============================================================================
// Tablet Record Review View (Full Tablet Page inside AppShell)
// ============================================================================

class TabletRecordReviewView extends StatefulWidget {
  const TabletRecordReviewView({
    super.key,
    required this.result,
    required this.onClose,
    this.onReviewed,
    this.simulateSaveError = false,
    this.initialState,
  });

  final LabResultModel result;
  final VoidCallback onClose;
  final ValueChanged<LabResultModel>? onReviewed;
  final bool simulateSaveError;
  final RecordReviewDrawerState? initialState;

  @override
  State<TabletRecordReviewView> createState() => _TabletRecordReviewViewState();
}

class _TabletRecordReviewViewState extends State<TabletRecordReviewView> {
  late RecordReviewDrawerState _state;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    if (widget.initialState != null) {
      _state = widget.initialState!;
    } else if (widget.result.status == LabReviewStatus.reviewed) {
      _state = RecordReviewDrawerState.reviewed;
    } else {
      _state = RecordReviewDrawerState.initial;
    }

    _notesController = TextEditingController(
      text: widget.result.reviewImpression ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onMarkAsReviewed() {
    if (widget.simulateSaveError || LabResultDrawer.staticSimulateSaveError) {
      setState(() {
        _state = RecordReviewDrawerState.saveError;
      });
      return;
    }
    _completeReview();
  }

  void _onTryAgain() {
    _completeReview();
  }

  void _completeReview() {
    setState(() {
      _state = RecordReviewDrawerState.reviewed;
    });
  }

  void _onDone() {
    final updated = widget.result.copyWith(
      status: LabReviewStatus.reviewed,
      reviewedBy: 'Dr. Maya Naidoo',
      reviewedAt: '12 Oct 2026 · 11:02',
      reviewAction: 'Normal · No follow-up needed',
      reviewImpression: _notesController.text.trim(),
    );

    if (Get.isRegistered<LabResultsController>()) {
      Get.find<LabResultsController>().recordReview(
        resultId: widget.result.id,
        action: 'Normal · No follow-up needed',
        impression: _notesController.text.trim(),
        notifyPatient: false,
      );
    }

    widget.onReviewed?.call(updated);
    widget.onClose();
  }

  void _handleClose() {
    if (_state == RecordReviewDrawerState.reviewed) {
      _onDone();
    } else {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: Column(
        children: [
          // Fixed Top Header (Boxed Back Button + Title + Subtitle)
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
                _BoxedBackButton(onTap: _handleClose),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Record Review',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Confirm you have reviewed this lab result.',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error alert box (Save Error State - Image 2)
                  if (_state == RecordReviewDrawerState.saveError)
                    _buildErrorBanner(),

                  // Success alert box (Reviewed State - Image 3)
                  if (_state == RecordReviewDrawerState.reviewed)
                    _buildSuccessBanner(),

                  // Review Summary Card
                  _buildReviewSummaryCard(),

                  const SizedBox(height: 18),

                  // Review notes (optional)
                  _buildReviewNotes(),

                  // Info Box (Initial State only - Image 1)
                  if (_state == RecordReviewDrawerState.initial) ...[
                    const SizedBox(height: 18),
                    _buildInfoBox(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      // Fixed Bottom Action Bar (above Tablet Bottom Nav)
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
        child: switch (_state) {
          RecordReviewDrawerState.initial => Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _handleClose,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onMarkAsReviewed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      child: const Text(
                        'Mark as reviewed',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          RecordReviewDrawerState.saveError => Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _handleClose,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onTryAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          RecordReviewDrawerState.reviewed => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusControl),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        },
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.errorAlertBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review not saved',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.safetyCriticalText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'We could not save your review. Your notes are kept  try again.',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Result marked as reviewed',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reviewed by ${widget.result.reviewedBy ?? "Dr. Maya Naidoo"} · ${widget.result.reviewedAt ?? "12 Oct 2026 · 11:02"}.',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSummaryCard() {
    final isReviewed = _state == RecordReviewDrawerState.reviewed;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review summary',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow(
            label: 'Patient',
            value: '${widget.result.patientName} · #${widget.result.folderNumber.replaceAll('#', '')}',
          ),
          const SizedBox(height: 10),
          _summaryRow(
            label: 'Test / Investigation',
            value: widget.result.testName,
          ),
          const SizedBox(height: 10),
          _summaryRow(
            label: 'Result received',
            value: widget.result.resultReceivedDate,
          ),
          const SizedBox(height: 10),
          _summaryRow(
            label: 'Documents',
            value: 'Report · PDF, Photo · JPG',
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Review status',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isReviewed
                      ? const Color(0xFFECFDF3)
                      : const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(Dimensions.radiusPill),
                ),
                child: Text(
                  isReviewed ? 'Reviewed' : 'Awaiting review',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isReviewed
                        ? const Color(0xFF15803D)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({required String label, required String value}) {
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

  Widget _buildReviewNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review notes (optional)',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Add a note about this result (optional)',
            hintStyle: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.all(14),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Color(0xFF2563EB),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Marking as reviewed records your name and the time. It does not change the lab referral status.',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 12.5,
                height: 1.4,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Drawer View (Used for Mobile Bottom Sheet & Desktop Right Drawer)
// ============================================================================

class LabResultDrawer extends StatefulWidget {
  const LabResultDrawer({
    super.key,
    required this.result,
    this.initialTabIndex = 0,
    required this.onClose,
    this.onReviewed,
    this.simulateSaveError = false,
    this.initialState,
    this.isMobileSheet = false,
  });

  final LabResultModel result;
  final int initialTabIndex;
  final VoidCallback onClose;
  final ValueChanged<LabResultModel>? onReviewed;

  /// When `true`, tapping "Mark as Reviewed" simulates a save failure
  /// and transitions to the [RecordReviewDrawerState.saveError] state.
  final bool simulateSaveError;

  /// Optional initial state override (useful for testing or direct preview).
  final RecordReviewDrawerState? initialState;

  /// When `true`, renders as the mobile bottom sheet (with drag handle pill and mobile padding).
  final bool isMobileSheet;

  /// Global static toggle for developers to preview the save failure state.
  static bool staticSimulateSaveError = false;

  @override
  State<LabResultDrawer> createState() => _LabResultDrawerState();
}

class _LabResultDrawerState extends State<LabResultDrawer> {
  late RecordReviewDrawerState _state;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    if (widget.initialState != null) {
      _state = widget.initialState!;
    } else if (widget.result.status == LabReviewStatus.reviewed) {
      _state = RecordReviewDrawerState.reviewed;
    } else {
      _state = RecordReviewDrawerState.initial;
    }

    _notesController = TextEditingController(
      text: widget.result.reviewImpression ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onMarkAsReviewed() {
    if (widget.simulateSaveError || LabResultDrawer.staticSimulateSaveError) {
      setState(() {
        _state = RecordReviewDrawerState.saveError;
      });
      return;
    }
    _completeReview();
  }

  void _onTryAgain() {
    _completeReview();
  }

  void _completeReview() {
    setState(() {
      _state = RecordReviewDrawerState.reviewed;
    });
  }

  void _onDone() {
    final updated = widget.result.copyWith(
      status: LabReviewStatus.reviewed,
      reviewedBy: 'Dr. Maya Naidoo',
      reviewedAt: '12 Oct 2026 · 11:02',
      reviewAction: 'Normal · No follow-up needed',
      reviewImpression: _notesController.text.trim(),
    );

    if (Get.isRegistered<LabResultsController>()) {
      Get.find<LabResultsController>().recordReview(
        resultId: widget.result.id,
        action: 'Normal · No follow-up needed',
        impression: _notesController.text.trim(),
        notifyPatient: false,
      );
    }

    widget.onReviewed?.call(updated);
    widget.onClose();
  }

  void _handleClose() {
    if (_state == RecordReviewDrawerState.reviewed) {
      _onDone();
    } else {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Drag Handle (Mobile bottom sheet only)
        if (widget.isMobileSheet)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

        // Header (Title, Subtitle, Close Button)
        _buildHeader(),

        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isMobileSheet ? 20 : 24,
              vertical: widget.isMobileSheet ? 16 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error alert box (Save Error State)
                if (_state == RecordReviewDrawerState.saveError)
                  _buildErrorBanner(),

                // Success alert box (Reviewed State)
                if (_state == RecordReviewDrawerState.reviewed)
                  _buildSuccessBanner(),

                // Review Summary Card
                _buildReviewSummaryCard(),

                // Notes field: visible in initial, error, and mobile reviewed state
                if (_state != RecordReviewDrawerState.reviewed ||
                    widget.isMobileSheet) ...[
                  const SizedBox(height: 18),
                  _buildReviewNotes(),
                ],

                // Blue info notice box: visible in initial state
                if (_state == RecordReviewDrawerState.initial) ...[
                  const SizedBox(height: 18),
                  _buildInfoBox(),
                ] else if (!widget.isMobileSheet &&
                    _state == RecordReviewDrawerState.reviewed) ...[
                  const SizedBox(height: 16),
                  _buildReviewedFootnote(),
                ],
              ],
            ),
          ),
        ),

        // Sticky Bottom Action Bar
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    final isReviewed = _state == RecordReviewDrawerState.reviewed;
    final String subtitle = widget.isMobileSheet
        ? 'Confirm you have reviewed this lab result.'
        : (isReviewed
            ? 'Review recorded for this lab result.'
            : 'Confirm you have reviewed this lab result.');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobileSheet ? 20 : 24,
        vertical: widget.isMobileSheet ? 14 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: widget.isMobileSheet
            ? null
            : const Border(
                bottom: BorderSide(
                  color: AppColors.borderDefault,
                  width: Dimensions.strokeDivider,
                ),
              ),
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
                  'Record Review',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: widget.isMobileSheet ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _handleClose,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.errorAlertBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review not saved',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.safetyCriticalText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'We could not save your review. Your notes are kept  try again.',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Result marked as reviewed',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reviewed by ${widget.result.reviewedBy ?? "Dr. Maya Naidoo"} · ${widget.result.reviewedAt ?? "12 Oct 2026 · 11:02"}.',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSummaryCard() {
    final isReviewed = _state == RecordReviewDrawerState.reviewed;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review summary',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow(
            label: 'Patient',
            value: '${widget.result.patientName} · #${widget.result.folderNumber.replaceAll('#', '')}',
          ),
          const SizedBox(height: 10),
          _summaryRow(
            label: 'Test / Investigation',
            value: widget.result.testName,
          ),
          const SizedBox(height: 10),
          _summaryRow(
            label: 'Result received',
            value: widget.result.resultReceivedDate,
          ),
          const SizedBox(height: 10),
          _summaryRow(
            label: 'Documents',
            value: 'Report · PDF, Photo · JPG',
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Review status',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isReviewed
                      ? const Color(0xFFECFDF3)
                      : const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(Dimensions.radiusPill),
                ),
                child: Text(
                  isReviewed ? 'Reviewed' : 'Awaiting review',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isReviewed
                        ? const Color(0xFF15803D)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({required String label, required String value}) {
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

  Widget _buildReviewNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review notes (optional)',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Add a note about this result (optional)',
            hintStyle: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.all(14),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Color(0xFF2563EB),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Marking as reviewed records your name and the time. It does not change the lab referral status.',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 12.5,
                height: 1.4,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewedFootnote() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'The report stays available on the result details page. The lab referral status is not changed by this review.',
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 12.5,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: switch (_state) {
          RecordReviewDrawerState.initial => Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _handleClose,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _onMarkAsReviewed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      child: const Text(
                        'Mark as Reviewed',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          RecordReviewDrawerState.saveError => Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _handleClose,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _onTryAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          RecordReviewDrawerState.reviewed => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusControl),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        },
      ),
    );
  }
}

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

// ============================================================================
// Lab Staff: Upload Lab Result (Desktop Drawer, Tablet Page, Mobile Sheet)
// ============================================================================

/// Opens the Upload Lab Result panel across platforms with bottom navigation
/// suppressed on mobile and tablet:
/// - Desktop: Slide-in right drawer with backdrop scrim & pinned bottom bar.
/// - Tablet: Full white page inside [AppShell] (`hideBottomNavigation: true`).
/// - Mobile: Modal bottom sheet (`useRootNavigator: true`, no bottom nav).
Future<void> showUploadLabResultPanel(
  BuildContext context, {
  required LabReferralModel referral,
}) async {
  final isMobile = ResponsiveHelper.isMobile(context);
  final isTablet = ResponsiveHelper.isTablet(context);

  Future<void> handleUploaded(String fileName) async {
    final updated = saveUploadedLabResult(referral, fileName: fileName);
    if (!context.mounted) return;
    await showLabResultUploadedDialog(
      context,
      referral: updated,
      fileName: fileName,
    );
  }

  if (isMobile) {
    final uploadedFile = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.90,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: _MobileUploadLabResultSheet(
              referral: referral,
              onClose: () => Navigator.of(ctx).pop(),
              onUploaded: (fileName) => Navigator.of(ctx).pop(fileName),
            ),
          ),
        ),
      ),
    );

    if (uploadedFile != null) {
      handleUploaded(uploadedFile);
    }
    return;
  }

  if (isTablet) {
    final uploadedFile = await Navigator.of(context).push<String>(
      PageRouteBuilder<String>(
        pageBuilder: (ctx, animation, secondaryAnimation) => AppShell(
          route: AppRoutes.labResults,
          hideBottomNavigation: true,
          hideMobileHeader: true,
          child: _TabletUploadLabResultView(
            referral: referral,
            onClose: () => Navigator.of(ctx).pop(),
            onUploaded: (fileName) => Navigator.of(ctx).pop(fileName),
          ),
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (uploadedFile != null) {
      handleUploaded(uploadedFile);
    }
    return;
  }

  // Desktop: Slide-in Right Drawer
  final uploadedFile = await showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 16,
          shadowColor: Colors.black45,
          child: Container(
            width: Dimensions.drawerWidth,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(
                  color: AppColors.borderDefault,
                  width: Dimensions.strokeDivider,
                ),
              ),
            ),
            child: _DesktopUploadLabResultDrawer(
              referral: referral,
              onClose: () => Navigator.of(dialogContext).pop(),
              onUploaded: (fileName) => Navigator.of(dialogContext).pop(fileName),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );

  if (uploadedFile != null) {
    handleUploaded(uploadedFile);
  }
}

class _DesktopUploadLabResultDrawer extends StatelessWidget {
  const _DesktopUploadLabResultDrawer({
    required this.referral,
    required this.onClose,
    required this.onUploaded,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final ValueChanged<String> onUploaded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Lab Result',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Attach a laboratory report to the selected patient referral.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderDefault),
        Expanded(
          child: _UploadLabResultForm(
            referral: referral,
            onClose: onClose,
            onUploaded: onUploaded,
            padding: const EdgeInsets.all(24),
          ),
        ),
      ],
    );
  }
}

class _TabletUploadLabResultView extends StatelessWidget {
  const _TabletUploadLabResultView({
    required this.referral,
    required this.onClose,
    required this.onUploaded,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final ValueChanged<String> onUploaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.pageMarginTablet,
              20,
              Dimensions.pageMarginTablet,
              4,
            ),
            child: Row(
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
                        'Upload Lab Result',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Attach a laboratory report to the selected patient referral.',
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
          ),
          Expanded(
            child: _UploadLabResultForm(
              referral: referral,
              onClose: onClose,
              onUploaded: onUploaded,
              fullWidthChooseButton: true,
              testLabel: 'Requested test',
              referenceLabel: 'Referral reference',
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginTablet,
                vertical: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileUploadLabResultSheet extends StatelessWidget {
  const _MobileUploadLabResultSheet({
    required this.referral,
    required this.onClose,
    required this.onUploaded,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final ValueChanged<String> onUploaded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Lab Result',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Attach a laboratory report to the selected patient referral.',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _UploadLabResultForm(
            referral: referral,
            onClose: onClose,
            onUploaded: onUploaded,
            fullWidthChooseButton: true,
            testLabel: 'Requested test',
            referenceLabel: 'Referral reference',
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          ),
        ),
      ],
    );
  }
}

class _UploadLabResultForm extends StatefulWidget {
  const _UploadLabResultForm({
    required this.referral,
    required this.onClose,
    required this.onUploaded,
    required this.padding,
    this.fullWidthChooseButton = false,
    this.testLabel = 'Test requested',
    this.referenceLabel = 'Referral',
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final ValueChanged<String> onUploaded;
  final EdgeInsets padding;
  final bool fullWidthChooseButton;
  final String testLabel;
  final String referenceLabel;

  @override
  State<_UploadLabResultForm> createState() => _UploadLabResultFormState();
}

class _UploadLabResultFormState extends State<_UploadLabResultForm> {
  String? _selectedFileName;
  String? _validationError;

  String get _selectedDocType {
    final name = _selectedFileName?.toLowerCase() ?? '';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'JPG image';
    if (name.endsWith('.png')) return 'PNG image';
    return 'PDF document';
  }

  Future<void> _pickFile() async {
    final chosenName = await showReportFilePicker(
      context,
      referral: widget.referral,
    );
    if (chosenName != null && mounted) {
      setState(() {
        _selectedFileName = chosenName;
        _validationError = null;
      });
    }
  }

  void _handleSubmit() {
    if (_selectedFileName == null) {
      setState(() {
        _validationError = 'Please choose a PDF, JPG, or PNG file to upload.';
      });
      return;
    }
    widget.onUploaded(_selectedFileName!);
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _selectedFileName != null;
    final hasError = _validationError != null;
    final borderColor =
        hasError ? AppColors.fieldErrorBorder : const Color(0xFFD1D5DB);
    const dropzoneBg = Color(0xFFF8FAFC);

    final chooseButton = OutlinedButton(
      onPressed: _pickFile,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: Size(
          widget.fullWidthChooseButton ? double.infinity : 124,
          42,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
        side: const BorderSide(color: AppColors.borderDefault),
        foregroundColor: AppColors.brandPrimary,
      ),
      child: const Text(
        'Choose File',
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: widget.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mint Info Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6F3),
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  ),
                  child: Column(
                    children: [
                      _buildMintRow('Patient', widget.referral.patientName),
                      const Divider(height: 16, color: Color(0x180F766E)),
                      _buildMintRow('Patient ID', widget.referral.folderNumber),
                      const Divider(height: 16, color: Color(0x180F766E)),
                      _buildMintRow(
                        widget.testLabel,
                        widget.referral.testsRequested,
                      ),
                      const Divider(height: 16, color: Color(0x180F766E)),
                      _buildMintRow(
                        'Requesting doctor',
                        widget.referral.requestedBy,
                      ),
                      const Divider(height: 16, color: Color(0x180F766E)),
                      _buildMintRow(
                        widget.referenceLabel,
                        '${widget.referral.referenceNumber} · ${widget.referral.referralDate}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Result document',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                if (hasFile)
                  _buildSelectedDocumentPreview()
                else
                  CustomPaint(
                    painter: LabDashedRRectPainter(
                      color: borderColor,
                      radius: Dimensions.radiusControl,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: dropzoneBg,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
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
                          const SizedBox(height: 14),
                          Text(
                            'Select a PDF or image file',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14,
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
                          if (widget.fullWidthChooseButton)
                            SizedBox(width: double.infinity, child: chooseButton)
                          else
                            chooseButton,
                        ],
                      ),
                    ),
                  ),

                if (hasError) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 15,
                        color: AppColors.safetyCriticalText,
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
              ],
            ),
          ),
        ),

        // Pinned Sticky Bottom Bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.borderDefault)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClose,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                      side: const BorderSide(color: AppColors.borderDefault),
                      foregroundColor: AppColors.brandPrimary,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FilledButton(
                    onPressed: _handleSubmit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: AppColors.brandPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDocumentPreview() {
    final isPdf = (_selectedFileName ?? '').toLowerCase().endsWith('.pdf');
    const previewBarFactors = [0.72, 0.85, 0.62, 0.78, 0.90, 0.68];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Selected file summary row card with delete button
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPdf ? Icons.description_outlined : Icons.image_outlined,
                  size: 20,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFileName!,
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
                      _selectedDocType,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                  width: 40,
                  height: 40,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Document preview paper mockup box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F9F8),
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
                const SizedBox(height: 12),
                ...List.generate(previewBarFactors.length, (index) {
                  final isLast = index == previewBarFactors.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: previewBarFactors[index],
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
        const SizedBox(height: 12),

        // 3. Blue attachment confirmation banner
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
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Will be attached to ${widget.referral.patientName} (${widget.referral.folderNumber}) · ${widget.referral.referenceNumber} · ${widget.referral.testsRequested}.',
                  style: const TextStyle(
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
    );
  }

  Widget _buildMintRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

/// Persists an uploaded laboratory result onto [LabReferralController] so
/// neither the Result list nor Referral Details asks to upload it again.
LabReferralModel saveUploadedLabResult(
  LabReferralModel referral, {
  required String fileName,
}) {
  final uploader = Get.isRegistered<RoleController>()
      ? RoleController.to.currentRole.value.demoUserName
      : 'Lerato Mokoena';
  final receivedAt = '${referral.referralDate}, 14:30';
  var updated = referral.copyWith(
    status: LabReferralStatus.resultReceived,
    uploadedDocumentName: fileName,
    resultReceivedAt: receivedAt,
    uploadedBy: uploader,
  );

  if (Get.isRegistered<LabReferralController>()) {
    LabReferralController.to.updateReferralStatus(
      referral.id,
      LabReferralStatus.resultReceived,
      uploadedDocumentName: fileName,
      resultReceivedAt: receivedAt,
      uploadedBy: uploader,
    );
    updated =
        LabReferralController.to.labStaffResults.firstWhereOrNull(
              (r) => r.id == referral.id,
            ) ??
            LabReferralController.to.referrals.firstWhereOrNull(
              (r) => r.id == referral.id,
            ) ??
            updated;
  }
  return updated;
}

/// Opens the shared PDF/JPG/PNG report picker across Desktop, Tablet, and Mobile.
Future<String?> showReportFilePicker(
  BuildContext context, {
  required LabReferralModel referral,
}) async {
  final stem = referral.documentStem;
  final options = <({String name, String meta, bool isPdf})>[
    (name: '$stem.pdf', meta: 'PDF · 420 KB', isPdf: true),
    (name: '${stem}_scan.jpg', meta: 'JPG · 1.2 MB', isPdf: false),
    (name: '${stem}_report.png', meta: 'PNG · 890 KB', isPdf: false),
  ];

  Widget buildOptionTile(
    BuildContext ctx,
    ({String name, String meta, bool isPdf}) item,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.of(ctx).pop(item),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F6F3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isPdf
                      ? Icons.description_outlined
                      : Icons.image_outlined,
                  size: 18,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.meta,
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
      ),
    );
  }

  final isMobile = ResponsiveHelper.isMobile(context);
  final chosen = isMobile
      ? await showModalBottomSheet<({String name, String meta, bool isPdf})>(
          context: context,
          useRootNavigator: true,
          backgroundColor: Colors.transparent,
          barrierColor: AppColors.scrim,
          builder: (ctx) => Container(
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
                    Text(
                      'Select Report File',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...options.map((item) => buildOptionTile(ctx, item)),
                  ],
                ),
              ),
            ),
          ),
        )
      : await showDialog<({String name, String meta, bool isPdf})>(
          context: context,
          barrierColor: AppColors.scrim,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Report File',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Accepted formats: PDF, JPG, PNG',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...options.map((item) => buildOptionTile(ctx, item)),
                  ],
                ),
              ),
            ),
          ),
        );

  return chosen?.name;
}

class LabDashedRRectPainter extends CustomPainter {
  const LabDashedRRectPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant LabDashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Displays the Lab Result Uploaded confirmation overlay after a result file
/// is attached: centered modal dialog on Desktop/Tablet, modal bottom sheet
/// on Mobile.
Future<void> showLabResultUploadedDialog(
  BuildContext context, {
  required LabReferralModel referral,
  required String fileName,
}) async {
  final isMobile = ResponsiveHelper.isMobile(context);
  final fromDetails =
      ModalRoute.of(context)?.settings.name == AppRoutes.labReferralDetails ||
      Get.currentRoute == AppRoutes.labReferralDetails;

  void handleViewResult(BuildContext overlayContext) {
    Navigator.of(overlayContext).pop();
    if (!context.mounted) return;
    openLabStaffResultDetailsPage(
      context,
      referral: referral,
      documentName: fileName,
      openedFromDetails: fromDetails,
    );
  }

  void handleReturnToResult(BuildContext overlayContext) {
    Navigator.of(overlayContext).pop();
    if (!fromDetails) return;
    final hasLabResultsRoute = Get.routeTree.routes.any(
      (r) => r.name == AppRoutes.labResults,
    );
    if (hasLabResultsRoute) {
      AppNavigation.goTo(AppRoutes.labResults);
    } else if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  if (isMobile) {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (sheetContext) => _LabResultUploadedMobileSheet(
        referral: referral,
        fileName: fileName,
        onViewResult: () => handleViewResult(sheetContext),
        onReturnToResult: () => handleReturnToResult(sheetContext),
      ),
    );
    return;
  }

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss lab result uploaded modal',
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, _) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _LabResultUploadedDialogCard(
          referral: referral,
          fileName: fileName,
          onViewResult: () => handleViewResult(dialogContext),
          onReturnToResult: () => handleReturnToResult(dialogContext),
        ),
      ),
    ),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _LabResultUploadedDialogCard extends StatelessWidget {
  const _LabResultUploadedDialogCard({
    required this.referral,
    required this.fileName,
    required this.onViewResult,
    required this.onReturnToResult,
  });

  final LabReferralModel referral;
  final String fileName;
  final VoidCallback onViewResult;
  final VoidCallback onReturnToResult;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 16,
      shadowColor: const Color(0x260F172A),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
          child: _LabResultUploadedContent(
            referral: referral,
            fileName: fileName,
            onViewResult: onViewResult,
            onReturnToResult: onReturnToResult,
          ),
        ),
      ),
    );
  }
}

class _LabResultUploadedMobileSheet extends StatelessWidget {
  const _LabResultUploadedMobileSheet({
    required this.referral,
    required this.fileName,
    required this.onViewResult,
    required this.onReturnToResult,
  });

  final LabReferralModel referral;
  final String fileName;
  final VoidCallback onViewResult;
  final VoidCallback onReturnToResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6DCE2),
                  borderRadius: BorderRadius.circular(Dimensions.radiusPill),
                ),
              ),
              _LabResultUploadedContent(
                referral: referral,
                fileName: fileName,
                onViewResult: onViewResult,
                onReturnToResult: onReturnToResult,
                isCompact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabResultUploadedContent extends StatelessWidget {
  const _LabResultUploadedContent({
    required this.referral,
    required this.fileName,
    required this.onViewResult,
    required this.onReturnToResult,
    this.isCompact = false,
  });

  final LabReferralModel referral;
  final String fileName;
  final VoidCallback onViewResult;
  final VoidCallback onReturnToResult;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F6F3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 26,
            color: Color(0xFF0F766E),
          ),
        ),
        SizedBox(height: isCompact ? 16 : 20),
        Text(
          'Lab Result Uploaded',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isCompact ? 20 : 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "The laboratory result has been attached to the patient's record.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isCompact ? 13.5 : 14,
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        SizedBox(height: isCompact ? 18 : 22),
        _UploadedDetailRow(
          label: 'Patient',
          valueWidget: Text(
            '${referral.patientName} · ${referral.folderNumber}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.borderDefault),
        _UploadedDetailRow(
          label: 'Requested test',
          valueWidget: Text(
            referral.testsRequested,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.borderDefault),
        _UploadedDetailRow(
          label: 'Referral reference',
          valueWidget: Text(
            referral.referenceNumber,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.borderDefault),
        _UploadedDetailRow(
          label: 'Document',
          valueWidget: Text(
            fileName,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.borderDefault),
        const _UploadedDetailRow(
          label: 'Referral status',
          valueWidget: LabReferralStatusPill(
            status: LabReferralStatus.resultReceived,
          ),
        ),
        const Divider(height: 1, color: AppColors.borderDefault),
        _UploadedDetailRow(
          label: 'Doctor review',
          valueWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(Dimensions.radiusPill),
            ),
            child: const Text(
              'Doctor review pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        SizedBox(height: isCompact ? 16 : 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${referral.requestedBy} can now access this result and has been notified. Clinical review is done by the doctor.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF4338CA),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isCompact ? 18 : 22),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onViewResult,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    Dimensions.buttonMinHeight,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.brandPrimary,
                  side: const BorderSide(color: AppColors.borderDefault),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusControl,
                    ),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('View Result'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onReturnToResult,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    Dimensions.buttonMinHeight,
                  ),
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusControl,
                    ),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Return to Result'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UploadedDetailRow extends StatelessWidget {
  const _UploadedDetailRow({
    required this.label,
    required this.valueWidget,
  });

  final String label;
  final Widget valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget,
            ),
          ),
        ],
      ),
    );
  }
}
