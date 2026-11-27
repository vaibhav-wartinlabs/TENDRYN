import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/features/appointments/controllers/appointment_conflicts_controller.dart';
import 'package:tendryn/features/appointments/models/appointment_conflict_model.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/desktop/desktop_scaffold.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

class AppointmentConflictsView extends GetView<AppointmentConflictsController> {
  const AppointmentConflictsView({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (ResponsiveHelper.screenType(context)) {
      LayoutType.desktop => _buildDesktop(context),
      LayoutType.tablet => _buildTablet(context),
      LayoutType.mobile => _buildMobile(context),
    };
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('appointment_conflicts_back_button'),
        onTap: controller.onBack,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        child: SizedBox.square(
          dimension: Dimensions.touchTarget,
          child: Center(
            child: Container(
              width: Dimensions.touchTarget,
              height: Dimensions.touchTarget,
              alignment: Alignment.center,
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

  // ---------------------------------------------------------------------------
  // Desktop Layout
  // ---------------------------------------------------------------------------
  Widget _buildDesktop(BuildContext context) {
    return DesktopScaffold(
      route: AppRoutes.dashboard,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back to Dashboard link
              InkWell(
                onTap: controller.onBack,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(AppIcons.arrowLeft, size: Dimensions.iconSize, color: AppColors.brandPrimary),
                      SizedBox(width: 8),
                      Text(
                        'Back to Dashboard',
                        style: TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title, Subtitle, and Count Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Appointment Conflicts',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Review scheduling conflicts that need front desk attention.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    final count = controller.conflicts.length;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.feedbackWarningTint,
                        borderRadius: BorderRadius.circular(Dimensions.radius),
                      ),
                      child: Text(
                        '$count conflict${count == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.feedbackWarning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Conflict Cards List
              Obx(() {
                if (controller.conflicts.isEmpty) {
                  return _buildEmptyState();
                }
                return Column(
                  children: [
                    for (final conflict in controller.conflicts)
                      _DesktopConflictCard(
                        conflict: conflict,
                        onResolve: () => controller.onResolve(conflict, context),
                        onViewAppointments: () => controller.onViewAppointments(conflict),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile Layout
  // ---------------------------------------------------------------------------
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundSurface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    _buildBackButton(),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Appointment Conflicts',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      'Review scheduling conflicts that need front desk attention.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Badge
                    Obx(() {
                      final count = controller.conflicts.length;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.feedbackWarningTint,
                          borderRadius: BorderRadius.circular(Dimensions.radius),
                        ),
                        child: Text(
                          '$count conflict${count == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: AppColors.feedbackWarning,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Cards
                    Obx(() {
                      if (controller.conflicts.isEmpty) {
                        return _buildEmptyState();
                      }
                      return Column(
                        children: [
                          for (final conflict in controller.conflicts)
                            _MobileConflictCard(
                              conflict: conflict,
                              onResolve: () => controller.onResolve(conflict, context),
                              onViewAppointments: () => controller.onViewAppointments(conflict),
                            ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tablet Layout
  // ---------------------------------------------------------------------------
  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TabletHeader(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.backgroundSurface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: Row(
                children: [
                  _buildBackButton(),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Appointment Conflicts',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Review scheduling conflicts that need front desk attention.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      final count = controller.conflicts.length;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.feedbackWarningTint,
                          borderRadius: BorderRadius.circular(Dimensions.radius),
                        ),
                        child: Text(
                          '$count conflict${count == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: AppColors.feedbackWarning,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Obx(() {
                      if (controller.conflicts.isEmpty) {
                        return _buildEmptyState();
                      }
                      return Column(
                        children: [
                          for (final conflict in controller.conflicts)
                            _DesktopConflictCard(
                              conflict: conflict,
                              onResolve: () => controller.onResolve(conflict, context),
                              onViewAppointments: () => controller.onViewAppointments(conflict),
                            ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.feedbackSuccessTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.checkCheck,
              size: 28,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'All Conflicts Resolved',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No scheduling conflicts currently need attention.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: Dimensions.pageSectionGap),
          ElevatedButton(
            onPressed: controller.onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, Dimensions.buttonMinHeight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusControl)),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: Dimensions.controlY),
            ),
            child: const Text('Return to Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Desktop Conflict Card
// -----------------------------------------------------------------------------
class _DesktopConflictCard extends StatelessWidget {
  const _DesktopConflictCard({
    required this.conflict,
    required this.onResolve,
    required this.onViewAppointments,
  });

  final AppointmentConflictItem conflict;
  final VoidCallback onResolve;
  final VoidCallback onViewAppointments;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F1F1D),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Time · Doctor on left, Double booking badge on right
          Row(
            children: [
              Expanded(
                child: Text(
                  '${conflict.time} · ${conflict.practitioner}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.safetyCriticalBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.safetyCriticalBackground),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.safetyCriticalText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      conflict.badgeText,
                      style: const TextStyle(
                        color: AppColors.safetyCriticalText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Date line
          Text(
            conflict.date,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Dimensions.sectionContentGap),

          // Patients Row: side-by-side
          Row(
            children: [
              Expanded(
                child: _PatientBox(
                  name: conflict.patient1Name,
                  type: conflict.patient1Type,
                ),
              ),
              const SizedBox(width: Dimensions.spaceMd),
              Expanded(
                child: _PatientBox(
                  name: conflict.patient2Name,
                  type: conflict.patient2Type,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.sectionContentGap),

          // Action Buttons: Right-aligned
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: onViewAppointments,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                child: Container(
                  height: Dimensions.buttonMinHeight,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: const Text(
                    'View Appointments',
                    style: TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onResolve,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                child: Container(
                  height: Dimensions.buttonMinHeight,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  ),
                  child: const Text(
                    'Resolve',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

// -----------------------------------------------------------------------------
// Mobile Conflict Card
// -----------------------------------------------------------------------------
class _MobileConflictCard extends StatelessWidget {
  const _MobileConflictCard({
    required this.conflict,
    required this.onResolve,
    required this.onViewAppointments,
  });

  final AppointmentConflictItem conflict;
  final VoidCallback onResolve;
  final VoidCallback onViewAppointments;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F1F1D),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge at top
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.safetyCriticalBackground,
              borderRadius: BorderRadius.circular(Dimensions.radius),
            ),
            child: Text(
              conflict.badgeText,
              style: const TextStyle(
                color: AppColors.safetyCriticalText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Time · Doctor
          Text(
            '${conflict.time} · ${conflict.practitioner}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Date
          Text(
            conflict.date,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: Dimensions.sectionContentGap),

          // Stacked Patient Boxes
          _PatientBox(
            name: conflict.patient1Name,
            type: conflict.patient1Type,
          ),
          const SizedBox(height: 8),
          _PatientBox(
            name: conflict.patient2Name,
            type: conflict.patient2Type,
          ),
          const SizedBox(height: 16),

          // Stacked Action Buttons
          InkWell(
            onTap: onResolve,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            child: Container(
              width: double.infinity,
              height: Dimensions.buttonMinHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              ),
              child: const Text(
                'Resolve',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onViewAppointments,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            child: Container(
              width: double.infinity,
              height: Dimensions.buttonMinHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: const Text(
                'View Appointments',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Patient Box Widget
// -----------------------------------------------------------------------------
class _PatientBox extends StatelessWidget {
  const _PatientBox({required this.name, required this.type});

  final String name;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundApp,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.patients,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
