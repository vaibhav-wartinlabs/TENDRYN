import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// Search input: leading 18px search icon + text. Stays expanded on
/// tablet/desktop; on mobile collapse it to an [AppIconButton] in the header.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.onTap,
    this.suffixIcon,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.hintStyle,
    this.isActive,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  /// Overrides the hint style (the Dashboard design uses the 12px caption).
  final TextStyle? hintStyle;

  /// Whether the search field is explicitly marked active (e.g. search overlay open).
  final bool? isActive;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  bool _hovered = false;
  bool _pressed = false;
  late final FocusNode _internalFocus;
  bool _hasLocalFocus = false;

  FocusNode get _effectiveFocus => widget.focusNode ?? _internalFocus;

  @override
  void initState() {
    super.initState();
    _internalFocus = FocusNode();
    _effectiveFocus.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocus).removeListener(_handleFocus);
      _effectiveFocus.addListener(_handleFocus);
    }
  }

  @override
  void dispose() {
    _effectiveFocus.removeListener(_handleFocus);
    _internalFocus.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (mounted && _hasLocalFocus != _effectiveFocus.hasFocus) {
      setState(() => _hasLocalFocus = _effectiveFocus.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(Dimensions.radiusControl);
    final isExplicitActive = widget.isActive ?? false;
    final isGreenActive = isExplicitActive || _hasLocalFocus || _hovered || _pressed;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.text,
      child: Listener(
        onPointerDown: (_) {
          if (!_pressed) setState(() => _pressed = true);
        },
        onPointerUp: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        onPointerCancel: (_) {
          if (_pressed) setState(() => _pressed = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isGreenActive
                ? AppColors.brandTint.withValues(alpha: 0.35)
                : AppColors.backgroundSurface,
            borderRadius: borderRadius,
            border: Border.all(
              color: isGreenActive ? AppColors.brandPrimary : scheme.outline,
              width: (_hasLocalFocus || isExplicitActive)
                  ? Dimensions.strokeFocus
                  : (isGreenActive ? 1.5 : Dimensions.strokeDivider),
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _effectiveFocus,
            onTap: widget.onTap,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            textInputAction: TextInputAction.search,
            style: AppTextStyles.body.copyWith(color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: widget.hintStyle,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              fillColor: Colors.transparent,
              filled: true,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 14,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.controlX,
                  right: Dimensions.componentGap,
                ),
                child: Icon(
                  AppIcons.search,
                  size: Dimensions.iconSize,
                  color: isGreenActive ? AppColors.brandPrimary : scheme.onSurfaceVariant,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: Dimensions.controlX +
                    Dimensions.iconSize +
                    Dimensions.componentGap,
              ),
              suffixIcon: widget.suffixIcon,
            ),
          ),
        ),
      ),
    );
  }
}
