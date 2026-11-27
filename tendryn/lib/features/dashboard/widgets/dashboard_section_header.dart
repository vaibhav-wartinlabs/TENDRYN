import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/widgets/common/app_button.dart';

/// Section heading used on tablet and mobile (outside a card): an H2 title
/// with an optional supporting line and an action on the right.
class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.titleStyle,
    this.summary,
    this.actionLabel,
    this.onAction,
    this.outlinedAction = false,
  });

  final String title;
  final TextStyle? titleStyle;
  final Widget? summary;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Tablet shows the action as a bordered button; mobile as a text link.
  final bool outlinedAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimensions.spaceXs,
            children: [
              Text(
                title,
                style: (titleStyle ?? AppTextStyles.h2Mobile).copyWith(
                  color: scheme.onSurface,
                ),
              ),
              ?summary,
            ],
          ),
        ),
        if (actionLabel != null)
          outlinedAction
              ? AppButton.secondary(label: actionLabel!, onPressed: onAction)
              : AppButton.text(label: actionLabel!, onPressed: onAction),
      ],
    );
  }
}
