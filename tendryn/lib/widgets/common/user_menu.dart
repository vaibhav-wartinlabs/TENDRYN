import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// Wraps [child] (usually the user badge) in the account menu: Switch Role & Sign out.
class UserMenu extends StatelessWidget {
  const UserMenu({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final roleController = Get.isRegistered<RoleController>() ? RoleController.to : null;

    return PopupMenuButton<void>(
      tooltip: 'Account & Switch User',
      offset: const Offset(0, Dimensions.touchTarget),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        side: BorderSide(color: scheme.outline),
      ),
      itemBuilder: (_) => [
        if (roleController != null) ...[
          PopupMenuItem<void>(
            enabled: false,
            height: 28,
            child: Text(
              'SWITCH CLINICAL ROLE',
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          PopupMenuItem<void>(
            onTap: () => roleController.switchRole(ClinicRole.doctor),
            child: Row(
              children: [
                Icon(
                  AppIcons.clinic,
                  size: Dimensions.iconSize,
                  color: roleController.currentRole.value == ClinicRole.doctor
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: Dimensions.componentGap),
                Expanded(
                  child: Text(
                    'Doctor (Dr Thandi Nkosi)',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: roleController.currentRole.value == ClinicRole.doctor
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: roleController.currentRole.value == ClinicRole.doctor
                          ? scheme.primary
                          : scheme.onSurface,
                    ),
                  ),
                ),
                if (roleController.currentRole.value == ClinicRole.doctor)
                  Icon(AppIcons.check, size: 16, color: scheme.primary),
              ],
            ),
          ),
          PopupMenuItem<void>(
            onTap: () => roleController.switchRole(ClinicRole.receptionist),
            child: Row(
              children: [
                Icon(
                  AppIcons.userCheck,
                  size: Dimensions.iconSize,
                  color: roleController.currentRole.value == ClinicRole.receptionist
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: Dimensions.componentGap),
                Expanded(
                  child: Text(
                    'Receptionist (Lerato Mokoena)',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: roleController.currentRole.value == ClinicRole.receptionist
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: roleController.currentRole.value == ClinicRole.receptionist
                          ? scheme.primary
                          : scheme.onSurface,
                    ),
                  ),
                ),
                if (roleController.currentRole.value == ClinicRole.receptionist)
                  Icon(AppIcons.check, size: 16, color: scheme.primary),
              ],
            ),
          ),
          PopupMenuItem<void>(
            onTap: () => roleController.switchRole(ClinicRole.nurse),
            child: Row(
              children: [
                Icon(
                  AppIcons.nurse,
                  size: Dimensions.iconSize,
                  color: roleController.currentRole.value == ClinicRole.nurse
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: Dimensions.componentGap),
                Expanded(
                  child: Text(
                    'Nurse (Sister Naledi Naidoo)',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: roleController.currentRole.value == ClinicRole.nurse
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: roleController.currentRole.value == ClinicRole.nurse
                          ? scheme.primary
                          : scheme.onSurface,
                    ),
                  ),
                ),
                if (roleController.currentRole.value == ClinicRole.nurse)
                  Icon(AppIcons.check, size: 16, color: scheme.primary),
              ],
            ),
          ),
          PopupMenuItem<void>(
            onTap: () => roleController.switchRole(ClinicRole.labStaff),
            child: Row(
              children: [
                Icon(
                  AppIcons.labResults,
                  size: Dimensions.iconSize,
                  color: roleController.currentRole.value == ClinicRole.labStaff
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: Dimensions.componentGap),
                Expanded(
                  child: Text(
                    'Lab Staff (Lerato Mokoena)',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: roleController.currentRole.value == ClinicRole.labStaff
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: roleController.currentRole.value == ClinicRole.labStaff
                          ? scheme.primary
                          : scheme.onSurface,
                    ),
                  ),
                ),
                if (roleController.currentRole.value == ClinicRole.labStaff)
                  Icon(AppIcons.check, size: 16, color: scheme.primary),
              ],
            ),
          ),
          const PopupMenuDivider(),
        ],
        PopupMenuItem<void>(
          onTap: () {
            if (Get.isRegistered<AuthController>()) {
              Get.find<AuthController>().logout();
            }
          },
          child: const Row(
            children: [
              Icon(AppIcons.logout, size: Dimensions.iconSize),
              SizedBox(width: Dimensions.componentGap),
              Text('Sign out'),
            ],
          ),
        ),
      ],
      child: child,
    );
  }
}
