import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/theme/app_theme.dart';

/// Locks the Flutter theme to the values read from the Figma file
/// "Tendryn DS / 01" (variable definitions). If design changes a token,
/// update Figma first, then these expectations and the theme files together.
void main() {
  test('AppColors match the Figma color variables', () {
    final expected = <(Color, int)>[
      (AppColors.brandPrimary, 0xFF0F766E),
      (AppColors.brandHover, 0xFF115E59),
      (AppColors.brandTint, 0xFFE6F4F2),
      (AppColors.backgroundApp, 0xFFF6FAF9),
      (AppColors.backgroundSurface, 0xFFFFFFFF),
      (AppColors.textPrimary, 0xFF0F1F1D),
      (AppColors.textSecondary, 0xFF5B6B69),
      (AppColors.textDisabled, 0xFF9AA9A7),
      (AppColors.textOnBrand, 0xFFFFFFFF),
      (AppColors.borderDefault, 0xFFDDE7E5),
      (AppColors.feedbackSuccess, 0xFF15803D),
      (AppColors.feedbackWarning, 0xFFB45309),
      (AppColors.feedbackInfo, 0xFF1D4ED8),
      (AppColors.safetyCriticalText, 0xFFB91C1C),
      (AppColors.safetyCriticalBackground, 0xFFFEE2E2),
      (AppColors.syncSynced, 0xFF16A34A),
      (AppColors.syncDeviceOnly, 0xFFD97706),
      (AppColors.syncSyncing, 0xFF2563EB),
      (AppColors.syncNeedsAttention, 0xFFDC2626),
      (AppColors.syncDeviceOnlyBackground, 0xFFFFF7E6),
      (AppColors.triageRed, 0xFFDC2626),
      (AppColors.triageOrange, 0xFFEA580C),
      (AppColors.triageYellow, 0xFFEAB308),
      (AppColors.triageGreen, 0xFF16A34A),
    ];
    for (final (color, value) in expected) {
      expect(color.toARGB32(), value);
    }
  });

  test('AppTextStyles match the Figma text styles', () {
    void check(TextStyle s, String family, double size, double lineHeight, FontWeight weight) {
      expect(s.fontFamily, family);
      expect(s.fontSize, size);
      expect(s.height! * s.fontSize!, closeTo(lineHeight, 0.001));
      expect(s.fontWeight, weight);
      expect(s.letterSpacing, 0);
    }

    const heading = 'Plus Jakarta Sans';
    const body = 'Inter';
    check(AppTextStyles.h1, heading, 32, 40, FontWeight.w700);
    check(AppTextStyles.h2, heading, 24, 32, FontWeight.w600);
    check(AppTextStyles.h3, heading, 20, 28, FontWeight.w600);
    check(AppTextStyles.h1Mobile, heading, 28, 36, FontWeight.w700);
    check(AppTextStyles.h2Mobile, heading, 22, 28, FontWeight.w600);
    check(AppTextStyles.h3Mobile, heading, 18, 26, FontWeight.w600);
    check(AppTextStyles.body, body, 16, 24, FontWeight.w400);
    check(AppTextStyles.bodyMedium, body, 16, 24, FontWeight.w500);
    check(AppTextStyles.label, body, 14, 20, FontWeight.w500);
    check(AppTextStyles.caption, body, 12, 16, FontWeight.w400);
  });

  test('AppTheme.light applies the tokens and every text slot uses a Figma style', () {
    final theme = AppTheme.light();
    expect(theme.colorScheme.primary, AppColors.brandPrimary);
    expect(theme.scaffoldBackgroundColor, AppColors.backgroundApp);
    expect(theme.colorScheme.surface, AppColors.backgroundSurface);
    expect(theme.colorScheme.outline, AppColors.borderDefault);

    final figmaSizes = {32.0, 24.0, 20.0, 16.0, 14.0, 12.0};
    final slots = [
      theme.textTheme.displayLarge, theme.textTheme.displayMedium, theme.textTheme.displaySmall,
      theme.textTheme.headlineLarge, theme.textTheme.headlineMedium, theme.textTheme.headlineSmall,
      theme.textTheme.titleLarge, theme.textTheme.titleMedium, theme.textTheme.titleSmall,
      theme.textTheme.bodyLarge, theme.textTheme.bodyMedium, theme.textTheme.bodySmall,
      theme.textTheme.labelLarge, theme.textTheme.labelMedium, theme.textTheme.labelSmall,
    ];
    for (final s in slots) {
      expect(figmaSizes, contains(s!.fontSize));
      expect(s.letterSpacing, 0);
    }
  });
}
