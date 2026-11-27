import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';

enum AppButtonVariant { primary, secondary, text }

/// Tendryn button: 48px high, 8px radius, 14/20 Inter Medium label. All
/// decoration (default / hover / focus / disabled) comes from the theme.
/// Primary is the main action; Secondary is a supporting action. Never give it
/// a fixed narrow width: labels can grow by 40%.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.height,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.height,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.height,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.height,
  }) : variant = AppButtonVariant.text;

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// Shows a spinner and blocks taps while true.
  final bool isLoading;

  /// Stretch to the available width.
  final bool expand;

  /// Explicit height override. If omitted, defaults to [Dimensions.buttonMinHeight] (48px)
  /// for primary and secondary buttons, matching the design tokens and inputs.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final content = _Content(label: label, icon: icon, isLoading: isLoading);

    final effectiveHeight = height ?? (variant == AppButtonVariant.text ? null : Dimensions.buttonMinHeight);

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(onPressed: effectiveOnPressed, child: content),
      AppButtonVariant.secondary => OutlinedButton(onPressed: effectiveOnPressed, child: content),
      AppButtonVariant.text => TextButton(onPressed: effectiveOnPressed, child: content),
    };

    if (expand) {
      return SizedBox(
        width: double.infinity,
        height: effectiveHeight,
        child: button,
      );
    }
    if (effectiveHeight != null) {
      return SizedBox(
        height: effectiveHeight,
        child: button,
      );
    }
    return button;
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.label, required this.icon, required this.isLoading});

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: Dimensions.iconSize), const SizedBox(width: Dimensions.componentGap)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
  }
}
