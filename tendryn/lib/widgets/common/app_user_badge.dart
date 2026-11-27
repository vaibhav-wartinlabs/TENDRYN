import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/formatters.dart';

/// Staff avatar (initials on brand tint) with an optional name + caption.
/// Compact: 28px avatar with the caption underneath (mobile header).
class AppUserBadge extends StatelessWidget {
  const AppUserBadge({super.key, required this.name, this.caption, this.compact = false});

  final String name;
  final String? caption;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 28.0 : 36.0;

    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
      child: Text(Formatters.initials(name), style: AppTextStyles.caption.copyWith(color: scheme.primary)),
    );

    if (compact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          avatar,
          if (caption != null) Text(caption!, style: AppTextStyles.caption.copyWith(fontSize: 9, height: 12 / 9, color: scheme.onSurfaceVariant)),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(width: Dimensions.componentGap),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: AppTextStyles.label.copyWith(color: scheme.onSurface), overflow: TextOverflow.ellipsis),
              if (caption != null) Text(caption!, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
