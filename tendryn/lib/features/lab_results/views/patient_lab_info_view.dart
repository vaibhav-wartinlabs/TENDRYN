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
import 'package:tendryn/features/lab_results/views/lab_result_details_view.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';

/// Opens the full-page Patient Lab Information view inside [AppShell] with
/// bottom navigation hidden on mobile & tablet.
void openPatientLabInfoPage(
  BuildContext context, {
  required LabReferralModel referral,
  String activeSidebarRoute = AppRoutes.labReferral,
  String backLabel = 'Back to lab referral',
  bool preferResultState = false,
}) {
  Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      settings: const RouteSettings(name: AppRoutes.patientLabInfo),
      pageBuilder: (ctx, animation, secondaryAnimation) => AppShell(
        route: activeSidebarRoute,
        hideBottomNavigation: true,
        hideMobileHeader: true,
        child: PatientLabInfoView(
          referral: referral,
          backLabel: backLabel,
          preferResultState: preferResultState,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

class PatientLabInfoView extends StatelessWidget {
  const PatientLabInfoView({
    super.key,
    this.referral,
    this.onClose,
    this.backLabel = 'Back to lab referral',
    this.preferResultState = false,
  });

  final LabReferralModel? referral;
  final VoidCallback? onClose;
  final String backLabel;
  final bool preferResultState;

  LabReferralModel _resolveInitialReferral() {
    if (referral != null) return referral!;
    final args = Get.arguments;
    if (args is LabReferralModel) return args;
    if (args is Map<String, dynamic> && args['referral'] is LabReferralModel) {
      return args['referral'] as LabReferralModel;
    }
    if (Get.isRegistered<LabReferralController>()) {
      final ctrl = LabReferralController.to;
      if (ctrl.referrals.isNotEmpty) return ctrl.referrals.first;
      if (ctrl.labStaffResults.isNotEmpty) return ctrl.labStaffResults.first;
    }
    return const LabReferralModel(
      id: 'ref-1',
      patientName: 'John Smith',
      folderNumber: 'TND-000124',
      testsRequested: 'Full Blood Count',
      referralDate: '31 Oct 2026',
      requestedBy: 'Dr Thandi Nkosi',
      queueNumber: 'Q-001',
      status: LabReferralStatus.awaitingResult,
      collectionDate: '31 Oct 2026',
      collectionTime: '10:15',
      sampleRecordedBy: 'Lerato Mokoena (Lab Staff)',
    );
  }

  VoidCallback _resolveOnClose(BuildContext context) {
    if (onClose != null) return onClose!;
    return () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        return;
      }
      final hasLabReferral = Get.routeTree.routes.any(
        (r) => r.name == AppRoutes.labReferral,
      );
      if (hasLabReferral) {
        AppNavigation.goTo(AppRoutes.labReferral);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final initial = _resolveInitialReferral();
    final handleClose = _resolveOnClose(context);

    if (Get.isRegistered<LabReferralController>()) {
      return Obx(() {
        final live = LabReferralController.to.resolveReferral(
          initial,
          preferResultState: preferResultState,
        );
        return _PatientLabInfoContent(
          referral: live,
          backLabel: backLabel,
          preferResultState: preferResultState,
          onClose: handleClose,
        );
      });
    }

    return _PatientLabInfoContent(
      referral: initial,
      backLabel: backLabel,
      preferResultState: preferResultState,
      onClose: handleClose,
    );
  }
}

class _PatientLabInfoContent extends StatelessWidget {
  const _PatientLabInfoContent({
    required this.referral,
    required this.onClose,
    required this.backLabel,
    required this.preferResultState,
  });

  final LabReferralModel referral;
  final VoidCallback onClose;
  final String backLabel;
  final bool preferResultState;

  List<LabReferralModel> _buildReferralHistory() {
    final historical = LabReferralModel(
      id: '${referral.id}-hist-0017',
      patientName: referral.patientName,
      folderNumber: referral.folderNumber,
      testsRequested: 'Urea & Electrolytes',
      referralDate: '12 Aug 2026',
      requestedBy: 'Dr Thandi Nkosi',
      status: LabReferralStatus.resultReceived,
      collectionDate: '12 Aug 2026',
      collectionTime: '09:30',
      sampleRecordedBy: 'Sister Naledi Naidoo (Nurse)',
      sampleNotes: 'Sample collected during previous consultation.',
      referralReference: 'LR-0017',
    );
    return [referral, historical];
  }

  List<_SampleTrackingEntry> _buildSampleTrackingEntries(
    List<LabReferralModel> referrals,
  ) {
    final entries = <_SampleTrackingEntry>[];
    final current = referrals.first;
    final hasSample = current.status != LabReferralStatus.requested ||
        current.collectionDate != null;
    if (hasSample) {
      final date = current.collectionDate ?? '31 Oct 2026';
      final time = current.collectionTime ?? '10:15';
      entries.add(
        _SampleTrackingEntry(
          reference: current.referenceNumber,
          test: current.testsRequested,
          collected: '$date, $time',
          recordedBy: current.sampleRecordedBy ?? 'Lerato Mokoena (Lab Staff)',
          status: LabReferralStatus.sampleTaken,
        ),
      );
    }

    final historical = referrals[1];
    entries.add(
      _SampleTrackingEntry(
        reference: historical.referenceNumber,
        test: historical.testsRequested,
        collected: '${historical.collectionDate}, ${historical.collectionTime}',
        recordedBy: historical.sampleRecordedBy ?? 'Sister Naledi Naidoo (Nurse)',
        status: LabReferralStatus.sampleTaken,
      ),
    );
    return entries;
  }

  List<_UploadedResultEntry> _buildUploadedResults(
    List<LabReferralModel> history,
  ) {
    final current = history.first;
    final historical = history.last;
    final entries = <_UploadedResultEntry>[];

    if (current.status == LabReferralStatus.resultReceived ||
        (current.uploadedDocumentName != null &&
            current.uploadedDocumentName!.isNotEmpty)) {
      entries.add(
        _UploadedResultEntry(
          referral: current,
          reference: current.referenceNumber,
          test: current.testsRequested,
          document: current.effectiveDocumentName,
          receivedAt: current.resultReceivedAt ?? '${current.referralDate}, 14:30',
        ),
      );
    }

    entries.add(
      _UploadedResultEntry(
        referral: historical,
        reference: historical.referenceNumber,
        test: historical.testsRequested,
        document: historical.effectiveDocumentName,
        receivedAt: '13 Aug 2026, 11:05',
      ),
    );
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final referralHistory = _buildReferralHistory();
    final sampleTracking = _buildSampleTrackingEntries(referralHistory);
    final uploadedResults = _buildUploadedResults(referralHistory);

    if (ResponsiveHelper.isDesktop(context)) {
      return _buildDesktopLayout(
        context,
        referralHistory: referralHistory,
        sampleTracking: sampleTracking,
        uploadedResults: uploadedResults,
      );
    } else if (ResponsiveHelper.isTablet(context)) {
      return _buildTabletLayout(
        context,
        referralHistory: referralHistory,
        sampleTracking: sampleTracking,
        uploadedResults: uploadedResults,
      );
    } else {
      return _buildMobileLayout(
        context,
        referralHistory: referralHistory,
        sampleTracking: sampleTracking,
        uploadedResults: uploadedResults,
      );
    }
  }

  // ── Desktop Layout ─────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(
    BuildContext context, {
    required List<LabReferralModel> referralHistory,
    required List<_SampleTrackingEntry> sampleTracking,
    required List<_UploadedResultEntry> uploadedResults,
  }) {
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
            _DesktopBackPill(onTap: onClose, label: backLabel),
            const SizedBox(height: 16),
            Text(
              'Patient Lab Information',
              style: AppTextStyles.h2.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Lab referrals, sample tracking and uploaded results for this patient.',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _buildPatientBannerCard(isMobile: false),
            const SizedBox(height: 14),
            _buildReadOnlyNotice(),
            const SizedBox(height: 20),

            // 1. Lab referrals table card
            _buildDesktopSectionCard(
              title: 'Lab referrals',
              trailingCaption: 'Lab history for this patient',
              headers: const [
                _TableColumn('Referral', 2),
                _TableColumn('Test', 3),
                _TableColumn('Requested By', 3),
                _TableColumn('Referral Date', 2),
                _TableColumn('Status', 2),
                _TableColumn('Action', 0, fixedWidth: 88, alignEnd: true),
              ],
              rows: referralHistory.map((item) {
                return [
                  _cellText(item.referenceNumber),
                  _cellText(item.testsRequested),
                  _cellText(item.requestedBy),
                  _cellText(item.referralDate),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LabReferralStatusPill(status: item.status),
                  ),
                  _buildViewDetailsLink(
                    onTap: () => openLabReferralDetailsPage(
                      context,
                      referral: item,
                      preferResultState: preferResultState && item.id == referral.id,
                    ),
                  ),
                ];
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 2. Sample tracking table card
            _buildDesktopSectionCard(
              title: 'Sample tracking',
              headers: const [
                _TableColumn('Referral', 2),
                _TableColumn('Test', 3),
                _TableColumn('Collected', 3),
                _TableColumn('Recorded By', 4),
                _TableColumn('Status', 2),
              ],
              rows: sampleTracking.map((entry) {
                return [
                  _cellText(entry.reference),
                  _cellText(entry.test),
                  _cellText(entry.collected),
                  _cellText(entry.recordedBy),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LabReferralStatusPill(status: entry.status),
                  ),
                ];
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 3. Uploaded results table card
            _buildDesktopSectionCard(
              title: 'Uploaded results',
              headers: const [
                _TableColumn('Referral', 2),
                _TableColumn('Test', 3),
                _TableColumn('Document', 4),
                _TableColumn('Result Received', 3),
                _TableColumn('Action', 0, fixedWidth: 88, alignEnd: true),
              ],
              rows: uploadedResults.map((res) {
                return [
                  _cellText(res.reference),
                  _cellText(res.test),
                  _cellText(res.document),
                  _cellText(res.receivedAt),
                  _buildViewDetailsLink(
                    onTap: () => openLabStaffResultDetailsPage(
                      context,
                      referral: res.referral,
                    ),
                  ),
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tablet Layout ──────────────────────────────────────────────────────────
  Widget _buildTabletLayout(
    BuildContext context, {
    required List<LabReferralModel> referralHistory,
    required List<_SampleTrackingEntry> sampleTracking,
    required List<_UploadedResultEntry> uploadedResults,
  }) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        top: false,
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
                        'Patient Lab Information',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lab referrals, sample tracking and uploaded results for this patient.',
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
            _buildPatientBannerCard(isMobile: false),
            const SizedBox(height: 14),
            _buildReadOnlyNotice(),
            const SizedBox(height: 20),
              ..._buildStackedCardSections(
                context,
                referralHistory: referralHistory,
                sampleTracking: sampleTracking,
                uploadedResults: uploadedResults,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mobile Layout ──────────────────────────────────────────────────────────
  Widget _buildMobileLayout(
    BuildContext context, {
    required List<LabReferralModel> referralHistory,
    required List<_SampleTrackingEntry> sampleTracking,
    required List<_UploadedResultEntry> uploadedResults,
  }) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: Column(
        children: [
          // Top Header with Boxed Back Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    'Patient Lab Information',
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

          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lab referrals, sample tracking and uploaded results for this patient.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildPatientBannerCard(isMobile: true),
                    const SizedBox(height: 12),
                    _buildReadOnlyNotice(),
                    const SizedBox(height: 20),
                    ..._buildStackedCardSections(
                      context,
                      referralHistory: referralHistory,
                      sampleTracking: sampleTracking,
                      uploadedResults: uploadedResults,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared Stacked Sections (Mobile & Tablet) ──────────────────────────────
  List<Widget> _buildStackedCardSections(
    BuildContext context, {
    required List<LabReferralModel> referralHistory,
    required List<_SampleTrackingEntry> sampleTracking,
    required List<_UploadedResultEntry> uploadedResults,
  }) {
    return [
      _buildSectionHeader(
        title: 'Lab referrals',
        trailingCaption: 'Lab history for this patient',
      ),
      const SizedBox(height: 12),
      ...referralHistory.map(
        (item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildKeyValueCard([
            _KeyValueItem('Referral', item.referenceNumber),
            _KeyValueItem('Test', item.testsRequested),
            _KeyValueItem('Requested By', item.requestedBy),
            _KeyValueItem('Referral Date', item.referralDate),
            _KeyValueItem(
              'Status',
              LabReferralStatusPill(status: item.status),
            ),
            _KeyValueItem(
              'Action',
              _buildViewDetailsLink(
                onTap: () => openLabReferralDetailsPage(
                  context,
                  referral: item,
                  preferResultState: preferResultState && item.id == referral.id,
                ),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 12),

      _buildSectionHeader(title: 'Sample tracking'),
      const SizedBox(height: 12),
      ...sampleTracking.map(
        (entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildKeyValueCard([
            _KeyValueItem('Referral', entry.reference),
            _KeyValueItem('Test', entry.test),
            _KeyValueItem('Collected', entry.collected),
            _KeyValueItem('Recorded By', entry.recordedBy),
            _KeyValueItem(
              'Status',
              LabReferralStatusPill(status: entry.status),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 12),

      _buildSectionHeader(title: 'Uploaded results'),
      const SizedBox(height: 12),
      ...uploadedResults.map(
        (res) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildKeyValueCard([
            _KeyValueItem('Referral', res.reference),
            _KeyValueItem('Test', res.test),
            _KeyValueItem('Document', res.document),
            _KeyValueItem('Result Received', res.receivedAt),
            _KeyValueItem(
              'Action',
              _buildViewDetailsLink(
                onTap: () => openLabStaffResultDetailsPage(
                  context,
                  referral: res.referral,
                ),
              ),
            ),
          ]),
        ),
      ),
    ];
  }

  // ── Shared UI Primitives ───────────────────────────────────────────────────
  Widget _buildPatientBannerCard({required bool isMobile}) {
    final initials = _getInitials(referral.patientName);

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
                Text(
                  referral.patientName,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${referral.folderNumber} · Male · 42 yrs',
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
        ],
      ),
    );
  }

  Widget _buildReadOnlyNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color: Color(0xFF4F46E5),
          ),
          SizedBox(width: 10),
          Expanded(
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
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? trailingCaption,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailingCaption != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              trailingCaption,
              textAlign: TextAlign.end,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopSectionCard({
    required String title,
    String? trailingCaption,
    required List<_TableColumn> headers,
    required List<List<Widget>> rows,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
            child: _buildSectionHeader(
              title: title,
              trailingCaption: trailingCaption,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            child: Row(
              children: headers.map((col) {
                final child = Text(
                  col.label,
                  textAlign: col.alignEnd ? TextAlign.end : TextAlign.start,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                );
                if (col.fixedWidth != null) {
                  return SizedBox(width: col.fixedWidth, child: child);
                }
                return Expanded(flex: col.flex, child: child);
              }).toList(),
            ),
          ),
          ...List.generate(rows.length, (rowIndex) {
            final cells = rows[rowIndex];
            final isLast = rowIndex == rows.length - 1;
            return Container(
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: isLast
                  ? null
                  : const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                    ),
              child: Row(
                children: List.generate(headers.length, (colIndex) {
                  final col = headers[colIndex];
                  final cell = cells[colIndex];
                  if (col.fixedWidth != null) {
                    return SizedBox(
                      width: col.fixedWidth,
                      child: Align(
                        alignment: col.alignEnd
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: cell,
                      ),
                    );
                  }
                  return Expanded(flex: col.flex, child: cell);
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildKeyValueCard(List<_KeyValueItem> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: item.value is Widget
                            ? item.value as Widget
                            : Text(
                                item.value.toString(),
                                textAlign: TextAlign.end,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }

  Widget _cellText(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.body.copyWith(
          fontSize: 13.5,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildViewDetailsLink({required VoidCallback onTap}) {
    return Semantics(
      button: true,
      label: 'View Details',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              'View Details',
              style: AppTextStyles.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'PT';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(1, 2))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _TableColumn {
  const _TableColumn(
    this.label,
    this.flex, {
    this.fixedWidth,
    this.alignEnd = false,
  });

  final String label;
  final int flex;
  final double? fixedWidth;
  final bool alignEnd;
}

class _KeyValueItem {
  const _KeyValueItem(this.label, this.value);

  final String label;
  final dynamic value;
}

class _SampleTrackingEntry {
  const _SampleTrackingEntry({
    required this.reference,
    required this.test,
    required this.collected,
    required this.recordedBy,
    required this.status,
  });

  final String reference;
  final String test;
  final String collected;
  final String recordedBy;
  final LabReferralStatus status;
}

class _UploadedResultEntry {
  const _UploadedResultEntry({
    required this.referral,
    required this.reference,
    required this.test,
    required this.document,
    required this.receivedAt,
  });

  final LabReferralModel referral;
  final String reference;
  final String test;
  final String document;
  final String receivedAt;
}

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

class _DesktopBackPill extends StatelessWidget {
  const _DesktopBackPill({
    required this.onTap,
    this.label = 'Back to lab referral',
  });

  final VoidCallback onTap;
  final String label;

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
                label,
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
