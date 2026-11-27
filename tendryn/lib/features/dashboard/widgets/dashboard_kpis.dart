import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/widgets/common/kpi_card.dart';

/// The four headline figures for Receptionist, or the 3 headline cards for Doctor.
class DashboardKpis extends StatelessWidget {
  const DashboardKpis({
    super.key,
    required this.summary,
    required this.screenType,
  });

  final DashboardModel summary;
  final LayoutType screenType;

  @override
  Widget build(BuildContext context) {
    final isDoctor = Get.isRegistered<RoleController>() &&
        RoleController.to.currentRole.value == ClinicRole.doctor;

    if (isDoctor) {
      const doctorCards = [
        _DoctorKpiCard(
          label: 'Patients waiting',
          value: '18',
          detail: '12 registered · 6 walk-ins',
        ),
        _DoctorKpiCard(
          label: 'Awaiting consultation',
          value: '6',
          detail: 'Average wait 24 min',
        ),
        _DoctorKpiCard(
          label: 'Pending lab results',
          value: '3',
          detail: '2 need review today',
        ),
      ];

      if (screenType == LayoutType.mobile) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Dimensions.spaceMd,
          children: doctorCards,
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900 ? 3 : 2;
          final cardWidth = (constraints.maxWidth - Dimensions.spaceMd * (columns - 1)) / columns;
          return Wrap(
            spacing: Dimensions.spaceMd,
            runSpacing: Dimensions.spaceMd,
            children: [for (final c in doctorCards) SizedBox(width: cardWidth, child: c)],
          );
        },
      );
    }

    final style = switch (screenType) {
      LayoutType.desktop => KpiCardStyle.desktop,
      LayoutType.tablet => KpiCardStyle.tablet,
      LayoutType.mobile => KpiCardStyle.mobile,
    };
    final desktop = screenType == LayoutType.desktop;
    final money = Formatters.rand(
      summary.takingsToday,
      decimals: desktop ? 2 : 0,
    );

    final cards = [
      KpiCard(
        style: style,
        label: desktop ? 'Patients Waiting' : 'Patients waiting',
        value: '${summary.patientsWaiting}',
        detail: 'Currently in queue',
      ),
      KpiCard(
        style: style,
        label: desktop ? 'Seen Today' : 'Seen today',
        value: '${summary.seenToday}',
        detail: 'Patients completed today',
      ),
      KpiCard(
        style: style,
        label: desktop ? 'Average Waiting Time' : 'Average wait',
        value: '${summary.averageWaitMinutes} min',
        detail: 'Across today’s queue',
      ),
      KpiCard(
        style: style,
        label: desktop ? 'Takings Today' : 'Takings today',
        value: money,
        detail: 'Payments recorded today',
      ),
    ];

    if (screenType == LayoutType.mobile) {
      return Column(
        spacing: Dimensions.spaceMd,
        children: [
          Row(
            spacing: Dimensions.spaceMd,
            children: [
              Expanded(child: cards[0]),
              Expanded(child: cards[1]),
            ],
          ),
          Row(
            spacing: Dimensions.spaceMd,
            children: [
              Expanded(child: cards[2]),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 2;
        final cardWidth = (constraints.maxWidth - Dimensions.spaceMd * (columns - 1)) / columns;
        return Wrap(
          spacing: Dimensions.spaceMd,
          runSpacing: Dimensions.spaceMd,
          children: [for (final c in cards) SizedBox(width: cardWidth, child: c)],
        );
      },
    );
  }
}

class _DoctorKpiCard extends StatelessWidget {
  const _DoctorKpiCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: scheme.outline, width: Dimensions.strokeDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.tabular(
              AppTextStyles.h1.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 26,
                height: 32 / 26,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
