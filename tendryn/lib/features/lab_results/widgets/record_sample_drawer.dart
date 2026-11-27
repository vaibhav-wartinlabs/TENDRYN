import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/lab_results/controllers/lab_referral_controller.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/features/lab_results/views/lab_referral_details_view.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';

/// Opens the Record Sample form across platforms:
/// - Desktop: Slide-in Right Drawer with backdrop scrim & pinned bottom action bar.
/// - Tablet: Full page inside AppShell with hideBottomNavigation: true & pinned bottom action bar.
/// - Mobile: Modal Bottom Sheet with useRootNavigator: true & pinned bottom action bar.
Future<void> showRecordSamplePanel(
  BuildContext context, {
  required LabReferralModel referral,
  ValueChanged<LabReferralModel>? onSampleSaved,
}) async {
  final isMobile = ResponsiveHelper.isMobile(context);
  final isTablet = ResponsiveHelper.isTablet(context);

  LabReferralModel buildUpdatedReferral(Map<String, String> saved) {
    return referral.copyWith(
      status: LabReferralStatus.sampleTaken,
      collectionDate: saved['collectionDate'] ?? '31 Oct 2026',
      collectionTime: saved['collectionTime'] ?? '10:15',
      sampleRecordedBy: saved['sampleRecordedBy'] ?? 'Lerato Mokoena (Lab Staff)',
      sampleNotes: saved['sampleNotes'] ?? 'Collected at lab reception.',
    );
  }

  if (isMobile) {
    final saved = await showModalBottomSheet<Map<String, String>>(
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
            child: _MobileRecordSampleSheet(
              referral: referral,
              onClose: () => Navigator.of(ctx).pop(),
              onSaved: (data) => Navigator.of(ctx).pop(data),
            ),
          ),
        ),
      ),
    );

    if (saved != null && context.mounted) {
      final updated = buildUpdatedReferral(saved);
      onSampleSaved?.call(updated);
      showSampleRecordedDialog(
        context,
        referral: updated,
        collectedDateTime: saved['collected'] ?? '',
        recordedBy: saved['recordedBy'] ?? 'Lerato Mokoena',
      );
    }
    return;
  }

  if (isTablet) {
    final saved = await Navigator.of(context).push<Map<String, String>>(
      PageRouteBuilder<Map<String, String>>(
        pageBuilder: (ctx, animation, secondaryAnimation) => AppShell(
          route: AppRoutes.labReferral,
          hideBottomNavigation: true,
          hideMobileHeader: true,
          child: TabletRecordSampleView(
            referral: referral,
            onClose: () => Navigator.of(ctx).pop(),
            onSaved: (data) => Navigator.of(ctx).pop(data),
          ),
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (saved != null && context.mounted) {
      final updated = buildUpdatedReferral(saved);
      onSampleSaved?.call(updated);
      showSampleRecordedDialog(
        context,
        referral: updated,
        collectedDateTime: saved['collected'] ?? '',
        recordedBy: saved['recordedBy'] ?? 'Lerato Mokoena',
      );
    }
    return;
  }

  // Desktop: Slide-in Drawer from right
  final saved = await showGeneralDialog<Map<String, String>>(
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
            child: _DesktopRecordSampleDrawer(
              referral: referral,
              onClose: () => Navigator.of(dialogContext).pop(),
              onSaved: (data) => Navigator.of(dialogContext).pop(data),
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

  if (saved != null && context.mounted) {
    final updated = buildUpdatedReferral(saved);
    onSampleSaved?.call(updated);
    showSampleRecordedDialog(
      context,
      referral: updated,
      collectedDateTime: saved['collected'] ?? '',
      recordedBy: saved['recordedBy'] ?? 'Lerato Mokoena',
    );
  }
}

// ── Desktop Drawer ───────────────────────────────────────────────────────────
class _DesktopRecordSampleDrawer extends StatelessWidget {
  const _DesktopRecordSampleDrawer({
    required this.referral,
    required this.onClose,
    this.onSaved,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final ValueChanged<Map<String, String>>? onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drawer Header (Title, Subtitle & Close 'X')
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
                      'Record Sample',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Record sample collection for this referral.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderDefault),

        // Form with Scrollable Content + Pinned Bottom Bar
        Expanded(
          child: _RecordSampleForm(
            referral: referral,
            onClose: onClose,
            onSaved: onSaved,
            padding: const EdgeInsets.all(24),
          ),
        ),
      ],
    );
  }
}

// ── Tablet Full Page View ────────────────────────────────────────────────────
class TabletRecordSampleView extends StatelessWidget {
  const TabletRecordSampleView({
    super.key,
    required this.referral,
    required this.onClose,
    this.onSaved,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final ValueChanged<Map<String, String>>? onSaved;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: Column(
        children: [
          // Tablet Header with Boxed Back Button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.pageMarginTablet,
              vertical: 16,
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
                        'Record Sample',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Record sample collection for this referral.',
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

          // Form with Scrollable Content + Pinned Bottom Bar
          Expanded(
            child: _RecordSampleForm(
              referral: referral,
              onClose: onClose,
              onSaved: onSaved,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginTablet,
                vertical: 24,
              ),
              centerContent: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile Bottom Sheet ──────────────────────────────────────────────────────
class _MobileRecordSampleSheet extends StatelessWidget {
  const _MobileRecordSampleSheet({
    required this.referral,
    required this.onClose,
    this.onSaved,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final ValueChanged<Map<String, String>>? onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top drag handle
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

        // Header
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
                      'Record Sample',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Record sample collection for this referral.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.borderDefault),

        // Form with Scrollable Content + Pinned Bottom Bar
        Expanded(
          child: _RecordSampleForm(
            referral: referral,
            onClose: onClose,
            onSaved: onSaved,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

// ── Record Sample Form (Common for all platforms) ────────────────────────────
class _RecordSampleForm extends StatefulWidget {
  const _RecordSampleForm({
    required this.referral,
    required this.onClose,
    this.onSaved,
    this.padding = const EdgeInsets.all(24),
    this.centerContent = false,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final ValueChanged<Map<String, String>>? onSaved;
  final EdgeInsets padding;
  final bool centerContent;

  @override
  State<_RecordSampleForm> createState() => _RecordSampleFormState();
}

class _RecordSampleFormState extends State<_RecordSampleForm> {
  final TextEditingController _notesController = TextEditingController();
  String _dateText = '';
  String _timeText = '';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandPrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      setState(() {
        _dateText = '${picked.day.toString().padLeft(2, '0')} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandPrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeText = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _handleSave() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final defaultDate =
        '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
    final defaultTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateVal = _dateText.isNotEmpty ? _dateText : defaultDate;
    final timeVal = _timeText.isNotEmpty ? _timeText : defaultTime;
    final notesVal = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : 'Collected at lab reception.';
    const recordedByVal = 'Lerato Mokoena (Lab Staff)';
    final collected = '$dateVal, $timeVal';

    if (Get.isRegistered<LabReferralController>()) {
      LabReferralController.to.updateReferralStatus(
        widget.referral.id,
        LabReferralStatus.sampleTaken,
        collectionDate: dateVal,
        collectionTime: timeVal,
        sampleRecordedBy: recordedByVal,
        sampleNotes: notesVal,
      );
    }
    if (widget.onSaved != null) {
      widget.onSaved!({
        'collected': collected,
        'collectionDate': dateVal,
        'collectionTime': timeVal,
        'recordedBy': 'Lerato Mokoena',
        'sampleRecordedBy': recordedByVal,
        'sampleNotes': notesVal,
      });
    } else {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final refNumber = 'LR-${widget.referral.folderNumber.replaceAll(RegExp(r'[^0-9]'), '')}';

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mint Info Card
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
              const SizedBox(height: 10),
              _buildMintRow('Patient ID', widget.referral.folderNumber),
              const SizedBox(height: 10),
              _buildMintRow('Requested test', widget.referral.testsRequested),
              const SizedBox(height: 10),
              _buildMintRow('Referral reference', refNumber),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Collection Date
        Text(
          'Collection date',
          style: AppTextStyles.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dateText.isNotEmpty ? _dateText : 'DD MMM YYYY',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      color: _dateText.isNotEmpty ? AppColors.textPrimary : AppColors.textDisabled,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Collection Time
        Text(
          'Collection time',
          style: AppTextStyles.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickTime,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _timeText.isNotEmpty ? _timeText : 'HH:MM',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      color: _timeText.isNotEmpty ? AppColors.textPrimary : AppColors.textDisabled,
                    ),
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Sample Notes (optional)
        Text(
          'Sample notes (optional)',
          style: AppTextStyles.label.copyWith(
            fontSize: 14,
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
            hintText: 'Add any collection notes',
            hintStyle: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textDisabled,
            ),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
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
        const SizedBox(height: 16),
      ],
    );

    if (widget.centerContent) {
      content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: content,
        ),
      );
    }

    return Column(
      children: [
        // 1. Scrollable Form Content
        Expanded(
          child: SingleChildScrollView(
            padding: widget.padding,
            child: content,
          ),
        ),

        // 2. Fixed Sticky Bottom Action Bar (at the very bottom!)
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
                        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
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
                    onPressed: _handleSave,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: AppColors.brandPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                      ),
                    ),
                    child: const Text(
                      'Save Sample',
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

  Widget _buildMintRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Boxed Back Button ────────────────────────────────────────────────────────
class _BoxedBackButton extends StatelessWidget {
  const _BoxedBackButton({required this.onTap, this.size = 40});

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

// ── Sample Recorded Success Popup (Dialog / Bottom Sheet) ────────────────────
/// Displays the "Sample Recorded" confirmation popup:
/// - Desktop & Tablet: Centered Modal Dialog with backdrop scrim.
/// - Mobile: Modal Bottom Sheet with drag handle pill and safe area.
void showSampleRecordedDialog(
  BuildContext context, {
  required LabReferralModel referral,
  required String collectedDateTime,
  String recordedBy = 'Lerato Mokoena',
  VoidCallback? onViewReferral,
  VoidCallback? onBackToLabReferral,
}) {
  final isMobile = ResponsiveHelper.isMobile(context);

  void handleViewReferral(BuildContext popupContext) {
    Navigator.of(popupContext).pop();
    if (onViewReferral != null) {
      onViewReferral();
      return;
    }
    final isAlreadyOnDetails =
        ModalRoute.of(context)?.settings.name == AppRoutes.labReferralDetails ||
        Get.currentRoute == AppRoutes.labReferralDetails;
    if (!isAlreadyOnDetails) {
      openLabReferralDetailsPage(context, referral: referral);
    }
  }

  void handleBackToLabReferral(BuildContext popupContext) {
    Navigator.of(popupContext).pop();
    if (onBackToLabReferral != null) {
      onBackToLabReferral();
      return;
    }
    final isDetails =
        ModalRoute.of(context)?.settings.name == AppRoutes.labReferralDetails ||
        Get.currentRoute == AppRoutes.labReferralDetails;
    if (isDetails && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  if (isMobile) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (ctx) => _SampleRecordedMobileSheet(
        referral: referral,
        collectedDateTime: collectedDateTime,
        recordedBy: recordedBy,
        onViewReferral: () => handleViewReferral(ctx),
        onBackToLabReferral: () => handleBackToLabReferral(ctx),
      ),
    );
    return;
  }

  // Desktop and Tablet: Centered Modal Dialog
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: _SampleRecordedDialogCard(
            referral: referral,
            collectedDateTime: collectedDateTime,
            recordedBy: recordedBy,
            onViewReferral: () => handleViewReferral(dialogContext),
            onBackToLabReferral: () => handleBackToLabReferral(dialogContext),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim, secAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ── Desktop & Tablet Centered Dialog Card ────────────────────────────────────
class _SampleRecordedDialogCard extends StatelessWidget {
  const _SampleRecordedDialogCard({
    required this.referral,
    required this.collectedDateTime,
    required this.recordedBy,
    required this.onViewReferral,
    required this.onBackToLabReferral,
  });

  final LabReferralModel referral;
  final String collectedDateTime;
  final String recordedBy;
  final VoidCallback onViewReferral;
  final VoidCallback onBackToLabReferral;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 520,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Green Success Checkmark Badge
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F6F3),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check_rounded,
                color: Color(0xFF0F766E),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Sample Recorded',
            textAlign: TextAlign.center,
            style: AppTextStyles.h2.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Sample information has been saved successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Mint Summary Card
          _SampleSummaryMintCard(
            referral: referral,
            collectedDateTime: collectedDateTime,
            recordedBy: recordedBy,
          ),
          const SizedBox(height: 24),

          // Action Buttons (Side by Side)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewReferral,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                    ),
                    side: const BorderSide(color: AppColors.borderDefault),
                    foregroundColor: AppColors.brandPrimary,
                  ),
                  child: const Text(
                    'View Referral',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onBackToLabReferral,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor: AppColors.brandPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                    ),
                  ),
                  child: const Text(
                    'Back to Lab Referral',
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
        ],
      ),
    );
  }
}

// ── Mobile Bottom Sheet View ────────────────────────────────────────────────
class _SampleRecordedMobileSheet extends StatelessWidget {
  const _SampleRecordedMobileSheet({
    required this.referral,
    required this.collectedDateTime,
    required this.recordedBy,
    required this.onViewReferral,
    required this.onBackToLabReferral,
  });

  final LabReferralModel referral;
  final String collectedDateTime;
  final String recordedBy;
  final VoidCallback onViewReferral;
  final VoidCallback onBackToLabReferral;

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Drag Handle Pill
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
              const SizedBox(height: 16),

              // Green Success Checkmark Badge
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F6F3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Color(0xFF0F766E),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Sample Recorded',
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              const Text(
                'Sample information has been saved successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Mint Summary Card
              _SampleSummaryMintCard(
                referral: referral,
                collectedDateTime: collectedDateTime,
                recordedBy: recordedBy,
              ),
              const SizedBox(height: 24),

              // Action Buttons (Side by Side)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onViewReferral,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                        ),
                        side: const BorderSide(color: AppColors.borderDefault),
                        foregroundColor: AppColors.brandPrimary,
                      ),
                      child: const Text(
                        'View Referral',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onBackToLabReferral,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: AppColors.brandPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      child: const Text(
                        'Back to Lab Referral',
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
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared Mint Information Summary Card ────────────────────────────────────
class _SampleSummaryMintCard extends StatelessWidget {
  const _SampleSummaryMintCard({
    required this.referral,
    required this.collectedDateTime,
    required this.recordedBy,
  });

  final LabReferralModel referral;
  final String collectedDateTime;
  final String recordedBy;

  @override
  Widget build(BuildContext context) {
    final digits = referral.folderNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final refNumber = 'LR-${digits.isNotEmpty ? digits : "0042"}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6F3),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      ),
      child: Column(
        children: [
          _buildRow('Patient', '${referral.patientName} · ${referral.folderNumber}'),
          const SizedBox(height: 10),
          _buildRow('Requested test', referral.testsRequested),
          const SizedBox(height: 10),
          _buildRow('Referral reference', refNumber),
          const SizedBox(height: 10),
          _buildRow('Collected', collectedDateTime),
          const SizedBox(height: 10),
          _buildRow('Recorded by', recordedBy),
          const SizedBox(height: 10),
          _buildRow('Referral status', 'Sample Taken', isStatus: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isStatus = false}) {
    return Row(
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              fontWeight: isStatus ? FontWeight.w600 : FontWeight.w600,
              color: isStatus ? const Color(0xFF0F766E) : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FUTURE USE REFERENCE CODE / COMMENTS:
// Sync Conflict Modal (Desktop & Tablet) and Bottom Sheet (Mobile).
// Uncomment this block when offline sample sync conflict detection is wired
// alongside [ConnectivityBanner] / [OfflineBanner].
// ============================================================================
/*
enum SyncConflictResolution { reviewLater, keepSyncedRecord }

/// Displays the responsive Sync Conflict modal/sheet when an offline sample
/// recording collides with an already-synced record from another device.
/// - Desktop & Tablet: Centered modal dialog with close 'X' button.
/// - Mobile: Root modal bottom sheet with drag handle & SafeArea actions.
///
/// Example trigger:
/// ```dart
/// await showSyncConflictDialog(
///   context,
///   referral: referral,
///   deviceRecordText: 'Sample recorded 10:15\nby Lerato Mokoena',
///   syncedRecordText: 'Sample recorded 10:12\nby Sister Naledi Naidoo',
///   onKeepSyncedRecord: () {
///     // Discard local device conflict and keep server-synced record.
///   },
///   onReviewLater: () {
///     // Defer resolution until staff reviews the referral manually.
///   },
/// );
/// ```
Future<SyncConflictResolution?> showSyncConflictDialog(
  BuildContext context, {
  required LabReferralModel referral,
  required String deviceRecordText,
  required String syncedRecordText,
  VoidCallback? onKeepSyncedRecord,
  VoidCallback? onReviewLater,
}) async {
  final isMobile = ResponsiveHelper.isMobile(context);

  void handleReviewLater(BuildContext overlayContext) {
    Navigator.of(overlayContext).pop(SyncConflictResolution.reviewLater);
    onReviewLater?.call();
  }

  void handleKeepSynced(BuildContext overlayContext) {
    Navigator.of(overlayContext).pop(SyncConflictResolution.keepSyncedRecord);
    onKeepSyncedRecord?.call();
  }

  if (isMobile) {
    return showModalBottomSheet<SyncConflictResolution>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.scrim,
      builder: (sheetContext) => _SyncConflictMobileSheet(
        referral: referral,
        deviceRecordText: deviceRecordText,
        syncedRecordText: syncedRecordText,
        onReviewLater: () => handleReviewLater(sheetContext),
        onKeepSyncedRecord: () => handleKeepSynced(sheetContext),
      ),
    );
  }

  return showGeneralDialog<SyncConflictResolution>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss sync conflict dialog',
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, _) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _SyncConflictDialogCard(
          referral: referral,
          deviceRecordText: deviceRecordText,
          syncedRecordText: syncedRecordText,
          onClose: () => Navigator.of(dialogContext).pop(),
          onReviewLater: () => handleReviewLater(dialogContext),
          onKeepSyncedRecord: () => handleKeepSynced(dialogContext),
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

class _SyncConflictDialogCard extends StatelessWidget {
  const _SyncConflictDialogCard({
    required this.referral,
    required this.deviceRecordText,
    required this.syncedRecordText,
    required this.onClose,
    required this.onReviewLater,
    required this.onKeepSyncedRecord,
  });

  final LabReferralModel referral;
  final String deviceRecordText;
  final String syncedRecordText;
  final VoidCallback onClose;
  final VoidCallback onReviewLater;
  final VoidCallback onKeepSyncedRecord;

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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sync conflict',
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This referral changed on another device while you were offline.',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Semantics(
                    button: true,
                    label: 'Close sync conflict dialog',
                    child: Tooltip(
                      message: 'Close',
                      child: Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                          side: const BorderSide(color: AppColors.borderDefault),
                        ),
                        child: InkWell(
                          onTap: onClose,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                          child: const SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SyncConflictBody(
                referral: referral,
                deviceRecordText: deviceRecordText,
                syncedRecordText: syncedRecordText,
                onReviewLater: onReviewLater,
                onKeepSyncedRecord: onKeepSyncedRecord,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncConflictMobileSheet extends StatelessWidget {
  const _SyncConflictMobileSheet({
    required this.referral,
    required this.deviceRecordText,
    required this.syncedRecordText,
    required this.onReviewLater,
    required this.onKeepSyncedRecord,
  });

  final LabReferralModel referral;
  final String deviceRecordText;
  final String syncedRecordText;
  final VoidCallback onReviewLater;
  final VoidCallback onKeepSyncedRecord;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DCE2),
                    borderRadius: BorderRadius.circular(Dimensions.radiusPill),
                  ),
                ),
              ),
              Text(
                'Sync conflict',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This referral changed on another device while you were offline.',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              _SyncConflictBody(
                referral: referral,
                deviceRecordText: deviceRecordText,
                syncedRecordText: syncedRecordText,
                onReviewLater: onReviewLater,
                onKeepSyncedRecord: onKeepSyncedRecord,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncConflictBody extends StatelessWidget {
  const _SyncConflictBody({
    required this.referral,
    required this.deviceRecordText,
    required this.syncedRecordText,
    required this.onReviewLater,
    required this.onKeepSyncedRecord,
  });

  final LabReferralModel referral;
  final String deviceRecordText;
  final String syncedRecordText;
  final VoidCallback onReviewLater;
  final VoidCallback onKeepSyncedRecord;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6F3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _buildRow(
                'Patient',
                '${referral.patientName} · ${referral.folderNumber}',
              ),
              const Divider(height: 18, color: Color(0x1A0F766E)),
              _buildRow(
                'Referral',
                '${referral.referenceNumber} · ${referral.testsRequested}',
              ),
              const Divider(height: 18, color: Color(0x1A0F766E)),
              _buildRow('Saved on this device', deviceRecordText),
              const Divider(height: 18, color: Color(0x1A0F766E)),
              _buildRow('Already synced', syncedRecordText),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Only one sample record is kept per referral. Keep the synced record, or review the referral before deciding.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12.5,
                    color: Color(0xFF1D4ED8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onReviewLater,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(Dimensions.buttonMinHeight),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.brandPrimary,
                  side: const BorderSide(color: AppColors.borderDefault),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusControl),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Review Later'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onKeepSyncedRecord,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(Dimensions.buttonMinHeight),
                  backgroundColor: AppColors.brandPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusControl),
                  ),
                ),
                child: const Text(
                  'Keep Synced Record',
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
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
*/
