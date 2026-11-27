import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';

/// Opens the Lab Referral Details across platforms:
/// - Desktop: Slide-in Right Drawer with backdrop scrim.
/// - Tablet: Full page inside AppShell with hideBottomNavigation: true and top TabletHeader.
/// - Mobile: Modal Bottom Sheet (useRootNavigator: true, no bottom navigation).
void showLabReferralDetails(
  BuildContext context, {
  required LabReferralModel referral,
}) {
  final isMobile = ResponsiveHelper.isMobile(context);
  final isTablet = ResponsiveHelper.isTablet(context);

  if (isMobile) {
    showModalBottomSheet<void>(
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
            child: _MobileLabReferralSheet(
              referral: referral,
              onClose: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      ),
    );
    return;
  }

  if (isTablet) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (ctx, animation, secondaryAnimation) => AppShell(
          route: AppRoutes.labResults,
          hideBottomNavigation: true,
          child: TabletLabReferralDetailsView(
            referral: referral,
            onClose: () => Navigator.of(ctx).pop(),
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
            child: _DesktopLabReferralDrawer(
              referral: referral,
              onClose: () => Navigator.of(dialogContext).pop(),
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
}

// ── Mobile Bottom Sheet View ────────────────────────────────────────────────
class _MobileLabReferralSheet extends StatelessWidget {
  const _MobileLabReferralSheet({
    required this.referral,
    required this.onClose,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Drag Handle Pill
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
        const SizedBox(height: 12),

        // Header (Title, Subtitle & Close 'x' button)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lab Referral Details',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${referral.patientName} · referred ${referral.referralDate}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(AppIcons.close, size: 20, color: AppColors.textSecondary),
                onPressed: onClose,
                tooltip: 'Close',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.borderDefault),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _LabReferralDetailsBody(referral: referral),
          ),
        ),

        // Bottom Action Bar
        _LabReferralActions(referral: referral, onClose: onClose),
      ],
    );
  }
}

// ── Tablet Full Page View ───────────────────────────────────────────────────
class TabletLabReferralDetailsView extends StatelessWidget {
  const TabletLabReferralDetailsView({
    super.key,
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
          // Tablet Top Header with Boxed Back Button
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
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${referral.patientName} · referred ${referral.referralDate}',
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
              child: _LabReferralDetailsBody(referral: referral, isTabletOrDesktop: true),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _LabReferralActions(referral: referral, onClose: onClose),
    );
  }
}

// ── Desktop Slide-in Drawer View ────────────────────────────────────────────
class _DesktopLabReferralDrawer extends StatelessWidget {
  const _DesktopLabReferralDrawer({
    required this.referral,
    required this.onClose,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with close 'x'
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lab Referral Details',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${referral.patientName} · referred ${referral.referralDate}',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close, size: 20, color: AppColors.textSecondary),
                  onPressed: onClose,
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _LabReferralDetailsBody(referral: referral, isTabletOrDesktop: true),
            ),
          ),

          // Action Buttons
          _LabReferralActions(referral: referral, onClose: onClose),
        ],
      ),
    );
  }
}

// ── Shared Body Content ─────────────────────────────────────────────────────
class _LabReferralDetailsBody extends StatelessWidget {
  const _LabReferralDetailsBody({
    required this.referral,
    this.isTabletOrDesktop = false,
  });

  final LabReferralModel referral;
  final bool isTabletOrDesktop;

  @override
  Widget build(BuildContext context) {
    final folderNo = referral.folderNumber.startsWith('#')
        ? referral.folderNumber
        : '#${referral.folderNumber}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Blue Read-only status Info Alert
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Read-only status',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D4ED8),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'The laboratory updates the referral status. Doctors can view it but not change it.',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            children: [
              _buildRow(
                label: 'Patient',
                valueWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      referral.patientName,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Folder $folderNo',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildRow(
                label: 'Referral status',
                valueWidget: LabReferralStatusPill(status: referral.status),
              ),
              const SizedBox(height: 16),
              _buildRow(
                label: 'Referral date',
                value: referral.referralDate,
              ),
              const SizedBox(height: 16),
              _buildRow(
                label: 'Laboratory',
                value: 'Soweto NHLS Laboratory',
              ),
              const SizedBox(height: 16),
              _buildRow(
                label: 'Requested by',
                value: 'Dr. Maya Naidoo',
              ),
              const SizedBox(height: 16),
              _buildRow(
                label: 'Tests requested',
                valueWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4EA),
                    borderRadius: BorderRadius.circular(Dimensions.radiusPill),
                  ),
                  child: Text(
                    referral.testsRequested,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildRow(
                label: 'Clinical notes',
                value: isTabletOrDesktop ? 'Not recorded (placeholder)' : 'Not recorded',
              ),
              const SizedBox(height: 16),
              _buildRow(
                label: 'ICD-10',
                value: isTabletOrDesktop ? 'Not recorded (placeholder)' : 'Not recorded',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Linked Result Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Linked result',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                referral.status == LabReferralStatus.resultReceived
                    ? 'Result received. The test report is available in Lab Results.'
                    : 'No result yet. The linked result appears here once the laboratory sends it.',
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow({
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        if (valueWidget != null)
          Flexible(child: valueWidget)
        else if (value != null)
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Shared Bottom Actions ───────────────────────────────────────────────────
class _LabReferralActions extends StatelessWidget {
  const _LabReferralActions({
    required this.referral,
    required this.onClose,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderDefault),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    onClose();
                    Get.toNamed(AppRoutes.patientDetails);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    ),
                  ),
                  child: const Text(
                    'View Patient Profile',
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
      ),
    );
  }
}

class _BoxedBackButton extends StatelessWidget {
  const _BoxedBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          border: Border.all(color: AppColors.borderDefault),
        ),
        alignment: Alignment.center,
        child: const Icon(
          AppIcons.chevronLeft,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
