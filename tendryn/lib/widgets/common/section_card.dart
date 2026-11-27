import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// A titled card whose body (usually a table) runs edge to edge. The header has
/// 20px padding, an H3 title, an optional supporting line and a trailing action.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.summary,
    this.trailing,
    required this.child,
  });

  final String title;
  final String? subtitle;

  /// Replaces [subtitle] with custom content (e.g. the appointment counts).
  final Widget? summary;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(
          color: scheme.outline,
          width: Dimensions.strokeDivider,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.sectionPadding,
              vertical: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h3.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Dimensions.spaceXs),
                      ?(summary ??
                          (subtitle == null
                              ? null
                              : Text(
                                  subtitle!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ))),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderDefault,
          ),
          child,
        ],
      ),
    );
  }
}
