import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// Lightweight user notices raised from controllers.
abstract class AppNotice {
  /// For actions whose destination feature isn't built yet.
  static void unavailable(String feature, [String message = 'Page is not generated']) {
    if (Get.context == null && Get.overlayContext == null) return;
    Get.closeAllSnackbars();
    Get.snackbar(
      feature,
      message,
      titleText: Center(
        child: Text(
          feature,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      messageText: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.transparent,
      colorText: AppColors.textPrimary,
      barBlur: 10.0,
      overlayBlur: 0.0,
      overlayColor: Colors.transparent,
      boxShadows: const [],
      duration: const Duration(seconds: 2),
    );
  }

  /// Informational notice matching the project's transparent style.
  static void info(String title, String message) {
    if (Get.context == null && Get.overlayContext == null) return;
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      titleText: Text(
        title,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.transparent,
      colorText: AppColors.textPrimary,
      barBlur: 10.0,
      overlayBlur: 0.0,
      overlayColor: Colors.transparent,
      boxShadows: const [],
      duration: const Duration(seconds: 2),
    );
  }
}

