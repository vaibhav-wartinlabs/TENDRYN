import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';
import 'package:tendryn/widgets/desktop/desktop_top_bar.dart';
import 'package:tendryn/widgets/desktop/side_navigation.dart';

/// Windows/desktop: fixed 248px side navigation, 64px top bar, content capped
/// to a readable width, reactive role destinations, and Ctrl+1..N shortcuts.
class DesktopScaffold extends StatelessWidget {
  const DesktopScaffold({super.key, required this.route, required this.child});

  final String route;
  final Widget child;

  static const _digitKeys = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
  ];

  Widget _buildContent(BuildContext context, List<NavDestination> destinations) {
    final selectedIndex = NavDestinations.indexOf(route, destinations);

    return CallbackShortcuts(
      bindings: {
        for (final (i, key) in _digitKeys.take(destinations.length).indexed)
          SingleActivator(key, control: true): () =>
              AppNavigation.goTo(destinations[i].route),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          // Windows has no system insets; this only matters if the desktop
          // layout is shown on an Android device in landscape or free-form mode.
          body: SafeArea(
            bottom: false,
            child: Row(
              children: [
                AppSideNavigation(
                  destinations: destinations,
                  selectedIndex: selectedIndex,
                  onSelected: (i) =>
                      AppNavigation.goTo(destinations[i].route),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const DesktopTopBar(),
                      Expanded(
                        child: child,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RoleController>()) {
      return _buildContent(context, NavDestinations.all);
    }
    return Obx(() {
      final destinations = RoleController.to.currentDestinations;
      return _buildContent(context, destinations);
    });
  }
}
