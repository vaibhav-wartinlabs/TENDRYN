import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/billing/controllers/billing_controller.dart';
import 'package:tendryn/features/billing/widgets/billing_invoice_card.dart';

class BillingMobile extends GetView<BillingController> {
  const BillingMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
      children: [
        // 1. Header
        Text(
          'Billing',
          style: AppTextStyles.h1Mobile.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '29 Sep 2026 · 12 patients currently in queue',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // 2. Summary Metric Cards (2 in a row + 1 full width)
        Row(
          children: const [
            Expanded(
              child: _MetricCardMobile(
                label: 'To collect',
                value: 'R 2,150',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCardMobile(
                label: 'Paid today',
                value: 'R 8,450',
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.sectionContentGap),
        const _MetricCardMobile(
          label: 'Cash up',
          value: 'Not started',
          fullWidth: true,
        ),
        const SizedBox(height: 16),

        // 3. Search Bar
        Container(
          height: Dimensions.buttonMinHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: TextField(
            onChanged: controller.search,
            decoration: const InputDecoration(
              hintText: 'Search patients or invoice',
              hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 14),
              prefixIcon: Icon(AppIcons.search, size: 18, color: AppColors.textDisabled),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.pageSectionGap),

        // 4. Recent Invoices
        const Text(
          'Recent Invoices',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: Dimensions.sectionContentGap),
        Obx(() {
          final list = controller.filteredInvoices;
          if (list.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                'No invoices found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return Column(
            children: [
              for (final inv in list)
                BillingInvoiceCard(invoice: inv),
            ],
          );
        }),
        const SizedBox(height: 16),

        // 5. Bottom Action Buttons
        InkWell(
          onTap: controller.onCashUp,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: const Text(
              'Cash Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: controller.onOutstandingBalances,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          hoverColor: AppColors.brandTint.withValues(alpha: 0.5),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            width: double.infinity,
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
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MetricCardMobile extends StatelessWidget {
  const _MetricCardMobile({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
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
        ],
      ),
    );
  }
}
