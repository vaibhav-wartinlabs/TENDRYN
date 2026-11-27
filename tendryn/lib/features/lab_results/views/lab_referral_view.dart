import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/lab_results/controllers/lab_referral_controller.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/widgets/common/app_action_menu.dart';
import 'package:tendryn/widgets/common/app_button.dart';

class LabReferralView extends StatefulWidget {
  const LabReferralView({super.key});

  @override
  State<LabReferralView> createState() => _LabReferralViewState();
}

class _LabReferralViewState extends State<LabReferralView> {
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
    _searchController = TextEditingController(text: controller.searchQuery.value);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    controller.clearSearch();
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
              // Referral Updated Success Banner (if present)
              Obx(() {
                final notice = controller.updateNotice.value;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    ),
                  ),
                  child: notice == null
                      ? const SizedBox.shrink(key: ValueKey('empty_notice'))
                      : Padding(
                          key: const ValueKey('referral_notice'),
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _ReferralUpdatedBanner(notice: notice),
                        ),
                );
              }),

              // Page Header: Lab Referral
              _buildPageHeader(context),
              const SizedBox(height: 18),

              // Search & Filter Toolbar
              _buildSearchAndFilterBar(context),
              const SizedBox(height: 20),

              // Responsive Content: Desktop Table vs Tablet 2-col Grid vs Mobile Card Stack
              if (isDesktop)
                _buildDesktopTable(context)
              else if (isTablet)
                _buildTabletContent(context)
              else
                _buildMobileContent(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page Header ─────────────────────────────────────────────────────────────
  Widget _buildPageHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lab Referral',
          style: AppTextStyles.h2.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'View laboratory requests and track sample progress.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ── Search & Filter Toolbar ─────────────────────────────────────────────────
  Widget _buildSearchAndFilterBar(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
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
              onChanged: controller.onSearchChanged,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: isDesktop
                    ? 'Search name, ID or queue number'
                    : 'Search name, ID or queue no...',
                hintStyle: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  color: AppColors.textDisabled,
                ),
                prefixIcon: const Icon(
                  AppIcons.search,
                  size: Dimensions.iconSize,
                  color: AppColors.textDisabled,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
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
            icon: const Icon(AppIcons.filter, size: 18, color: AppColors.textPrimary),
            tooltip: 'Filter',
            onPressed: () => _showFilterDialog(context),
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    final filterOptions = ['All', 'Requested', 'Sample Taken', 'Awaiting Result', 'Result Received'];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter Referrals by Status'),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: filterOptions.map((f) {
              final isSelected = controller.selectedFilter.value == f;
              return ListTile(
                title: Text(f),
                leading: Icon(
                  isSelected ? AppIcons.check : Icons.circle_outlined,
                  size: 18,
                  color: isSelected ? AppColors.brandPrimary : AppColors.textDisabled,
                ),
                onTap: () {
                  controller.onFilterChanged(f);
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ── Desktop Table ───────────────────────────────────────────────────────────
  Widget _buildDesktopTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Card Header: Referrals & Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Referrals',
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

          const Divider(height: 1, color: AppColors.borderDefault),

          // Table Header Row
          _buildDesktopTableHeader(),

          // Table Rows
          Obx(() {
            final paged = controller.pagedReferrals;
            if (paged.isEmpty) {
              return _buildSearchEmptyState(context, isDesktop: true);
            }

            return Column(
              children: [
                ...paged.map((referral) => _buildDesktopTableRow(context, referral)),
                const Divider(height: 1, color: AppColors.borderDefault),
                // Pagination row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
              'Test Requested',
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
              'Requested By',
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
              'Status',
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

  Widget _buildDesktopTableRow(BuildContext context, LabReferralModel referral) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          // 1. Patient Name & Folder Number
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.patientName,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  referral.folderNumber,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // 2. Test Requested
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                referral.testsRequested,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 3. Requested By
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                referral.requestedBy,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 4. Referral Date
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                referral.referralDate,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 5. Status
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: LabReferralStatusPill(status: referral.status),
            ),
          ),
          // 6. Action Button
          SizedBox(
            width: 64,
            child: Center(
              child: _buildActionMenu(context, referral),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tablet Content: 2-Column Card Grid ──────────────────────────────────────
  Widget _buildTabletContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Today's queue
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "Today's queue",
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Obx(
                () {
                  if (controller.filteredReferrals.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${controller.filteredReferrals.length} patients · 2 awaiting triage',
                    textAlign: TextAlign.end,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2-Column Cards Grid or Empty State
        Obx(() {
          final paged = controller.pagedReferrals;
          if (paged.isEmpty) {
            return _buildSearchEmptyState(context, isDesktop: false);
          }

          return Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paged.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 185,
                ),
                itemBuilder: (context, index) {
                  return _buildReferralCard(context, paged[index]);
                },
              ),
              const SizedBox(height: 24),
              _buildNumericPagination(),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  // ── Mobile Content: 1-Column Card List ──────────────────────────────────────
  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Today's queue
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "Today's queue",
              style: AppTextStyles.h3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Obx(
                () {
                  if (controller.filteredReferrals.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${controller.filteredReferrals.length} patients · 2 awaiting triage',
                    textAlign: TextAlign.end,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Single Column List or Empty State
        Obx(() {
          final paged = controller.pagedReferrals;
          if (paged.isEmpty) {
            return _buildSearchEmptyState(context, isDesktop: false);
          }

          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paged.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildReferralCard(context, paged[index]);
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Previous',
                      onPressed: controller.currentPage.value > 1
                          ? () => controller.previousPage()
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton.primary(
                      label: 'Next',
                      onPressed: controller.currentPage.value < 10
                          ? () => controller.nextPage()
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          );
        }),
      ],
    );
  }

  // ── Referral Card Widget (Tablet & Mobile) ──────────────────────────────────
  Widget _buildReferralCard(BuildContext context, LabReferralModel referral) {
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
          // Row 1: Patient Name + Status Pill + 3-dots Button
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
                            referral.patientName,
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
                        LabReferralStatusPill(status: referral.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      referral.folderNumber,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 3-dots action menu button
              _buildActionMenu(context, referral),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Detail Rows
          _buildCardInfoRow('Test Requested', referral.testsRequested),
          const SizedBox(height: 6),
          _buildCardInfoRow('Requested by', referral.requestedBy),
          const SizedBox(height: 6),
          _buildCardInfoRow('Requested Date', referral.referralDate),
        ],
      ),
    );
  }

  Widget _buildCardInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ── 3-Dots Action Menu (View Detail, Record Sample, Patient Lab Information)
  Widget _buildActionMenu(BuildContext context, LabReferralModel referral) {
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
        constraints: const BoxConstraints.tightFor(width: 212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        onSelected: (val) {
          if (val == 'view_detail') {
            controller.onViewDetail(context, referral);
          } else if (val == 'record_sample') {
            controller.onRecordSample(context, referral);
          } else if (val == 'patient_lab_info') {
            controller.onPatientLabInfo(context, referral);
          }
        },
        itemBuilder: (context) => [
          const AppActionMenuItem<String>(
            value: 'view_detail',
            label: 'View Detail',
            alignment: Alignment.center,
          ),
          const AppActionMenuItem<String>(
            value: 'record_sample',
            label: 'Record Sample',
            alignment: Alignment.center,
          ),
          const AppActionMenuItem<String>(
            value: 'patient_lab_info',
            label: 'Patient Lab Information',
            alignment: Alignment.center,
          ),
        ],
        child: const AppActionsBoxButton(icon: AppIcons.rowMenu),
      ),
    );
  }

  // ── Numeric Pagination (Showing 1-5 of 24 patients, 1 2 3 4 ... 10) ─────────
  Widget _buildNumericPagination() {
    return Obx(() {
      final current = controller.currentPage.value;
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _LabReferralPageBlock(
                label: 'Previous',
                width: 88,
                enabled: current > 1,
                onTap: controller.previousPage,
              ),
              const SizedBox(width: 8),
              _LabReferralPageBlock(
                label: '1',
                width: 40,
                selected: current == 1,
                onTap: () => controller.goToPage(1),
              ),
              const SizedBox(width: 6),
              _LabReferralPageBlock(
                label: '2',
                width: 40,
                selected: current == 2,
                onTap: () => controller.goToPage(2),
              ),
              const SizedBox(width: 6),
              _LabReferralPageBlock(
                label: '3',
                width: 40,
                selected: current == 3,
                onTap: () => controller.goToPage(3),
              ),
              const SizedBox(width: 6),
              _LabReferralPageBlock(
                label: '4',
                width: 40,
                selected: current == 4,
                onTap: () => controller.goToPage(4),
              ),
              const SizedBox(width: 6),
              _LabReferralPageBlock(
                label: '...',
                width: 40,
                enabled: true,
                onTap: () => controller.goToPage(
                  current <= 4 ? 5 : (current == 10 ? 9 : current),
                ),
              ),
              const SizedBox(width: 6),
              _LabReferralPageBlock(
                label: '10',
                width: 44,
                selected: current == 10,
                onTap: () => controller.goToPage(10),
              ),
              const SizedBox(width: 8),
              _LabReferralPageBlock(
                label: 'Next',
                width: 66,
                enabled: current < 10,
                onTap: controller.nextPage,
              ),
            ],
          ),
        ],
      );
    });
  }

  // ── Search Empty State (No referrals match your search) ─────────────────────
  Widget _buildSearchEmptyState(BuildContext context, {required bool isDesktop}) {
    final buttonChild = Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        onTap: _clearSearch,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: const Text(
            'Clear search',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.brandPrimary,
            ),
          ),
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
            const _NoReferralsEmptyIllustration(),
            const SizedBox(height: 20),
            Text(
              'No referrals match your search',
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
              SizedBox(
                width: 180,
                child: buttonChild,
              )
            else
              SizedBox(
                width: double.infinity,
                child: buttonChild,
              ),
          ],
        ),
      ),
    );
  }
}

class _LabReferralPageBlock extends StatefulWidget {
  const _LabReferralPageBlock({
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
  State<_LabReferralPageBlock> createState() => _LabReferralPageBlockState();
}

class _LabReferralPageBlockState extends State<_LabReferralPageBlock> {
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
      cursor: enabled && !selected ? SystemMouseCursors.click : SystemMouseCursors.basic,
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

/// Illustration shown when search/filter returns zero lab referrals.
/// Matches Figma design: Doctor with stethoscope, patient card & magnifying glass with 'X'.
class _NoReferralsEmptyIllustration extends StatelessWidget {
  const _NoReferralsEmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 140,
      height: 96,
      child: CustomPaint(
        painter: _NoReferralsEmptyPainter(),
      ),
    );
  }
}

class _NoReferralsEmptyPainter extends CustomPainter {
  const _NoReferralsEmptyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background ID / Medical Record Card
    final cardRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(50, 18, 56, 44),
      const Radius.circular(6),
    );
    final cardFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final cardStroke = Paint()
      ..color = const Color(0xFFBCE3DC)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(cardRect, cardFill);
    canvas.drawRRect(cardRect, cardStroke);

    // Card avatar
    final avatarPaint = Paint()
      ..color = const Color(0xFF67B7A7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(63, 31), 4.5, avatarPaint);

    // Card lines
    final cardLinePaint = Paint()
      ..color = const Color(0xFFCBEAE4)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(72, 29), const Offset(94, 29), cardLinePaint);
    canvas.drawLine(const Offset(72, 35), const Offset(88, 35), cardLinePaint);

    final cardLineLight = Paint()
      ..color = const Color(0xFFE2F3F0)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(58, 45), const Offset(94, 45), cardLineLight);
    canvas.drawLine(const Offset(58, 51), const Offset(86, 51), cardLineLight);

    // Radiant ticks at top right of card
    final sparkPaint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(98, 16), const Offset(102, 11), sparkPaint);
    canvas.drawLine(const Offset(106, 18), const Offset(111, 16), sparkPaint);
    canvas.drawLine(const Offset(94, 13), const Offset(92, 8), sparkPaint);

    // Dotted curve trailing to the right
    final dotTrailPaint = Paint()
      ..color = const Color(0xFF14B8A6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(108, 38), 1.2, dotTrailPaint);
    canvas.drawCircle(const Offset(113, 36), 1.2, dotTrailPaint);
    canvas.drawCircle(const Offset(118, 34), 1.2, dotTrailPaint);
    canvas.drawCircle(const Offset(123, 33), 2.0, dotTrailPaint);

    // 2. Doctor / Health Worker on Left
    // Hair bun
    final hairPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(31, 32), 4.5, hairPaint);

    // Head
    canvas.drawCircle(const Offset(37, 36), 8, hairPaint);

    // Face
    final skinPaint = Paint()
      ..color = const Color(0xFFFFD4B2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(39, 38), 5.5, skinPaint);

    // Fringe / bangs
    final fringePath = Path()
      ..moveTo(33, 33)
      ..quadraticBezierTo(38, 32, 42, 35)
      ..lineTo(40, 38)
      ..quadraticBezierTo(36, 36, 33, 38)
      ..close();
    canvas.drawPath(fringePath, hairPaint);

    // Hand at chin (thinking gesture)
    canvas.drawCircle(const Offset(43, 44), 2.5, skinPaint);

    // Doctor Body / Scrubs
    final scrubsPaint = Paint()
      ..color = const Color(0xFF0D9488)
      ..style = PaintingStyle.fill;
    final bodyPath = Path()
      ..moveTo(32, 48)
      ..lineTo(44, 48)
      ..lineTo(45, 68)
      ..lineTo(31, 68)
      ..close();
    canvas.drawPath(bodyPath, scrubsPaint);

    // White Coat overlay
    final coatPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final coatStroke = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final leftCoat = Path()
      ..moveTo(31, 48)
      ..lineTo(35, 48)
      ..lineTo(34, 68)
      ..lineTo(29, 68)
      ..close();
    canvas.drawPath(leftCoat, coatPaint);
    canvas.drawPath(leftCoat, coatStroke);

    // Stethoscope
    final stethPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      const Rect.fromLTWH(34, 44, 8, 12),
      0.2,
      2.8,
      false,
      stethPaint,
    );

    // Clipboard / Folder
    final folderPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(34, 54);
    canvas.rotate(-0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 14, 18),
        const Radius.circular(2),
      ),
      folderPaint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(2, 2, 10, 14),
      Paint()..color = const Color(0xFFF1F5F9),
    );
    canvas.restore();

    // 3. Magnifying Glass with 'X' in Foreground
    final glassCenter = const Offset(85, 48);
    const glassRadius = 15.0;

    // Lens fill
    final lensFill = Paint()
      ..color = const Color(0xFFF0FDFA)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(glassCenter, glassRadius, lensFill);

    // Lens border
    final glassBorder = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(glassCenter, glassRadius, glassBorder);

    // 'X' icon inside lens
    final xPaint = Paint()
      ..color = const Color(0xFF0D9488)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(glassCenter.dx - 4.5, glassCenter.dy - 4.5),
      Offset(glassCenter.dx + 4.5, glassCenter.dy + 4.5),
      xPaint,
    );
    canvas.drawLine(
      Offset(glassCenter.dx + 4.5, glassCenter.dy - 4.5),
      Offset(glassCenter.dx - 4.5, glassCenter.dy + 4.5),
      xPaint,
    );

    // Magnifying glass handle
    final handlePaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(glassCenter.dx + 11, glassCenter.dy + 11),
      Offset(glassCenter.dx + 21, glassCenter.dy + 21),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Referral Updated Success Banner ──────────────────────────────────────────
class _ReferralUpdatedBanner extends StatelessWidget {
  const _ReferralUpdatedBanner({required this.notice});

  final ReferralUpdateNotice notice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check,
              size: 18,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Referral updated',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notice.message,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF166534),
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
