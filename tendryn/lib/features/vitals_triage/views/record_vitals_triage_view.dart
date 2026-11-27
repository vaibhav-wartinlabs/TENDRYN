import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/vitals_triage/controllers/record_vitals_triage_controller.dart';

/// Full "Vitals & Triage" record observations screen matching Figma designs:
/// - Desktop: `media_1794409673687_1bb40c7c.jpg`
/// - Tablet: `media_1794409673563_0e3959c9.png`
/// - Mobile: `media_1794409673558_d71c85ec.png`
class RecordVitalsTriageView extends GetView<RecordVitalsTriageController> {
  const RecordVitalsTriageView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _MobileTabletVitalsTriage(isTablet: false),
      tablet: _MobileTabletVitalsTriage(isTablet: true),
      desktop: _DesktopVitalsTriage(),
    );
  }
}

// ----------------------------------------------------------- Mobile & Tablet View

class _MobileTabletVitalsTriage extends GetView<RecordVitalsTriageController> {
  const _MobileTabletVitalsTriage({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return Obx(() {
        if (controller.isReviewing.value) {
          return _TabletReviewTriageView(controller: controller);
        }
        return _buildForm(context);
      });
    }

    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final horizontalPadding =
        isTablet ? Dimensions.pageMarginTablet : Dimensions.pageMarginMobile;

    return Column(
      children: [
        _RecordVitalsTriageTopBar(
          onBack: controller.cancel,
          horizontalPadding: horizontalPadding,
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              16,
            ),
            children: [
              _PatientBannerCard(controller: controller, isDesktop: false),
              const SizedBox(height: 16),
              const _AllergyBanner(allergy: 'Penicillin'),
              const SizedBox(height: 16),
              _PresentingComplaintCard(controller: controller),
              const SizedBox(height: 16),
              _VitalSignsCard(
                controller: controller,
                columnCount: isTablet ? 2 : 1,
              ),
              const SizedBox(height: 16),
              _TriagePriorityCard(controller: controller),
              const SizedBox(height: 16),
              _TriageNotesCard(controller: controller),
              const SizedBox(height: 16),
              if (isTablet)
                _TabletActionBar(controller: controller)
              else
                _MobileActionBar(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- Desktop View

class _DesktopVitalsTriage extends GetView<RecordVitalsTriageController> {
  const _DesktopVitalsTriage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.pageMarginDesktop,
        24,
        Dimensions.pageMarginDesktop,
        24,
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _BackToProfileButton(onTap: controller.cancel),
        ),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: const Text(
            'Vitals & Triage',
            style: TextStyle(
              fontFamily: AppTextStyles.headingFamily,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1E),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Record patient observations and prepare the patient for clinical assessment.',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            color: Color(0xFF535F69),
          ),
        ),
        const SizedBox(height: 16),
        _PatientBannerCard(controller: controller, isDesktop: true),
        const SizedBox(height: 16),
        const _AllergyBanner(allergy: 'Penicillin'),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _PresentingComplaintCard(controller: controller)),
            const SizedBox(width: 16),
            Expanded(child: _TriagePriorityCard(controller: controller)),
          ],
        ),
        const SizedBox(height: 16),
        _VitalSignsCard(controller: controller, columnCount: 4),
        const SizedBox(height: 16),
        _TriageNotesCard(controller: controller),
        const SizedBox(height: 16),
        _DesktopActionBar(controller: controller),
      ],
    );
  }
}

// ------------------------------------------------------------- Fixed Top Bar

/// Consistent 64px top navigation bar across Mobile and Tablet with boxed back button.
class _RecordVitalsTriageTopBar extends StatelessWidget {
  const _RecordVitalsTriageTopBar({
    required this.onBack,
    required this.horizontalPadding,
  });

  final VoidCallback onBack;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        spacing: 12,
        children: [
          Semantics(
            button: true,
            label: 'Back',
            child: Tooltip(
              message: 'Back',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  hoverColor: AppColors.brandTint,
                  splashColor: Colors.transparent,
                  highlightColor: AppColors.brandTint,
                  overlayColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed) ||
                        states.contains(WidgetState.hovered)) {
                      return AppColors.brandTint;
                    }
                    return Colors.transparent;
                  }),
                  onTap: onBack,
                  child: SizedBox.square(
                    dimension: Dimensions.touchTarget,
                    child: Center(
                      child: Container(
                        width: Dimensions.touchTarget,
                        height: Dimensions.touchTarget,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSurface,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
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
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Vitals & Triage',
                  style: TextStyle(
                    fontFamily: AppTextStyles.headingFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1C1E),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  'Record patient observations and prepare the patient for clinical assessment.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    color: Color(0xFF535F69),
                    height: 1.2,
                  ),
                  maxLines: 1,
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

// ----------------------------------------------------------------- Back Button

class _BackToProfileButton extends StatelessWidget {
  const _BackToProfileButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE6F4F1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.chevron_left, size: 16, color: Color(0xFF00685F)),
              SizedBox(width: 4),
              Text(
                'Back to Patient profile',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00685F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- Patient Banner

class _PatientBannerCard extends StatelessWidget {
  const _PatientBannerCard({required this.controller, required this.isDesktop});

  final RecordVitalsTriageController controller;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: isDesktop
          ? Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 14),
                Expanded(child: _buildDetails(isDesktop: true)),
                _buildStatusAndPriority(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 14),
                    Expanded(child: _buildDetails(isDesktop: false)),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, thickness: 1, color: AppColors.borderDefault),
                const SizedBox(height: 12),
                _buildStatusAndPriority(),
              ],
            ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFE6F4F1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        controller.initials,
        style: const TextStyle(
          fontFamily: AppTextStyles.headingFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF00685F),
        ),
      ),
    );
  }

  Widget _buildDetails({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.patientName,
          style: const TextStyle(
            fontFamily: AppTextStyles.headingFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: 2),
        if (isDesktop)
          Text(
            '${controller.patientId} · Visit ${controller.queueNumber} · ${controller.visitDate} · ${controller.sex} · ${controller.age} yrs',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              color: Color(0xFF535F69),
            ),
          )
        else ...[
          Text(
            '${controller.patientId} · ${controller.sex} · ${controller.age} yrs',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              color: Color(0xFF535F69),
            ),
          ),
          Text(
            'Visit ${controller.queueNumber} · ${controller.visitDate}',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              color: Color(0xFF535F69),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusAndPriority() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Queue status',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'With Nurse',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Priority',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Obx(() {
              final priority = controller.selectedPriority.value;
              final (dotColor, label) = switch (priority) {
                QueuePriority.routine => (const Color(0xFF10B981), 'Routine'),
                QueuePriority.urgent => (const Color(0xFFF59E0B), 'Urgent'),
                QueuePriority.emergency => (const Color(0xFFEF4444), 'Emergency'),
              };
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1C1E),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- Allergy Banner

class _AllergyBanner extends StatelessWidget {
  const _AllergyBanner({required this.allergy});

  final String allergy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.alert, size: 18, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Text(
            'Allergy: $allergy',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------- A. Presenting Complaint

class _PresentingComplaintCard extends StatelessWidget {
  const _PresentingComplaintCard({required this.controller});

  final RecordVitalsTriageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A Presenting complaint',
            style: TextStyle(
              fontFamily: AppTextStyles.headingFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Reason for visit from reception: ${controller.presentingComplaintController.text}',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              color: Color(0xFF535F69),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Presenting complaint',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.presentingComplaintController,
            minLines: 3,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: Color(0xFF1A1C1E),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderDefault, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderDefault, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF00685F), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Required before completing triage',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------- C. Triage Priority

class _TriagePriorityCard extends StatelessWidget {
  const _TriagePriorityCard({required this.controller});

  final RecordVitalsTriageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'C Triage priority',
            style: TextStyle(
              fontFamily: AppTextStyles.headingFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Select manually after reviewing vital signs',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              color: Color(0xFF535F69),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children: [
                _PriorityRadioItem(
                  priority: QueuePriority.routine,
                  label: 'Routine',
                  dotColor: const Color(0xFF10B981),
                  description: 'Stable, can wait for the doctor',
                  isSelected: controller.selectedPriority.value == QueuePriority.routine,
                  onTap: () => controller.setPriority(QueuePriority.routine),
                ),
                const SizedBox(height: 10),
                _PriorityRadioItem(
                  priority: QueuePriority.urgent,
                  label: 'Urgent',
                  dotColor: const Color(0xFFF59E0B),
                  description: 'Needs to be seen soon',
                  isSelected: controller.selectedPriority.value == QueuePriority.urgent,
                  onTap: () => controller.setPriority(QueuePriority.urgent),
                ),
                const SizedBox(height: 10),
                _PriorityRadioItem(
                  priority: QueuePriority.emergency,
                  label: 'Emergency',
                  dotColor: const Color(0xFFEF4444),
                  description: 'Needs immediate attention',
                  isSelected: controller.selectedPriority.value == QueuePriority.emergency,
                  onTap: () => controller.setPriority(QueuePriority.emergency),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityRadioItem extends StatelessWidget {
  const _PriorityRadioItem({
    required this.priority,
    required this.label,
    required this.dotColor,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final QueuePriority priority;
  final String label;
  final Color dotColor;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? const Color(0xFF00685F) : AppColors.borderDefault;
    final bgColor = isSelected ? const Color(0xFFE6F4F1) : Colors.white;

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: isSelected ? 1.5 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Custom Radio Circle
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00685F) : const Color(0xFF94A3B8),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00685F),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Priority Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1C1E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Description
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    color: Color(0xFF535F69),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- B. Vital Signs

class _VitalSignsCard extends StatelessWidget {
  const _VitalSignsCard({required this.controller, required this.columnCount});

  final RecordVitalsTriageController controller;
  final int columnCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'B Vital signs',
            style: TextStyle(
              fontFamily: AppTextStyles.headingFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'All values are numeric. BMI is calculated automatically.',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              color: Color(0xFF535F69),
            ),
          ),
          const SizedBox(height: 16),
          _buildVitalInputs(),
        ],
      ),
    );
  }

  Widget _buildVitalInputs() {
    final bp = _VitalInputField(
      label: 'Blood pressure (mmHg)',
      controller: controller.bloodPressureController,
      suffix: 'mmHg',
      helper: 'Systolic/diastolic',
    );
    final pulse = _VitalInputField(
      label: 'Pulse (bpm)',
      controller: controller.pulseController,
      suffix: 'bpm',
      helper: 'Beats per minute',
    );
    final temp = _VitalInputField(
      label: 'Temperature (°C)',
      controller: controller.temperatureController,
      suffix: '°C',
      helper: 'Degrees Celsius',
    );
    final weight = _VitalInputField(
      label: 'Weight (kg)',
      controller: controller.weightController,
      suffix: 'kg',
      helper: 'Kilograms',
    );
    final height = _VitalInputField(
      label: 'Height (cm)',
      controller: controller.heightController,
      suffix: 'cm',
      helper: 'Centimetres',
    );
    final bmi = Obx(
      () => _VitalInputField(
        label: 'BMI (kg/m²)',
        readOnlyText: controller.bmiString.value,
        suffixIcon: Icons.lock_outline,
        helper: 'Calculated from weight and height',
      ),
    );
    final glucose = _VitalInputField(
      label: 'Blood glucose (mmol/L)',
      controller: controller.bloodGlucoseController,
      suffix: 'mmol/L',
      helper: 'Millimoles per litre',
    );
    final o2 = _VitalInputField(
      label: 'Oxygen saturation (%)',
      controller: controller.oxygenSaturationController,
      suffix: '%',
      helper: 'SpO₂',
    );

    if (columnCount == 4) {
      // Desktop 4 columns
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: bp),
              const SizedBox(width: 16),
              Expanded(child: pulse),
              const SizedBox(width: 16),
              Expanded(child: temp),
              const SizedBox(width: 16),
              Expanded(child: weight),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: height),
              const SizedBox(width: 16),
              Expanded(child: bmi),
              const SizedBox(width: 16),
              Expanded(child: glucose),
              const SizedBox(width: 16),
              Expanded(child: o2),
            ],
          ),
        ],
      );
    } else if (columnCount == 2) {
      // Tablet 2 columns matching Figma
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: bp),
              const SizedBox(width: 16),
              Expanded(child: pulse),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: temp),
              const SizedBox(width: 16),
              Expanded(child: weight),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: height),
              const SizedBox(width: 16),
              Expanded(child: bmi),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: glucose),
              const SizedBox(width: 16),
              Expanded(child: o2),
            ],
          ),
        ],
      );
    } else {
      // Mobile 1 column
      return Column(
        children: [
          bp,
          const SizedBox(height: 14),
          pulse,
          const SizedBox(height: 14),
          temp,
          const SizedBox(height: 14),
          weight,
          const SizedBox(height: 14),
          height,
          const SizedBox(height: 14),
          bmi,
          const SizedBox(height: 14),
          glucose,
          const SizedBox(height: 14),
          o2,
        ],
      );
    }
  }
}

class _VitalInputField extends StatelessWidget {
  const _VitalInputField({
    required this.label,
    this.controller,
    this.readOnlyText,
    this.suffix,
    this.suffixIcon,
    required this.helper,
  });

  final String label;
  final TextEditingController? controller;
  final String? readOnlyText;
  final String? suffix;
  final IconData? suffixIcon;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = readOnlyText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1E),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isReadOnly ? const Color(0xFFF8FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderDefault, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: isReadOnly
                    ? Text(
                        readOnlyText!,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1C1E),
                        ),
                      )
                    : TextField(
                        controller: controller,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1C1E),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          fillColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
              ),
              if (suffix != null)
                Text(
                  suffix!,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              if (suffixIcon != null)
                Icon(suffixIcon, size: 16, color: const Color(0xFF94A3B8)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helper,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ D. Triage Notes

class _TriageNotesCard extends StatelessWidget {
  const _TriageNotesCard({required this.controller});

  final RecordVitalsTriageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'D Triage notes',
            style: TextStyle(
              fontFamily: AppTextStyles.headingFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Optional observations for the doctor',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              color: Color(0xFF535F69),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Triage notes',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.triageNotesController,
            minLines: 3,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: Color(0xFF1A1C1E),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderDefault, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderDefault, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF00685F), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Visible to the assigned doctor',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- Action Bars

class _DesktopActionBar extends StatelessWidget {
  const _DesktopActionBar({required this.controller});

  final RecordVitalsTriageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Save to keep your progress. Complete triage to send the patient to the doctor.',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                color: Color(0xFF535F69),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _ActionButton(
            label: 'Cancel',
            isPrimary: false,
            onTap: controller.cancel,
          ),
          const SizedBox(width: 12),
          _ActionButton(
            label: 'Save triage',
            isPrimary: false,
            textColor: const Color(0xFF00685F),
            onTap: controller.saveTriage,
          ),
          const SizedBox(width: 12),
          _ActionButton(
            label: 'Review triage',
            isPrimary: true,
            onTap: () {
              if (controller.presentingComplaintController.text.trim().isEmpty) {
                AppNotice.info('Required field', 'Please provide a presenting complaint.');
                return;
              }
              _showDesktopReviewDrawer(context, controller);
            },
          ),
        ],
      ),
    );
  }
}

class _TabletActionBar extends StatelessWidget {
  const _TabletActionBar({required this.controller});

  final RecordVitalsTriageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Cancel',
              isPrimary: false,
              onTap: controller.cancel,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Save triage',
              isPrimary: false,
              textColor: const Color(0xFF00685F),
              onTap: controller.saveTriage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Review triage',
              isPrimary: true,
              onTap: controller.reviewTriage,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileActionBar extends StatelessWidget {
  const _MobileActionBar({required this.controller});

  final RecordVitalsTriageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Save to keep your progress. Complete triage to send the patient to the doctor.',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              color: Color(0xFF535F69),
            ),
          ),
          const SizedBox(height: 16),
          _ActionButton(
            label: 'Review triage',
            isPrimary: true,
            height: 48,
            onTap: () {
              if (controller.presentingComplaintController.text.trim().isEmpty) {
                AppNotice.info('Required field', 'Please provide a presenting complaint.');
                return;
              }
              _showMobileReviewSheet(context, controller);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Cancel',
                  isPrimary: false,
                  height: 48,
                  onTap: controller.cancel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Save triage',
                  isPrimary: false,
                  height: 48,
                  textColor: const Color(0xFF00685F),
                  onTap: controller.saveTriage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.isPrimary,
    this.textColor,
    this.height = 42,
    required this.onTap,
  });

  final String label;
  final bool isPrimary;
  final Color? textColor;
  final double height;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color effectiveText;
    final BorderSide borderSide;

    if (widget.isPrimary) {
      bgColor = _hovered ? AppColors.brandHover : const Color(0xFF00685F);
      effectiveText = Colors.white;
      borderSide = BorderSide.none;
    } else {
      bgColor = _hovered ? AppColors.brandTint : Colors.white;
      effectiveText = widget.textColor ?? const Color(0xFF535F69);
      borderSide = BorderSide(
        color: _hovered ? const Color(0xFF00685F) : AppColors.borderDefault,
        width: 1,
      );
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: borderSide,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: bgColor,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: widget.onTap,
          child: Container(
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: effectiveText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Review Triage Presentations (Mobile Sheet, Tablet View, Desktop Drawer)
// =============================================================================

Color _reviewPriorityColor(QueuePriority priority) {
  return switch (priority) {
    QueuePriority.emergency => const Color(0xFFDC2626),
    QueuePriority.urgent => const Color(0xFFEA580C),
    QueuePriority.routine => const Color(0xFF16A34A),
  };
}

void _showMobileReviewSheet(
  BuildContext context,
  RecordVitalsTriageController controller,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Review triage',
                          style: TextStyle(
                            fontFamily: AppTextStyles.headingFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${controller.patientName} · ${controller.patientId}',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  _ReviewTriageContent(controller: controller),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Back to edit',
                      isPrimary: false,
                      height: 48,
                      textColor: const Color(0xFF00685F),
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'Complete triage',
                      isPrimary: true,
                      height: 48,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        controller.completeTriage();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final targetCtx = Get.context ?? context;
                          _showTriageCompleted(targetCtx, controller, isMobile: true);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Dedicated Tablet Review Triage View with 48x48 boxed back button and full-width complete button.
class _TabletReviewTriageView extends StatelessWidget {
  const _TabletReviewTriageView({required this.controller});

  final RecordVitalsTriageController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.pageMarginTablet,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.borderDefault, width: 1),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => controller.isReviewing.value = false,
                    child: Tooltip(
                      message: 'Back',
                      child: Container(
                        width: Dimensions.touchTarget,
                        height: Dimensions.touchTarget,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSurface,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Review triage',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${controller.patientName} · ${controller.patientId}',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        color: Color(0xFF535F69),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.pageMarginTablet,
              20,
              Dimensions.pageMarginTablet,
              24,
            ),
            children: [
              _ReviewTriageContent(controller: controller),
              const SizedBox(height: 24),
              _ActionButton(
                label: 'Complete triage',
                isPrimary: true,
                height: 48,
                onTap: () {
                  controller.completeTriage();
                  _showTriageCompleted(context, controller, isMobile: false);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-height Slide-over Right Drawer for Desktop with global modal scrim.
void _showDesktopReviewDrawer(
  BuildContext context,
  RecordVitalsTriageController controller,
) {
  controller.isReviewing.value = true;
  showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'Close review triage',
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.white,
          elevation: 16,
          shadowColor: Colors.black54,
          child: SizedBox(
            width: 480,
            height: double.infinity,
            child: _DesktopReviewDrawer(
              controller: controller,
              onClose: () => Navigator.of(dialogContext).pop(),
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
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return SlideTransition(
        position: slideAnimation,
        child: child,
      );
    },
  ).then((_) {
    controller.isReviewing.value = false;
  });
}

/// Slide-over Right Drawer for Desktop with scrim backdrop and pinned bottom actions.
class _DesktopReviewDrawer extends StatelessWidget {
  const _DesktopReviewDrawer({
    required this.controller,
    this.onClose,
  });

  final RecordVitalsTriageController controller;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Review triage',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${controller.patientName} · ${controller.patientId}',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onClose ?? () => controller.isReviewing.value = false,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _ReviewTriageContent(controller: controller),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Back to edit',
                    isPrimary: false,
                    height: 44,
                    textColor: const Color(0xFF00685F),
                    onTap: onClose ?? () => controller.isReviewing.value = false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'Complete triage',
                    isPrimary: true,
                    height: 44,
                    onTap: () {
                      final navContext = Navigator.of(context).context;
                      if (onClose != null) {
                        onClose!();
                      }
                      controller.completeTriage();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final targetCtx = Get.context ?? navContext;
                        _showTriageCompleted(targetCtx, controller, isMobile: false);
                      });
                    },
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

/// Shared content: summary pills, vitals list, triage notes card, and next stage banner.
class _ReviewTriageContent extends StatelessWidget {
  const _ReviewTriageContent({required this.controller});

  final RecordVitalsTriageController controller;

  @override
  Widget build(BuildContext context) {
    final complaintText =
        controller.presentingComplaintController.text.trim().isEmpty
            ? 'Headache'
            : controller.presentingComplaintController.text.trim();

    final bpText =
        controller.bloodPressureController.text.trim().isEmpty
            ? '128/84'
            : controller.bloodPressureController.text.trim();
    final pulseText =
        controller.pulseController.text.trim().isEmpty
            ? '76'
            : controller.pulseController.text.trim();
    final tempText =
        controller.temperatureController.text.trim().isEmpty
            ? '36.8'
            : controller.temperatureController.text.trim();
    final weightText =
        controller.weightController.text.trim().isEmpty
            ? '78'
            : controller.weightController.text.trim();
    final heightText =
        controller.heightController.text.trim().isEmpty
            ? '176'
            : controller.heightController.text.trim();
    final bmiVal =
        controller.bmiString.value.trim().isEmpty || controller.bmiString.value == '—'
            ? '25.2 kg/m²'
            : controller.bmiString.value.trim();
    final glucoseText =
        controller.bloodGlucoseController.text.trim().isEmpty
            ? '5.4'
            : controller.bloodGlucoseController.text.trim();
    final o2Text =
        controller.oxygenSaturationController.text.trim().isEmpty
            ? '98'
            : controller.oxygenSaturationController.text.trim();

    final notesText =
        controller.triageNotesController.text.trim().isEmpty
            ? 'Patient alert and orientated. Penicillin allergy confirmed with patient.'
            : controller.triageNotesController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Presenting complaint & priority pill row
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Presenting complaint',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF005149),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        complaintText,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _reviewPriorityColor(controller.selectedPriority.value),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.selectedPriority.value.label,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Vital signs
        const Text(
          'Vital signs',
          style: TextStyle(
            fontFamily: AppTextStyles.headingFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        _ReviewVitalRow(label: 'Blood pressure', value: '$bpText mmHg'),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        _ReviewVitalRow(label: 'Pulse', value: '$pulseText bpm'),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        _ReviewVitalRow(label: 'Temperature', value: '$tempText °C'),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        _ReviewVitalRow(label: 'Weight', value: '$weightText kg'),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        _ReviewVitalRow(label: 'Height', value: '$heightText cm'),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        _ReviewVitalRow(label: 'BMI', value: bmiVal),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        _ReviewVitalRow(label: 'Blood glucose', value: '$glucoseText mmol/L'),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
        _ReviewVitalRow(label: 'Oxygen saturation', value: '$o2Text %'),
        const SizedBox(height: 20),

        // 3. Triage notes
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Triage notes',
                style: TextStyle(
                  fontFamily: AppTextStyles.headingFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notesText,
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Next stage banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Next stage',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Completing triage sets the queue status to Waiting for Doctor.',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        color: Color(0xFF1E40AF),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewVitalRow extends StatelessWidget {
  const _ReviewVitalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
// ------------------------------------------------------------- Triage Completed

void _showTriageCompleted(
  BuildContext context,
  RecordVitalsTriageController controller, {
  required bool isMobile,
}) {
  if (isMobile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _TriageCompletedContent(
                controller: controller,
                onViewPatient: () {
                  Navigator.of(sheetCtx).pop();
                  controller.viewPatient();
                },
                onReturnToQueue: () {
                  Navigator.of(sheetCtx).pop();
                  controller.cancel();
                },
              ),
            ],
          ),
        );
      },
    );
  } else {
    showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: 'Close triage completed',
      barrierColor: AppColors.scrim,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogCtx, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.white,
            elevation: 20,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(32),
              child: _TriageCompletedContent(
                controller: controller,
                onViewPatient: () {
                  Navigator.of(dialogCtx).pop();
                  controller.viewPatient();
                },
                onReturnToQueue: () {
                  Navigator.of(dialogCtx).pop();
                  controller.cancel();
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _TriageCompletedContent extends StatelessWidget {
  const _TriageCompletedContent({
    required this.controller,
    required this.onViewPatient,
    required this.onReturnToQueue,
  });

  final RecordVitalsTriageController controller;
  final VoidCallback onViewPatient;
  final VoidCallback onReturnToQueue;

  @override
  Widget build(BuildContext context) {
    final priority = controller.selectedPriority.value;
    final priorityLabel = switch (priority) {
      QueuePriority.emergency => 'Emergency',
      QueuePriority.urgent => 'Urgent',
      QueuePriority.routine => 'Routine',
    };
    final priorityColor = switch (priority) {
      QueuePriority.emergency => AppColors.triageRed,
      QueuePriority.urgent => AppColors.triageOrange,
      QueuePriority.routine => AppColors.triageGreen,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFE6F5F3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 26,
            color: Color(0xFF00685F),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Triage completed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTextStyles.headingFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Patient observations have been saved and the patient is ready for the next stage.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            color: Color(0xFF535F69),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
          ),
          child: Column(
            children: [
              _TriageDetailRow(
                label: 'Patient',
                valueWidget: Text(
                  '${controller.patientName} · ${controller.patientId}',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _TriageDetailRow(
                label: 'Triage priority',
                valueWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        priorityLabel,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _TriageDetailRow(
                label: 'Queue status',
                valueWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F5F3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Waiting for Doctor',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00685F),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _TriageDetailRow(
                label: 'Assigned practitioner',
                valueWidget: const Text(
                  'Dr Thandi Nkosi',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'View patient',
                isPrimary: false,
                height: 44,
                textColor: const Color(0xFF00685F),
                onTap: onViewPatient,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: 'Return to Queue',
                isPrimary: true,
                height: 44,
                onTap: onReturnToQueue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TriageDetailRow extends StatelessWidget {
  const _TriageDetailRow({
    required this.label,
    required this.valueWidget,
  });

  final String label;
  final Widget valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13,
              color: Color(0xFF535F69),
            ),
          ),
          valueWidget,
        ],
      ),
    );
  }
}
