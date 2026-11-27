import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Clean placeholder view for modules currently under development.
/// Prevents blank screens and gives clear feedback and navigation paths.
class UnderDevelopmentView extends StatelessWidget {
  const UnderDevelopmentView({
    super.key,
    required this.title,
    this.icon = AppIcons.clinic,
    this.description,
  });

  final String title;
  final IconData icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isNurse = Get.isRegistered<RoleController>() &&
        RoleController.to.currentRole.value == ClinicRole.nurse;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.cardInner),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(Dimensions.radius),
              border: Border.all(color: scheme.outline),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: Dimensions.spaceLg),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.feedbackInfoTint,
                    borderRadius: BorderRadius.circular(Dimensions.radiusPill),
                    border: Border.all(color: AppColors.feedbackInfo.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(AppIcons.sparkles, size: 14, color: AppColors.feedbackInfo),
                      const SizedBox(width: 6),
                      Text(
                        'UNDER DEVELOPMENT',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.feedbackInfo,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.spaceMd),
                Text(
                  '$title Module',
                  style: AppTextStyles.h2.copyWith(color: scheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.spaceSm),
                Text(
                  description ??
                      'The $title feature is currently being designed and integrated for clinical workflows. You can return to the dashboard or explore active modules like Queue and Patients.',
                  style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.spaceXl),
                Wrap(
                  spacing: Dimensions.spaceMd,
                  runSpacing: Dimensions.spaceSm,
                  alignment: WrapAlignment.center,
                  children: [
                    if (isNurse)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(160, Dimensions.buttonMinHeight),
                          backgroundColor: scheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                          ),
                        ),
                        onPressed: () => AppNavigation.goTo(AppRoutes.queue),
                        icon: const Icon(AppIcons.queue, size: Dimensions.iconSize),
                        label: const Text('Back to Queue'),
                      )
                    else ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(140, Dimensions.buttonMinHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      onPressed: () => AppNavigation.goTo(AppRoutes.dashboard),
                      icon: const Icon(AppIcons.home, size: Dimensions.iconSize),
                      label: const Text('Back to Dashboard'),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(160, Dimensions.buttonMinHeight),
                        backgroundColor: scheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                        ),
                      ),
                      onPressed: () {
                        if (Get.isRegistered<RoleController>()) {
                          RoleController.to.switchRole(ClinicRole.receptionist);
                        }
                        AppNavigation.goTo(AppRoutes.dashboard);
                      },
                      icon: const Icon(AppIcons.userCheck, size: Dimensions.iconSize),
                      label: const Text('Receptionist View'),
                    ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
