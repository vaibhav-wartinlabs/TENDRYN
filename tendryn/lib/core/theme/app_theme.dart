import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// The light [ThemeData] (the app is light-mode only). Component decoration (buttons, inputs, cards,
/// navigation) is defined here once, from the design tokens, so plain Material
/// widgets and the Tendryn widgets in `widgets/common` look the same.
///
/// Widgets should read neutral colors from the theme (`colorScheme.surface`,
/// `.outline`, `.onSurface`...) and use [AppColors] only for the fixed semantic
/// colors (triage, sync, safety), which never change with branding or theme.
abstract class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.brandPrimary,
      onPrimary: AppColors.textOnBrand,
      primaryContainer: AppColors.brandTint,
      onPrimaryContainer: AppColors.brandPrimary,
      secondary: AppColors.brandHover, // hover/pressed shade of the brand color
      onSecondary: AppColors.textOnBrand,
      error: AppColors.safetyCriticalText,
      onError: AppColors.textOnBrand,
      errorContainer: AppColors.safetyCriticalBackground,
      onErrorContainer: AppColors.safetyCriticalText,
      surface: AppColors.backgroundSurface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.borderDefault,
      outlineVariant: AppColors.borderDefault,
      shadow: AppColors.shadowSoft,
    );
    return _build(scheme, AppColors.backgroundApp, AppColors.textDisabled);
  }

  static ThemeData _build(ColorScheme scheme, Color appBackground, Color disabled) {
    final controlShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusControl));
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.radius),
      side: BorderSide(color: scheme.outline, width: Dimensions.strokeDivider),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      scaffoldBackgroundColor: appBackground,
      disabledColor: disabled,
      fontFamily: AppTextStyles.bodyFamily,
      textTheme: AppTextStyles.textTheme(primary: scheme.onSurface, secondary: scheme.onSurfaceVariant),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      dividerTheme: DividerThemeData(color: scheme.outline, thickness: Dimensions.strokeDivider, space: 1),

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.h3Mobile.copyWith(color: scheme.onSurface),
      ),

      // Card: 12px radius, 1px border, no elevation (Flat). Soft elevation is AppCard.
      cardTheme: CardThemeData(color: scheme.surface, elevation: 0, margin: EdgeInsets.zero, shape: cardShape),

      // Button: 48px high, 8px radius, 14/20 Inter Medium label.
      // Primary: default / hover / focus (2px ring) / disabled.
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, Dimensions.buttonMinHeight)),
          fixedSize: const WidgetStatePropertyAll(Size.fromHeight(Dimensions.buttonMinHeight)),
          visualDensity: VisualDensity.standard,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: Dimensions.controlY),
          ),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(AppTextStyles.label),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return appBackground;
            if (s.contains(WidgetState.hovered) || s.contains(WidgetState.pressed)) return scheme.secondary;
            return scheme.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? disabled : scheme.onPrimary,
          ),
          side: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.focused)
                ? BorderSide(color: scheme.secondary, width: Dimensions.strokeFocus)
                : BorderSide.none,
          ),
        ),
      ),

      // Secondary: surface fill, 1px border, brand-colored label.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, Dimensions.buttonMinHeight)),
          fixedSize: const WidgetStatePropertyAll(Size.fromHeight(Dimensions.buttonMinHeight)),
          visualDensity: VisualDensity.standard,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: Dimensions.controlY),
          ),
          elevation: const WidgetStatePropertyAll(0),
          shape: WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(AppTextStyles.label),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return appBackground;
            if (s.contains(WidgetState.hovered) || s.contains(WidgetState.pressed)) return scheme.primaryContainer;
            return scheme.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return disabled;
            if (s.contains(WidgetState.hovered) || s.contains(WidgetState.pressed)) return scheme.secondary;
            return scheme.primary;
          }),
          side: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.focused)
                ? BorderSide(color: scheme.primary, width: Dimensions.strokeFocus)
                : BorderSide(color: scheme.outline, width: Dimensions.strokeDivider),
          ),
        ),
      ),

      // Text link: 14/20 Inter Medium in the brand color (e.g. "View Full Queue").
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, Dimensions.buttonMinHeight)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: Dimensions.controlX)),
          shape: WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(AppTextStyles.label),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return disabled;
            if (s.contains(WidgetState.hovered) || s.contains(WidgetState.pressed)) return scheme.secondary;
            return scheme.primary;
          }),
          side: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.focused) ? BorderSide(color: scheme.primary, width: Dimensions.strokeFocus) : BorderSide.none,
          ),
        ),
      ),

      // Input: 48px, 16px body text, 1px border; 2px brand border on focus;
      // disabled uses the app background and disabled text color. The label
      // is external to the field (see AppTextField).
      inputDecorationTheme: InputDecorationTheme(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        filled: true,
        fillColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.disabled) ? appBackground : scheme.surface,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: Dimensions.controlY),
        hintStyle: WidgetStateTextStyle.resolveWith(
          (s) => AppTextStyles.body.copyWith(color: s.contains(WidgetState.disabled) ? disabled : scheme.onSurfaceVariant),
        ),
        errorStyle: AppTextStyles.caption.copyWith(color: scheme.error),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: _inputBorder(scheme.outline, Dimensions.strokeDivider),
        enabledBorder: _inputBorder(scheme.outline, Dimensions.strokeDivider),
        disabledBorder: _inputBorder(scheme.outline, Dimensions.strokeDivider),
        focusedBorder: _inputBorder(scheme.primary, Dimensions.strokeFocus),
        errorBorder: _inputBorder(scheme.error, Dimensions.strokeDivider),
        focusedErrorBorder: _inputBorder(scheme.error, Dimensions.strokeFocus),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: scheme.primary),

      // Tablet navigation rail, styled like the nav items.
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: controlShape,
        selectedIconTheme: IconThemeData(color: scheme.primary, size: Dimensions.iconSize),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: Dimensions.iconSize),
        selectedLabelTextStyle: AppTextStyles.caption.copyWith(color: scheme.primary),
        unselectedLabelTextStyle: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        borderSide: BorderSide(color: color, width: width),
      );
}
