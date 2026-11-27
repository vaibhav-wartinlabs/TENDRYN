import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

enum BadgeTone { neutral, brand, success, info, warning }

/// Soft tinted pill with a 12px label, used in table cells (Priority, Status).
/// The dot-style [StatusPill] is used on cards; this one is for dense tables.
/// It keeps its natural width: in a table cell it may be wider than the column
/// (as in the design) rather than being truncated.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone});

  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = switch (tone) {
      BadgeTone.neutral => (
        theme.scaffoldBackgroundColor,
        scheme.onSurfaceVariant,
      ),
      BadgeTone.brand => (scheme.primaryContainer, scheme.primary),
      BadgeTone.success => (
        AppColors.feedbackSuccessTint,
        AppColors.feedbackSuccess,
      ),
      BadgeTone.info => (AppColors.feedbackInfoTint, AppColors.feedbackInfo),
      BadgeTone.warning => (
        AppColors.feedbackWarningTint,
        AppColors.feedbackWarning,
      ),
    };

    return OverflowBox(
      alignment: Alignment.centerLeft,
      minWidth: 0,
      maxWidth: 240,
      fit: OverflowBoxFit.deferToChild,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.badgePaddingX,
          vertical: Dimensions.badgePaddingY,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Dimensions.radiusPill),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(color: foreground),
          softWrap: false,
        ),
      ),
    );
  }
}
