import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/consultation/controllers/consultation_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

/// Clinical consultation examination, diagnosis, and treatment form.
class ClinicalConsultationView extends StatefulWidget {
  const ClinicalConsultationView({
    super.key,
    this.onBack,
    this.backLabel = 'Back to consultations',
    this.patient,
    this.statusLabel,
  });

  final VoidCallback? onBack;
  final String backLabel;
  final PatientRecord? patient;
  final String? statusLabel;

  @override
  State<ClinicalConsultationView> createState() =>
      _ClinicalConsultationViewState();
}

class _ClinicalConsultationViewState extends State<ClinicalConsultationView> {
  bool _isReviewing = false;

  String get _resolvedStatus {
    if (widget.statusLabel != null && widget.statusLabel!.trim().isNotEmpty) {
      return widget.statusLabel!.trim();
    }
    final patientName = widget.patient?.name.trim().toLowerCase();
    if (patientName != null && Get.isRegistered<ConsultationController>()) {
      final match = Get.find<ConsultationController>()
          .allRecords
          .firstWhereOrNull(
            (r) => r.patientName.trim().toLowerCase() == patientName,
          );
      if (match != null) return match.status.label;
    }
    return 'In progress';
  }

  Widget _buildStatusBadge(String status) {
    final Color bgColor;
    final Color textColor;

    switch (status.toLowerCase()) {
      case 'draft':
        bgColor = AppColors.feedbackWarningTint;
        textColor = AppColors.feedbackWarning;
        break;
      case 'signed':
        bgColor = AppColors.feedbackInfoTint;
        textColor = AppColors.feedbackInfo;
        break;
      case 'in progress':
      default:
        bgColor = AppColors.feedbackSuccessTint;
        textColor = AppColors.brandPrimary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusPill),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // Presenting complaint
  final _chiefComplaintController = TextEditingController(
    text: 'Recurring headaches',
  );
  final _onsetDurationController = TextEditingController(
    text: 'Gradual - about 3 weeks',
  );
  final _symptomDescController = TextEditingController(
    text: 'Recurring headaches, usually in the afternoon. Illustrative note only. No chest pain.',
  );
  final _complaintNotesController = TextEditingController();
  String? _prescribedMedicine;

  // Vitals
  final _bpController = TextEditingController(text: '142/90');
  final _pulseController = TextEditingController(text: '78');
  final _tempController = TextEditingController(text: '36.7');
  final _spo2Controller = TextEditingController(text: '98');
  final _weightController = TextEditingController(text: '91.2');
  final _heightController = TextEditingController(text: '178');
  final _bmiController = TextEditingController(text: '28.8 kg/m²');
  final _painScoreController = TextEditingController(text: '0..4');

  // Medical history
  final _conditionsController = TextEditingController(
    text: 'No chronic conditions recorded (illustrative)',
  );
  final _allergiesController = TextEditingController(
    text: 'Penicillin — anaphylaxis',
  );
  final _medicationHistoryController = TextEditingController(
    text: 'No regular medication recorded',
  );
  final _historyNotesController = TextEditingController();

  // Examination
  final _findingsController = TextEditingController(
    text: 'Alert, well hydrated. Chest clear. Heart sounds normal. No pedal oedema.',
  );
  final _observationsController = TextEditingController(
    text: 'Mild acanthosis nigricans, neck',
  );
  final _examNotesController = TextEditingController();

  // Diagnosis
  final _searchIcdController = TextEditingController(text: 'R51');
  final _diagnosisSummaryController = TextEditingController(
    text: 'Illustrative assessment only: recurring headaches, no validated diagnosis.',
  );
  bool _showExampleCodeTag = true;

  // Treatment plan
  final _instructionsController = TextEditingController(
    text: 'Illustrative plan: Paracetamol as needed, keep a headache diary, review if symptoms change.',
  );
  final _followUpController = TextEditingController(
    text: 'In 4 weeks - 12 Nov 2026',
  );
  final _treatmentNotesController = TextEditingController();

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _onsetDurationController.dispose();
    _symptomDescController.dispose();
    _complaintNotesController.dispose();
    _bpController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _spo2Controller.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bmiController.dispose();
    _painScoreController.dispose();
    _conditionsController.dispose();
    _allergiesController.dispose();
    _medicationHistoryController.dispose();
    _historyNotesController.dispose();
    _findingsController.dispose();
    _observationsController.dispose();
    _examNotesController.dispose();
    _searchIcdController.dispose();
    _diagnosisSummaryController.dispose();
    _instructionsController.dispose();
    _followUpController.dispose();
    _treatmentNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final horizontalPadding = switch (ResponsiveHelper.screenType(context)) {
      LayoutType.mobile => Dimensions.pageMarginMobile,
      LayoutType.tablet => Dimensions.pageMarginTablet,
      LayoutType.desktop => Dimensions.pageMarginDesktop,
    };

    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobileOrTablet = isMobile || isTablet;

    if (_isReviewing) {
      if (!isMobileOrTablet) {
        return _buildDesktopReviewConsultationView(context);
      }
      return _buildReviewConsultationView(
        context: context,
        horizontalPadding: horizontalPadding,
        isMobileOrTablet: isMobileOrTablet,
      );
    }

    final stickyHeader = isMobileOrTablet
        ? Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.borderDefault),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.onBack != null) ...[
                  InkWell(
                    onTap: widget.onBack,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusControl,
                    ),
                    child: Container(
                      width: Dimensions.touchTarget,
                      height: Dimensions.touchTarget,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: const Center(
                        child: Icon(
                          AppIcons.chevronLeft,
                          size: Dimensions.iconSize,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.spaceMd),
                ],
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Consultation',
                          style: (isMobile
                                  ? AppTextStyles.h1Mobile
                                  : AppTextStyles.h1)
                              .copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildStatusBadge(_resolvedStatus),
                    ],
                  ),
                ),
              ],
            ),
          )
        : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?stickyHeader,
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isMobileOrTablet
                    ? Dimensions.spaceMd
                    : horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobileOrTablet) ...[
                    if (widget.onBack != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: scheme.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusControl),
                            onTap: widget.onBack,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.controlX,
                                vertical: 14,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: Dimensions.spaceSm,
                                children: [
                                  Icon(
                                    AppIcons.arrowLeft,
                                    size: Dimensions.iconSize,
                                    color: scheme.primary,
                                  ),
                                  Text(
                                    widget.backLabel,
                                    style: AppTextStyles.label.copyWith(
                                      color: scheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.pageSectionGap),
                    ],
                    // Page Heading & Badge
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Text(
                          'Consultation',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _buildStatusBadge(_resolvedStatus),
                      ],
                    ),
                  ],
            const SizedBox(height: 4),
            Text(
              'Record the assessment, diagnosis and treatment plan for this visit.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: Dimensions.spaceLg),

            // Patient Card
            _buildPatientHeaderCard(),
            const SizedBox(height: Dimensions.spaceMd),

            // Critical Alert Banner
            _buildCriticalAlertBanner(),
            const SizedBox(height: Dimensions.spaceMd),

            // Section A: Presenting complaint
            _ConsultationCard(
              letter: 'A',
              title: 'Presenting complaint',
              subtitle: "Reason for visit in the patient's words",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _responsiveFields([
                    _ConsultationField(
                      label: 'Chief complaint',
                      controller: _chiefComplaintController,
                    ),
                    _ConsultationField(
                      label: 'Onset & duration',
                      controller: _onsetDurationController,
                    ),
                  ], columns: 2),
                  const SizedBox(height: 16),
                  _ConsultationField(
                    label: 'Symptom description',
                    controller: _symptomDescController,
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _ConsultationField(
                    label: 'Notes',
                    hint: 'Add notes',
                    controller: _complaintNotesController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.spaceMd),

            // Section B: Vitals
            _ConsultationCard(
              letter: 'B',
              title: 'Vitals',
              subtitle:
                  'Recorded today 09:10 by Nurse Khanyile • edit to update',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _responsiveFields([
                    _ConsultationField(
                      label: 'BP (mmHg)',
                      controller: _bpController,
                    ),
                    _ConsultationField(
                      label: 'Pulse (bpm)',
                      controller: _pulseController,
                    ),
                    _ConsultationField(
                      label: 'Temperature (°C)',
                      controller: _tempController,
                    ),
                    _ConsultationField(
                      label: 'SpO₂ (%)',
                      controller: _spo2Controller,
                    ),
                  ], columns: 4),
                  const SizedBox(height: 16),
                  _responsiveFields([
                    _ConsultationField(
                      label: 'Weight (kg)',
                      controller: _weightController,
                    ),
                    _ConsultationField(
                      label: 'Height (cm)',
                      controller: _heightController,
                    ),
                    _ConsultationField(
                      label: 'BMI (calculated)',
                      controller: _bmiController,
                      readOnly: true,
                      filled: true,
                    ),
                    _ConsultationField(
                      label: 'Pain score (0-10)',
                      controller: _painScoreController,
                    ),
                  ], columns: 4),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.spaceMd),

            // Section C: Medical history
            _ConsultationCard(
              letter: 'C',
              title: 'Medical history',
              subtitle: 'Pre-filled from the patient record',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _responsiveFields([
                    _ConsultationField(
                      label: 'Conditions',
                      controller: _conditionsController,
                    ),
                    _ConsultationField(
                      label: 'Allergies',
                      controller: _allergiesController,
                    ),
                  ], columns: 2),
                  const SizedBox(height: 16),
                  _ConsultationField(
                    label: 'Medication history',
                    controller: _medicationHistoryController,
                  ),
                  const SizedBox(height: 16),
                  _ConsultationField(
                    label: 'Notes',
                    hint: 'Add notes',
                    controller: _historyNotesController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.spaceMd),

            // Section D: Examination
            _ConsultationCard(
              letter: 'D',
              title: 'Examination',
              subtitle: 'Physical and systemic exam',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ConsultationField(
                    label: 'Findings',
                    controller: _findingsController,
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _responsiveFields([
                    _ConsultationField(
                      label: 'Observations',
                      controller: _observationsController,
                    ),
                    _ConsultationField(
                      label: 'Notes',
                      hint: 'Add notes',
                      controller: _examNotesController,
                    ),
                  ], columns: 2),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.spaceMd),

            // Section E: Diagnosis (ICD-10)
            _ConsultationCard(
              letter: 'E',
              title: 'Diagnosis (ICD-10)',
              subtitle: 'Search and select codes — no automatic suggestions',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ConsultationField(
                    label: 'Search ICD-10',
                    controller: _searchIcdController,
                  ),
                  if (_showExampleCodeTag) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandTint,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusPill,
                        ),
                        border: Border.all(color: AppColors.brandTint),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(
                            child: Text(
                              'R51 - Headache (example code)',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () =>
                                setState(() => _showExampleCodeTag = false),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusPill,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(
                                AppIcons.close,
                                size: 14,
                                color: AppColors.brandPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _ConsultationField(
                    label: 'Diagnosis summary',
                    controller: _diagnosisSummaryController,
                    minLines: 1,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.spaceMd),

            // Section F: Treatment plan
            _ConsultationCard(
              letter: 'F',
              title: 'Treatment plan',
              subtitle: 'Instructions and follow-up',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ConsultationField(
                    label: 'Instructions',
                    controller: _instructionsController,
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _responsiveFields([
                    _ConsultationField(
                      label: 'Follow-up',
                      controller: _followUpController,
                    ),
                    _ConsultationField(
                      label: 'Notes',
                      hint: 'Add notes',
                      controller: _treatmentNotesController,
                    ),
                  ], columns: 2),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.spaceMd),

            // Clinicals Actions
            _buildClinicalsActionsCard(context),
            const SizedBox(height: Dimensions.spaceMd),

            // Bottom action bar
            _buildBottomActionBar(),
            const SizedBox(height: Dimensions.spaceLg),
          ],
        ),
      ),
    ),
  ],
),
);
  }

  Widget _responsiveFields(List<Widget> fields, {required int columns}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final columnCount = isNarrow ? (columns == 4 ? 2 : 1) : columns;
        final gap = isNarrow ? 12.0 : 16.0;
        final fieldWidth =
            (constraints.maxWidth - gap * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: [
            for (final field in fields)
              SizedBox(width: fieldWidth, child: field),
          ],
        );
      },
    );
  }

  Widget _buildPatientHeaderCard() {
    final name = widget.patient?.name ?? 'John Smith';
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    final avatar = Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.brandTint,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? 'PT' : initials,
        style: const TextStyle(
          fontFamily: AppTextStyles.headingFamily,
          color: AppColors.brandPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );

    final queue = widget.patient?.queueNumber;
    final folder = widget.patient?.fileNumber ?? 'SWC-10427';
    final dob = widget.patient?.dateOfBirth ?? '12 Mar 1974';
    final mobile = widget.patient?.mobile ?? '+27 82 555 0143';

    final badges = [
      if (queue != null && queue.isNotEmpty)
        _patientBadge(
          queue.startsWith('Q') ? queue : 'Q$queue',
          AppColors.feedbackInfoTint,
          AppColors.feedbackInfo,
        )
      else if (widget.patient == null)
        _patientBadge(
          'Q015',
          AppColors.feedbackInfoTint,
          AppColors.feedbackInfo,
        ),
      if (widget.patient?.careFlags != null &&
          widget.patient!.careFlags!.isNotEmpty)
        _patientBadge(
          widget.patient!.careFlags!,
          AppColors.feedbackWarningTint,
          AppColors.feedbackWarning,
        )
      else
        _patientBadge(
          'Urgent',
          AppColors.feedbackWarningTint,
          AppColors.feedbackWarning,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final horizontalCardPadding = isNarrow ? 14.0 : 20.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalCardPadding,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(
              color: AppColors.borderDefault,
              width: Dimensions.strokeDivider,
            ),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        avatar,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.headingFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '52 / Male • DOB: $dob',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                              Text(
                                'ID: 740312 5021 087',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: badges,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Folder: #$folder • $mobile',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Started 11:32 • Consultation Room 2',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    avatar,
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.headingFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              ...badges,
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '52 / Male • DOB: $dob\nStarted 11:32 • Consultation Room 2\nID: 740312 5021 087 • Folder: #$folder • $mobile',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              height: 1.4,
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

  Widget _patientBadge(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Dimensions.radiusPill),
        border: Border.all(color: background),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }

  Widget _buildCriticalAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.safetyCriticalBackground,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(
          color: AppColors.safetyCriticalBackground,
          width: Dimensions.strokeDivider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.safetyCriticalText,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              '!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'CRITICAL ALERT • ',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.safetyCriticalText,
                        ),
                      ),
                      TextSpan(
                        text: widget.patient?.careFlags != null &&
                                widget.patient!.careFlags!.isNotEmpty
                            ? widget.patient!.careFlags!
                            : 'Allergy: Penicillin (anaphylaxis)',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.safetyCriticalText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Chronic: none recorded (illustrative)',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalsActionsCard(BuildContext context) {
    final actionTiles = [
      _ActionTile(
        label: 'Add prescription',
        trailing: null,
        onTap: () => showAddPrescriptionView(
          context,
          patient: widget.patient,
          previousMedicine: _prescribedMedicine,
          onMedicineSelected: (medicine) {
            setState(() {
              _prescribedMedicine = medicine;
            });
          },
        ),
      ),
      _ActionTile(
        label: 'Lab referral',
        onTap: () => showLabReferralView(
          context,
          patient: widget.patient,
        ),
      ),
      _ActionTile(
        label: 'Sick note / Letter',
        onTap: () => showSickNoteView(
          context,
          patient: widget.patient,
        ),
      ),
      _ActionTile(
        label: 'Attachments',
        onTap: () => showAttachmentsView(
          context,
          patient: widget.patient,
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(
          color: AppColors.borderDefault,
          width: Dimensions.strokeDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinicals Actions',
            style: TextStyle(
              fontFamily: AppTextStyles.headingFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _responsiveActionTiles(context, actionTiles),
          const SizedBox(height: Dimensions.sectionContentGap),
          const Text(
            'Optional — use only when needed',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    final saveDraftButton = OutlinedButton(
      onPressed: () {
        AppNotice.info('Draft Saved', 'Consultation draft saved successfully.');
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: AppColors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
      ),
      child: const Text(
        'Save draft',
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.brandPrimary,
        ),
      ),
    );
    final reviewButton = FilledButton(
      onPressed: () {
        setState(() => _isReviewing = true);
      },
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
      ),
      child: const Text(
        'Review consultation',
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
    const status = Text(
      'Draft autosaved 11:48 · Complete required sections to review',
      style: TextStyle(
        fontFamily: AppTextStyles.bodyFamily,
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = ResponsiveHelper.screenType(context);
        final isMobile = screenType == LayoutType.mobile;
        final isTablet = screenType == LayoutType.tablet;

        Widget content;
        if (isMobile) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              status,
              const SizedBox(height: 12),
              saveDraftButton,
              const SizedBox(height: 8),
              reviewButton,
            ],
          );
        } else if (isTablet) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              status,
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: saveDraftButton),
                  const SizedBox(width: 12),
                  Expanded(child: reviewButton),
                ],
              ),
            ],
          );
        } else {
          content = Row(
            children: [
              Expanded(child: status),
              const SizedBox(width: 16),
              saveDraftButton,
              const SizedBox(width: 12),
              reviewButton,
            ],
          );
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(
              color: AppColors.borderDefault,
              width: Dimensions.strokeDivider,
            ),
          ),
          child: content,
        );
      },
    );
  }

  Widget _responsiveActionTiles(BuildContext context, List<Widget> tiles) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final columns = isNarrow ? 1 : 2;
        final gap = isNarrow ? 8.0 : 16.0;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 12,
          children: [
            for (final tile in tiles) SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }

  Widget _buildDesktopReviewConsultationView(BuildContext context) {
    final patientName = widget.patient?.name ?? 'John Smith';
    final folderNumber = widget.patient?.fileNumber ?? 'SWC-10427';
    final dob = widget.patient?.dateOfBirth ?? '12 Mar 1974';
    final phone = widget.patient?.mobile ?? '+27 82 555 0143';
    final initials = patientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Review consultation',
                  style: TextStyle(
                    fontFamily: AppTextStyles.headingFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F5F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Ready for sign-off',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Check each section before signing off. Signed records cannot be edited.',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),

            // Patient Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F5F3),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials.isEmpty ? 'JS' : initials,
                      style: const TextStyle(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              patientName,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.headingFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Q015',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, size: 6, color: Color(0xFFEA580C)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Urgent',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFEA580C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '52 / Male  ·  DOB $dob  ·  ID: 740312 5021 087  ·  Folder: #$folderNumber  ·  $phone',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Started 11:32 · Consultation Room 2',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section Cards
            _buildDesktopSectionCard(
              title: 'A Presenting complaint',
              onEdit: () => setState(() => _isReviewing = false),
              rows: const [
                MapEntry('Chief complaint', 'Recurring headaches'),
                MapEntry('Symptoms', 'Recurring headaches, usually in the afternoon. Illustrative note only.'),
                MapEntry('Onset & duration', 'Gradual · about 3 weeks'),
              ],
            ),
            const SizedBox(height: 14),

            _buildDesktopSectionCard(
              title: 'B Vitals',
              onEdit: () => setState(() => _isReviewing = false),
              rows: const [
                MapEntry('Measurements', 'BP 124/80 mmHg · Pulse 78 bpm · Temp 36.7 °C · SpO2 98%'),
                MapEntry('Body', 'Weight 78.0 kg · Height 178 cm (Illustrative)'),
              ],
            ),
            const SizedBox(height: 14),

            _buildDesktopSectionCard(
              title: 'C Medical history',
              onEdit: () => setState(() => _isReviewing = false),
              rows: const [
                MapEntry('Conditions', 'No chronic conditions recorded (illustrative)'),
                MapEntry('Medication history', 'No regular medication recorded'),
                MapEntry('Allergies', 'Penicillin — anaphylaxis'),
              ],
            ),
            const SizedBox(height: 14),

            _buildDesktopSectionCard(
              title: 'D Examination',
              onEdit: () => setState(() => _isReviewing = false),
              rows: const [
                MapEntry('Findings', 'Alert, well hydrated. Chest clear. Heart sounds normal. No pedal oedema.'),
                MapEntry('Observations', 'Mild acanthosis nigricans, neck'),
              ],
            ),
            const SizedBox(height: 14),

            _buildDesktopSectionCard(
              title: 'E Diagnosis',
              onEdit: () => setState(() => _isReviewing = false),
              rows: const [
                MapEntry('ICD-10', 'R51 · Headache (example code)'),
                MapEntry('Summary', 'Illustrative assessment only: recurring headaches, no validated diagnosis.'),
              ],
            ),
            const SizedBox(height: 14),

            _buildDesktopSectionCard(
              title: 'F Treatment plan',
              onEdit: () => setState(() => _isReviewing = false),
              rows: const [
                MapEntry('Instructions', 'Illustrative plan: Paracetamol as needed, keep a headache diary, review if symptoms change.'),
                MapEntry('Follow-up', 'In 4 weeks · 12 Nov 2026'),
              ],
            ),
            const SizedBox(height: 14),

            _buildDesktopSectionCard(
              title: 'Prescription',
              onEdit: () => setState(() => _isReviewing = false),
              rows: const [
                MapEntry('Rx-2028-10427-03', 'Paracetamol 500 mg · Awaiting dispensing'),
              ],
            ),
            const SizedBox(height: 14),

            _buildDesktopSectionCard(
              title: 'Lab referral, letters & attachments',
              onEdit: () => setState(() => _isReviewing = false),
              rows: const [
                MapEntry('Lab referral', 'Full blood count · Sent to Soweto NHLS Laboratory'),
                MapEntry('Sick note', '15–17 Oct 2026 · Finalised'),
                MapEntry('Attachments', 'Headache_diary_Oct.pdf'),
              ],
            ),
            const SizedBox(height: 14),

            // Bottom Action Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                children: [
                  const Text(
                    'All required sections complete',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => setState(() => _isReviewing = false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDefault),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Back to consultation',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: _signOffConsultation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Sign Off Consultation',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSectionCard({
    required String title,
    required VoidCallback onEdit,
    required List<MapEntry<String, String>> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.headingFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit section',
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.brandPrimary,
                ),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      row.key,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      row.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewConsultationView({
    required BuildContext context,
    required double horizontalPadding,
    required bool isMobileOrTablet,
  }) {
    final patientName = widget.patient?.name ?? 'John Smith';
    final folderNumber = widget.patient?.fileNumber ?? 'SWC-10427';
    final dob = widget.patient?.dateOfBirth ?? '12 Mar 1974';
    final phone = widget.patient?.mobile ?? '+27 82 555 0143';
    final initials = patientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Ready for sign-off)
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    Text(
                      'Review consultation',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: isNarrow ? 22 : 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F5F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ready for sign-off',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Check each section before signing off. Signed records cannot be edited.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Patient Card
                if (isNarrow)
                  _buildMobilePatientCard(
                    patientName: patientName,
                    initials: initials,
                    dob: dob,
                    folderNumber: folderNumber,
                    phone: phone,
                  )
                else
                  _buildTabletPatientCard(
                    patientName: patientName,
                    initials: initials,
                    dob: dob,
                    folderNumber: folderNumber,
                    phone: phone,
                  ),
                const SizedBox(height: 14),

                // Section Cards
                _buildReviewSectionCard(
                  codeLetter: 'A',
                  title: 'Presenting complaint',
                  isMobile: isNarrow,
                  onEdit: () => setState(() => _isReviewing = false),
                  rows: const [
                    MapEntry('Chief complaint', 'Recurring headaches'),
                    MapEntry('Symptoms', 'Recurring headaches, usually in the afternoon. Illustrative note only.'),
                    MapEntry('Onset & duration', 'Gradual · about 3 weeks'),
                  ],
                ),
                const SizedBox(height: 14),

                _buildReviewSectionCard(
                  codeLetter: 'B',
                  title: 'Vitals',
                  isMobile: isNarrow,
                  onEdit: () => setState(() => _isReviewing = false),
                  rows: const [
                    MapEntry('Measurements', 'BP 124/80 mmHg · Pulse 78 bpm · Temp 36.7 °C · SpO2 98%'),
                    MapEntry('Body', 'Weight 78.0 kg · Height 178 cm (Illustrative)'),
                  ],
                ),
                const SizedBox(height: 14),

                _buildReviewSectionCard(
                  codeLetter: 'C',
                  title: 'Medical history',
                  isMobile: isNarrow,
                  onEdit: () => setState(() => _isReviewing = false),
                  rows: const [
                    MapEntry('Conditions', 'No chronic conditions recorded (illustrative)'),
                    MapEntry('Medication history', 'No regular medication recorded'),
                    MapEntry('Allergies', 'Penicillin — anaphylaxis'),
                  ],
                ),
                const SizedBox(height: 14),

                _buildReviewSectionCard(
                  codeLetter: 'D',
                  title: 'Examination',
                  isMobile: isNarrow,
                  onEdit: () => setState(() => _isReviewing = false),
                  rows: const [
                    MapEntry('Findings', 'Alert, well hydrated. Chest clear. Heart sounds normal. No pedal oedema.'),
                    MapEntry('Observations', 'Mild acanthosis nigricans, neck'),
                  ],
                ),
                const SizedBox(height: 14),

                _buildReviewSectionCard(
                  codeLetter: 'E',
                  title: 'Diagnosis',
                  isMobile: isNarrow,
                  onEdit: () => setState(() => _isReviewing = false),
                  rows: const [
                    MapEntry('ICD-10', 'R51 · Headache (example code)'),
                    MapEntry('Summary', 'Illustrative assessment only: recurring headaches, no validated diagnosis.'),
                  ],
                ),
                const SizedBox(height: 14),

                _buildReviewSectionCard(
                  codeLetter: 'F',
                  title: 'Treatment plan',
                  isMobile: isNarrow,
                  onEdit: () => setState(() => _isReviewing = false),
                  rows: const [
                    MapEntry('Instructions', 'Illustrative plan: Paracetamol as needed, keep a headache diary, review if symptoms change.'),
                    MapEntry('Follow-up', 'In 4 weeks · 12 Nov 2026'),
                  ],
                ),
                const SizedBox(height: 14),

                _buildReviewSectionCard(
                  title: 'Prescription',
                  isMobile: isNarrow,
                  onEdit: () => setState(() => _isReviewing = false),
                  rows: const [
                    MapEntry('Rx-2026-10427-03', 'Paracetamol 500 mg · Awaiting dispensing'),
                  ],
                ),
                const SizedBox(height: 14),

                _buildReviewSectionCard(
                  title: 'Lab referral, letters & attachments',
                  isMobile: isNarrow,
                  onEdit: () => setState(() => _isReviewing = false),
                  rows: const [
                    MapEntry('Lab referral', 'Full blood count · Sent to Soweto NHLS Laboratory'),
                    MapEntry('Sick note', '15–17 Oct 2026 · Finalised'),
                    MapEntry('Attachments', 'Headache_diary_Oct.pdf'),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Card (scrolls with entire screen)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'All required sections complete',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isNarrow) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => setState(() => _isReviewing = false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.borderDefault),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Back to consultation',
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFamily,
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _signOffConsultation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Sign Off Consultation',
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _isReviewing = false),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.borderDefault),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text(
                                    'Back to consultation',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.bodyFamily,
                                      color: AppColors.brandPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _signOffConsultation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brandPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text(
                                    'Sign Off Consultation',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.bodyFamily,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobilePatientCard({
    required String patientName,
    required String initials,
    required String dob,
    required String folderNumber,
    required String phone,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F5F3),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.isEmpty ? 'JS' : initials,
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '52 / Male',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Q015',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: Color(0xFFEA580C)),
                    SizedBox(width: 4),
                    Text(
                      'Urgent',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFEA580C)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _reviewPatientMetaRow('Date of birth', dob),
          const SizedBox(height: 8),
          _reviewPatientMetaRow('ID', '740312 5021 087'),
          const SizedBox(height: 8),
          _reviewPatientMetaRow('Folder', '#$folderNumber'),
          const SizedBox(height: 8),
          _reviewPatientMetaRow('Phone', phone),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Reason for visit',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Follow-up',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletPatientCard({
    required String patientName,
    required String initials,
    required String dob,
    required String folderNumber,
    required String phone,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F5F3),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.isEmpty ? 'JS' : initials,
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '52 / Male',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Q015',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 6, color: Color(0xFFEA580C)),
                          SizedBox(width: 4),
                          Text(
                            'Urgent',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFEA580C)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _reviewPatientMeta('Date of birth', dob),
              _reviewPatientMeta('ID', '740312 5021 087'),
              _reviewPatientMeta('Folder', '#$folderNumber'),
              _reviewPatientMeta('Phone', phone),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Reason for visit',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Follow-up',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewPatientMetaRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _signOffConsultation() {
    showSignOffView(
      context,
      patient: widget.patient,
      onConfirm: _completeSignOff,
    );
  }

  void _completeSignOff() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showConsultationCompletedView(
        context,
        patient: widget.patient,
        onViewRecord: () {
          setState(() {
            _isReviewing = true;
          });
        },
        onReturnToQueue: () {
          setState(() => _isReviewing = false);
          widget.onBack?.call();
        },
      );
    });
  }

  Widget _reviewPatientMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildReviewSectionCard({
    String? codeLetter,
    required String title,
    bool isMobile = false,
    required VoidCallback onEdit,
    required List<MapEntry<String, String>> rows,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (codeLetter != null) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F766E),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    codeLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.headingFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit section',
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.brandPrimary,
                ),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isMobile)
            ...rows.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.key,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      row.value,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            ...rows.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        row.key,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        row.value,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String letter;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(
          color: AppColors.borderDefault,
          width: Dimensions.strokeDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.brandPrimary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ConsultationField extends StatelessWidget {
  const _ConsultationField({
    required this.label,
    this.controller,
    this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
    this.filled = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final int minLines;
  final int maxLines;
  final bool readOnly;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          minLines: minLines,
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textDisabled,
            ),
            filled: filled,
            fillColor: filled ? AppColors.backgroundApp : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(
                color: AppColors.borderDefault,
                width: Dimensions.strokeDivider,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(
                color: AppColors.borderDefault,
                width: Dimensions.strokeDivider,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(
                color: AppColors.brandPrimary,
                width: Dimensions.strokeFocus,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.label, this.trailing, required this.onTap});

  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        hoverColor: AppColors.backgroundApp,
        child: Container(
          height: Dimensions.buttonMinHeight,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(
              color: AppColors.borderDefault,
              width: Dimensions.strokeDivider,
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.brandPrimary,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

String? _lastPrescribedMedicineSession;
final Set<String> _prescribedHistorySession = <String>{};
List<PrescriptionItem> _prescribedItemsSession = <PrescriptionItem>[];

@visibleForTesting
void resetPrescriptionSession() {
  _lastPrescribedMedicineSession = null;
  _prescribedHistorySession.clear();
  _prescribedItemsSession.clear();
}

class PrescriptionItem {
  PrescriptionItem({
    required this.name,
    this.strength = '',
    this.dose = '',
    this.duration = '',
    this.quantity = '',
    this.frequency = '',
    this.instructions = '',
    this.isRepeat = false,
  });

  final String name;
  final String strength;
  final String dose;
  final String duration;
  final String quantity;
  final String frequency;
  final String instructions;
  final bool isRepeat;

  String get displayName {
    if (strength.isEmpty ||
        name.toLowerCase().contains(strength.toLowerCase())) {
      return name;
    }
    if (name.toLowerCase().contains('tablet')) {
      final base =
          name.replaceAll(RegExp(r'\btablet\b', caseSensitive: false), '').trim();
      return '$base $strength tablet';
    }
    if (name.toLowerCase().contains('capsule')) {
      final base = name
          .replaceAll(RegExp(r'\bcapsule\b', caseSensitive: false), '')
          .trim();
      return '$base $strength capsule';
    }
    if (name.toLowerCase().contains('syrup')) {
      final base =
          name.replaceAll(RegExp(r'\bsyrup\b', caseSensitive: false), '').trim();
      return '$base $strength syrup';
    }
    return '$name $strength';
  }

  String get summary {
    final parts = <String>[];
    if (dose.isNotEmpty) parts.add(dose);
    if (frequency.isNotEmpty) parts.add(frequency);
    if (duration.isNotEmpty) parts.add(duration);
    if (quantity.isNotEmpty) {
      if (quantity.toLowerCase().startsWith('qty')) {
        parts.add(quantity);
      } else {
        parts.add('Qty $quantity');
      }
    }
    return parts.join(' · ');
  }
}

/// Responsive launcher for "Lab referral" workflow:
/// - Desktop (>= 1200): Slide drawer from right with scrim over consultation
/// - Tablet (600..1199): Dedicated page with header, back button, actions & bottom nav bar
/// - Mobile (< 600): Modal bottom sheet with scrim over consultation
void showLabReferralView(
  BuildContext context, {
  PatientRecord? patient,
}) {
  if (ResponsiveHelper.isMobile(context)) {
    showLabReferralBottomSheet(context, patient: patient);
  } else if (ResponsiveHelper.isTablet(context)) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (pageContext, animation, secondaryAnimation) =>
            LabReferralTabletPage(patient: patient),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  } else {
    showLabReferralDrawer(context, patient: patient);
  }
}

/// Desktop slide-in drawer for Lab referral
void showLabReferralDrawer(
  BuildContext context, {
  PatientRecord? patient,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x850F1F1D),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final screenWidth = MediaQuery.sizeOf(dialogContext).width;
      final drawerWidth = screenWidth < 768
          ? (screenWidth * 0.85).clamp(320.0, 420.0)
          : (screenWidth < 1100 ? 430.0 : Dimensions.drawerWidth);

      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 16,
          color: Colors.transparent,
          child: Container(
            width: drawerWidth,
            height: double.infinity,
            color: Colors.white,
            child: _LabReferralContent(
              patient: patient,
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
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slideAnimation, child: child);
    },
  );
}

/// Mobile bottom sheet for Lab referral
void showLabReferralBottomSheet(
  BuildContext context, {
  PatientRecord? patient,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x850F1F1D),
    showDragHandle: false,
    builder: (sheetContext) {
      final screenHeight = MediaQuery.sizeOf(sheetContext).height;
      return Container(
        height: screenHeight * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: _LabReferralContent(
                  patient: patient,
                  isMobile: true,
                  onClose: () => Navigator.of(sheetContext).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Tablet page for Lab referral
class LabReferralTabletPage extends StatelessWidget {
  const LabReferralTabletPage({super.key, this.patient});

  final PatientRecord? patient;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      route: AppRoutes.consultations,
      hideBottomNavigation: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusControl),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                          border: Border.all(
                            color: AppColors.borderDefault,
                            width: Dimensions.strokeDivider,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          AppIcons.chevronLeft,
                          size: Dimensions.iconSize,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lab referral',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Request tests for this consultation',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderDefault),
            Expanded(
              child: _LabReferralContent(
                patient: patient,
                isTabletPage: true,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared form content for Lab referral across Desktop, Mobile, and Tablet
class _LabReferralContent extends StatefulWidget {
  const _LabReferralContent({
    this.patient,
    required this.onClose,
    this.isMobile = false,
    this.isTabletPage = false,
  });

  final PatientRecord? patient;
  final VoidCallback onClose;
  final bool isMobile;
  final bool isTabletPage;

  @override
  State<_LabReferralContent> createState() => _LabReferralContentState();
}

class _LabReferralContentState extends State<_LabReferralContent> {
  final TextEditingController _laboratoryController =
      TextEditingController(text: 'Soweto NHLS Laboratory');
  final TextEditingController _searchTestsController =
      TextEditingController(text: 'Full blood count');
  final List<String> _selectedTests = ['Full blood count', '—', '—'];
  String _urgency = 'Routine';
  String _specimen = 'Blood · venous';
  final TextEditingController _clinicalNotesController = TextEditingController(
    text: 'Recurring headaches for about 3 weeks. Illustrative request.',
  );

  @override
  void dispose() {
    _laboratoryController.dispose();
    _searchTestsController.dispose();
    _clinicalNotesController.dispose();
    super.dispose();
  }

  void _addTest(String test) {
    final trimmed = test.trim();
    if (trimmed.isNotEmpty && !_selectedTests.contains(trimmed)) {
      setState(() {
        _selectedTests.add(trimmed);
        _searchTestsController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patient?.name ?? 'John Smith';
    final folderNumber = widget.patient?.fileNumber ?? 'SWC-10427';
    final initials = patientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Column(
      children: [
        if (!widget.isTabletPage) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lab referral',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Request tests for this consultation',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(
                    AppIcons.close,
                    size: Dimensions.iconSize,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
        ],
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Patient Capsule
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials.isEmpty ? 'JS' : initials,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '52 / Male · Folder #$folderNumber',
                            style: const TextStyle(
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
              const SizedBox(height: 16),

              // Laboratory
              const Text(
                'Laboratory',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _laboratoryController,
                decoration: _fieldInputDecoration(),
              ),
              const SizedBox(height: 16),

              // Search tests
              const Text(
                'Search tests',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchTestsController,
                onSubmitted: _addTest,
                decoration: _fieldInputDecoration(),
              ),
              const SizedBox(height: 16),

              // Selected tests
              const Text(
                'Selected tests',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_selectedTests.length, (index) {
                  final test = _selectedTests[index];
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F5F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          test,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTests.removeAt(index);
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Urgency and Specimen
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Urgency',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _urgency,
                          isExpanded: true,
                          decoration: _fieldInputDecoration(),
                          items: ['Routine', 'Urgent', 'Immediate'].map((u) {
                            return DropdownMenuItem(
                              value: u,
                              child: Text(
                                u,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.bodyFamily,
                                  fontSize: 13.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _urgency = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Specimen',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _specimen,
                          isExpanded: true,
                          decoration: _fieldInputDecoration(),
                          items: [
                            'Blood · venous',
                            'Blood · arterial',
                            'Urine',
                            'Sputum',
                            'Swab'
                          ].map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.bodyFamily,
                                  fontSize: 13.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _specimen = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Clinical notes
              const Text(
                'Clinical notes',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _clinicalNotesController,
                minLines: 3,
                maxLines: 4,
                decoration: _fieldInputDecoration(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Sticky Bottom actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.borderDefault,
                width: Dimensions.strokeDivider,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onClose();
                      AppNotice.info('Lab referral', 'Referral saved as draft');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onClose();
                      AppNotice.info(
                        'Lab referral',
                        'Referral sent to ${_laboratoryController.text.trim()}',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Send Refferal',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
      ),
    );
  }
}

/// Responsive launcher for "Sick note / Letter" workflow:
/// - Desktop (>= 1200): Slide drawer from right with scrim over consultation
/// - Tablet (600..1199): Dedicated white page with header, back button, no bottom nav bar
/// - Mobile (< 600): Modal bottom sheet with scrim over consultation
void showSickNoteView(
  BuildContext context, {
  PatientRecord? patient,
}) {
  if (ResponsiveHelper.isMobile(context)) {
    showSickNoteBottomSheet(context, patient: patient);
  } else if (ResponsiveHelper.isTablet(context)) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (pageContext, animation, secondaryAnimation) =>
            SickNoteTabletPage(patient: patient),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  } else {
    showSickNoteDrawer(context, patient: patient);
  }
}

/// Desktop slide-in drawer for Sick note / Letter
void showSickNoteDrawer(
  BuildContext context, {
  PatientRecord? patient,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x850F1F1D),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final screenWidth = MediaQuery.sizeOf(dialogContext).width;
      final drawerWidth = screenWidth < 768
          ? (screenWidth * 0.85).clamp(320.0, 420.0)
          : (screenWidth < 1100 ? 430.0 : Dimensions.drawerWidth);

      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: drawerWidth,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x260F1F1D),
                  blurRadius: 24,
                  offset: Offset(-4, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: _SickNoteContent(
                patient: patient,
                onClose: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim, secAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
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

/// Mobile bottom sheet for Sick note / Letter
void showSickNoteBottomSheet(
  BuildContext context, {
  PatientRecord? patient,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x850F1F1D),
    showDragHandle: false,
    builder: (sheetContext) {
      final screenHeight = MediaQuery.sizeOf(sheetContext).height;
      return Container(
        height: screenHeight * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: _SickNoteContent(
                  patient: patient,
                  isMobile: true,
                  onClose: () => Navigator.of(sheetContext).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Tablet page for Sick note / Letter without bottom nav bar
class SickNoteTabletPage extends StatelessWidget {
  const SickNoteTabletPage({super.key, this.patient});

  final PatientRecord? patient;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      route: AppRoutes.consultations,
      hideBottomNavigation: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusControl),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                          border: Border.all(
                            color: AppColors.borderDefault,
                            width: Dimensions.strokeDivider,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          AppIcons.chevronLeft,
                          size: Dimensions.iconSize,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sick note / Letter',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Step 1 of 2 · Choose a template and review',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderDefault),
            Expanded(
              child: _SickNoteContent(
                patient: patient,
                isTabletPage: true,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared form content for Sick note / Letter across Desktop, Mobile, and Tablet
class _SickNoteContent extends StatefulWidget {
  const _SickNoteContent({
    this.patient,
    required this.onClose,
    this.isMobile = false,
    this.isTabletPage = false,
  });

  final PatientRecord? patient;
  final VoidCallback onClose;
  final bool isMobile;
  final bool isTabletPage;

  @override
  State<_SickNoteContent> createState() => _SickNoteContentState();
}

class _SickNoteContentState extends State<_SickNoteContent> {
  final TextEditingController _templateController =
      TextEditingController(text: 'Sick note (medical certificate)');
  final TextEditingController _fromController =
      TextEditingController(text: '15 Oct 2026');
  final TextEditingController _toController =
      TextEditingController(text: '17 Oct 2026');

  @override
  void dispose() {
    _templateController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patient?.name ?? 'John Smith';
    final folderNumber = widget.patient?.fileNumber ?? 'SWC-10427';
    final initials = patientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Column(
      children: [
        if (!widget.isTabletPage) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sick note / Letter',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Step 1 of 2 · Choose a template and review',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(
                    AppIcons.close,
                    size: Dimensions.iconSize,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
        ],
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Patient Capsule
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials.isEmpty ? 'JS' : initials,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '52 / Male · Folder #$folderNumber',
                            style: const TextStyle(
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
              const SizedBox(height: 16),

              // Template
              const Text(
                'Template',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _templateController.text,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'Sick note (medical certificate)',
                    child: Text(
                      'Sick note (medical certificate)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Referral letter',
                    child: Text(
                      'Referral letter',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Fitness to work certificate',
                    child: Text(
                      'Fitness to work certificate',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _templateController.text = val);
                  }
                },
                decoration: _fieldInputDecoration(),
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),

              // From & To Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'From',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _fromController,
                          decoration: _fieldInputDecoration(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'To',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _toController,
                          decoration: _fieldInputDecoration(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Certificate Preview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'T',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Soweto Community Health Centre',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '12 Vilakazi St, Orlando West, Soweto · 011 555 0100',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.borderDefault),
                    const SizedBox(height: 12),
                    const Text(
                      'Medical certificate',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is to certify that $patientName (ID 740312 5021 087) was examined on ${_fromController.text.trim()} and is unfit for work from ${_fromController.text.trim()} to ${_toController.text.trim()}.',
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Dr. Maya Naidoo · MP 0612345 · Signature applied on finalise',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Review button
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    AppNotice.info(
                      'Sick note / Letter',
                      'Reviewing medical certificate draft',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderDefault),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Sticky Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.borderDefault,
                width: Dimensions.strokeDivider,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: widget.onClose,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onClose();
                      AppNotice.info(
                        'Sick note / Letter',
                        'Medical certificate finalised and saved',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Finalise',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
      ),
    );
  }
}

class _ConsultationAttachment {
  const _ConsultationAttachment({
    required this.name,
    required this.size,
    required this.time,
  });
  final String name;
  final String size;
  final String time;
  String get extension => 'PDF';
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 8.0,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  static const double _gap = 5.0;
  static const double _dash = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = _dash.clamp(0.0, metric.length - distance);
        dashPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += _dash + _gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) => false;
}

/// Responsive launcher for "Attachments" workflow:
/// - Desktop (>= 1200): Slide drawer from right with scrim over consultation
/// - Tablet (600..1199): Dedicated white page with header, back button, no bottom nav bar
/// - Mobile (< 600): Modal bottom sheet with scrim over consultation
void showAttachmentsView(
  BuildContext context, {
  PatientRecord? patient,
}) {
  if (ResponsiveHelper.isMobile(context)) {
    showAttachmentsBottomSheet(context, patient: patient);
  } else if (ResponsiveHelper.isTablet(context)) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (pageContext, animation, secondaryAnimation) =>
            AttachmentsTabletPage(patient: patient),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  } else {
    showAttachmentsDrawer(context, patient: patient);
  }
}

/// Desktop slide-in drawer for Attachments
void showAttachmentsDrawer(
  BuildContext context, {
  PatientRecord? patient,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x850F1F1D),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final screenWidth = MediaQuery.sizeOf(dialogContext).width;
      final drawerWidth = screenWidth < 768
          ? (screenWidth * 0.85).clamp(320.0, 420.0)
          : (screenWidth < 1100 ? 430.0 : Dimensions.drawerWidth);

      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: drawerWidth,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x260F1F1D),
                  blurRadius: 24,
                  offset: Offset(-4, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: _AttachmentsContent(
                patient: patient,
                onClose: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim, secAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
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

/// Mobile bottom sheet for Attachments
void showAttachmentsBottomSheet(
  BuildContext context, {
  PatientRecord? patient,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x850F1F1D),
    showDragHandle: false,
    builder: (sheetContext) {
      final screenHeight = MediaQuery.sizeOf(sheetContext).height;
      return Container(
        height: screenHeight * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: _AttachmentsContent(
                  patient: patient,
                  isMobile: true,
                  onClose: () => Navigator.of(sheetContext).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Tablet page for Attachments without bottom nav bar
class AttachmentsTabletPage extends StatelessWidget {
  const AttachmentsTabletPage({super.key, this.patient});

  final PatientRecord? patient;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      route: AppRoutes.consultations,
      hideBottomNavigation: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusControl),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusControl),
                          border: Border.all(
                            color: AppColors.borderDefault,
                            width: Dimensions.strokeDivider,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          AppIcons.chevronLeft,
                          size: Dimensions.iconSize,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attachments',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Files linked to this consultation',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderDefault),
            Expanded(
              child: _AttachmentsContent(
                patient: patient,
                isTabletPage: true,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared form content for Attachments across Desktop, Mobile, and Tablet
class _AttachmentsContent extends StatefulWidget {
  const _AttachmentsContent({
    this.patient,
    required this.onClose,
    this.isMobile = false,
    this.isTabletPage = false,
  });

  final PatientRecord? patient;
  final VoidCallback onClose;
  final bool isMobile;
  final bool isTabletPage;

  @override
  State<_AttachmentsContent> createState() => _AttachmentsContentState();
}

class _AttachmentsContentState extends State<_AttachmentsContent> {
  final List<_ConsultationAttachment> _attachments = [
    const _ConsultationAttachment(
      name: 'ECG_15Oct2026.pdf',
      size: '1.2 MB',
      time: '11:40',
    ),
    const _ConsultationAttachment(
      name: 'Headache_diary_Oct.pdf',
      size: '340 KB',
      time: '11:42',
    ),
  ];

  void _addSampleAttachment() {
    setState(() {
      _attachments.add(
        _ConsultationAttachment(
          name: 'Medical_report_${_attachments.length + 1}.pdf',
          size: '520 KB',
          time: '11:45',
        ),
      );
    });
    AppNotice.info('Attachments', 'File attached successfully');
  }

  void _removeAttachment(int index) {
    if (index >= 0 && index < _attachments.length) {
      final removed = _attachments[index];
      setState(() {
        _attachments.removeAt(index);
      });
      AppNotice.info('Attachments', '${removed.name} removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patient?.name ?? 'John Smith';
    final folderNumber = widget.patient?.fileNumber ?? 'SWC-10427';
    final initials = patientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Column(
      children: [
        if (!widget.isTabletPage) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attachments',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Files linked to this consultation',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(
                    AppIcons.close,
                    size: Dimensions.iconSize,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
        ],
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Patient Capsule
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials.isEmpty ? 'JS' : initials,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '52 / Male · Folder #$folderNumber',
                            style: const TextStyle(
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
              const SizedBox(height: 16),

              // Drag & drop box
              InkWell(
                onTap: _addSampleAttachment,
                borderRadius: BorderRadius.circular(8),
                child: CustomPaint(
                  painter: const _DashedRectPainter(
                    color: AppColors.brandPrimary,
                    radius: 8,
                    strokeWidth: 1.5,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FAF9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.file_upload_outlined,
                          size: 26,
                          color: AppColors.brandPrimary,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Drag files here or browse',
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'PDF, JPG or PNG · max 10 MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Attached files title
              Text(
                'Attached files (${_attachments.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Files list
              ...List.generate(_attachments.length, (index) {
                final file = _attachments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F5F3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            file.extension,
                            style: const TextStyle(
                              color: AppColors.brandPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${file.size} · uploaded ${file.time}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFFDC2626),
                            size: 20,
                          ),
                          onPressed: () => _removeAttachment(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),

              const Text(
                'Files can be removed until the consultation is signed off.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Sticky Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.borderDefault,
                width: Dimensions.strokeDivider,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: widget.onClose,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onClose();
                      AppNotice.info(
                        'Attachments',
                        'Attachments saved for this consultation',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Responsive launcher for "Add prescription" workflow:
/// - Desktop (>= 1200): Slide drawer from right with scrim over consultation
/// - Tablet (600..1199): Dedicated page with header, back button, actions & no bottom nav bar
/// - Mobile (< 600): Modal bottom sheet with scrim over consultation
void showAddPrescriptionView(
  BuildContext context, {
  PatientRecord? patient,
  String? previousMedicine,
  List<PrescriptionItem>? initialItems,
  ValueChanged<String>? onMedicineSelected,
}) {
  final effectivePreviousMedicine =
      previousMedicine ?? _lastPrescribedMedicineSession;
  final effectiveItems = initialItems ?? _prescribedItemsSession;
  if (ResponsiveHelper.isMobile(context)) {
    showAddPrescriptionBottomSheet(
      context,
      patient: patient,
      previousMedicine: effectivePreviousMedicine,
      initialItems: effectiveItems,
      onMedicineSelected: onMedicineSelected,
    );
  } else if (ResponsiveHelper.isTablet(context)) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (pageContext, animation, secondaryAnimation) =>
            AddPrescriptionTabletPage(
          parentContext: context,
          patient: patient,
          previousMedicine: effectivePreviousMedicine,
          initialItems: effectiveItems,
          onMedicineSelected: onMedicineSelected,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  } else {
    showAddPrescriptionDrawer(
      context,
      patient: patient,
      previousMedicine: effectivePreviousMedicine,
      initialItems: effectiveItems,
      onMedicineSelected: onMedicineSelected,
    );
  }
}

/// Desktop slide-in drawer
void showAddPrescriptionDrawer(
  BuildContext context, {
  PatientRecord? patient,
  String? previousMedicine,
  List<PrescriptionItem>? initialItems,
  ValueChanged<String>? onMedicineSelected,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x850F1F1D),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final screenWidth = MediaQuery.sizeOf(dialogContext).width;
      final drawerWidth = screenWidth < 768
          ? (screenWidth * 0.85).clamp(320.0, 420.0)
          : (screenWidth < 1100 ? 430.0 : Dimensions.drawerWidth);

      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 16,
          color: Colors.transparent,
          child: Container(
            width: drawerWidth,
            height: double.infinity,
            color: Colors.white,
            child: _AddPrescriptionContent(
              parentContext: context,
              patient: patient,
              previousMedicine: previousMedicine,
              initialItems: initialItems,
              onMedicineSelected: onMedicineSelected,
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
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slideAnimation, child: child);
    },
  );
}

/// Mobile modal bottom sheet
void showAddPrescriptionBottomSheet(
  BuildContext context, {
  PatientRecord? patient,
  String? previousMedicine,
  List<PrescriptionItem>? initialItems,
  ValueChanged<String>? onMedicineSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    barrierColor: const Color(0x850F1F1D),
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.88,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: _AddPrescriptionContent(
                  parentContext: context,
                  patient: patient,
                  isMobile: true,
                  previousMedicine: previousMedicine,
                  initialItems: initialItems,
                  onMedicineSelected: onMedicineSelected,
                  onClose: () => Navigator.of(sheetContext).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Responsive modal for "Sent to dispensing" confirmation:
/// - Desktop (>= 1200): Centered dialog with dimmed scrim over consultation
/// - Tablet (600..1199): Centered dialog with dimmed scrim over consultation
/// - Mobile (< 600): Modal bottom sheet with dimmed scrim over consultation
void showSentToDispensingDialog(
  BuildContext context, {
  String rxNumber = 'Rx-2026-10427-03',
  VoidCallback? onPrint,
  VoidCallback? onReturn,
}) {
  if (ResponsiveHelper.isMobile(context)) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x850F1F1D),
      showDragHandle: false,
      builder: (sheetContext) => _SentToDispensingBottomSheet(
        rxNumber: rxNumber,
        onPrint: () {
          onPrint?.call();
          AppNotice.info('Prescription', 'Printing prescription $rxNumber...');
        },
        onReturn: () {
          Navigator.of(sheetContext).pop();
          onReturn?.call();
        },
      ),
    );
  } else {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: const Color(0x850F1F1D),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => Center(
        child: Material(
          color: Colors.transparent,
          child: _SentToDispensingCard(
            rxNumber: rxNumber,
            onPrint: () {
              onPrint?.call();
              AppNotice.info('Prescription', 'Printing prescription $rxNumber...');
            },
            onReturn: () {
              Navigator.of(dialogContext).pop();
              onReturn?.call();
            },
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) {
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

class _SentToDispensingCard extends StatelessWidget {
  const _SentToDispensingCard({
    required this.rxNumber,
    required this.onPrint,
    required this.onReturn,
  });

  final String rxNumber;
  final VoidCallback onPrint;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Check Badge
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEBF8F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 26,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Sent to dispensing',
            style: TextStyle(
              fontFamily: AppTextStyles.headingFamily,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$rxNumber is in the dispensing queue. Dispensing staff will update the status once medicines are issued.',
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 14),
          // Awaiting dispensing pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFEF3C7)),
            ),
            child: const Text(
              'Awaiting dispensing',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB45309),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Bottom Actions
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onPrint,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Print',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onReturn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Return to consultation',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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

class _SentToDispensingBottomSheet extends StatelessWidget {
  const _SentToDispensingBottomSheet({
    required this.rxNumber,
    required this.onPrint,
    required this.onReturn,
  });

  final String rxNumber;
  final VoidCallback onPrint;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Inner bordered card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEBF8F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 26,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sent to dispensing',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$rxNumber is in the dispensing queue. Dispensing staff will update the status once medicines are issued.',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFEF3C7)),
                      ),
                      child: const Text(
                        'Awaiting dispensing',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Bottom Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: onPrint,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderDefault),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Print',
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            color: AppColors.brandPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: onReturn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Return to consultation',
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
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

const List<String> _kPrescriptionMedicineNames = [
  'Paracetamol tablet',
  'Paracetamol syrup',
  'Paracetamol suspension',
  'Amoxicillin capsule',
  'Amoxicillin suspension',
  'Augmentin tablet',
  'Ibuprofen tablet',
  'Ibuprofen syrup',
  'Azithromycin capsule',
  'Cetirizine tablet',
  'Metformin tablet',
  'Omeprazole capsule',
  'Salbutamol inhaler',
];

/// Reusable search results list showing clean medicine names with Select / Repeat actions.
class _PrescriptionMedicineSearchResults extends StatelessWidget {
  const _PrescriptionMedicineSearchResults({
    required this.query,
    required this.selectedMedicine,
    this.previousMedicine,
    this.previousMedicines = const {},
    required this.onSelect,
    required this.onRepeat,
  });

  final String query;
  final String? selectedMedicine;
  final String? previousMedicine;
  final Set<String> previousMedicines;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRepeat;

  @override
  Widget build(BuildContext context) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    final matches = _kPrescriptionMedicineNames
        .where((med) => med.toLowerCase().contains(cleanQuery))
        .toList();

    final allPrevious = <String>{
      if (previousMedicine != null && previousMedicine!.trim().isNotEmpty)
        previousMedicine!.trim(),
      ...previousMedicines.where((m) => m.trim().isNotEmpty),
    };

    final relevantPrevious = allPrevious.where((prev) {
      final pLow = prev.toLowerCase();
      final pToken = pLow.split(' ').first;
      return pLow.contains(cleanQuery) || cleanQuery.contains(pToken);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '${matches.length} results',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        ...matches.map((name) {
          final isSelected = selectedMedicine == name;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0FAF8) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.brandPrimary
                    : AppColors.borderDefault,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(name),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        for (final prev in relevantPrevious)
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 10),
            decoration: BoxDecoration(
              color: (selectedMedicine == prev ||
                      selectedMedicine == 'Repeat previous prescription')
                  ? const Color(0xFFE6F5F3)
                  : const Color(0xFFF3FBF9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (selectedMedicine == prev ||
                        selectedMedicine == 'Repeat previous prescription')
                    ? AppColors.brandPrimary
                    : const Color(0xFFD4EDE6),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onRepeat(prev),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Repeat previous prescription',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$prev · 14 Aug 2026',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Repeat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Reusable Step 2 form for prescription details (matching desktop, tablet, and mobile mockups).
class _PrescriptionDetailsForm extends StatelessWidget {
  const _PrescriptionDetailsForm({
    required this.medicineNameController,
    required this.strengthController,
    required this.doseController,
    required this.durationController,
    required this.quantityController,
    required this.frequencyController,
    required this.instructionsController,
    required this.repeatPrevious,
    required this.onRepeatPreviousChanged,
    this.isDesktop = false,
  });

  final TextEditingController medicineNameController;
  final TextEditingController strengthController;
  final TextEditingController doseController;
  final TextEditingController durationController;
  final TextEditingController quantityController;
  final TextEditingController frequencyController;
  final TextEditingController instructionsController;
  final bool repeatPrevious;
  final ValueChanged<bool> onRepeatPreviousChanged;
  final bool isDesktop;

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    int minLines = 1,
    int maxLines = 1,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.textDisabled,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.brandPrimary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildField(
          label: 'Medicine name',
          controller: medicineNameController,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildField(
                label: 'Strength',
                controller: strengthController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildField(
                label: 'Dose',
                controller: doseController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isDesktop) ...[
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Frequency',
                  controller: frequencyController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  label: 'Duration',
                  controller: durationController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Quantity',
            controller: quantityController,
          ),
        ] else ...[
          _buildField(
            label: 'Duration',
            controller: durationController,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Quantity',
            controller: quantityController,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Frequency',
            controller: frequencyController,
          ),
        ],
        const SizedBox(height: 16),
        InkWell(
          onTap: () => onRepeatPreviousChanged(!repeatPrevious),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: repeatPrevious,
                    onChanged: (val) => onRepeatPreviousChanged(val ?? false),
                    activeColor: AppColors.brandPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: AppColors.borderDefault,
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Repeat previous prescription (14 Aug 2026)',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildField(
          label: 'Instructions for patient',
          controller: instructionsController,
          minLines: 3,
          maxLines: 3,
          hintText: 'Take with breakfast and supper.',
        ),
      ],
    );
  }
}

/// Reusable Step 3 Review View (matching mockup with allergy alert, Rx draft, items & print)
class _PrescriptionReviewView extends StatelessWidget {
  const _PrescriptionReviewView({
    this.patient,
    required this.items,
    required this.onEditItem,
    this.onRemoveItem,
    required this.onAddAnother,
    required this.onPrint,
  });

  final PatientRecord? patient;
  final List<PrescriptionItem> items;
  final ValueChanged<int> onEditItem;
  final ValueChanged<int>? onRemoveItem;
  final VoidCallback onAddAnother;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    final patientName = patient?.name ?? 'John Smith';
    final folderNumber = patient?.fileNumber ?? 'SWC-10427';
    final initials = patientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Patient Capsule
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F5F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.isEmpty ? 'JS' : initials,
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '52 / Male · Folder #$folderNumber',
                      style: const TextStyle(
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
        // Rx Header & Draft badge
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Rx-2026-10427-03',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Draft',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Prescribed by Dr. Maya Naidoo · 15 Oct 2026',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Medicine Cards
        for (int i = 0; i < items.length; i++) ...[
          _PrescriptionMedicineCard(
            item: items[i],
            onEdit: () => onEditItem(i),
            onRemove: () => onRemoveItem?.call(i),
          ),
        ],
        // + Add another medicine button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddAnother,
            icon: const Icon(
              Icons.add,
              size: 18,
              color: AppColors.brandPrimary,
            ),
            label: const Text(
              'Add another medicine',
              style: TextStyle(
                color: AppColors.brandPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Print button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: onPrint,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.borderDefault),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Print',
              style: TextStyle(
                color: AppColors.brandPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrescriptionMedicineCard extends StatefulWidget {
  const _PrescriptionMedicineCard({
    required this.item,
    required this.onEdit,
    required this.onRemove,
  });

  final PrescriptionItem item;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  State<_PrescriptionMedicineCard> createState() =>
      _PrescriptionMedicineCardState();
}

class _PrescriptionMedicineCardState extends State<_PrescriptionMedicineCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isTouch = ResponsiveHelper.isMobile(context) ||
        ResponsiveHelper.isTablet(context);
    final showCross = _isHovered || isTouch;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovered
                    ? AppColors.brandPrimary.withValues(alpha: 0.35)
                    : AppColors.borderDefault,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.summary,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.brandPrimary,
                  ),
                  tooltip: 'Edit medicine',
                  onPressed: widget.onEdit,
                ),
              ],
            ),
          ),
          // Cross button on right top
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: Tooltip(
                message: 'Remove medicine',
                child: InkWell(
                  onTap: widget.onRemove,
                  customBorder: const CircleBorder(),
                  hoverColor: const Color(0xFFFEE2E2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: showCross
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 13,
                      color: showCross
                          ? const Color(0xFFDC2626)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dedicated tablet page for Add prescription matching mockup:
/// Top TabletHeader, subheader with boxed `<` back button, patient capsule,
/// search field or details form, and bottom sticky Cancel & Continue buttons.
/// Note: No bottom navigation bar is rendered.
class AddPrescriptionTabletPage extends StatefulWidget {
  const AddPrescriptionTabletPage({
    super.key,
    this.parentContext,
    this.patient,
    this.previousMedicine,
    this.initialItems,
    this.onMedicineSelected,
  });

  final BuildContext? parentContext;
  final PatientRecord? patient;
  final String? previousMedicine;
  final List<PrescriptionItem>? initialItems;
  final ValueChanged<String>? onMedicineSelected;

  @override
  State<AddPrescriptionTabletPage> createState() =>
      _AddPrescriptionTabletPageState();
}

class _AddPrescriptionTabletPageState extends State<AddPrescriptionTabletPage> {
  final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _medicineNameController;
  final TextEditingController _strengthController =
      TextEditingController(text: '1 g');
  final TextEditingController _doseController =
      TextEditingController(text: '1 tablet');
  final TextEditingController _durationController =
      TextEditingController(text: '30 days');
  final TextEditingController _quantityController =
      TextEditingController(text: '60 tablets');
  final TextEditingController _frequencyController =
      TextEditingController(text: 'Twice daily with meals');
  final TextEditingController _instructionsController =
      TextEditingController(text: 'Take with breakfast and supper.');

  String? _selectedMedicine;
  bool _repeatPrevious = false;
  int _currentStep = 1;
  late List<PrescriptionItem> _prescriptionItems;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _prescriptionItems = List<PrescriptionItem>.from(
      widget.initialItems ?? _prescribedItemsSession,
    );
    _currentStep = _prescriptionItems.isNotEmpty ? 3 : 1;
    _medicineNameController =
        TextEditingController(text: widget.previousMedicine ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _medicineNameController.dispose();
    _strengthController.dispose();
    _doseController.dispose();
    _durationController.dispose();
    _quantityController.dispose();
    _frequencyController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _selectMedicineAndProceed(String medicine) {
    setState(() {
      _selectedMedicine = medicine;
      _medicineNameController.text = medicine;
      _repeatPrevious = false;
      if (medicine.toLowerCase().contains('paracetamol')) {
        _strengthController.text = '500 mg';
        _doseController.text = '1–2 tablets';
        _frequencyController.text = 'up to 4 times daily';
        _durationController.text = '5 days';
        _quantityController.text = '20';
        _instructionsController.text = 'Take after food for pain relief.';
      } else if (medicine.toLowerCase().contains('ibuprofen')) {
        _strengthController.text = '200 mg';
        _doseController.text = '1 tablet';
        _frequencyController.text = 'up to 3 times daily';
        _durationController.text = '5 days';
        _quantityController.text = '15';
        _instructionsController.text = 'Take with food or milk.';
      }
      _currentStep = 2;
    });
  }

  void _repeatMedicine(String medicine) {
    setState(() {
      _selectedMedicine = medicine;
      _medicineNameController.text = medicine;
      _repeatPrevious = true;
      if (medicine.toLowerCase().contains('paracetamol')) {
        _strengthController.text = '500 mg';
        _doseController.text = '1–2 tablets';
        _frequencyController.text = 'up to 4 times daily';
        _durationController.text = '5 days';
        _quantityController.text = '20';
        _instructionsController.text = 'Take after food for pain relief.';
      } else if (medicine.toLowerCase().contains('ibuprofen')) {
        _strengthController.text = '200 mg';
        _doseController.text = '1 tablet';
        _frequencyController.text = 'up to 3 times daily';
        _durationController.text = '5 days';
        _quantityController.text = '15';
        _instructionsController.text = 'Take with food or milk.';
      }
      _currentStep = 2;
    });
  }

  void _addOrUpdatePrescription() {
    final med = _medicineNameController.text.trim().isNotEmpty
        ? _medicineNameController.text.trim()
        : (_selectedMedicine ?? 'Prescription');

    final item = PrescriptionItem(
      name: med,
      strength: _strengthController.text.trim(),
      dose: _doseController.text.trim(),
      duration: _durationController.text.trim(),
      quantity: _quantityController.text.trim(),
      frequency: _frequencyController.text.trim(),
      instructions: _instructionsController.text.trim(),
      isRepeat: _repeatPrevious,
    );

    setState(() {
      if (_editingIndex != null && _editingIndex! < _prescriptionItems.length) {
        _prescriptionItems[_editingIndex!] = item;
        _editingIndex = null;
      } else {
        _prescriptionItems.add(item);
      }
      _currentStep = 3;
    });

    _lastPrescribedMedicineSession = item.name;
    _prescribedHistorySession.add(item.name);
    _prescribedItemsSession = List<PrescriptionItem>.from(_prescriptionItems);
    widget.onMedicineSelected?.call(item.displayName);
  }

  void _editItem(int index) {
    final item = _prescriptionItems[index];
    setState(() {
      _editingIndex = index;
      _selectedMedicine = item.name;
      _medicineNameController.text = item.name;
      _strengthController.text = item.strength;
      _doseController.text = item.dose;
      _durationController.text = item.duration;
      _quantityController.text = item.quantity;
      _frequencyController.text = item.frequency;
      _instructionsController.text = item.instructions;
      _repeatPrevious = item.isRepeat;
      _currentStep = 2;
    });
  }

  void _removeItem(int index) {
    final removed = _prescriptionItems[index];
    setState(() {
      _prescriptionItems.removeAt(index);
      if (_prescriptionItems.isEmpty) {
        _currentStep = 1;
        _selectedMedicine = null;
        _searchController.clear();
        _editingIndex = null;
      }
    });
    if (!_prescriptionItems.any((item) => item.name.toLowerCase() == removed.name.toLowerCase())) {
      _prescribedHistorySession.removeWhere(
        (name) => name.toLowerCase() == removed.name.toLowerCase(),
      );
    }
    if (_prescriptionItems.isEmpty) {
      _prescribedHistorySession.clear();
    }
    _prescribedItemsSession = List<PrescriptionItem>.from(_prescriptionItems);
    _lastPrescribedMedicineSession =
        _prescriptionItems.isNotEmpty ? _prescriptionItems.first.name : null;
    final summary = _prescriptionItems.map((e) => e.displayName).join(', ');
    widget.onMedicineSelected?.call(summary);
  }

  void _sendToDispensing() {
    final summary = _prescriptionItems.map((e) => e.displayName).join(', ');
    _lastPrescribedMedicineSession =
        _prescriptionItems.isNotEmpty ? _prescriptionItems.first.name : null;
    _prescribedItemsSession = List<PrescriptionItem>.from(_prescriptionItems);
    widget.onMedicineSelected?.call(summary);

    final targetContext = widget.parentContext ??
        Get.overlayContext ??
        Get.context;

    if (targetContext != null && targetContext.mounted) {
      Navigator.of(context).pop();
      showSentToDispensingDialog(targetContext);
    } else {
      showSentToDispensingDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patient?.name ?? 'John Smith';
    final folderNumber = widget.patient?.fileNumber ?? 'SWC-10427';
    final initials = patientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TabletHeader(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginDesktop,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (_currentStep == 2) {
                        setState(() =>
                            _currentStep = _prescriptionItems.isNotEmpty ? 3 : 1);
                      } else if (_currentStep == 1 &&
                          _prescriptionItems.isNotEmpty) {
                        setState(() => _currentStep = 3);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusControl,
                    ),
                    child: Container(
                      width: Dimensions.touchTarget,
                      height: Dimensions.touchTarget,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: const Center(
                        child: Icon(
                          AppIcons.chevronLeft,
                          size: Dimensions.iconSize,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentStep == 3
                              ? 'Prescription'
                              : 'Add prescription',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.headingFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentStep == 3
                              ? 'Review before sending'
                              : (_currentStep == 1
                                  ? 'Step 1 of 2 · Find a medicine'
                                  : 'Step 2 of 2 · Prescription details'),
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginDesktop,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.isTabletLandscape(context)
                          ? double.infinity
                          : 720,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_currentStep == 3) ...[
                          _PrescriptionReviewView(
                            patient: widget.patient,
                            items: _prescriptionItems,
                            onEditItem: (index) => _editItem(index),
                            onRemoveItem: (index) => _removeItem(index),
                            onAddAnother: () {
                              setState(() {
                                _selectedMedicine = null;
                                _searchController.clear();
                                _editingIndex = null;
                                _currentStep = 1;
                              });
                            },
                            onPrint: () => AppNotice.info(
                              'Prescription',
                              'Printing draft prescription...',
                            ),
                          ),
                        ] else ...[
                          // Patient Capsule
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F5F3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initials.isEmpty ? 'JS' : initials,
                                    style: const TextStyle(
                                      color: AppColors.brandPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        patientName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '52 / Male · Folder #$folderNumber',
                                        style: const TextStyle(
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
                          const SizedBox(height: 20),

                          if (_currentStep == 1) ...[
                            // Search medicine section
                            const Text(
                              'Search medicine',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() {}),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  AppIcons.search,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(AppIcons.close, size: 16),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                hintText: 'Search Medicines',
                                hintStyle: const TextStyle(
                                  color: AppColors.textDisabled,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.borderDefault,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.brandPrimary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            _PrescriptionMedicineSearchResults(
                              query: _searchController.text,
                              selectedMedicine: _selectedMedicine,
                              previousMedicine: widget.previousMedicine ??
                                  _lastPrescribedMedicineSession,
                              previousMedicines: _prescribedHistorySession,
                              onSelect: (med) => _selectMedicineAndProceed(med),
                              onRepeat: (med) => _repeatMedicine(med),
                            ),
                          ] else ...[
                            _PrescriptionDetailsForm(
                              medicineNameController: _medicineNameController,
                              strengthController: _strengthController,
                              doseController: _doseController,
                              durationController: _durationController,
                              quantityController: _quantityController,
                              frequencyController: _frequencyController,
                              instructionsController: _instructionsController,
                              repeatPrevious: _repeatPrevious,
                              onRepeatPreviousChanged: (val) =>
                                  setState(() => _repeatPrevious = val),
                              isDesktop: false,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Sticky Bottom Actions (No bottom navigation bar below)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderDefault,
                    width: Dimensions.strokeDivider,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          if (_currentStep == 2) {
                            setState(() => _currentStep =
                                _prescriptionItems.isNotEmpty ? 3 : 1);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.borderDefault,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _currentStep == 2 ? 'Back' : 'Cancel',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            color: AppColors.brandPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentStep == 1) {
                            if (_selectedMedicine != null) {
                              _selectMedicineAndProceed(_selectedMedicine!);
                            } else {
                              AppNotice.unavailable(
                                'Add prescription',
                                'Page not available',
                              );
                            }
                          } else if (_currentStep == 2) {
                            _addOrUpdatePrescription();
                          } else {
                            _sendToDispensing();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _currentStep == 2
                              ? 'Add to Prescription'
                              : (_currentStep == 3
                                  ? 'Send to despensing'
                                  : 'Continue'),
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPrescriptionContent extends StatefulWidget {
  const _AddPrescriptionContent({
    this.parentContext,
    this.patient,
    this.previousMedicine,
    this.initialItems,
    this.onMedicineSelected,
    required this.onClose,
    this.isMobile = false,
  });

  final BuildContext? parentContext;
  final PatientRecord? patient;
  final String? previousMedicine;
  final List<PrescriptionItem>? initialItems;
  final ValueChanged<String>? onMedicineSelected;
  final VoidCallback onClose;
  final bool isMobile;

  @override
  State<_AddPrescriptionContent> createState() => _AddPrescriptionContentState();
}

class _AddPrescriptionContentState extends State<_AddPrescriptionContent> {
  final TextEditingController _searchController = TextEditingController();
  late final TextEditingController _medicineNameController;
  final TextEditingController _strengthController =
      TextEditingController(text: '1 g');
  final TextEditingController _doseController =
      TextEditingController(text: '1 tablet');
  final TextEditingController _durationController =
      TextEditingController(text: '30 days');
  final TextEditingController _quantityController =
      TextEditingController(text: '60 tablets');
  final TextEditingController _frequencyController =
      TextEditingController(text: 'Twice daily with meals');
  final TextEditingController _instructionsController =
      TextEditingController(text: 'Take with breakfast and supper.');

  String? _selectedMedicine;
  bool _repeatPrevious = false;
  int _currentStep = 1;
  int? _editingIndex;
  late final List<PrescriptionItem> _prescriptionItems;

  @override
  void initState() {
    super.initState();
    _prescriptionItems = widget.initialItems != null
        ? List<PrescriptionItem>.from(widget.initialItems!)
        : <PrescriptionItem>[];
    if (_prescriptionItems.isNotEmpty) {
      _currentStep = 3;
    }
    _medicineNameController =
        TextEditingController(text: widget.previousMedicine ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _medicineNameController.dispose();
    _strengthController.dispose();
    _doseController.dispose();
    _durationController.dispose();
    _quantityController.dispose();
    _frequencyController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _selectMedicineAndProceed(String medicine) {
    setState(() {
      _selectedMedicine = medicine;
      _medicineNameController.text = medicine;
      _repeatPrevious = false;
      _currentStep = 2;
    });
  }

  void _repeatMedicine(String medicine) {
    setState(() {
      _selectedMedicine = medicine;
      _medicineNameController.text = medicine;
      _repeatPrevious = true;
      if (medicine.toLowerCase().contains('paracetamol')) {
        _strengthController.text = '500 mg';
        _doseController.text = '2 tablets';
        _frequencyController.text = 'up to 4 times daily';
        _durationController.text = '5 days';
        _quantityController.text = '20';
        _instructionsController.text = 'Take after food for pain relief.';
      } else if (medicine.toLowerCase().contains('ibuprofen')) {
        _strengthController.text = '200 mg';
        _doseController.text = '1 tablet';
        _frequencyController.text = 'up to 3 times daily';
        _durationController.text = '5 days';
        _quantityController.text = '15';
        _instructionsController.text = 'Take with food or milk.';
      }
      _currentStep = 2;
    });
  }

  void _addOrUpdatePrescription() {
    final med = _medicineNameController.text.trim().isNotEmpty
        ? _medicineNameController.text.trim()
        : (_selectedMedicine ?? 'Prescription');

    final item = PrescriptionItem(
      name: med,
      strength: _strengthController.text.trim(),
      dose: _doseController.text.trim(),
      duration: _durationController.text.trim(),
      quantity: _quantityController.text.trim(),
      frequency: _frequencyController.text.trim(),
      instructions: _instructionsController.text.trim(),
      isRepeat: _repeatPrevious,
    );

    setState(() {
      if (_editingIndex != null && _editingIndex! < _prescriptionItems.length) {
        _prescriptionItems[_editingIndex!] = item;
        _editingIndex = null;
      } else {
        _prescriptionItems.add(item);
      }
      _currentStep = 3;
    });

    _lastPrescribedMedicineSession = item.name;
    _prescribedHistorySession.add(item.name);
    _prescribedItemsSession = List<PrescriptionItem>.from(_prescriptionItems);
    widget.onMedicineSelected?.call(item.displayName);
  }

  void _editItem(int index) {
    final item = _prescriptionItems[index];
    setState(() {
      _editingIndex = index;
      _selectedMedicine = item.name;
      _medicineNameController.text = item.name;
      _strengthController.text = item.strength;
      _doseController.text = item.dose;
      _durationController.text = item.duration;
      _quantityController.text = item.quantity;
      _frequencyController.text = item.frequency;
      _instructionsController.text = item.instructions;
      _repeatPrevious = item.isRepeat;
      _currentStep = 2;
    });
  }

  void _removeItem(int index) {
    final removed = _prescriptionItems[index];
    setState(() {
      _prescriptionItems.removeAt(index);
      if (_prescriptionItems.isEmpty) {
        _currentStep = 1;
        _selectedMedicine = null;
        _searchController.clear();
        _editingIndex = null;
      }
    });
    if (!_prescriptionItems.any((item) => item.name.toLowerCase() == removed.name.toLowerCase())) {
      _prescribedHistorySession.removeWhere(
        (name) => name.toLowerCase() == removed.name.toLowerCase(),
      );
    }
    if (_prescriptionItems.isEmpty) {
      _prescribedHistorySession.clear();
    }
    _prescribedItemsSession = List<PrescriptionItem>.from(_prescriptionItems);
    _lastPrescribedMedicineSession =
        _prescriptionItems.isNotEmpty ? _prescriptionItems.first.name : null;
    final summary = _prescriptionItems.map((e) => e.displayName).join(', ');
    widget.onMedicineSelected?.call(summary);
  }

  void _sendToDispensing() {
    final summary = _prescriptionItems.map((e) => e.displayName).join(', ');
    _lastPrescribedMedicineSession =
        _prescriptionItems.isNotEmpty ? _prescriptionItems.first.name : null;
    _prescribedItemsSession = List<PrescriptionItem>.from(_prescriptionItems);
    widget.onMedicineSelected?.call(summary);

    final targetContext = widget.parentContext ??
        Get.overlayContext ??
        Get.context;

    if (targetContext != null && targetContext.mounted) {
      widget.onClose();
      showSentToDispensingDialog(targetContext);
    } else {
      showSentToDispensingDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patient?.name ?? 'John Smith';
    final folderNumber = widget.patient?.fileNumber ?? 'SWC-10427';
    final initials = patientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Column(
      children: [
        // Header matching mockup
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentStep == 2 ||
                  (_currentStep == 1 && _prescriptionItems.isNotEmpty)) ...[
                IconButton(
                  tooltip: 'Back',
                  icon: const Icon(
                    AppIcons.chevronLeft,
                    size: Dimensions.iconSize,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStep = _prescriptionItems.isNotEmpty ? 3 : 1;
                    });
                  },
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentStep == 3 ? 'Prescription' : 'Add prescription',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentStep == 3
                          ? 'Review before sending'
                          : (_currentStep == 1
                              ? 'Step 1 of 2 · Find a medicine'
                              : 'Step 2 of 2 · Prescription details'),
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(
                  AppIcons.close,
                  size: Dimensions.iconSize,
                  color: AppColors.textSecondary,
                ),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderDefault),

        // Scrollable Body
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_currentStep == 3) ...[
                _PrescriptionReviewView(
                  patient: widget.patient,
                  items: _prescriptionItems,
                  onEditItem: (index) => _editItem(index),
                  onRemoveItem: (index) => _removeItem(index),
                  onAddAnother: () {
                    setState(() {
                      _selectedMedicine = null;
                      _searchController.clear();
                      _editingIndex = null;
                      _currentStep = 1;
                    });
                  },
                  onPrint: () => AppNotice.info(
                    'Prescription',
                    'Printing draft prescription...',
                  ),
                ),
              ] else ...[
                // Patient capsule
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F5F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials.isEmpty ? 'JS' : initials,
                          style: const TextStyle(
                            color: AppColors.brandPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              patientName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '52 / Male · Folder #$folderNumber',
                              style: const TextStyle(
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
                const SizedBox(height: 20),

                if (_currentStep == 1) ...[
                  // Search medicine section
                  const Text(
                    'Search medicine',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        AppIcons.search,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(AppIcons.close, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      hintText: 'Search Medicines',
                      hintStyle: const TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.borderDefault),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.brandPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  _PrescriptionMedicineSearchResults(
                    query: _searchController.text,
                    selectedMedicine: _selectedMedicine,
                    previousMedicine: widget.previousMedicine ??
                        _lastPrescribedMedicineSession,
                    previousMedicines: _prescribedHistorySession,
                    onSelect: (med) => _selectMedicineAndProceed(med),
                    onRepeat: (med) => _repeatMedicine(med),
                  ),
                ] else ...[
                  _PrescriptionDetailsForm(
                    medicineNameController: _medicineNameController,
                    strengthController: _strengthController,
                    doseController: _doseController,
                    durationController: _durationController,
                    quantityController: _quantityController,
                    frequencyController: _frequencyController,
                    instructionsController: _instructionsController,
                    repeatPrevious: _repeatPrevious,
                    onRepeatPreviousChanged: (val) =>
                        setState(() => _repeatPrevious = val),
                    isDesktop: !widget.isMobile,
                  ),
                ],
              ],
            ],
          ),
        ),

        // Sticky Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.borderDefault,
                width: Dimensions.strokeDivider,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      if (_currentStep == 2) {
                        setState(() => _currentStep =
                            _prescriptionItems.isNotEmpty ? 3 : 1);
                      } else {
                        widget.onClose();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Back' : 'Cancel',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep == 1) {
                        if (_selectedMedicine != null) {
                          _selectMedicineAndProceed(_selectedMedicine!);
                        } else {
                          AppNotice.unavailable(
                            'Add prescription',
                            'Page not available',
                          );
                        }
                      } else if (_currentStep == 2) {
                        _addOrUpdatePrescription();
                      } else {
                        _sendToDispensing();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2
                          ? 'Add to Prescription'
                          : (_currentStep == 3
                              ? 'Send to despensing'
                              : 'Continue'),
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Responsive launcher for "Sign off consultation" confirmation workflow:
/// - Desktop (>= 1200): Slide drawer from right with scrim over consultation
/// - Tablet (600..1199): Dedicated white page with header, back button, no bottom nav bar
/// - Mobile (< 600): Modal bottom sheet with scrim over consultation
void showSignOffView(
  BuildContext context, {
  PatientRecord? patient,
  required VoidCallback onConfirm,
}) {
  if (ResponsiveHelper.isMobile(context)) {
    showSignOffBottomSheet(context, patient: patient, onConfirm: onConfirm);
  } else if (ResponsiveHelper.isTablet(context)) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (pageContext, animation, secondaryAnimation) =>
            SignOffTabletPage(patient: patient, onConfirm: onConfirm),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  } else {
    showSignOffDrawer(context, patient: patient, onConfirm: onConfirm);
  }
}

/// Desktop slide-in drawer for Sign Off confirmation
void showSignOffDrawer(
  BuildContext context, {
  PatientRecord? patient,
  required VoidCallback onConfirm,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x850F1F1D),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final screenWidth = MediaQuery.sizeOf(dialogContext).width;
      final drawerWidth = screenWidth < 768
          ? (screenWidth * 0.85).clamp(320.0, 420.0)
          : (screenWidth < 1100 ? 440.0 : 480.0);

      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: drawerWidth,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x260F1F1D),
                  blurRadius: 24,
                  offset: Offset(-4, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: _SignOffContent(
                patient: patient,
                isDesktop: true,
                onClose: () => Navigator.of(dialogContext).pop(),
                onConfirm: () {
                  Navigator.of(dialogContext).pop();
                  onConfirm();
                },
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim, secAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
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

/// Mobile bottom sheet for Sign Off confirmation
void showSignOffBottomSheet(
  BuildContext context, {
  PatientRecord? patient,
  required VoidCallback onConfirm,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x850F1F1D),
    showDragHandle: false,
    builder: (sheetContext) {
      final screenHeight = MediaQuery.sizeOf(sheetContext).height;
      return Container(
        height: screenHeight * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: _SignOffContent(
                  patient: patient,
                  isMobile: true,
                  onClose: () => Navigator.of(sheetContext).pop(),
                  onConfirm: () {
                    Navigator.of(sheetContext).pop();
                    onConfirm();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Tablet page for Sign Off confirmation without bottom nav bar
class SignOffTabletPage extends StatelessWidget {
  const SignOffTabletPage({
    super.key,
    this.patient,
    required this.onConfirm,
  });

  final PatientRecord? patient;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      route: AppRoutes.consultations,
      hideBottomNavigation: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                          border: Border.all(
                            color: AppColors.borderDefault,
                            width: Dimensions.strokeDivider,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          AppIcons.chevronLeft,
                          size: Dimensions.iconSize,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign off consultation',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Confirm to finalise the record',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderDefault),
            Expanded(
              child: _SignOffContent(
                patient: patient,
                isTabletPage: true,
                onClose: () => Navigator.of(context).pop(),
                onConfirm: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared form content for Sign Off confirmation across Desktop, Mobile, and Tablet
class _SignOffContent extends StatefulWidget {
  const _SignOffContent({
    this.patient,
    this.isMobile = false,
    this.isTabletPage = false,
    this.isDesktop = false,
    required this.onClose,
    required this.onConfirm,
  });

  final PatientRecord? patient;
  final bool isMobile;
  final bool isTabletPage;
  final bool isDesktop;
  final VoidCallback onClose;
  final VoidCallback onConfirm;

  @override
  State<_SignOffContent> createState() => _SignOffContentState();
}

class _SignOffContentState extends State<_SignOffContent> {
  bool _isConfirmed = true;

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patient?.name ?? 'John Smith';
    final folderNumber = widget.patient?.fileNumber ?? 'SWC-10427';
    final initials = patientName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Column(
      children: [
        if (!widget.isTabletPage) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign off consultation',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Confirm to finalise the record',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(
                    AppIcons.close,
                    size: Dimensions.iconSize,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
        ],
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Patient Capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials.isEmpty ? 'JS' : initials,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.headingFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '52 / Male · Folder #$folderNumber',
                            style: const TextStyle(
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
              const SizedBox(height: 14),

              // Warning Notice Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This record will be finalised',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'After sign-off the consultation is locked. Any corrections must be added as dated addenda; the original record is never changed.',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF78350F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Key-Values Table
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Column(
                  children: [
                    _SignOffMetaRow(
                      label: 'Diagnosis',
                      value: 'R51 · Headache (example code)',
                    ),
                    SizedBox(height: 14),
                    _SignOffMetaRow(
                      label: 'Prescription',
                      value: 'Rx-2026-10427-03 · Awaiting dispensing',
                    ),
                    SizedBox(height: 14),
                    _SignOffMetaRow(
                      label: 'Signed by',
                      value: 'Dr. Maya Naidoo · MP 0612345',
                    ),
                    SizedBox(height: 14),
                    _SignOffMetaRow(
                      label: 'Date & time',
                      value: '15 Oct 2026 · 12:05',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Checkbox Confirmation
              InkWell(
                onTap: () => setState(() => _isConfirmed = !_isConfirmed),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _isConfirmed,
                          activeColor: AppColors.brandPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() => _isConfirmed = val ?? false);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'I confirm this record is accurate and complete',
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderDefault),
        // Action Buttons at Bottom
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: widget.onClose,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.isDesktop ? 'Cancel / Return to review' : 'Cancel',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
                    onPressed: _isConfirmed ? widget.onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      disabledBackgroundColor:
                          AppColors.brandPrimary.withValues(alpha: 0.4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.isDesktop ? 'Confirm Sign Off' : 'Done',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignOffMetaRow extends StatelessWidget {
  const _SignOffMetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Displays the Consultation Completed confirmation view.
/// - Mobile: Bottom sheet
/// - Desktop / Tablet: Centered modal dialog
void showConsultationCompletedView(
  BuildContext context, {
  PatientRecord? patient,
  VoidCallback? onViewRecord,
  VoidCallback? onReturnToQueue,
}) {
  if (ResponsiveHelper.isMobile(context)) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x850F1F1D),
      builder: (sheetContext) => _ConsultationCompletedBottomSheet(
        patient: patient,
        onViewRecord: onViewRecord,
        onReturnToQueue: onReturnToQueue,
      ),
    );
  } else {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x850F1F1D),
      builder: (dialogContext) => _ConsultationCompletedDialog(
        patient: patient,
        onViewRecord: onViewRecord,
        onReturnToQueue: onReturnToQueue,
      ),
    );
  }
}

/// Desktop / Tablet centered modal dialog for completed consultation
class _ConsultationCompletedDialog extends StatelessWidget {
  const _ConsultationCompletedDialog({
    this.patient,
    this.onViewRecord,
    this.onReturnToQueue,
  });

  final PatientRecord? patient;
  final VoidCallback? onViewRecord;
  final VoidCallback? onReturnToQueue;

  @override
  Widget build(BuildContext context) {
    final patientName = (patient?.name != null && patient!.name.trim().isNotEmpty)
        ? patient!.name
        : 'John Smith';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      elevation: 0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F7F0),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF0F766E),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Consultation completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextStyles.headingFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'The consultation for $patientName was signed off at 12:05 on 15 Oct 2026.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onViewRecord?.call();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0F766E),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'View finalised record',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onReturnToQueue?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Return to Queue',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

/// Mobile modal bottom sheet for completed consultation
class _ConsultationCompletedBottomSheet extends StatelessWidget {
  const _ConsultationCompletedBottomSheet({
    this.patient,
    this.onViewRecord,
    this.onReturnToQueue,
  });

  final PatientRecord? patient;
  final VoidCallback? onViewRecord;
  final VoidCallback? onReturnToQueue;

  @override
  Widget build(BuildContext context) {
    final patientName = (patient?.name != null && patient!.name.trim().isNotEmpty)
        ? patient!.name
        : 'John Smith';

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderDefault,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F7F0),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              color: Color(0xFF0F766E),
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Consultation completed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.headingFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The consultation for $patientName was signed off at 12:05 on 15 Oct 2026.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onViewRecord?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0F766E), width: 1.2),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View Finalized Record',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onReturnToQueue?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Return to queue',
                    textAlign: TextAlign.center,
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
