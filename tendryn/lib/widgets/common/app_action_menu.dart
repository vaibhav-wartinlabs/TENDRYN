import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// Standard 3-dots action button inside a box with interactive hover effect.
class AppActionsBoxButton extends StatefulWidget {
  const AppActionsBoxButton({
    super.key,
    this.size = Dimensions.touchTarget,
    this.touchTargetSize = Dimensions.touchTarget,
    this.icon,
    this.color,
    this.borderColor,
    this.iconColor,
  });

  final double size;
  final double touchTargetSize;
  final IconData? icon;
  final Color? color;
  final Color? borderColor;
  final Color? iconColor;

  @override
  State<AppActionsBoxButton> createState() => _AppActionsBoxButtonState();
}

class _AppActionsBoxButtonState extends State<AppActionsBoxButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = _hovered
        ? AppColors.brandTint
        : (widget.color ?? const Color(0xFFF8FAFC));
    final borderCol = _hovered
        ? AppColors.brandPrimary.withValues(alpha: 0.6)
        : (widget.borderColor ?? AppColors.borderDefault);
    final iColor = _hovered
        ? AppColors.brandPrimary
        : (widget.iconColor ?? const Color(0xFF535F69));

    return SizedBox(
      width: widget.touchTargetSize,
      height: widget.touchTargetSize,
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(
                color: borderCol,
                width: 1,
              ),
            ),
            child: Icon(
              widget.icon ?? Icons.more_vert,
              size: 18,
              color: iColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard menu item for PopupMenuButton with smooth hover effect across all views.
class AppActionMenuItem<T> extends PopupMenuEntry<T> {
  const AppActionMenuItem({
    super.key,
    required this.value,
    required this.label,
    this.height = Dimensions.touchTarget,
    this.icon,
    this.isHighlighted = false,
    this.isDestructive = false,
    this.textColor,
    this.alignment = Alignment.center,
  });

  final T value;
  final String label;
  @override
  final double height;
  final IconData? icon;
  final bool isHighlighted;
  final bool isDestructive;
  final Color? textColor;
  final Alignment alignment;

  @override
  bool represents(T? other) => other == value;

  @override
  State<AppActionMenuItem<T>> createState() => _AppActionMenuItemState<T>();
}

class _AppActionMenuItemState<T> extends State<AppActionMenuItem<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || widget.isHighlighted;

    final defaultColor = widget.isDestructive
        ? AppColors.safetyCriticalText
        : (widget.textColor ?? const Color(0xFF1A1C1E));

    final textCol = _hovered
        ? (widget.isDestructive ? AppColors.safetyCriticalText : AppColors.brandHover)
        : (widget.isHighlighted ? AppColors.brandPrimary : defaultColor);

    final bgCol = _hovered
        ? (widget.isDestructive ? AppColors.statusCancelledTint : AppColors.brandTint)
        : (widget.isHighlighted ? AppColors.brandTint.withValues(alpha: 0.5) : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(widget.value),
        child: Container(
          width: double.infinity,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: widget.alignment,
          color: bgCol,
          child: widget.icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, size: 16, color: textCol),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: widget.alignment == Alignment.center
                            ? TextAlign.center
                            : TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: textCol,
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: widget.alignment == Alignment.center
                      ? TextAlign.center
                      : TextAlign.start,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: textCol,
                  ),
                ),
        ),
      ),
    );
  }
}
