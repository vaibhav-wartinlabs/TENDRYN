import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/constants/app_config.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/widgets/common/app_icon_button.dart';
import 'package:tendryn/widgets/common/app_user_badge.dart';
import 'package:tendryn/widgets/common/brand_logo.dart';
import 'package:tendryn/widgets/common/connectivity_sync_chip.dart';
import 'package:tendryn/widgets/common/sync_chip.dart';
import 'package:tendryn/widgets/common/user_menu.dart';

/// Phone header: a brand row (logo, search button, avatar) over a context row
/// (workspace + clinic, with the sync chip). It sits below the status bar.
class MobileHeader extends GetView<AuthController> {
  const MobileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outline, width: Dimensions.strokeDivider)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.pageMarginMobile,
            vertical: 10,
          ),
          child: Obx(() {
            final hasRole = Get.isRegistered<RoleController>();
            final hasAuth = Get.isRegistered<AuthController>();
            if (!hasRole && !hasAuth) {
              return const Row(
                children: [
                  BrandLogo(height: 30),
                ],
              );
            }

            final isDoctor = hasRole && RoleController.to.currentRole.value == ClinicRole.doctor;
            final user = hasAuth ? controller.user : null;

            if (hasRole && (RoleController.to.currentRole.value == ClinicRole.nurse || RoleController.to.currentRole.value == ClinicRole.labStaff)) {
              final role = RoleController.to.currentRole.value;
              final name = user?.name ?? role.demoUserName;
              return SizedBox(
                height: 44,
                child: Row(
                  children: [
                    const BrandLogo(height: 38),
                    const Spacer(),
                    const ConnectivitySyncChip(offlineLabel: 'Sync pending'),
                    const SizedBox(width: Dimensions.componentGap),
                    UserMenu(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
                          child: Text(
                            Formatters.staffInitials(name),
                            style: AppTextStyles.label.copyWith(color: scheme.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (isDoctor) {
              return Row(
                children: [
                  const BrandLogo(height: 28),
                  const Spacer(),
                  const SyncChip(state: SyncState.deviceOnly),
                  const SizedBox(width: 8),
                  UserMenu(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          'TN',
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const BrandLogo(height: 38),
                    const Spacer(),
                    AppIconButton(tooltip: 'Patient search', onPressed: () => AppNotice.unavailable('Patient search')),
                    if (user != null) ...[
                      const SizedBox(width: Dimensions.componentGap),
                      UserMenu(child: AppUserBadge(name: user.name, compact: true)),
                    ],
                  ],
                ),
                const SizedBox(height: Dimensions.componentGap),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            [AppConfig.appName, if (user?.jobTitle != null) user!.jobTitle!].join(' · '),
                            style: AppTextStyles.bodyMedium.copyWith(color: scheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user?.clinicName != null)
                            Text(user!.clinicName!, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const ConnectivitySyncChip(),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
