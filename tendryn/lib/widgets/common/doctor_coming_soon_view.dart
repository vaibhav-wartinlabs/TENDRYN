import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// Clean, minimal view for under-development pages.
/// Displays the page heading on the top-left and 'Coming Soon' in the center.
class DoctorComingSoonView extends StatelessWidget {
  const DoctorComingSoonView({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final margin = isMobile ? Dimensions.pageMarginMobile : Dimensions.pageMarginDesktop;

    final roleLabel = Get.isRegistered<RoleController>()
        ? RoleController.to.currentRole.value.label
        : null;
    final defaultSubtitle = roleLabel != null
        ? 'This page is under development for $roleLabel role.'
        : 'This page is under development.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top-left Heading
        Padding(
          padding: EdgeInsets.only(
            left: margin,
            top: margin,
            right: margin,
          ),
          child: Text(
            title,
            style: (isMobile ? AppTextStyles.h1Mobile : AppTextStyles.h1).copyWith(
              color: scheme.onSurface,
            ),
          ),
        ),

        // Center Coming Soon
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.clock,
                    size: 26,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: Dimensions.spaceMd),
                Text(
                  'Coming Soon',
                  style: AppTextStyles.h2.copyWith(
                    color: scheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: Dimensions.spaceXs),
                Text(
                  subtitle ?? defaultSubtitle,
                  style: AppTextStyles.body.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
