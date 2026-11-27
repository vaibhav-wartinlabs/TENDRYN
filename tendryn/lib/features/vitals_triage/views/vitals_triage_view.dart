import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/vitals_triage/controllers/vitals_triage_controller.dart';
import 'package:tendryn/features/vitals_triage/widgets/vitals_triage_widgets.dart';

/// Main screen for Vitals & Triage (Nurse role).
class VitalsTriageView extends GetView<VitalsTriageController> {
  const VitalsTriageView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _VitalsTriageMobile(),
      tablet: _VitalsTriageTablet(),
      desktop: _VitalsTriageDesktop(),
    );
  }
}

// ----------------------------------------------------------------- Mobile Layout

class _VitalsTriageMobile extends GetView<VitalsTriageController> {
  const _VitalsTriageMobile();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Vitals & Triage',
            style: AppTextStyles.h2Bold.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Patients waiting for or currently in triage. Select a patient to record observations.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: Dimensions.spaceLg),
        VitalsTriageSearchToolbar(onChanged: controller.search),
        const SizedBox(height: Dimensions.spaceLg),
        const Text(
          'Awaiting triage',
          style: TextStyle(
            fontFamily: AppTextStyles.headingFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: Dimensions.spaceSm),
        Obx(() {
          final rows = controller.filteredEntries;
          if (rows.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No patients found',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    color: Color(0xFF535F69),
                  ),
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final entry in rows) ...[
                VitalsTriageCard(entry: entry),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              const VitalsTriageMobilePagination(),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }
}

// ----------------------------------------------------------------- Tablet Layout

class _VitalsTriageTablet extends GetView<VitalsTriageController> {
  const _VitalsTriageTablet();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginTablet),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Vitals & Triage',
            style: AppTextStyles.h2Bold.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Patients waiting for or currently in triage. Select a patient to record observations.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: Dimensions.spaceLg),
        VitalsTriageSearchToolbar(onChanged: controller.search),
        const SizedBox(height: Dimensions.spaceLg),
        Obx(() {
          final count = controller.entries.length;
          final awaiting = controller.awaitingTriageCount;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's queue",
                style: TextStyle(
                  fontFamily: AppTextStyles.headingFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              Text(
                '$count patients · $awaiting awaiting triage',
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 13,
                  color: Color(0xFF535F69),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: Dimensions.spaceSm),
        Obx(() {
          final rows = controller.filteredEntries;
          if (rows.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No patients found',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    color: Color(0xFF535F69),
                  ),
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < rows.length; i += 2) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: VitalsTriageCard(entry: rows[i])),
                    const SizedBox(width: 16),
                    Expanded(
                      child: i + 1 < rows.length
                          ? VitalsTriageCard(entry: rows[i + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: Dimensions.spaceSm),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing 1–5 of ${controller.totalCount} patients',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        color: Color(0xFF535F69),
                      ),
                    ),
                    const VitalsTriagePagination(),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ----------------------------------------------------------------- Desktop Layout

class _VitalsTriageDesktop extends GetView<VitalsTriageController> {
  const _VitalsTriageDesktop();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Vitals & Triage',
            style: AppTextStyles.h2Bold.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Patients waiting for or currently in triage. Select a patient to record observations.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: Dimensions.spaceLg),
        VitalsTriageSearchToolbar(
          hint: 'Search name, ID or queue number',
          onChanged: controller.search,
        ),
        const SizedBox(height: Dimensions.spaceLg),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(
              color: AppColors.borderDefault,
              width: Dimensions.strokeDivider,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Text(
                  'Awaiting triage',
                  style: TextStyle(
                    fontFamily: AppTextStyles.headingFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
              ),
              Obx(() {
                final rows = controller.filteredEntries;
                if (rows.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No patients found',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          color: Color(0xFF535F69),
                        ),
                      ),
                    ),
                  );
                }
                return VitalsTriageTable(entries: rows);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing 1–5 of ${controller.totalCount} patients',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: Color(0xFF535F69),
                        ),
                      ),
                      const VitalsTriagePagination(),
                    ],
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
