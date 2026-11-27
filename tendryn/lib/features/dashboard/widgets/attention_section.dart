import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';

import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/utils/app_notice.dart';

/// "Needs Attention": desktop shows two cards with an inline link, tablet two
/// cards with a full-width button, mobile a column of tappable rows.
/// In Doctor mode, shows the 3 clinical attention cards (abnormal vitals, lab results, sign-offs).
class AttentionSection extends GetView<DashboardController> {
  const AttentionSection({
    super.key,
    required this.items,
    required this.screenType,
  });

  final List<AttentionItem> items;
  final LayoutType screenType;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDoctor = Get.isRegistered<RoleController>() &&
        RoleController.to.currentRole.value == ClinicRole.doctor;

    if (isDoctor) {
      return _DoctorAttentionSection(screenType: screenType);
    }

    final isMobile = screenType == LayoutType.mobile;
    final cards = [
      for (final i in items)
        _AttentionCard(
          item: i,
          screenType: screenType,
          onTap: () => controller.openAttention(i.kind),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Dimensions.spaceMd,
      children: [
        // Mobile and tablet frames use the 22/28 heading; desktop the 20/28 one.
        Text(
          'Needs Attention',
          style:
              (screenType == LayoutType.desktop
                      ? AppTextStyles.h3
                      : AppTextStyles.h2Mobile)
                  .copyWith(color: scheme.onSurface),
        ),
        if (isMobile)
          Column(spacing: Dimensions.spaceMd, children: cards)
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Dimensions.spaceMd,
              children: [for (final c in cards) Expanded(child: c)],
            ),
          ),
      ],
    );
  }
}

class _DoctorAttentionSection extends StatelessWidget {
  const _DoctorAttentionSection({required this.screenType});

  final LayoutType screenType;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMobile = screenType == LayoutType.mobile;
    final isTablet = screenType == LayoutType.tablet;

    final card1 = _DoctorAttentionCard(
      title: 'Abnormal vitals flagged',
      subtitle: 'Review patient observations',
      actionLabel: 'Review',
      bg: AppColors.safetyCriticalBackground,
      titleColor: AppColors.triageRed,
      subtitleColor: AppColors.safetyCriticalText,
      actionColor: AppColors.triageRed,
      isTablet: isTablet,
    );

    final card2 = _DoctorAttentionCard(
      title: 'New lab results',
      subtitle: '2 awaiting review',
      actionLabel: 'Review',
      bg: AppColors.brandTint,
      titleColor: AppColors.textPrimary,
      subtitleColor: AppColors.textSecondary,
      actionColor: scheme.primary,
      isTablet: isTablet,
    );

    final card3 = _DoctorAttentionCard(
      title: 'Pending sign-offs',
      subtitle: '1 consultation draft',
      actionLabel: 'Review',
      bg: AppColors.feedbackWarningTint,
      titleColor: AppColors.feedbackWarning,
      subtitleColor: AppColors.feedbackWarning,
      actionColor: AppColors.feedbackWarning,
      isTablet: isTablet,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Needs attention',
          style: (screenType == LayoutType.desktop
                  ? AppTextStyles.h3
                  : AppTextStyles.h2Mobile)
              .copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        if (isMobile)
          Column(
            spacing: Dimensions.spaceMd,
            children: [card1, card2, card3],
          )
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Dimensions.spaceMd,
              children: [
                Expanded(child: card1),
                Expanded(child: card2),
                Expanded(child: card3),
              ],
            ),
          ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: scheme.outline, width: Dimensions.strokeDivider),
      ),
      child: content,
    );
  }
}

class _DoctorAttentionCard extends StatelessWidget {
  const _DoctorAttentionCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.bg,
    required this.titleColor,
    required this.subtitleColor,
    required this.actionColor,
    required this.isTablet,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final Color bg;
  final Color titleColor;
  final Color subtitleColor;
  final Color actionColor;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Dimensions.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.sectionContentGap),
            InkWell(
              onTap: () => AppNotice.unavailable(title),
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: actionColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => AppNotice.unavailable(title),
            child: Text(
              actionLabel,
              style: TextStyle(
                color: actionColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.item,
    required this.screenType,
    required this.onTap,
  });

  final AttentionItem item;
  final LayoutType screenType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final conflicts = item.kind == AttentionKind.appointmentConflicts;
    final actionLabel = conflicts ? 'Review Appointments' : 'View Billing';
    final isDesktop = screenType == LayoutType.desktop;
    final isMobile = screenType == LayoutType.mobile;

    final icon = Container(
      width: isMobile ? Dimensions.actionIconBox : Dimensions.attentionIconBox,
      height: isMobile ? Dimensions.actionIconBox : Dimensions.attentionIconBox,
      decoration: BoxDecoration(
        color: AppColors.feedbackWarningTint,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      ),
      child: Icon(
        conflicts ? AppIcons.conflict : AppIcons.payments,
        size: Dimensions.iconSize,
        color: AppColors.triageOrange,
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 3,
      children: [
        Text(
          item.title,
          style: AppTextStyles.label.copyWith(color: scheme.onSurface),
        ),
        Text(
          item.description,
          style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final header = Row(
      spacing: isDesktop ? 14 : Dimensions.statusX,
      children: [
        icon,
        Expanded(child: copy),
        if (isDesktop) AppButton.text(label: actionLabel, onPressed: onTap),
        if (isMobile)
          Icon(AppIcons.chevronRight, size: 16, color: scheme.onSurfaceVariant),
      ],
    );

    return AppCard(
      padding: const EdgeInsets.all(Dimensions.sectionPadding),
      onTap: onTap,
      child: screenType == LayoutType.tablet
          ? Column(
              spacing: Dimensions.spaceMd,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                AppButton.secondary(
                  label: actionLabel,
                  onPressed: onTap,
                  expand: true,
                ),
              ],
            )
          : header,
    );
  }
}
