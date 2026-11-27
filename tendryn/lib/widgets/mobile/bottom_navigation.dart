import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';
import 'package:tendryn/widgets/common/nav_item.dart';

/// Bottom navigation: a bar of icon-over-label destinations that share the
/// width. 64px on phones; tablets pass 76px. The active item sits on the brand tint.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.height = Dimensions.bottomNavHeight,
    this.showTopShadow = true,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double height;
  final bool showTopShadow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: showTopShadow
            ? const [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ]
            : null,
      ),
      // Keep the bar clear of the system gesture area.
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceXs),
          child: SizedBox(
            height: height,
            child: Row(
              spacing: 2,
              children: [
                for (final (i, d) in destinations.indexed)
                  Expanded(
                    child: AppNavItem(
                      icon: d.icon,
                      label: d.label,
                      selected: i == selectedIndex,
                      placement: NavItemPlacement.bottom,
                      height: height,
                      onTap: () => onSelected(i),
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
