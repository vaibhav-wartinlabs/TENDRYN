import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/lab_results/controllers/lab_results_controller.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';

/// Opens the Create Lab Referral UI across platforms:
/// - Desktop: Slide-in Right Drawer with backdrop scrim.
/// - Tablet: Full page inside AppShell with hideBottomNavigation: true, no slide animation.
/// - Mobile: Modal Bottom Sheet (useRootNavigator: true, no bottom navigation).
void showCreateLabReferral(BuildContext context) {
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
            child: _MobileCreateLabReferralSheet(
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
          child: TabletCreateLabReferralView(
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
            child: _DesktopCreateLabReferralDrawer(
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
class _MobileCreateLabReferralSheet extends StatelessWidget {
  const _MobileCreateLabReferralSheet({required this.onClose});

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
                      'Create Lab Referral',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Request laboratory tests for a patient.',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
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

        // Scrollable Form Content
        Expanded(
          child: _CreateLabReferralForm(onClose: onClose),
        ),
      ],
    );
  }
}

// ── Tablet Full Page View ───────────────────────────────────────────────────
class TabletCreateLabReferralView extends StatelessWidget {
  const TabletCreateLabReferralView({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: Column(
        children: [
          // Tablet Top Header with Boxed Back Button & Close Icon
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
                        'Create Lab Referral',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Request laboratory tests for a patient.',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close, size: 22, color: AppColors.textSecondary),
                  onPressed: onClose,
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Scrollable Form Content
          Expanded(
            child: _CreateLabReferralForm(onClose: onClose),
          ),
        ],
      ),
    );
  }
}

// ── Desktop Slide-in Drawer View ────────────────────────────────────────────
class _DesktopCreateLabReferralDrawer extends StatelessWidget {
  const _DesktopCreateLabReferralDrawer({required this.onClose});

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
                        'Create Lab Referral',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Request laboratory tests for a patient.',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
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

          // Scrollable Form Content
          Expanded(
            child: _CreateLabReferralForm(onClose: onClose),
          ),
        ],
      ),
    );
  }
}

// ── Shared Form Content & Sticky Actions ────────────────────────────────────
class _CreateLabReferralForm extends StatefulWidget {
  const _CreateLabReferralForm({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_CreateLabReferralForm> createState() => _CreateLabReferralFormState();
}

class _CreateLabReferralFormState extends State<_CreateLabReferralForm> {
  final _patientController = TextEditingController();
  final _testsController = TextEditingController();
  final _labController = TextEditingController(text: 'Soweto NHLS Laboratory');
  final _notesController = TextEditingController();
  final _icdController = TextEditingController();

  @override
  void dispose() {
    _patientController.dispose();
    _testsController.dispose();
    _labController.dispose();
    _notesController.dispose();
    _icdController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final patient = _patientController.text.trim().isEmpty
        ? 'Jane Doe'
        : _patientController.text.trim();
    final tests = _testsController.text.trim().isEmpty
        ? 'Full blood count'
        : _testsController.text.trim();

    final newReferral = LabReferralModel(
      id: 'ref-${DateTime.now().millisecondsSinceEpoch}',
      patientName: patient,
      folderNumber: '#SWC-50${(100 + (DateTime.now().millisecond % 899))}',
      testsRequested: tests,
      referralDate: '12 Oct 2026',
      status: LabReferralStatus.requested,
    );

    if (Get.isRegistered<LabResultsController>()) {
      Get.find<LabResultsController>().referrals.insert(0, newReferral);
    }

    AppNotice.info('Lab Referral', 'Referral created successfully');
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Patient* Field
                _buildFieldLabel('Patient', isRequired: true),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _patientController,
                  hintText: 'Search patient by name or folder no.',
                ),
                const SizedBox(height: 18),

                // 2. Tests* Field
                _buildFieldLabel('Tests', isRequired: true),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _testsController,
                  hintText: 'Search tests (e.g. Full blood count)',
                ),
                const SizedBox(height: 4),
                const Text(
                  'Search and select one or more tests.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Laboratory Field
                _buildFieldLabel('Laboratory', isRequired: false),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _labController,
                  hintText: 'Laboratory name',
                ),
                const SizedBox(height: 18),

                // 4. Clinical notes Field
                _buildFieldLabel('Clinical notes', isRequired: false),
                const SizedBox(height: 6),
                _buildTextAreaField(
                  controller: _notesController,
                  hintText: 'Add clinical notes for the laboratory',
                ),
                const SizedBox(height: 18),

                // 5. ICD-10 Field
                _buildFieldLabel('ICD-10', isRequired: false),
                const SizedBox(height: 6),
                _buildInputField(
                  controller: _icdController,
                  hintText: 'Search by code or description',
                  prefixIcon: AppIcons.search,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Sticky Bottom Actions
        Container(
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
                      onPressed: widget.onClose,
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
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      child: const Text(
                        'Create Refferal',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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

  Widget _buildFieldLabel(String label, {required bool isRequired}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            color: AppColors.textDisabled,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 18, color: AppColors.textSecondary)
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            color: AppColors.textDisabled,
          ),
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
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
