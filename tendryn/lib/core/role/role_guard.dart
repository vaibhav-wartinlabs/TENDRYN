import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/role/role_controller.dart';

/// Route middleware for the main destinations: a role is sent to its home page
/// when it opens a destination it has no access to (Nurse on the Dashboard,
/// Doctor or Receptionist on the Nurse-only Vitals / Triage page).
class RoleGuard extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (route == null || !Get.isRegistered<RoleController>()) return null;
    final roles = RoleController.to;
    if (roles.canAccess(route)) return null;
    final home = roles.homeRoute;
    return home == route ? null : RouteSettings(name: home);
  }
}
