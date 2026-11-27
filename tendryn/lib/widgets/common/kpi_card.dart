import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/widgets/common/app_card.dart';

/// Which Dashboard layout the card belongs to; each follows its own Figma frame.
enum KpiCardStyle {
  /// Flat, 24px padding, label + big value + detail line.
  desktop,

  /// Soft shadow, 16px padding, 104px high, brand-colored value.
  tablet,

  /// Soft shadow, compact 92px high, brand-colored value (Mobile/H2).
  mobile,
}

/// A headline figure. Numbers use tabular figures so digits line up.
class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.label, required this.value, this.detail, this.style = KpiCardStyle.desktop});

  final String label;
  final String value;

  /// Supporting line; only shown by the desktop style.
  final String? detail;
  final KpiCardStyle style;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (padding, minHeight, elevation) = switch (style) {
      KpiCardStyle.desktop => (Dimensions.cardInner, 136.0, AppCardElevation.flat),
      KpiCardStyle.tablet => (Dimensions.spaceMd, 104.0, AppCardElevation.soft),
      KpiCardStyle.mobile => (Dimensions.spaceMd, 92.0, AppCardElevation.soft),
    };

    final labelStyle = switch (style) {
      KpiCardStyle.desktop => AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
      KpiCardStyle.tablet => AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant),
      KpiCardStyle.mobile => AppTextStyles.label.copyWith(color: scheme.onSurface),
    };
    final valueStyle = switch (style) {
      KpiCardStyle.desktop => AppTextStyles.h2.copyWith(color: scheme.onSurface),
      KpiCardStyle.tablet => AppTextStyles.h2.copyWith(color: scheme.primary),
      KpiCardStyle.mobile => AppTextStyles.h2Mobile.copyWith(color: scheme.primary),
    };

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: AppCard(
        elevation: elevation,
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(height: Dimensions.componentGap),
            Text(value, style: AppTextStyles.tabular(valueStyle)),
            if (style == KpiCardStyle.desktop && detail != null) ...[
              const SizedBox(height: Dimensions.componentGap),
              Text(detail!, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}
