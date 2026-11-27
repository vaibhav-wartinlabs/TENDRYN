import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/billing/controllers/billing_controller.dart';
import 'package:tendryn/features/billing/widgets/billing_invoice_card.dart';

class BillingTablet extends GetView<BillingController> {
  const BillingTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginTablet),
      children: [
        // Header Row with Title & Cash Up Button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Billing',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Invoices, payments and cash up for Ubuntu Family Clinic.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: controller.onCashUp,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: AppColors.brandHover,
              child: Container(
                height: Dimensions.buttonMinHeight,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
                child: const Text(
                  'Cash Up',
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
        const SizedBox(height: Dimensions.pageSectionGap),

        // 3 Summary Metric Cards
        Row(
          children: const [
            Expanded(
              child: _MetricCardDesktopTablet(
                label: 'To collect',
                value: 'R 2,150',
                subtitle: '3 invoices',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _MetricCardDesktopTablet(
                label: 'Paid today',
                value: 'R 8,450',
                subtitle: '12 payments',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _MetricCardDesktopTablet(
                label: 'Cash up',
                value: 'Not started',
                subtitle: "Lerato's shift",
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search and Filter Bar
        Row(
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
                  onChanged: controller.search,
                  decoration: const InputDecoration(
                    hintText: 'Search Patients or Invoice',
                    hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 14),
                    prefixIcon: Icon(AppIcons.search, size: 18, color: AppColors.textDisabled),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: controller.onFilter,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              hoverColor: AppColors.brandTint,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                width: Dimensions.buttonMinHeight,
                height: Dimensions.buttonMinHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: const Icon(
                  AppIcons.filter,
                  size: 20,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Recent Invoices Box Container
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Recent Invoices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Showing 4 of 1,248',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.sectionContentGap),

              // Invoices List
              Obx(() {
                final list = controller.filteredInvoices;
                if (list.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: const Text('No invoices found', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                return Column(
                  children: [
                    for (final inv in list)
                      BillingInvoiceCard(invoice: inv),
                  ],
                );
              }),
              const SizedBox(height: 12),

              // Pagination Row
              Row(
                children: [
                  const Text(
                    'Showing 1–5 of 5 patients',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  _PaginationButton(
                    icon: AppIcons.chevronLeft,
                    iconColor: AppColors.textDisabled,
                    onTap: () => controller.onPagination(0),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: Dimensions.touchTarget,
                    height: Dimensions.touchTarget,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PaginationButton(
                    icon: AppIcons.chevronRight,
                    iconColor: AppColors.brandPrimary,
                    onTap: () => controller.onPagination(2),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Bottom Action Buttons
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: controller.onOutstandingBalances,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                hoverColor: AppColors.brandTint.withValues(alpha: 0.5),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    border: Border.all(color: AppColors.brandPrimary),
                  ),
                  child: const Text(
                    'Outstanding balances',
                    style: TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: controller.onDailyCashUp,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  ),
                  child: const Text(
                    'Daily cash up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MetricCardDesktopTablet extends StatelessWidget {
  const _MetricCardDesktopTablet({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.tabular(
              AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      hoverColor: AppColors.brandTint,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: Dimensions.touchTarget,
        height: Dimensions.touchTarget,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.backgroundApp,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Icon(icon, size: Dimensions.iconSize, color: iconColor),
      ),
    );
  }
}
