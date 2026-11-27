import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/patients/controllers/patient_quick_view_controller.dart';

class AssignPractitionerDropdown extends StatelessWidget {
  const AssignPractitionerDropdown({super.key, required this.controller});

  final PatientQuickViewController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign practitioner',
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: Dimensions.spaceSm),
        GetBuilder<PatientQuickViewController>(
          init: controller,
          builder: (ctrl) {
            final isOpen = ctrl.isDropdownOpen.value;
            final selectedValue = ctrl.selectedPractitioner.value;
            final options = ctrl.practitioners;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.toggleDropdown,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  hoverColor: AppColors.brandTint,
                  splashColor: Colors.transparent,
                  highlightColor: AppColors.brandTint,
                  overlayColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                      return AppColors.brandTint;
                    }
                    return Colors.transparent;
                  }),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceMd),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                      border: Border.all(
                        color: isOpen ? AppColors.brandPrimary : AppColors.borderDefault,
                        width: Dimensions.strokeDivider,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedValue,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Icon(
                          isOpen ? AppIcons.chevronUp : AppIcons.chevronDown,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isOpen) ...[
                const SizedBox(height: Dimensions.spaceXs),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    border: Border.all(
                      color: AppColors.borderDefault,
                      width: Dimensions.strokeDivider,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowSoft,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: options.map((option) {
                        final isSelected = option == selectedValue;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.selectPractitioner(option),
                            hoverColor: AppColors.brandTint,
                            splashColor: Colors.transparent,
                            highlightColor: AppColors.brandTint,
                            overlayColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                                return AppColors.brandTint;
                              }
                              return Colors.transparent;
                            }),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceMd),
                              decoration: isSelected
                                  ? const BoxDecoration(
                                      color: AppColors.brandTint,
                                    )
                                  : null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    option,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      AppIcons.check,
                                      size: 20,
                                      color: AppColors.brandPrimary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }
}
