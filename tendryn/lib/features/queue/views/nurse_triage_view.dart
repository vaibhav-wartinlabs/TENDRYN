import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/dashboard/widgets/queue_widgets.dart';
import 'package:tendryn/features/queue/controllers/nurse_patient_profile_controller.dart';
import 'package:tendryn/features/queue/controllers/record_sample_controller.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';
import 'package:tendryn/features/queue/views/record_sample_view.dart';
import 'package:tendryn/features/queue/views/nurse_patient_profile_view.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/status_pill.dart';

/// Opens the read-only "Triage · 12 Aug 2026" of a past visit (Figma: desktop 472px
/// drawer, phone bottom sheet, tablet full page).
void showNurseTriage(BuildContext context, TriageRecord record, {VoidCallback? onCallPatient}) {
  showNurseRecordPanel(
    context,
    title: record.title,
    subtitle: record.subtitle,
    body: _TriageBody(record: record),
    sheetFooter: (close) => _CancelButton(onPressed: close),
    openPage: () => Get.toNamed(AppRoutes.nurseTriageDetail, arguments: {'record': record}),
  );
}

/// Opens the read-only Consultations of a patient (Figma: desktop drawer, phone
/// sheet, tablet full page). Nothing is recorded yet, so it shows the empty state.
void showNurseConsultations(BuildContext context, PatientRecordRef record) =>
    _showEmptyRecord(context, record, _EmptyRecordKind.consultations);

/// Opens the read-only Prescriptions of a patient, presented like Consultations.
void showNursePrescriptions(BuildContext context, PatientRecordRef record) =>
    _showEmptyRecord(context, record, _EmptyRecordKind.prescriptions);

/// Opens the "Lab Referral Details" across platforms (desktop drawer, phone sheet,
/// tablet full page). In drawer and sheet modes, Record Sample switches the view
/// in-place inside the single panel, preventing stacked dialogs and double scrims.
void showNurseLabReferral(BuildContext context, LabReferralDetail detail) {
  if (ResponsiveHelper.usesDrawer(context)) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: AppColors.scrim,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: AppColors.backgroundSurface,
          elevation: 16,
          child: SizedBox(
            width: 472,
            height: double.infinity,
            child: _NurseLabReferralFlow(
              initialDetail: detail,
              onClose: () => Navigator.of(dialogContext).pop(),
              isDrawer: true,
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  } else if (ResponsiveHelper.isMobile(context)) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: AppColors.backgroundSurface,
      barrierColor: AppColors.scrim,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius))),
      builder: (sheetContext) => _NurseLabReferralFlow(
        initialDetail: detail,
        onClose: () => Navigator.of(sheetContext).pop(),
        isDrawer: false,
      ),
    );
  } else {
    Get.toNamed(AppRoutes.nurseLabReferral, arguments: {'detail': detail});
  }
}

enum _ReferralFlowStep { details, recordSample, resultDocument }

class _NurseLabReferralFlow extends StatefulWidget {
  const _NurseLabReferralFlow({
    required this.initialDetail,
    required this.onClose,
    required this.isDrawer,
  });

  final LabReferralDetail initialDetail;
  final VoidCallback onClose;
  final bool isDrawer;

  @override
  State<_NurseLabReferralFlow> createState() => _NurseLabReferralFlowState();
}

class _NurseLabReferralFlowState extends State<_NurseLabReferralFlow> {
  _ReferralFlowStep _step = _ReferralFlowStep.details;
  RecordSampleController? _sampleController;

  void _openRecordSample(LabReferralDetail detail) {
    Get.delete<RecordSampleController>(force: true);
    final c = Get.put(RecordSampleController(detail: detail));
    setState(() {
      _sampleController = c;
      _step = _ReferralFlowStep.recordSample;
    });
  }

  void _closeRecordSample() {
    Get.delete<RecordSampleController>(force: true);
    setState(() {
      _sampleController = null;
      _step = _ReferralFlowStep.details;
    });
  }

  void _openResultDocument() {
    setState(() {
      _step = _ReferralFlowStep.resultDocument;
    });
  }

  void _backToReferral() {
    if (Get.isRegistered<NursePatientProfileController>()) {
      final c = Get.find<NursePatientProfileController>();
      c.referrals.clear();
      c.selectTab(NurseProfileTab.labReferrals);
    }
    widget.onClose();
  }

  @override
  void dispose() {
    Get.delete<RecordSampleController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LabReferralDetail currentDetail = widget.initialDetail;
    if (Get.isRegistered<NursePatientProfileController>()) {
      final c = Get.find<NursePatientProfileController>();
      final r = c.referrals.firstWhereOrNull((ref) => ref.test == widget.initialDetail.referral.test);
      if (r != null) {
        currentDetail = LabReferralDetail(
          patientName: widget.initialDetail.patientName,
          patientId: widget.initialDetail.patientId,
          referral: r,
        );
      }
    }

    final isRecord = _step == _ReferralFlowStep.recordSample;
    final isResultDoc = _step == _ReferralFlowStep.resultDocument;

    final String title;
    final String subtitle;
    final Widget body;
    final Widget footer;
    final VoidCallback closeAction;

    if (isResultDoc) {
      title = 'Result Document';
      subtitle = '${currentDetail.patientName} · ${currentDetail.patientId}';
      body = _ResultDocumentBody(detail: currentDetail);
      footer = AppButton.secondary(
        label: 'Back to Referral',
        onPressed: _backToReferral,
        expand: true,
      );
      closeAction = _backToReferral;
    } else if (isRecord) {
      title = 'Record Sample';
      subtitle = currentDetail.subtitle;
      body = RecordSampleForm(controller: _sampleController!);
      footer = RecordSampleFooter(
        controller: _sampleController!,
        onCancel: _closeRecordSample,
      );
      closeAction = _closeRecordSample;
    } else {
      title = currentDetail.title;
      subtitle = currentDetail.subtitle;
      body = _LabReferralBody(
        detail: currentDetail,
        onViewResults: _openResultDocument,
      );
      footer = _CloseAndRecord(
        detail: currentDetail,
        onClose: widget.onClose,
        height: widget.isDrawer ? 40 : 48,
        onRecordSample: () => _openRecordSample(currentDetail),
        onViewResults: _openResultDocument,
      );
      closeAction = widget.onClose;
    }

    if (widget.isDrawer) {
      return _RecordDrawer(
        title: title,
        subtitle: subtitle,
        body: body,
        footer: footer,
        onClose: closeAction,
      );
    } else {
      return _RecordSheet(
        title: title,
        subtitle: subtitle,
        titleSize: 20,
        body: body,
        footer: footer,
        onClose: closeAction,
      );
    }
  }
}

/// The two read-only record views that share one layout and differ in their copy.
enum _EmptyRecordKind {
  consultations(
    title: 'Consultations',
    emptyTitle: 'No consultations recorded for this patient',
    message: 'Consultation notes are added by the doctor and are read only for nurses.',
    route: AppRoutes.nurseConsultations,
  ),
  prescriptions(
    title: 'Prescriptions',
    emptyTitle: 'No prescriptions recorded for this patient',
    message: 'Prescriptions are issued by the doctor and are read only for nurses.',
    route: AppRoutes.nursePrescriptions,
    sheetMessageSize: 13, // Figma's phone sheet sets this message at 13px
  );

  const _EmptyRecordKind({
    required this.title,
    required this.emptyTitle,
    required this.message,
    required this.route,
    this.sheetMessageSize = 14,
  });

  final String title;
  final String emptyTitle;
  final String message;
  final String route;
  final double sheetMessageSize;
}

void _showEmptyRecord(BuildContext context, PatientRecordRef record, _EmptyRecordKind kind) {
  showNurseRecordPanel(
    context,
    title: kind.title,
    subtitle: record.subtitle,
    sheetTitleSize: 16,
    body: _RecordEmpty(kind: kind, messageSize: ResponsiveHelper.isMobile(context) ? kind.sheetMessageSize : 14),
    sheetFooter: (close) => _CloseButton(onPressed: close),
    openPage: () => Get.toNamed(kind.route, arguments: {'record': record}),
  );
}

/// Desktop drawer, phone sheet, or (tablet) [openPage], like the other Nurse read-only views.
void showNurseRecordPanel(
  BuildContext context, {
  required String title,
  required String subtitle,
  required Widget body,
  required Widget Function(VoidCallback close) sheetFooter,
  required VoidCallback openPage,
  double sheetTitleSize = 20,
  Widget Function(VoidCallback close)? drawerFooter,
  VoidCallback? onClosed,
}) {
  if (ResponsiveHelper.usesDrawer(context)) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: AppColors.scrim,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: AppColors.backgroundSurface,
          elevation: 16,
          child: SizedBox(
            width: 472,
            height: double.infinity,
            child: _RecordDrawer(
              title: title,
              subtitle: subtitle,
              body: body,
              footer: drawerFooter?.call(() => Navigator.of(dialogContext).pop()),
              onClose: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ).whenComplete(() => onClosed?.call());
  } else if (ResponsiveHelper.isMobile(context)) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: AppColors.backgroundSurface,
      barrierColor: AppColors.scrim,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius))),
      builder: (sheetContext) => _RecordSheet(
        title: title,
        subtitle: subtitle,
        titleSize: sheetTitleSize,
        body: body,
        footer: sheetFooter(() => Navigator.of(sheetContext).pop()),
        onClose: () => Navigator.of(sheetContext).pop(),
      ),
    ).whenComplete(() => onClosed?.call());
  } else {
    openPage();
  }
}

final TextStyle _sectionTitle =
    AppTextStyles.h3Mobile.copyWith(fontSize: 16, height: 24 / 16, color: AppColors.textPrimary);

/// Badges, presenting complaint, previous vitals and triage notes. Shared by the
/// drawer, the sheet and the tablet page; [vitalsInset] is the page's 22px indent.
class _TriageBody extends StatelessWidget {
  const _TriageBody({required this.record, this.vitalsInset = 0});

  final TriageRecord record;
  final double vitalsInset;

  @override
  Widget build(BuildContext context) {
    final vitals = record.vitals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Dimensions.spaceMd,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: Dimensions.spaceSm,
            runSpacing: Dimensions.spaceSm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const ProfileReadOnlyBadge(locked: true),
              StatusPill(color: QueueStyles.priorityDot(record.priority), label: record.priority.label),
            ],
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 8),
          decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(2)),
          child: Row(
            spacing: Dimensions.spaceMd,
            children: [
              Text('Presenting complaint', style: _sectionTitle),
              Expanded(
                child: Text(
                  record.complaint,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        Text('Vital signs (previous)', style: _sectionTitle),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: vitalsInset),
          child: Column(
            children: [
              for (final (i, v) in vitals.indexed)
                ProfileKeyValueRow(
                  label: v.label,
                  value: v.display,
                  divider: i < vitals.length - 1,
                  verticalPadding: 8,
                  labelRegular: true,
                  valueColor: AppColors.textSecondary,
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text('Triage notes', style: _sectionTitle),
            Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 14),
              alignment: Alignment.centerLeft,
              color: AppColors.backgroundApp,
              child: Text(record.notes, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Title and subtitle beside the close control.
class _RecordHeading extends StatelessWidget {
  const _RecordHeading({required this.title, required this.subtitle, this.titleSize = 20});

  final String title;
  final String subtitle;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final style = titleSize == 20
        ? AppTextStyles.h3
        : AppTextStyles.h3.copyWith(fontSize: titleSize, height: 24 / titleSize);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(title, style: style.copyWith(color: AppColors.textPrimary)),
        Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      AppButton.secondary(label: 'Close', onPressed: onPressed, expand: true);
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      AppButton.secondary(label: 'Cancel', onPressed: onPressed, expand: true);
}



/// Footer strip: 80px, top divider, 24px side padding.
class _FooterBar extends StatelessWidget {
  const _FooterBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceLg),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(top: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
      ),
      child: child,
    );
  }
}

class _RecordDrawer extends StatelessWidget {
  const _RecordDrawer({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.onClose,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget body;
  final VoidCallback onClose;

  /// Defaults to a full-width Close button.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 83),
          padding: const EdgeInsets.fromLTRB(Dimensions.spaceLg, 20, 20, 20),
          decoration: const BoxDecoration(
            color: AppColors.backgroundSurface,
            border: Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
          ),
          child: Row(
            spacing: Dimensions.spaceMd,
            children: [
              Expanded(child: _RecordHeading(title: title, subtitle: subtitle)),
              Semantics(
                button: true,
                label: 'Close',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    onTap: onClose,
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSurface,
                        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                        border: Border.all(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
                      ),
                      child: const Icon(AppIcons.close, size: 20, color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(padding: const EdgeInsets.all(Dimensions.spaceLg), child: body),
        ),
        _FooterBar(child: footer ?? _CloseButton(onPressed: onClose)),
      ],
    );
  }
}

class _RecordSheet extends StatelessWidget {
  const _RecordSheet({
    required this.title,
    required this.subtitle,
    required this.titleSize,
    required this.body,
    required this.footer,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final double titleSize;
  final Widget body;
  final Widget footer;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.borderDefault, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: Dimensions.spaceMd),
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(child: _RecordHeading(title: title, subtitle: subtitle, titleSize: titleSize)),
                IconButton(
                  tooltip: 'Close',
                  onPressed: onClose,
                  constraints: const BoxConstraints.tightFor(width: Dimensions.touchTarget, height: Dimensions.touchTarget),
                  icon: const Icon(AppIcons.close, size: 22, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(padding: const EdgeInsets.all(Dimensions.spaceMd), child: body),
        ),
        _FooterBar(child: footer),
      ],
    );
  }
}

/// Tablet: a full page inside the shell with Queue selected. Back returns to the
/// patient profile underneath. [bottom] is the bar above the navigation.
class NurseRecordPage extends StatelessWidget {
  const NurseRecordPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bottom,
    this.titleStyle,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget body;
  final Widget bottom;

  /// Defaults to the 24px page title; the referral details use the 20px one.
  final TextStyle? titleStyle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginTablet, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.backgroundSurface,
            border: Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
          ),
          child: Row(
            spacing: 12,
            children: [
              Semantics(
                button: true,
                label: 'Back to patient profile',
                child: Material(
                  color: AppColors.backgroundSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    side: const BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    onTap: onBack ?? Get.back,
                    child: const SizedBox(
                      width: 52,
                      height: Dimensions.touchTarget,
                      child: Icon(AppIcons.chevronLeft, size: 24, color: AppColors.brandPrimary),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: (titleStyle ?? AppTextStyles.h2).copyWith(color: AppColors.textPrimary)),
                    Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginTablet, vertical: 24),
            child: body,
          ),
        ),
        bottom,
      ],
    );
  }
}

/// Tablet triage page: the triage with the Cancel bar.
class NurseTriagePage extends StatelessWidget {
  const NurseTriagePage({super.key, required this.record});

  final TriageRecord record;

  @override
  Widget build(BuildContext context) {
    return NurseRecordPage(
      title: record.title,
      subtitle: record.subtitle,
      body: _TriageBody(record: record, vitalsInset: 22),
      bottom: _FooterBar(child: _CancelButton(onPressed: Get.back)),
    );
  }
}

/// Tablet Consultations page: the empty state with a Close bar.
class NurseConsultationsPage extends StatelessWidget {
  const NurseConsultationsPage({super.key, required this.record});

  final PatientRecordRef record;

  @override
  Widget build(BuildContext context) => _EmptyRecordPage(kind: _EmptyRecordKind.consultations, record: record);
}

/// Tablet Prescriptions page: the same layout as Consultations.
class NursePrescriptionsPage extends StatelessWidget {
  const NursePrescriptionsPage({super.key, required this.record});

  final PatientRecordRef record;

  @override
  Widget build(BuildContext context) => _EmptyRecordPage(kind: _EmptyRecordKind.prescriptions, record: record);
}

class _EmptyRecordPage extends StatelessWidget {
  const _EmptyRecordPage({required this.kind, required this.record});

  final _EmptyRecordKind kind;
  final PatientRecordRef record;

  @override
  Widget build(BuildContext context) {
    return NurseRecordPage(
      title: kind.title,
      subtitle: record.subtitle,
      body: _RecordEmpty(kind: kind),
      bottom: _FooterBar(child: _CloseButton(onPressed: Get.back)),
    );
  }
}

/// The "none recorded for this patient" panel: brand tint with a file icon.
class _RecordEmpty extends StatelessWidget {
  const _RecordEmpty({required this.kind, this.messageSize = 14});

  final _EmptyRecordKind kind;
  final double messageSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceLg, vertical: 48),
      color: AppColors.brandTint,
      child: Column(
        spacing: 7,
        children: [
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(24)),
            child: const Icon(AppIcons.file, size: 78, color: AppColors.brandPrimary),
          ),
          Column(
            spacing: 5,
            children: [
              Text(kind.emptyTitle, textAlign: TextAlign.center, style: _sectionTitle),
              Text(
                kind.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: messageSize),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Close and Record Sample side by side.
class _CloseAndRecord extends StatelessWidget {
  const _CloseAndRecord({
    required this.detail,
    required this.onClose,
    this.height,
    this.onRecordSample,
    this.onViewResults,
  });

  final LabReferralDetail detail;
  final VoidCallback onClose;
  final double? height;
  final VoidCallback? onRecordSample;
  final VoidCallback? onViewResults;

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<NursePatientProfileController>()) {
      final controller = Get.find<NursePatientProfileController>();
      return Obx(() {
        final r = controller.referrals.firstWhereOrNull((ref) => ref.test == detail.referral.test) ?? detail.referral;
        final currentDetail = LabReferralDetail(
          patientName: detail.patientName,
          patientId: detail.patientId,
          referral: r,
        );
        return _buildButtons(context, currentDetail);
      });
    }
    return _buildButtons(context, detail);
  }

  Widget _buildButtons(BuildContext context, LabReferralDetail currentDetail) {
    final hasResult = currentDetail.referral.status == LabReferralStatus.resultReceived;
    return Row(
      spacing: 12,
      children: [
        Expanded(child: AppButton.secondary(label: 'Close', onPressed: onClose, expand: true)),
        Expanded(
          child: hasResult
              ? AppButton.primary(
                  onPressed: onViewResults ?? _resultUnavailable,
                  label: 'View Results',
                  expand: true,
                )
              : AppButton.primary(
                  onPressed: onRecordSample ?? () => showNurseRecordSample(context, currentDetail),
                  label: 'Record Sample',
                  expand: true,
                ),
        ),
      ],
    );
  }
}

/// Result documents are not available in the app yet (no results model or
/// endpoint), so opening one says so instead of showing an invented result.
void _resultUnavailable() =>
    AppNotice.unavailable('Result document', 'Lab results are not available yet.');

/// The six referral facts on a brand-tint panel: patient, test, date, requester, status.
class _ReferralDetailsPanel extends StatelessWidget {
  const _ReferralDetailsPanel({required this.detail, this.horizontalPadding = 14});

  final LabReferralDetail detail;

  /// 14px in the Requested design, 17px in the Result Received one.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final r = detail.referral;
    final rows = <(String, Widget)>[
      ('Patient Name', _value(detail.patientName)),
      ('Patient ID', _value(detail.patientId)),
      ('Requested Test', _value(r.test)),
      ('Referral Date', _value(r.date)),
      ('Requesting Practitioner', _value(r.requestedBy)),
      ('Referral Status', ProfileReferralStatusPill(status: r.status, fontSize: 12)),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      color: AppColors.brandTint,
      child: Column(
        children: [
          for (final (i, row) in rows.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: i < rows.length - 1
                    ? const Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider))
                    : null,
              ),
              child: Row(
                spacing: Dimensions.spaceMd,
                children: [
                  Expanded(child: Text(row.$1, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
                  Flexible(child: row.$2),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _value(String text) => Text(
        text,
        textAlign: TextAlign.end,
        style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
      );
}

/// Tablet Lab Referral Details page: switches in-place to Result Document when viewing results.
class NurseLabReferralPage extends StatefulWidget {
  const NurseLabReferralPage({super.key, required this.detail});

  final LabReferralDetail detail;

  @override
  State<NurseLabReferralPage> createState() => _NurseLabReferralPageState();
}

class _NurseLabReferralPageState extends State<NurseLabReferralPage> {
  bool _showResultDocument = false;

  void _openResultDocument() {
    setState(() {
      _showResultDocument = true;
    });
  }

  void _backToReferral() {
    if (Get.isRegistered<NursePatientProfileController>()) {
      final c = Get.find<NursePatientProfileController>();
      c.referrals.clear();
      c.selectTab(NurseProfileTab.labReferrals);
    }
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.nursePatientProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    LabReferralDetail currentDetail = widget.detail;
    if (Get.isRegistered<NursePatientProfileController>()) {
      final c = Get.find<NursePatientProfileController>();
      final r = c.referrals.firstWhereOrNull((ref) => ref.test == widget.detail.referral.test);
      if (r != null) {
        currentDetail = LabReferralDetail(
          patientName: widget.detail.patientName,
          patientId: widget.detail.patientId,
          referral: r,
        );
      }
    }

    if (_showResultDocument) {
      return NurseRecordPage(
        title: 'Result Document',
        subtitle: '${currentDetail.patientName} · ${currentDetail.patientId}',
        titleStyle: AppTextStyles.h3,
        onBack: _backToReferral,
        body: _ResultDocumentBody(detail: currentDetail),
        bottom: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginTablet),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.backgroundSurface,
            border: Border(top: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
          ),
          child: AppButton.secondary(
            label: 'Back to Referral',
            onPressed: _backToReferral,
            expand: true,
          ),
        ),
      );
    }

    return NurseRecordPage(
      title: currentDetail.title,
      subtitle: currentDetail.subtitle,
      titleStyle: AppTextStyles.h3,
      body: _LabReferralBody(
        detail: currentDetail,
        onViewResults: _openResultDocument,
      ),
      bottom: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginTablet),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.backgroundSurface,
          border: Border(top: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
        ),
        child: _CloseAndRecord(
          detail: currentDetail,
          onClose: Get.back,
          height: 48,
          onViewResults: _openResultDocument,
        ),
      ),
    );
  }
}

/// The four referral facts above the Record Sample form (13px, brand-tint panel).
class ReferralContextPanel extends StatelessWidget {
  const ReferralContextPanel({super.key, required this.detail});

  final LabReferralDetail detail;

  @override
  Widget build(BuildContext context) {
    final r = detail.referral;
    final rows = [
      ('Patient Name', detail.patientName),
      ('Patient ID', detail.patientId),
      ('Requested Test', r.test),
      ('Referral Date', r.date),
    ];
    final label = AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary);
    final value = AppTextStyles.label.copyWith(color: AppColors.textPrimary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: AppColors.brandTint,
      child: Column(
        children: [
          for (final (i, row) in rows.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: i < rows.length - 1
                    ? const Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider))
                    : null,
              ),
              child: Row(
                spacing: Dimensions.spaceMd,
                children: [
                  Expanded(child: Text(row.$1, style: label)),
                  Flexible(child: Text(row.$2, textAlign: TextAlign.end, style: value)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Lab Referral Details body. A referral with a result also shows the Read only
/// badge and the "Result document" link (Figma: Result Received variant).
class _LabReferralBody extends StatelessWidget {
  const _LabReferralBody({
    required this.detail,
    this.onViewResults,
  });

  final LabReferralDetail detail;
  final VoidCallback? onViewResults;

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<NursePatientProfileController>()) {
      final controller = Get.find<NursePatientProfileController>();
      return Obx(() {
        final r = controller.referrals.firstWhereOrNull((ref) => ref.test == detail.referral.test) ?? detail.referral;
        final currentDetail = LabReferralDetail(
          patientName: detail.patientName,
          patientId: detail.patientId,
          referral: r,
        );
        return _buildBody(currentDetail);
      });
    }
    return _buildBody(detail);
  }

  Widget _buildBody(LabReferralDetail detail) {
    final hasResult = detail.referral.status == LabReferralStatus.resultReceived;
    if (!hasResult) return _ReferralDetailsPanel(detail: detail);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Dimensions.spaceMd,
      children: [
        const Align(alignment: Alignment.centerLeft, child: ProfileReadOnlyBadge(locked: true)),
        _ReferralDetailsPanel(detail: detail, horizontalPadding: 17),
        _ResultDocumentDropdown(
          label: '${detail.referral.test} result',
          onTap: onViewResults,
        ),
      ],
    );
  }
}

/// "Result document" as an expandable dropdown. It starts open, as in Figma, and
/// the heading toggles the document row.
class _ResultDocumentDropdown extends StatelessWidget {
  const _ResultDocumentDropdown({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textSecondary,
        title: Text('Result document', style: _sectionTitle),
        children: [_ResultDocumentLink(label: label, onTap: onTap)],
      ),
    );
  }
}

/// The linked result document: file icon, brand-coloured name and an up-right arrow.
class _ResultDocumentLink extends StatelessWidget {
  const _ResultDocumentLink({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        onTap: onTap ?? _resultUnavailable,
        child: Container(
          padding: const EdgeInsets.all(Dimensions.spaceMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
          ),
          child: Row(
            spacing: 12,
            children: [
              const Icon(AppIcons.fileText, size: 24, color: AppColors.brandPrimary),
              Expanded(child: Text(label, style: AppTextStyles.label.copyWith(color: AppColors.brandPrimary))),
              const Icon(AppIcons.arrowUpRight, size: 16, color: AppColors.brandPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Result Document view body (Figma: Result Document screen across mobile, tablet, desktop).
/// Displays test name with Read-only badge, referral date, and a placeholder card
/// indicating that the document preview is unavailable.
class _ResultDocumentBody extends StatelessWidget {
  const _ResultDocumentBody({required this.detail});

  final LabReferralDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                detail.referral.test,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const ProfileReadOnlyBadge(locked: true),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Referral · ${detail.referral.date}',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: Dimensions.spaceLg),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
          ),
          padding: const EdgeInsets.all(Dimensions.spaceMd),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceLg, vertical: 48),
            decoration: BoxDecoration(
              color: AppColors.brandTint,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(AppIcons.file, size: 56, color: AppColors.brandPrimary),
                const SizedBox(height: 16),
                Text(
                  'Document preview unavailable',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The source result document was not supplied. No report content is available to preview.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
