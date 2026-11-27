import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';

/// 48x48 icon target (the minimum mobile tap size) on the app background.
class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    this.icon = AppIcons.search,
    required this.onPressed,
    required this.tooltip,
    this.outlined = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  /// Surface fill with a 1px border instead of the app-background fill (tablet header).
  final bool outlined;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(Dimensions.radiusControl);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: Dimensions.touchTarget,
        height: Dimensions.touchTarget,
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.brandTint
              : (widget.outlined ? theme.colorScheme.surface : theme.scaffoldBackgroundColor),
          borderRadius: radius,
          border: Border.all(
            color: _hovered
                ? AppColors.brandPrimary
                : (widget.outlined ? theme.colorScheme.outline : Colors.transparent),
            width: Dimensions.strokeDivider,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onPressed,
            hoverColor: Colors.transparent,
            splashColor: AppColors.brandTint.withValues(alpha: 0.5),
            highlightColor: Colors.transparent,
            child: Center(
              child: Icon(
                widget.icon,
                size: Dimensions.iconSize,
                color: widget.onPressed == null
                    ? theme.disabledColor
                    : (_hovered ? AppColors.brandPrimary : theme.colorScheme.onSurface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
