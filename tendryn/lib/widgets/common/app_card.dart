import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// Flat: dense tables and nested panels. Soft: a card that needs a gentle lift
/// (0 1px 3px rgba(15,31,29,.08)).
enum AppCardElevation { flat, soft }

/// Tendryn card: surface fill, 12px radius, 1px border, 24px inner padding.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.elevation = AppCardElevation.flat,
    this.padding = const EdgeInsets.all(Dimensions.cardInner),
    this.onTap,
  });

  /// Card with the standard heading + supporting text.
  factory AppCard.titled({
    Key? key,
    required String title,
    String? detail,
    AppCardElevation elevation = AppCardElevation.flat,
    VoidCallback? onTap,
  }) =>
      AppCard(
        key: key,
        elevation: elevation,
        onTap: onTap,
        child: _TitledContent(title: title, detail: detail),
      );

  final Widget child;
  final AppCardElevation elevation;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(Dimensions.radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: radius,
        border: Border.all(color: scheme.outline, width: Dimensions.strokeDivider),
        boxShadow: elevation == AppCardElevation.soft
            ? const [BoxShadow(color: AppColors.shadowSoft, offset: Offset(0, 1), blurRadius: 3)]
            : null,
      ),
      child: onTap != null
          ? Material(
              type: MaterialType.transparency,
              borderRadius: radius,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                child: Padding(padding: padding, child: child),
              ),
            )
          : Padding(padding: padding, child: child),
    );
  }
}

class _TitledContent extends StatelessWidget {
  const _TitledContent({required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTextStyles.h3.copyWith(color: scheme.onSurface)),
        if (detail != null) ...[
          const SizedBox(height: Dimensions.componentGap),
          Text(detail!, style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}
