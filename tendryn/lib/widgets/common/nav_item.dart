import 'package:flutter/material.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// Side: icon + label row, at least 48px high (desktop side navigation).
/// Bottom: icon above label, at least 72x64 (it grows to fill its slot).
enum NavItemPlacement { side, bottom }

/// One navigation destination. Active state uses the brand tint (side) or the
/// brand color (bottom); hover feedback is shown for mouse users.
class AppNavItem extends StatelessWidget {
  const AppNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
    this.placement = NavItemPlacement.side,
    this.tooltip,
    this.height,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;
  final NavItemPlacement placement;
  final String? tooltip;

  /// Bottom placement only: overrides the 64px default (tablet uses 76px).
  final double? height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSide = placement == NavItemPlacement.side;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusControl));

    final iconWidget = Icon(icon, size: Dimensions.iconSize, color: color);

    final content = isSide
        ? Row(
            children: [
              iconWidget,
              const SizedBox(width: Dimensions.statusX),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.label.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeCount != null && badgeCount! > 0)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.triageRed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  iconWidget,
                  if (badgeCount != null && badgeCount! > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.triageRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        alignment: Alignment.center,
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.spaceXs),
              // Never truncate a destination name: shrink slightly instead.
              FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: AppTextStyles.caption.copyWith(color: color), maxLines: 1)),
            ],
          );

    final item = Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surface,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          hoverColor: scheme.primaryContainer.withValues(alpha: 0.6),
          child: SizedBox(
            height: isSide ? Dimensions.touchTarget : (height ?? Dimensions.bottomNavHeight),
            width: double.infinity,
            child: Padding(
              padding: isSide ? const EdgeInsets.symmetric(horizontal: Dimensions.statusX) : EdgeInsets.zero,
              child: content,
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? item : Tooltip(message: tooltip, child: item);
  }
}
