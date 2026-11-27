import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/widgets/common/brand_logo.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';
import 'package:tendryn/widgets/common/nav_item.dart';

/// Desktop: fixed 248px left menu with the Tendryn logo, labelled destinations,
/// badge indicators, and role switcher.
class AppSideNavigation extends StatelessWidget {
  const AppSideNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDoctor = Get.isRegistered<RoleController>() &&
        RoleController.to.currentRole.value == ClinicRole.doctor;

    return Container(
      width: Dimensions.sideNavWidth,
      padding: const EdgeInsets.only(
        top: 20,
        left: Dimensions.spaceMd,
        right: Dimensions.spaceMd,
        bottom: Dimensions.spaceMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: BorderSide(color: scheme.outline, width: Dimensions.strokeDivider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: BrandLogo(height: 52)),
          const SizedBox(height: Dimensions.spaceLg),
          for (final (i, d) in destinations.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.spaceXs),
              child: AppNavItem(
                icon: d.icon,
                label: d.label,
                badgeCount: isDoctor && (d.label == 'Queue' || d.label == 'Lab Results') ? 3 : d.badgeCount,
                selected: i == selectedIndex,
                tooltip: 'Ctrl+${i + 1}',
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}
