import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// Shared frame of the clinical banners: 16px padding, 8px radius, 1px border.
/// Colors are fixed (system-controlled) and must never follow clinic branding
/// or the light/dark theme, so they are set explicitly here.
class _Banner extends StatelessWidget {
  const _Banner({
    required this.background,
    required this.border,
    required this.leading,
    required this.message,
    required this.textColor,
  });

  final Color background;
  final Color border;
  final Widget leading;
  final String message;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.controlX),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          border: Border.all(color: border, width: Dimensions.strokeDivider),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: Dimensions.componentGap),
            Expanded(child: Text(message, style: AppTextStyles.bodyMedium.copyWith(color: textColor))),
          ],
        ),
      ),
    );
  }
}

/// Pin at the top of every patient-facing clinical view. Critical colors stay fixed.
class AllergyBanner extends StatelessWidget {
  const AllergyBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _Banner(
      background: AppColors.safetyCriticalBackground,
      border: AppColors.safetyCriticalText,
      leading: const Icon(AppIcons.alert, size: Dimensions.iconSize + 2, color: AppColors.safetyCriticalText),
      message: message,
      textColor: AppColors.safetyCriticalText,
    );
  }
}

/// Persistent amber notice while work is saved on the device and awaits sync.
/// Do not imply the work was lost.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    this.message = 'Working on this device. All changes are saved and will sync automatically.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return _Banner(
      background: AppColors.syncDeviceOnlyBackground,
      border: AppColors.syncDeviceOnly,
      leading: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(color: AppColors.syncDeviceOnly, shape: BoxShape.circle),
      ),
      message: message,
      textColor: AppColors.textPrimary,
    );
  }
}
