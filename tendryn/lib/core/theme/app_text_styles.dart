import 'package:flutter/material.dart';

/// Typography from the Figma design system ("Tendryn DS / 01"). Every value is
/// the Figma text style: family, weight, size and line height (letter spacing
/// is 0 in all styles).
///
/// Headings use Plus Jakarta Sans; UI and body text use Inter (both bundled as
/// variable fonts in assets/fonts). Colors are not baked in: apply them via
/// the theme's text theme or `copyWith(color: ...)`.
abstract class AppTextStyles {
  static const String headingFamily = 'Plus Jakarta Sans';
  static const String bodyFamily = 'Inter';

  static TextStyle _style(String family, double size, double lineHeight, int weight) => TextStyle(
        fontFamily: family,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: FontWeight.values[(weight ~/ 100) - 1],
        fontVariations: [FontVariation.weight(weight.toDouble())],
        letterSpacing: 0,
      );

  // Tendryn/Web/* (tablet + desktop)
  static final TextStyle h1 = _style(headingFamily, 32, 40, 700); // Web/H1
  static final TextStyle h2 = _style(headingFamily, 24, 32, 600); // Web/H2
  static final TextStyle h3 = _style(headingFamily, 20, 28, 600); // Web/H3

  /// Plus Jakarta Sans Bold 24/32: the Nurse Triage queue page title (Web/H2 size at Bold).
  static final TextStyle h2Bold = _style(headingFamily, 24, 32, 700);

  // Tendryn/Mobile/*
  static final TextStyle h1Mobile = _style(headingFamily, 28, 36, 700); // Mobile/H1
  static final TextStyle h2Mobile = _style(headingFamily, 22, 28, 600); // Mobile/H2
  static final TextStyle h3Mobile = _style(headingFamily, 18, 26, 600); // Mobile/H3

  // Shared Inter styles (Mobile/Body = Web/Body, Mobile/Label Secondary = Web/Label UI)
  static final TextStyle body = _style(bodyFamily, 16, 24, 400); // Web/Body, Mobile/Body
  static final TextStyle bodyMedium = _style(bodyFamily, 16, 24, 500); // Web/Body Medium
  static final TextStyle label = _style(bodyFamily, 14, 20, 500); // Web/Label UI, Mobile/Label Secondary (also buttons)
  static final TextStyle caption = _style(bodyFamily, 12, 16, 400); // Web/Caption Meta

  /// Inter Regular 14/20: supporting text under page titles (the Label UI size at Regular).
  static final TextStyle bodySmall = _style(bodyFamily, 14, 20, 400);

  /// Inter SemiBold 10/20: the small field labels on the mobile appointment
  /// cards in the Dashboard design (not one of the named Figma text styles).
  static final TextStyle micro = _style(bodyFamily, 10, 20, 600);

  /// Tabular figures: required for vitals, ZAR amounts, times and ICD-10 codes
  /// so digits line up. Wrap any numeric style: `AppTextStyles.tabular(style)`.
  static TextStyle tabular(TextStyle style) =>
      style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// Material text theme. All 15 slots are bound to a Figma style so no
  /// Material default size or weight can appear.
  static TextTheme textTheme({required Color primary, required Color secondary}) => TextTheme(
        displayLarge: h1.copyWith(color: primary),
        displayMedium: h1.copyWith(color: primary),
        displaySmall: h1.copyWith(color: primary),
        headlineLarge: h1.copyWith(color: primary),
        headlineMedium: h1.copyWith(color: primary),
        headlineSmall: h2.copyWith(color: primary),
        titleLarge: h2.copyWith(color: primary),
        titleMedium: h3.copyWith(color: primary),
        titleSmall: bodyMedium.copyWith(color: primary),
        bodyLarge: body.copyWith(color: primary),
        bodyMedium: body.copyWith(color: primary),
        bodySmall: caption.copyWith(color: secondary),
        labelLarge: label.copyWith(color: primary),
        labelMedium: label.copyWith(color: primary),
        labelSmall: caption.copyWith(color: secondary),
      );
}
