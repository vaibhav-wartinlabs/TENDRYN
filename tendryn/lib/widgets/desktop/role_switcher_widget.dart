import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// Choice chip role switcher pinned at the bottom-left of the side navigation.
/// Allows instant switching between Doctor, Receptionist and Nurse clinical views.
class RoleSwitcherWidget extends StatelessWidget {
  const RoleSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RoleController>()) {
      return const SizedBox.shrink();
    }
    final roleController = Get.find<RoleController>();
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final active = roleController.currentRole.value;

      return Container(
        padding: const EdgeInsets.all(Dimensions.spaceSm),
        decoration: BoxDecoration(
          color: AppColors.backgroundApp,
          borderRadius: BorderRadius.circular(Dimensions.radius),
          border: Border.all(color: scheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.userCog,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: Dimensions.spaceXs),
                Text(
                  'ROLE SWITCHER',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.6,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spaceSm),
            Row(
              children: [
                Expanded(
                  child: _RoleChoiceChip(
                    label: 'Doctor',
                    icon: AppIcons.clinic,
                    isSelected: active == ClinicRole.doctor,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      roleController.switchRole(ClinicRole.doctor);
                    },
                  ),
                ),
                const SizedBox(width: Dimensions.spaceXs),
                Expanded(
                  child: _RoleChoiceChip(
                    label: 'Reception',
                    icon: AppIcons.userCheck,
                    isSelected: active == ClinicRole.receptionist,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      roleController.switchRole(ClinicRole.receptionist);
                    },
                  ),
                ),
                const SizedBox(width: Dimensions.spaceXs),
                Expanded(
                  child: _RoleChoiceChip(
                    label: 'Nurse',
                    icon: AppIcons.nurse,
                    isSelected: active == ClinicRole.nurse,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      roleController.switchRole(ClinicRole.nurse);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _RoleChoiceChip extends StatelessWidget {
  const _RoleChoiceChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label view',
      child: Material(
        color: isSelected ? scheme.surface : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: BorderSide(
            color: isSelected ? scheme.primary : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
        ),
        elevation: isSelected ? 1 : 0,
        shadowColor: AppColors.shadowSoft,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          onTap: onTap,
          hoverColor: scheme.primaryContainer.withValues(alpha: 0.4),
          child: Container(
            height: Dimensions.chipHeight,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
