import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';
import 'package:tendryn/widgets/mobile/doctor_more_bottom_sheet.dart';
import 'package:tendryn/widgets/mobile/mobile_header.dart';

/// Phone: header, single-column content, bottom navigation with role awareness.
class MobileScaffold extends StatelessWidget {
  const MobileScaffold({
    super.key,
    required this.route,
    required this.child,
    this.showBottomNavigation = true,
    this.showHeader = true,
  });

  final String route;
  final Widget child;
  final bool showBottomNavigation;

  /// False when the page draws its own heading; the content then clears the status bar itself.
  final bool showHeader;

  Widget _buildBottomNav(
    BuildContext context,
    List<NavDestination> destinations,
  ) {
    final selectedIndex = NavDestinations.indexOf(route, destinations);
    return AppBottomNavigation(
      destinations: destinations,
      selectedIndex: selectedIndex,
      onSelected: (i) {
        final dest = destinations[i];
        if (dest.route == NavDestinations.moreRoute) {
          DoctorMoreBottomSheet.show(context, currentRoute: route);
        } else {
          AppNavigation.goTo(dest.route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showHeader
          ? Column(
              children: [
                const MobileHeader(),
                Expanded(child: child),
              ],
            )
          : SafeArea(bottom: false, child: child),
      bottomNavigationBar: !showBottomNavigation
          ? null
          : Get.isRegistered<RoleController>()
          ? Obx(
              () => _buildBottomNav(
                context,
                RoleController.to.currentBottomDestinations,
              ),
            )
          : _buildBottomNav(
              context,
              NavDestinations.forRoleBottom(ClinicRole.receptionist),
            ),
    );
  }
}
