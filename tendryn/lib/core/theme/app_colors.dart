import 'package:flutter/material.dart';

/// Complete Tendryn color palette, from the Figma file's variables.
/// Source: https://www.figma.com/design/2WJ3m2g9ycodx33rkpWIKn/Tendryn
///
/// Add new tokens here only; never write a raw hex color in a widget.
abstract class AppColors {
  // Brand
  static const Color brandPrimary = Color(0xFF0F766E); // --color-brand-primary
  static const Color brandHover = Color(0xFF115E59); // --color-brand-hover
  static const Color brandTint = Color(0xFFE6F4F2); // --color-brand-tint

  // Backgrounds
  static const Color backgroundApp = Color(0xFFF6FAF9); // --color-background-app
  static const Color backgroundSurface = Color(0xFFFFFFFF); // --color-background-surface

  // Text
  static const Color textPrimary = Color(0xFF0F1F1D); // --color-text-primary
  static const Color textSecondary = Color(0xFF5B6B69); // --color-text-secondary
  static const Color textDisabled = Color(0xFF9AA9A7); // --color-text-disabled
  static const Color textOnBrand = Color(0xFFFFFFFF); // --color-text-on-brand

  // Borders
  static const Color borderDefault = Color(0xFFDDE7E5); // --color-border-default

  // Status tints: soft backgrounds for status badges (Dashboard design). They are
  // raw values in the Figma frames, not variables; each pairs with the
  // matching feedback/brand text color below.
  static const Color feedbackSuccessTint = Color(0xFFECFDF3); // text: feedbackSuccess
  static const Color feedbackInfoTint = Color(0xFFEFF6FF); // text: feedbackInfo
  static const Color feedbackWarningTint = Color(0xFFFFF7ED); // text: feedbackWarning

  // Doctor appointment status pills (raw values in the Figma frames)
  static const Color statusRescheduledTint = Color(0xFFFFFBEB); // text: feedbackWarning
  static const Color statusCancelledTint = Color(0xFFFEF2F2); // text: safetyCriticalText
  static const Color statusNoShowTint = Color(0xFFF1F5F4); // text: textSecondary

  // Appointment details: read-only alert border and the dim behind drawers and sheets
  static const Color infoBorder = Color(0xFFBFD7FE);
  static const Color scrim = Color(0xA30F1F1D); // #0F1F1D at 64%

  // Request Leave: invalid field border and the warning alert border (tint: statusRescheduledTint, text: feedbackWarning)
  static const Color fieldErrorBorder = Color(0xFFDC2626);
  static const Color warningAlertBorder = Color(0xFFF5D58A);
  static const Color errorAlertBorder = Color(0xFFF5B5B5); // tint: statusCancelledTint, text: safetyCriticalText

  // Doctor week grid: tint of today's column
  static const Color weekTodayTint = Color(0xFFF3FAF8);

  // Feedback & safety (fixed; never replaced by clinic branding)
  static const Color feedbackSuccess = Color(0xFF15803D); // --color-feedback-success
  static const Color feedbackInfo = Color(0xFF1D4ED8); // --color-feedback-info
  static const Color safetyCriticalText = Color(0xFFB91C1C); // --color-safety-critical-text
  static const Color safetyCriticalBackground = Color(0xFFFEE2E2); // --color-safety-critical-background

  // Triage / queue priority (SATS, system-controlled)
  static const Color triageGreen = Color(0xFF16A34A); // --color-triage-green
  static const Color triageOrange = Color(0xFFEA580C); // --color-triage-orange
  static const Color triageRed = Color(0xFFDC2626); // --color-triage-red
  static const Color triageYellow = Color(0xFFEAB308); // --color-triage-yellow

  // Appointments: double-booking notice and week grid header
  static const Color warningSoftBackground = Color(0xFFFFF6E2);
  static const Color warningSoftText = Color(0xFFAC5800);
  static const Color gridHeader = Color(0xFFF0F4F3);
  static const Color leavePillBackground = Color(0xFFFEF3E2);
  static const Color neutralPillBackground = Color(0xFFEEF2F1);

  // Priority options in the Add Walk-in dropdown
  static const Color priorityUrgent = Color(0xFFD97706);
  static const Color priorityEmergency = Color(0xFFDC2626);

  // Sync status
  static const Color syncSynced = Color(0xFF16A34A); // --color-sync-synced
  static const Color syncDeviceOnly = Color(0xFFD97706); // --color-sync-device-only
  static const Color syncSyncing = Color(0xFF2563EB); // --color-sync-syncing
  static const Color syncNeedsAttention = Color(0xFFDC2626); // --color-sync-needs-attention
  static const Color syncDeviceOnlyBackground = Color(0xFFFFF7E6); // --color-sync-device-only-background

  // Feedback
  static const Color feedbackWarning = Color(0xFFB45309); // --color-feedback-warning

  // Elevation shadow: Tendryn/Elevation/Soft (#0F1F1D14)
  static const Color shadowSoft = Color(0x140F1F1D);
}
