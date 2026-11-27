import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';
import 'package:tendryn/widgets/mobile/bottom_navigation.dart';
import 'package:tendryn/widgets/mobile/doctor_more_bottom_sheet.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

/// Tablet: 88px header, content, and a 76px bottom navigation bar with role awareness.
class TabletScaffold extends StatelessWidget {
  const TabletScaffold({
    super.key,
    required this.route,
    required this.child,
    this.showHeader = true,
    this.showBottomNavigation = true,
  });

  final String route;
  final Widget child;
  final bool showHeader;
  final bool showBottomNavigation;

  Widget _buildBottomNav(
    BuildContext context,
    List<NavDestination> destinations,
  ) {
    final selectedIndex = NavDestinations.indexOf(route, destinations);
    return AppBottomNavigation(
      destinations: destinations,
      selectedIndex: selectedIndex,
      height: Dimensions.tabletBottomNavHeight,
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
      // Keep the header clear of the system status bar (Android tablets).
      body: SafeArea(
        bottom: false,
        child: showHeader
            ? Column(
                children: [
                  const TabletHeader(),
                  Expanded(child: child),
                ],
              )
            : child,
      ),
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
