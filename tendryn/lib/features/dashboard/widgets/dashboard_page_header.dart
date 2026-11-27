import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/connectivity_sync_chip.dart';

/// Top of the Dashboard. Adapts dynamically based on active role (Doctor vs Receptionist).
class DashboardPageHeader extends GetView<DashboardController> {
  const DashboardPageHeader({super.key, required this.screenType});

  final LayoutType screenType;

  Widget _buildDesktopHeader(BuildContext context, ColorScheme scheme, bool isDoctor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: AppTextStyles.h1.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: Dimensions.spaceXs),
              Text(
                isDoctor
                    ? 'Your patient queue, appointments, and clinical tasks at a glance.'
                    : 'Front desk overview for today',
                style: AppTextStyles.body.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (isDoctor)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.controlX + 4,
                vertical: Dimensions.controlY + 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              ),
            ),
            onPressed: () => AppNavigation.goTo(AppRoutes.queue),
            child: const Text(
              'View Patient Queue',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.controlX,
              vertical: Dimensions.controlY,
            ),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(
                color: scheme.outline,
                width: Dimensions.strokeDivider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.calendarDays,
                  size: Dimensions.iconSize,
                  color: scheme.onSurface,
                ),
                const SizedBox(width: Dimensions.componentGap),
                Text(
                  controller.todayLabel,
                  style: AppTextStyles.label.copyWith(color: scheme.onSurface),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (Get.isRegistered<RoleController>()) {
      return Obx(() {
        final isDoctor = RoleController.to.currentRole.value == ClinicRole.doctor;

        if (isDoctor) {
          if (screenType == LayoutType.desktop || screenType == LayoutType.tablet) {
            return _buildDesktopHeader(context, scheme, true);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: AppTextStyles.h1Mobile.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: Dimensions.spaceXs),
              Text(
                'Your patient queue, appointments, and clinical tasks at a glance.',
                style: AppTextStyles.body.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }

        if (screenType == LayoutType.desktop) {
          return _buildDesktopHeader(context, scheme, false);
        }
        return _buildReceptionistHeader(context, scheme);
      });
    }

    if (screenType == LayoutType.desktop) {
      return _buildDesktopHeader(context, scheme, false);
    }
    return _buildReceptionistHeader(context, scheme);
  }

  Widget _buildReceptionistHeader(BuildContext context, ColorScheme scheme) {
    final isMobile = screenType == LayoutType.mobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                controller.todayLabel,
                style: AppTextStyles.label.copyWith(color: scheme.primary),
              ),
            ),
            if (!isMobile) const ConnectivitySyncChip(),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          controller.greeting,
          style: (isMobile ? AppTextStyles.h1Mobile : AppTextStyles.h1)
              .copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 6),
        Text(
          controller.greetingSubtitle,
          style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
