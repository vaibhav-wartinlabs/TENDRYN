import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/lab_results/models/lab_result_model.dart';

class LabResultStatusPill extends StatelessWidget {
  const LabResultStatusPill({
    super.key,
    required this.status,
  });

  final LabReviewStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      LabReviewStatus.awaitingReview => (
          AppColors.feedbackWarningTint,
          const Color(0xFFC2410C),
        ),
      LabReviewStatus.reviewed => (
          AppColors.feedbackSuccessTint,
          AppColors.feedbackSuccess,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.badgePaddingX,
        vertical: Dimensions.badgePaddingY,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Dimensions.radiusPill),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
