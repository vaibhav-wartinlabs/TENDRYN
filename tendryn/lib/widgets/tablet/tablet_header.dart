import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/constants/app_config.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/widgets/common/app_icon_button.dart';
import 'package:tendryn/widgets/common/brand_logo.dart';
import 'package:tendryn/widgets/common/connectivity_sync_chip.dart';
import 'package:tendryn/widgets/common/sync_chip.dart';
import 'package:tendryn/widgets/common/user_menu.dart';

/// Tablet header (88px): logo and workspace context on the left; patient
/// search button and the user pill on the right.
class TabletHeader extends GetView<AuthController> {
  const TabletHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 600
        ? 12.0
        : (screenWidth < 768 ? 16.0 : Dimensions.pageMarginDesktop);

    return Container(
      height: Dimensions.tabletHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outline, width: Dimensions.strokeDivider)),
      ),
      child: Obx(() {
        final hasRole = Get.isRegistered<RoleController>();
        final hasAuth = Get.isRegistered<AuthController>();
        if (!hasRole && !hasAuth) {
          return const Row(
            children: [
              BrandLogo(height: 44),
            ],
          );
        }

        final isDoctor = hasRole && RoleController.to.currentRole.value == ClinicRole.doctor;
        final user = hasAuth ? controller.user : null;
        final clinicName = user?.clinicName ?? 'Ubuntu Family Clinic';

        if (hasRole && (RoleController.to.currentRole.value == ClinicRole.nurse || RoleController.to.currentRole.value == ClinicRole.labStaff)) {
          final role = RoleController.to.currentRole.value;
          final name = user?.name ?? role.demoUserName;
          return Row(
            children: [
              const BrandLogo(height: 50),
              const SizedBox(width: Dimensions.spaceMd),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.label.copyWith(color: scheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${role.jobTitle} · Switch user',
                      style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.spaceSm),
              const ConnectivitySyncChip(offlineLabel: 'Sync pending'),
              const SizedBox(width: Dimensions.spaceSm),
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
          );
        }

        if (isDoctor) {
          final screenWidth = MediaQuery.sizeOf(context).width;
          final isCompact = screenWidth < 640;

          return Row(
            children: [
              BrandLogo(height: isCompact ? 36 : 44),
              SizedBox(width: isCompact ? 10 : Dimensions.spaceMd),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      clinicName,
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.spaceSm),
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
              const SizedBox(width: 14),
              UserMenu(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 36,
                    height: 36,
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
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            const BrandLogo(height: 50),
            const SizedBox(width: Dimensions.spaceMd),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [AppConfig.appName, if (user?.jobTitle != null) user!.jobTitle!].join(' · '),
                    style: AppTextStyles.label.copyWith(color: scheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user?.clinicName != null)
                    Text(user!.clinicName!, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            AppIconButton(outlined: true, tooltip: 'Patient search', onPressed: () => AppNotice.unavailable('Patient search')),
            if (user != null) ...[
              const SizedBox(width: Dimensions.statusX),
              UserMenu(
                child: Container(
                  height: Dimensions.touchTarget,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.componentGap),
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outline, width: Dimensions.strokeDivider),
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
                        child: Text(Formatters.initials(user.name), style: AppTextStyles.caption.copyWith(color: scheme.primary)),
                      ),
                      const SizedBox(width: Dimensions.componentGap),
                      Text(user.name, style: AppTextStyles.caption.copyWith(color: scheme.onSurface)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
