import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/widgets/common/connectivity_sync_chip.dart';
import 'package:tendryn/widgets/common/app_user_badge.dart';
import 'package:tendryn/widgets/common/sync_chip.dart';
import 'package:tendryn/widgets/common/user_menu.dart';

/// Desktop header (64px): workspace name on the left, signed-in user with
/// role and account menu on the right.
class DesktopTopBar extends GetView<AuthController> {
  const DesktopTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The Nurse top bar sits on the surface color; the other roles on the app background.
    return Obx(() => Container(
      height: Dimensions.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginDesktop),
      decoration: BoxDecoration(
        color: Get.isRegistered<RoleController>() && RoleController.to.currentRole.value == ClinicRole.nurse
            ? scheme.surface
            : Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: scheme.outline, width: Dimensions.strokeDivider)),
      ),
      child: Obx(() {
        final hasRole = Get.isRegistered<RoleController>();
        final hasAuth = Get.isRegistered<AuthController>();
        if (!hasRole && !hasAuth) {
          return const SizedBox.shrink();
        }

        final isDoctor = hasRole && RoleController.to.currentRole.value == ClinicRole.doctor;
        final user = hasAuth ? controller.user : null;
        final clinicName = user?.clinicName ?? 'Ubuntu Family Clinic';
        final doctorName = user?.name ?? 'Dr. Maya Naidoo';

        if (hasRole && (RoleController.to.currentRole.value == ClinicRole.nurse || RoleController.to.currentRole.value == ClinicRole.labStaff)) {
          final role = RoleController.to.currentRole.value;
          final effectiveClinic = role == ClinicRole.labStaff ? 'Soweto Community Health Centre' : clinicName;
          return _staffBar(context, user?.name ?? role.demoUserName, effectiveClinic, role.jobTitle);
        }

        if (isDoctor) {
          return Row(
            children: [
              Icon(AppIcons.hospital, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                clinicName,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              const SyncChip(state: SyncState.deviceOnly),
              const SizedBox(width: 14),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(AppIcons.notifications, size: 20, color: scheme.onSurfaceVariant),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.triageRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              UserMenu(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _getInitials(doctorName),
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctorName,
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          Text(
                            'Switch user',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Icon(AppIcons.chevronDown, size: 16, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Text(
                clinicName,
                style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user != null)
              UserMenu(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: AppUserBadge(name: user.name, caption: user.jobTitle)),
                    const SizedBox(width: Dimensions.componentGap),
                    Icon(AppIcons.chevronDown, size: Dimensions.iconSize, color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
          ],
        );
      }),
    ));
  }

  /// Staff top bar (Figma): clinic name on the left;
  /// sync chip, notifications, and the staff profile with the Switch user menu on the right.
  Widget _staffBar(BuildContext context, String name, String clinicName, String jobTitle) {
    final scheme = Theme.of(context).colorScheme;

    final userMenu = UserMenu(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
              child: Text(
                Formatters.staffInitials(name),
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  '$jobTitle · Switch user',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(AppIcons.chevronDown, size: 16, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );

    return Row(
      children: [
        Icon(AppIcons.hospital, size: 18, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          'Soweto Community Health Centre',
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const Spacer(),
        const ConnectivitySyncChip(
          offlineState: SyncState.deviceOnly,
          offlineLabel: 'Device only',
        ),
        const SizedBox(width: 14),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(AppIcons.notifications, size: 20, color: scheme.onSurfaceVariant),
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.triageRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        userMenu,
      ],
    );
  }

  String _getInitials(String name) {
    final clean = name.replaceAll(RegExp(r'^(Dr|Mr|Mrs|Ms)\.?\s*', caseSensitive: false), '').trim();
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'MN';
  }
}
