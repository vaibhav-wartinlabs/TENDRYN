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
import 'package:tendryn/features/lab_results/widgets/lab_result_drawer.dart';
import 'package:tendryn/features/lab_results/widgets/lab_result_status_pill.dart';
import 'package:tendryn/widgets/common/app_action_menu.dart';

class LabResultsView extends StatefulWidget {
  const LabResultsView({super.key});

  @override
  State<LabResultsView> createState() => _LabResultsViewState();
}

class _LabResultsViewState extends State<LabResultsView> {
  late final LabResultsController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<LabResultsController>()) {
      controller = Get.find<LabResultsController>();
      if (controller.referrals.isEmpty) {
        controller.referrals.assignAll(LabResultsController.defaultReferrals);
      }
    } else {
      controller = Get.put(LabResultsController());
    }
  }

  // =======================================================================
  // EMPTY STATE TOGGLE (No lab results yet for Desktop, Tablet, & Mobile):
  // Set [hasNoLabResults = true] to preview the "No lab results yet" screen.
  // When `false` (default), normal populated view with records is shown.
  // =======================================================================
  bool hasNoLabResults = false; // Set to true to preview empty state

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<RoleController>() &&
        RoleController.to.currentRole.value == ClinicRole.labStaff) {
      return const _LabStaffResultView();
    }

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = isDesktop
        ? Dimensions.pageMarginDesktop
        : isTablet
            ? Dimensions.pageMarginTablet
            : Dimensions.pageMarginMobile;

    return Obx(() {
      final isReferralsTab = controller.selectedTab.value == 1;

      return Scaffold(
        backgroundColor: AppColors.backgroundApp,
        bottomNavigationBar: (isMobile && isReferralsTab)
            ? _buildMobileCreateReferralStickyBottom(context)
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: Dimensions.pageSectionGap,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                _buildPageHeader(context),
                const SizedBox(height: 18),

                // Segmented Tab Bar: Lab Results vs Lab Referrals
                _buildSegmentedTabs(),
                const SizedBox(height: 20),

                // Search & Filter Toolbar
                _buildSearchAndFilterBar(context),
                const SizedBox(height: 20),

                // Empty state vs Normal populated view:
                if (hasNoLabResults)
                  (isDesktop
                      ? _buildDesktopEmptyState(context)
                      : _buildMobileTabletEmptyState(context))
                else if (isReferralsTab)
                  (isDesktop
                      ? _buildDesktopLabReferralsCard(context)
                      : _buildMobileAndTabletReferralsContent(context))
                else
                  (isDesktop
                      ? _buildDesktopLabResultsCard(context)
                      : _buildMobileAndTabletContent(context)),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPageHeader(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isReferralsTab = controller.selectedTab.value == 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lab Results',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Review patient test results and track lab referrals.',
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (!isMobile && isReferralsTab) ...[
          const SizedBox(width: 16),
          _buildCreateReferralButton(context),
        ],
      ],
    );
  }

  Widget _buildCreateReferralButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => controller.onCreateReferral(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
      ),
      child: const Text(
        'Create Lab Referral',
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMobileCreateReferralStickyBottom(BuildContext context) {
    return Container(
      color: AppColors.backgroundApp,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => controller.onCreateReferral(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
          ),
          child: const Text(
            'Create Lab Referral',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Obx(() {
      final active = controller.selectedTab.value;
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFEDF6F5),
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _TabPill(
                title: 'Lab Results',
                isActive: active == 0,
                onTap: () => controller.setTab(0),
              ),
            ),
            Expanded(
              child: _TabPill(
                title: 'Lab Referrals',
                isActive: active == 1,
                onTap: () => controller.setTab(1),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchAndFilterBar(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return Row(
      children: [
        // Search Input Field
        Expanded(
          child: Container(
            height: Dimensions.buttonMinHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: isMobile
                    ? 'Search by patient name, folder no.'
                    : 'Search by patient name, folder number or test',
                hintStyle: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  color: AppColors.textDisabled,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  AppIcons.search,
                  size: 18,
                  color: AppColors.textDisabled,
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(
                      AppIcons.close,
                      size: Dimensions.iconSize,
                      color: AppColors.textDisabled,
                    ),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.onSearchChanged('');
                    },
                  );
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Filter button
        PopupMenuButton<String>(
          tooltip: 'Filter records',
          onSelected: controller.setFilter,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            side: const BorderSide(color: AppColors.borderDefault),
          ),
          color: Colors.white,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'All',
              child: Text('All statuses'),
            ),
            const PopupMenuItem(
              value: 'Awaiting review',
              child: Text('Awaiting review'),
            ),
            const PopupMenuItem(
              value: 'Reviewed',
              child: Text('Reviewed'),
            ),
          ],
          child: Container(
            width: Dimensions.buttonMinHeight,
            height: Dimensions.buttonMinHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: const Icon(
              AppIcons.filter,
              size: Dimensions.iconSize,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Empty State Views (Desktop, Tablet, Mobile) ───────────────────────────
  Widget _buildDesktopEmptyState(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header: Title & Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All lab results',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.filteredResults.length} results',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _buildEmptyStateCardContent(context),
        ],
      ),
    );
  }

  Widget _buildMobileTabletEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header (Outside card)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'All lab results',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Text(
                '${controller.filteredResults.length} results',
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: _buildEmptyStateCardContent(context),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCardContent(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _NoLabResultsIllustration(),
          const SizedBox(height: 18),
          const Text(
            'No lab results yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: const Text(
              'Results from the laboratory will appear here once they are received. Track requested tests under Lab Referrals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: isMobile ? double.infinity : 240,
            height: Dimensions.buttonMinHeight,
            child: OutlinedButton(
              onPressed: () => controller.setTab(1),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandPrimary,
                side: const BorderSide(color: AppColors.borderDefault),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'View Lab Referrals',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile & Tablet Cards Content ─────────────────────────────────────────
  Widget _buildMobileAndTabletContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'All lab results',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Text(
                '${controller.filteredResults.length} results',
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Cards List / Grid
        Obx(() {
          final paged = controller.pagedResults;
          if (paged.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radius),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                children: [
                  const Icon(
                    AppIcons.labResults,
                    size: 40,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No lab results found',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTabletGrid = constraints.maxWidth >= 600;

              if (isTabletGrid) {
                final itemWidth = (constraints.maxWidth - 16) / 2;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final record in paged)
                          SizedBox(
                            width: itemWidth,
                            child: _buildLabResultCard(context, record),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTabletPagination(),
                  ],
                );
              }

              // Mobile single-column list
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < paged.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _buildLabResultCard(context, paged[i]),
                  ],
                  const SizedBox(height: 20),
                  _buildMobilePagination(),
                ],
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildLabResultCard(BuildContext context, LabResultModel record) {
    final folderNo = record.folderNumber.startsWith('#')
        ? record.folderNumber
        : '#${record.folderNumber}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.onViewDetail(record),
          borderRadius: BorderRadius.circular(Dimensions.radius),
          hoverColor: AppColors.brandTint.withValues(alpha: 0.35),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Patient Name + Status Pill on left, 3-Dots with box surrounding on right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              record.patientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.bodyFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          LabResultStatusPill(status: record.status),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _LabActionMenu(
                      record: record,
                      onViewDetails: () => controller.onViewDetail(record),
                      onRecordReview: () => controller.onRecordReview(record),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Middle Row: Folder Number & Result received date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Folder Number',
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            folderNo,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.bodyFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Result received date',
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            record.resultReceivedDate,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.bodyFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Bottom Row: Test Name
                Text(
                  record.testName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobilePagination() {
    return Obx(() {
      final start =
          (controller.currentPage.value - 1) * controller.itemsPerPage + 1;
      final end = (start + controller.pagedResults.length - 1)
          .clamp(0, controller.filteredResults.length);
      final total = controller.filteredResults.length;
      final text = total == 0
          ? 'Showing 0 consultations'
          : 'Showing $start–$end of $total consultations';
      final canPrev = controller.currentPage.value > 1;
      final canNext = controller.currentPage.value < controller.totalPages;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: canPrev ? controller.previousPage : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      disabledForegroundColor: AppColors.textDisabled,
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusControl),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: canNext ? controller.nextPage : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: canNext
                          ? AppColors.brandPrimary
                          : AppColors.textDisabled,
                      disabledForegroundColor: AppColors.textDisabled,
                      side: BorderSide(
                        color: canNext
                            ? AppColors.brandPrimary
                            : AppColors.borderDefault,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusControl),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildTabletPagination() {
    return Obx(() {
      final start =
          (controller.currentPage.value - 1) * controller.itemsPerPage + 1;
      final end = (start + controller.pagedResults.length - 1)
          .clamp(0, controller.filteredResults.length);
      final total = controller.filteredResults.length;
      final text = total == 0
          ? 'Showing 0 consultations'
          : 'Showing $start–$end of $total consultations';
      final canPrev = controller.currentPage.value > 1;
      final canNext = controller.currentPage.value < controller.totalPages;
      final current = controller.currentPage.value;
      final totalPages = controller.totalPages;
      final pagesCount = totalPages > 1 ? totalPages : 2;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              // Previous
              SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: canPrev ? controller.previousPage : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textDisabled,
                    side: const BorderSide(color: AppColors.borderDefault),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Previous',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Page Pills
              for (int p = 1; p <= pagesCount; p++) ...[
                InkWell(
                  onTap: p <= totalPages ? () => controller.goToPage(p) : null,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusControl),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p == current
                          ? AppColors.brandPrimary
                          : const Color(0xFF165C54),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                    ),
                    child: Text(
                      '$p',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Next
              SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: canNext ? controller.nextPage : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: canNext
                        ? AppColors.brandPrimary
                        : AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textDisabled,
                    side: BorderSide(
                      color: canNext
                          ? AppColors.brandPrimary
                          : AppColors.borderDefault,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  // ── Mobile & Tablet Referrals Content ──────────────────────────────────────
  Widget _buildMobileAndTabletReferralsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'All lab referrals',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Text(
                '${controller.filteredReferrals.length} referrals',
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Referrals Cards List / Grid
        Obx(() {
          final paged = controller.pagedReferrals;
          if (paged.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radius),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                children: [
                  const Icon(
                    AppIcons.labResults,
                    size: 40,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No lab referrals found',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTabletGrid = constraints.maxWidth >= 600;

              if (isTabletGrid) {
                final itemWidth = (constraints.maxWidth - 16) / 2;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final referral in paged)
                          SizedBox(
                            width: itemWidth,
                            child: _buildReferralCard(context, referral),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTabletReferralPagination(),
                  ],
                );
              }

              // Mobile single-column list
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < paged.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _buildReferralCard(context, paged[i]),
                  ],
                  const SizedBox(height: 20),
                  _buildMobileReferralPagination(),
                ],
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildReferralCard(BuildContext context, LabReferralModel referral) {
    final folderNo = referral.folderNumber.startsWith('#')
        ? referral.folderNumber
        : '#${referral.folderNumber}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Patient Name & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  referral.patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              LabReferralStatusPill(status: referral.status),
            ],
          ),
          const SizedBox(height: 12),

          // Middle Row: Folder Number & Referral Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Folder Number',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      folderNo,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Referral Date',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      referral.referralDate,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bottom Row: Tests Requested (left) & "View Referral" link (right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  referral.testsRequested,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => controller.onViewReferral(context, referral),
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileReferralPagination() {
    return Obx(() {
      final start =
          (controller.currentPage.value - 1) * controller.itemsPerPage + 1;
      final end = (start + controller.pagedReferrals.length - 1)
          .clamp(0, controller.filteredReferrals.length);
      final total = controller.filteredReferrals.length;
      final text = total == 0
          ? 'Showing 0 referrals'
          : 'Showing $start–$end of $total referrals';
      final canPrev = controller.currentPage.value > 1;
      final canNext =
          controller.currentPage.value < controller.totalReferralPages;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: canPrev ? controller.previousPage : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      disabledForegroundColor: AppColors.textDisabled,
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusControl),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: canNext ? controller.nextPage : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: canNext
                          ? AppColors.brandPrimary
                          : AppColors.textDisabled,
                      disabledForegroundColor: AppColors.textDisabled,
                      side: BorderSide(
                        color: canNext
                            ? AppColors.brandPrimary
                            : AppColors.borderDefault,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusControl),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildTabletReferralPagination() {
    return Obx(() {
      final start =
          (controller.currentPage.value - 1) * controller.itemsPerPage + 1;
      final end = (start + controller.pagedReferrals.length - 1)
          .clamp(0, controller.filteredReferrals.length);
      final total = controller.filteredReferrals.length;
      final text = total == 0
          ? 'Showing 0 referrals'
          : 'Showing $start–$end of $total referrals';
      final canPrev = controller.currentPage.value > 1;
      final canNext =
          controller.currentPage.value < controller.totalReferralPages;
      final current = controller.currentPage.value;
      final totalPages = controller.totalReferralPages;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: canPrev ? controller.previousPage : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  disabledForegroundColor: AppColors.textDisabled,
                  side: const BorderSide(color: AppColors.borderDefault),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusControl),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: const Text('Previous'),
              ),
              const SizedBox(width: 8),
              for (int p = 1; p <= totalPages; p++) ...[
                if (p > 1) const SizedBox(width: 8),
                InkWell(
                  onTap: () => controller.goToPage(p),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusControl),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p == current
                          ? AppColors.brandPrimary
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                      border: p == current
                          ? null
                          : Border.all(color: AppColors.borderDefault),
                    ),
                    child: Text(
                      '$p',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color:
                            p == current ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: canNext ? controller.nextPage : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  disabledForegroundColor: AppColors.textDisabled,
                  side: const BorderSide(color: AppColors.borderDefault),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusControl),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      );
    });
  }

  // ── Desktop Table Card ────────────────────────────────────────────────────
  Widget _buildDesktopLabResultsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header: Title & Total Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All lab results',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Obx(() => Text(
                      '${controller.filteredResults.length} results',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    )),
              ],
            ),
          ),

          // Table Content
          Obx(() {
            final paged = controller.pagedResults;
            if (paged.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(
                      AppIcons.labResults,
                      size: 40,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No lab results found',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                const minTableWidth = 720.0;
                final needsHorizontalScroll = constraints.maxWidth < minTableWidth;

                final tableWidget = Column(
                  children: [
                    _buildTableHeader(),
                    for (final record in paged) _buildTableRow(context, record),
                  ],
                );

                if (needsHorizontalScroll) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: minTableWidth,
                      child: tableWidget,
                    ),
                  );
                }

                return tableWidget;
              },
            );
          }),

          // Pagination Footer
          _buildPaginationFooter(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: Dimensions.tableHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundApp,
        border: Border(
          top: BorderSide(color: AppColors.borderDefault, width: 1),
          bottom: BorderSide(color: AppColors.borderDefault, width: 1),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Patient Name',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Test / Investigation',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Result Received Date',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Review Status',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: Dimensions.touchTarget,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Action',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, LabResultModel record) {
    return InkWell(
      onTap: () => controller.onViewDetail(record),
      hoverColor: AppColors.brandTint.withValues(alpha: 0.35),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
        ),
        child: Row(
          children: [
            // Patient Name & Folder Number
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    record.patientName,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Folder #${record.folderNumber}',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Test / Investigation
            Expanded(
              flex: 3,
              child: Text(
                record.testName,
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Result Received Date
            Expanded(
              flex: 3,
              child: Text(
                record.resultReceivedDate,
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Review Status
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: LabResultStatusPill(status: record.status),
              ),
            ),

            // Action (3-Dots menu)
            SizedBox(
              width: Dimensions.touchTarget,
              child: Align(
                alignment: Alignment.centerRight,
                child: _LabActionMenu(
                  record: record,
                  onViewDetails: () => controller.onViewDetail(record),
                  onRecordReview: () => controller.onRecordReview(record),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final start = (controller.currentPage.value - 1) * controller.itemsPerPage + 1;
            final end = (start + controller.pagedResults.length - 1).clamp(0, controller.filteredResults.length);
            final total = controller.filteredResults.length;
            final text = total == 0 ? 'Showing 0 of 0 results' : 'Showing $start–$end of $total results';

            return Text(
              text,
              style: AppTextStyles.caption.copyWith(
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
            );
          }),

          // Pagination Buttons
          Obx(() {
            final canPrev = controller.currentPage.value > 1;
            final canNext = controller.currentPage.value < controller.totalPages;

            return Row(
              children: [
                // Previous Button
                OutlinedButton(
                  onPressed: canPrev ? controller.previousPage : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textDisabled,
                    side: const BorderSide(color: AppColors.borderDefault),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),

                // Current Page Pill (active page "1")
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  ),
                  child: Text(
                    '${controller.currentPage.value}',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Next Button
                OutlinedButton(
                  onPressed: canNext ? controller.nextPage : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textDisabled,
                    side: const BorderSide(color: AppColors.borderDefault),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
  // ── Desktop Referrals Card ────────────────────────────────────────────────
  Widget _buildDesktopLabReferralsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header: Title & Total Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All lab referrals',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.filteredReferrals.length} referrals',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Content
          Obx(() {
            final paged = controller.pagedReferrals;
            if (paged.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(
                      AppIcons.labResults,
                      size: 40,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No lab referrals found',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                const minTableWidth = 720.0;
                final needsHorizontalScroll =
                    constraints.maxWidth < minTableWidth;

                final tableWidget = Column(
                  children: [
                    _buildDesktopReferralHeaderRow(),
                    for (final referral in paged)
                      _buildDesktopReferralRow(referral),
                  ],
                );

                if (needsHorizontalScroll) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: minTableWidth,
                      child: tableWidget,
                    ),
                  );
                }

                return tableWidget;
              },
            );
          }),

          // Pagination Footer
          _buildDesktopReferralPagination(),
        ],
      ),
    );
  }

  Widget _buildDesktopReferralHeaderRow() {
    return Container(
      height: Dimensions.tableHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundApp,
        border: Border(
          top: BorderSide(color: AppColors.borderDefault, width: 1),
          bottom: BorderSide(color: AppColors.borderDefault, width: 1),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Patient Name',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Tests Requested',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Referral Date',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Referral Status',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Action',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopReferralRow(LabReferralModel referral) {
    final folderNo = referral.folderNumber.startsWith('#')
        ? referral.folderNumber
        : '#${referral.folderNumber}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          // Patient Name & Folder Number
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                  folderNo,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Tests Requested
          Expanded(
            flex: 3,
            child: Text(
              referral.testsRequested,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Referral Date
          Expanded(
            flex: 2,
            child: Text(
              referral.referralDate,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Referral Status
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: LabReferralStatusPill(status: referral.status),
            ),
          ),

          // Action
          SizedBox(
            width: 110,
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => controller.onViewReferral(context, referral),
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    'View Referral',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
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

  Widget _buildDesktopReferralPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final start =
                (controller.currentPage.value - 1) * controller.itemsPerPage + 1;
            final end = (start + controller.pagedReferrals.length - 1)
                .clamp(0, controller.filteredReferrals.length);
            final total = controller.filteredReferrals.length;
            final text = total == 0
                ? 'Showing 0 referrals'
                : 'Showing $start–$end of $total referrals';

            return Text(
              text,
              style: AppTextStyles.caption.copyWith(
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
            );
          }),

          // Pagination Buttons
          Obx(() {
            final canPrev = controller.currentPage.value > 1;
            final canNext =
                controller.currentPage.value < controller.totalReferralPages;

            return Row(
              children: [
                OutlinedButton(
                  onPressed: canPrev ? controller.previousPage : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textDisabled,
                    side: const BorderSide(color: AppColors.borderDefault),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusControl),
                  ),
                  child: Text(
                    '${controller.currentPage.value}',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: canNext ? controller.nextPage : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    disabledForegroundColor: AppColors.textDisabled,
                    side: const BorderSide(color: AppColors.borderDefault),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusControl),
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusControl - 2),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl - 2),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.brandPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _LabActionMenu extends StatefulWidget {
  const _LabActionMenu({
    required this.record,
    required this.onViewDetails,
    required this.onRecordReview,
  });

  final LabResultModel record;
  final VoidCallback onViewDetails;
  final VoidCallback onRecordReview;

  @override
  State<_LabActionMenu> createState() => _LabActionMenuState();
}

class _LabActionMenuState extends State<_LabActionMenu> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: Color(0x1F000000),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Actions',
        elevation: 6,
        shadowColor: const Color(0x1F000000),
        surfaceTintColor: Colors.transparent,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 196),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        onSelected: (val) {
          if (val == 'view_details') {
            widget.onViewDetails();
          } else if (val == 'record_review') {
            widget.onRecordReview();
          }
        },
        itemBuilder: (context) => [
          const AppActionMenuItem<String>(
            value: 'view_details',
            label: 'View details',
            alignment: Alignment.center,
          ),
          const AppActionMenuItem<String>(
            value: 'record_review',
            label: 'Record review',
            alignment: Alignment.center,
          ),
        ],
        child: const AppActionsBoxButton(icon: AppIcons.rowMenu),
      ),
    );
  }
}

class _NoLabResultsIllustration extends StatelessWidget {
  const _NoLabResultsIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 120,
      height: 96,
      child: CustomPaint(
        painter: _NoLabResultsPainter(),
      ),
    );
  }
}

class _NoLabResultsPainter extends CustomPainter {
  const _NoLabResultsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft Mint Background Circle
    final bgPaint = Paint()
      ..color = const Color(0xFFE8F6F3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.54, size.height * 0.50), 38, bgPaint);

    // Decorative dots / plus around circle
    final decoPaint = Paint()
      ..color = const Color(0xFF81C3B6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Tiny plus symbol at top left of background
    canvas.drawLine(const Offset(22, 28), const Offset(28, 28), decoPaint);
    canvas.drawLine(const Offset(25, 25), const Offset(25, 31), decoPaint);

    // Small circle dot at right
    final dotPaint = Paint()
      ..color = const Color(0xFF81C3B6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(98, 48), 2.5, dotPaint);

    // 2. Document
    final docRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(50, 16, 46, 58),
      const Radius.circular(6),
    );
    final docBgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(docRect, docBgPaint);

    final docBorderPaint = Paint()
      ..color = const Color(0xFF81C3B6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(docRect, docBorderPaint);

    // Document lines
    final linePaint = Paint()
      ..color = const Color(0xFFBCE3DC)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(58, 30), const Offset(76, 30), linePaint);
    canvas.drawLine(const Offset(58, 38), const Offset(84, 38), linePaint);
    canvas.drawLine(const Offset(58, 46), const Offset(80, 46), linePaint);
    canvas.drawLine(const Offset(58, 54), const Offset(74, 54), linePaint);

    // Plus symbol on document
    final plusPaint = Paint()
      ..color = const Color(0xFF81C3B6)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(84, 50), const Offset(88, 50), plusPaint);
    canvas.drawLine(const Offset(86, 48), const Offset(86, 52), plusPaint);

    // 3. Test Tube
    canvas.save();
    canvas.translate(36, 44);
    canvas.rotate(-0.18); // slight tilt

    // Tube Body
    final tubeRect = RRect.fromRectAndCorners(
      const Rect.fromLTWH(-8, -20, 16, 42),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );

    // Tube background fill
    final tubeBgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(tubeRect, tubeBgPaint);

    // Liquid fill (bottom half)
    final liquidRect = RRect.fromRectAndCorners(
      const Rect.fromLTWH(-8, -2, 16, 24),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    final liquidPaint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(liquidRect, liquidPaint);

    // Tube border
    final tubeBorderPaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(tubeRect, tubeBorderPaint);

    // Tube lip / rim
    final rimRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-10, -23, 20, 4),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      rimRect,
      Paint()
        ..color = const Color(0xFF0F766E)
        ..style = PaintingStyle.fill,
    );

    // Measurement tick marks
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(-4, 4), const Offset(0, 4), tickPaint);
    canvas.drawLine(const Offset(-4, 10), const Offset(2, 10), tickPaint);
    canvas.drawLine(const Offset(-4, 16), const Offset(0, 16), tickPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// Lab Staff Result Screen (Desktop Table, Tablet & Mobile Card Stack)
// ============================================================================
class _LabStaffResultView extends StatefulWidget {
  const _LabStaffResultView();

  @override
  State<_LabStaffResultView> createState() => _LabStaffResultViewState();
}

class _LabStaffResultViewState extends State<_LabStaffResultView> {
  late final LabReferralController controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<LabReferralController>()) {
      controller = Get.find<LabReferralController>();
    } else {
      controller = Get.put(LabReferralController());
    }
    _searchController = TextEditingController(
      text: controller.resultSearchQuery.value,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    controller.clearResultSearch();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final horizontalPadding = isDesktop
        ? Dimensions.pageMarginDesktop
        : isTablet
            ? Dimensions.pageMarginTablet
            : Dimensions.pageMarginMobile;

    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: Dimensions.pageSectionGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Result',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload and manage laboratory result documents.',
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              _buildSearchAndFilterBar(context),
              const SizedBox(height: 20),
              if (isDesktop)
                _buildDesktopTableCard(context)
              else
                _buildCardStackSection(context, isTablet: isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: Dimensions.buttonMinHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: controller.onResultSearchChanged,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Search name, ID or queue number',
                hintStyle: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  color: AppColors.textDisabled,
                ),
                prefixIcon: Icon(
                  AppIcons.search,
                  size: Dimensions.iconSize,
                  color: AppColors.textDisabled,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.componentGap),
        Container(
          width: Dimensions.buttonMinHeight,
          height: Dimensions.buttonMinHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: IconButton(
            icon: const Icon(
              AppIcons.filter,
              size: 18,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Filter',
            onPressed: () => _showFilterDialog(context),
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    const filterOptions = ['All', 'Awaiting Result', 'Result Received'];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter Results by Status'),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: filterOptions.map((option) {
              final isSelected = controller.resultSelectedFilter.value == option;
              return ListTile(
                title: Text(option),
                leading: Icon(
                  isSelected ? AppIcons.check : Icons.circle_outlined,
                  size: 18,
                  color: isSelected
                      ? AppColors.brandPrimary
                      : AppColors.textDisabled,
                ),
                onTap: () {
                  controller.onResultFilterChanged(option);
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCountsCaption({required double fontSize}) {
    return Obx(
      () => Text(
        '${controller.awaitingResultCount} awaiting result · ${controller.resultReceivedCount} result received',
        textAlign: TextAlign.end,
        style: AppTextStyles.caption.copyWith(
          fontSize: fontSize,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ── Desktop Table Card ─────────────────────────────────────────────────────
  Widget _buildDesktopTableCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lab results',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(child: _buildCountsCaption(fontSize: 13.5)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDefault),
          _buildDesktopTableHeader(),
          Obx(() {
            final paged = controller.pagedLabStaffResults;
            if (paged.isEmpty) {
              return _buildEmptySearchState(isDesktop: true);
            }
            return Column(
              children: [
                ...paged.map(_buildDesktopTableRow),
                const Divider(height: 1, color: AppColors.borderDefault),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: _buildNumericPagination(),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDesktopTableHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              'Patient Name',
              style: AppTextStyles.label.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Test Name',
              style: AppTextStyles.label.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Referral Date',
              style: AppTextStyles.label.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Result Status',
              style: AppTextStyles.label.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Center(
              child: Text(
                'Action',
                style: AppTextStyles.label.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTableRow(LabReferralModel item) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.patientName,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.folderNumber,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              item.testsRequested,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.referralDate,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: LabReferralStatusPill(status: item.status),
            ),
          ),
          SizedBox(
            width: 64,
            child: Center(child: _buildActionDotsButton(item)),
          ),
        ],
      ),
    );
  }

  // ── Mobile & Tablet Stacked Card Layout ────────────────────────────────────
  Widget _buildCardStackSection(
    BuildContext context, {
    required bool isTablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Lab results',
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _buildCountsCaption(fontSize: isTablet ? 13 : 12),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 14),
        Obx(() {
          final paged = controller.pagedLabStaffResults;
          if (paged.isEmpty) {
            return _buildEmptySearchState(isDesktop: false);
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paged.length,
            separatorBuilder: (_, _) => SizedBox(height: isTablet ? 14 : 12),
            itemBuilder: (context, index) => _buildResultCard(paged[index]),
          );
        }),
      ],
    );
  }

  Widget _buildResultCard(LabReferralModel item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.patientName,
                            style: AppTextStyles.label.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        LabReferralStatusPill(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.folderNumber,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildActionDotsButton(item),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Name',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.testsRequested,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referral Date',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.referralDate,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionDotsButton(LabReferralModel item) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: Color(0x1F000000),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Actions',
        position: PopupMenuPosition.under,
        offset: const Offset(0, 4),
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 6,
        shadowColor: const Color(0x1F000000),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        constraints: const BoxConstraints.tightFor(width: 196),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        onSelected: (val) {
          if (val == 'upload_lab_results') {
            showUploadLabResultPanel(context, referral: item);
          } else if (val == 'view_details') {
            openLabStaffResultDetailsPage(context, referral: item);
          }
        },
        itemBuilder: (context) => [
          if (item.status != LabReferralStatus.resultReceived)
            const AppActionMenuItem<String>(
              value: 'upload_lab_results',
              label: 'Upload Lab Results',
              alignment: Alignment.center,
            ),
          const AppActionMenuItem<String>(
            value: 'view_details',
            label: 'View Details',
            alignment: Alignment.center,
          ),
        ],
        child: const AppActionsBoxButton(icon: AppIcons.rowMenu),
      ),
    );
  }

  Widget _buildNumericPagination() {
    return Obx(() {
      final current = controller.resultCurrentPage.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Showing 1–5 of ${controller.totalPatientCount} patients',
              style: AppTextStyles.caption.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ResultPageBlock(
                label: 'Previous',
                width: 88,
                enabled: current > 1,
                onTap: controller.previousResultPage,
              ),
              const SizedBox(width: 8),
              _ResultPageBlock(
                label: '1',
                width: 40,
                selected: current == 1,
                onTap: () => controller.goToResultPage(1),
              ),
              const SizedBox(width: 6),
              _ResultPageBlock(
                label: '2',
                width: 40,
                selected: current == 2,
                onTap: () => controller.goToResultPage(2),
              ),
              const SizedBox(width: 6),
              _ResultPageBlock(
                label: '3',
                width: 40,
                selected: current == 3,
                onTap: () => controller.goToResultPage(3),
              ),
              const SizedBox(width: 6),
              _ResultPageBlock(
                label: '...',
                width: 40,
                enabled: true,
                onTap: () => controller.goToResultPage(
                  current <= 3 ? 4 : (current == 10 ? 9 : current),
                ),
              ),
              const SizedBox(width: 6),
              _ResultPageBlock(
                label: '10',
                width: 44,
                selected: current == 10,
                onTap: () => controller.goToResultPage(10),
              ),
              const SizedBox(width: 8),
              _ResultPageBlock(
                label: 'Next',
                width: 66,
                enabled: current < 10,
                onTap: controller.nextResultPage,
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildEmptySearchState({required bool isDesktop}) {
    final clearButton = OutlinedButton(
      onPressed: _clearSearch,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
        side: const BorderSide(color: AppColors.borderDefault),
        foregroundColor: AppColors.brandPrimary,
      ),
      child: const Text(
        'Clear search',
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isDesktop ? 56 : 36,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _NoLabResultsIllustration(),
            const SizedBox(height: 20),
            Text(
              'No lab results match your search',
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check the patient name or ID and try again.',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (isDesktop)
              SizedBox(width: 180, child: clearButton)
            else
              SizedBox(width: double.infinity, child: clearButton),
          ],
        ),
      ),
    );
  }
}

class _ResultPageBlock extends StatefulWidget {
  const _ResultPageBlock({
    required this.label,
    required this.width,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final double width;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_ResultPageBlock> createState() => _ResultPageBlockState();
}

class _ResultPageBlockState extends State<_ResultPageBlock> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final enabled = widget.enabled;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      side: BorderSide(
        color: selected
            ? AppColors.brandPrimary
            : _hovered && enabled
                ? AppColors.brandPrimary
                : AppColors.borderDefault,
        width: Dimensions.strokeDivider,
      ),
    );

    final bgColor = selected
        ? AppColors.brandPrimary
        : _hovered && enabled
            ? AppColors.brandTint
            : Colors.white;

    final textColor = selected
        ? Colors.white
        : !enabled
            ? AppColors.textDisabled
            : _hovered
                ? AppColors.brandHover
                : AppColors.brandPrimary;

    return MouseRegion(
      onEnter: (_) {
        if (enabled && !selected) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (enabled && !selected) setState(() => _hovered = false);
      },
      cursor:
          enabled && !selected ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Material(
        color: bgColor,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          hoverColor: Colors.transparent,
          splashColor: AppColors.brandPrimary.withValues(alpha: 0.12),
          onTap: enabled && !selected ? widget.onTap : null,
          child: SizedBox(
            width: widget.width,
            height: Dimensions.buttonMinHeight,
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
