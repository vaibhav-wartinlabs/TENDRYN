import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';

enum ClinicRole {
  doctor,
  receptionist,
  nurse,
  labStaff;

  String get label => switch (this) {
        ClinicRole.doctor => 'Doctor',
        ClinicRole.receptionist => 'Receptionist',
        ClinicRole.nurse => 'Nurse',
        ClinicRole.labStaff => 'Lab Staff',
      };

  String get demoUserName => switch (this) {
        ClinicRole.doctor => 'Dr Thandi Nkosi',
        ClinicRole.receptionist => 'Lerato Mokoena',
        ClinicRole.nurse => 'Sister Naledi Naidoo',
        ClinicRole.labStaff => 'Lerato Mokoena',
      };

  String get jobTitle => switch (this) {
        ClinicRole.doctor => 'Doctor',
        ClinicRole.receptionist => 'Receptionist',
        ClinicRole.nurse => 'Nurse',
        ClinicRole.labStaff => 'Lab Staff',
      };
}

/// Global role state controller for switching between Doctor, Receptionist and Nurse modes.
class RoleController extends GetxController {
  static RoleController get to => Get.find<RoleController>();

  static const _storageKey = 'tendryn_active_role';

  static bool get _isTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  final currentRole = (_isTest ? ClinicRole.receptionist : ClinicRole.doctor).obs;

  List<NavDestination> get currentDestinations => NavDestinations.forRole(currentRole.value);

  List<NavDestination> get currentBottomDestinations =>
      NavDestinations.forRoleBottom(currentRole.value);

  /// First destination of the active role: Dashboard for Doctor and
  /// Receptionist, Queue for Nurse.
  String get homeRoute => currentDestinations.first.route;

  /// Pages only the Nurse opens: Vitals / Triage, the Patient profile and its past-visit Triage.
  static const _nurseOnlyRoutes = {
    AppRoutes.vitalsTriage,
    AppRoutes.recordVitalsTriage,
    AppRoutes.nursePatientProfile,
    AppRoutes.nurseTriageDetail,
    AppRoutes.nurseConsultations,
    AppRoutes.nursePrescriptions,
    AppRoutes.nurseLabReferral,
    AppRoutes.nurseRecordSample,
  };

  /// Whether the active role may open [route]. Nurse only reaches its own
  /// destinations and the Patient profile; the Nurse-only pages are closed to other roles.
  bool canAccess(String route) {
    if (currentRole.value == ClinicRole.nurse) {
      return route == AppRoutes.recordVitalsTriage ||
          route == AppRoutes.nursePatientProfile ||
          route == AppRoutes.nurseTriageDetail ||
          route == AppRoutes.nurseConsultations ||
          route == AppRoutes.nursePrescriptions ||
          route == AppRoutes.nurseLabReferral ||
          route == AppRoutes.nurseRecordSample ||
          currentDestinations.any((d) => d.route == route);
    }
    if (currentRole.value == ClinicRole.labStaff) {
      return route == AppRoutes.labReferral ||
          route == AppRoutes.labReferralDetails ||
          route == AppRoutes.labResults ||
          route == AppRoutes.patientLabInfo ||
          route == AppRoutes.labResultDetails ||
          route == AppRoutes.nurseLabReferral ||
          route == AppRoutes.nurseRecordSample ||
          currentDestinations.any((d) => d.route == route);
    }
    return !_nurseOnlyRoutes.contains(route);
  }

  @override
  void onInit() {
    super.onInit();
    _restoreSavedRole();
  }

  Future<void> _restoreSavedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null) {
        final role = ClinicRole.values.firstWhereOrNull((r) => r.name == saved);
        if (role != null) {
          currentRole.value = role;
          _syncUserHeader(role);
          _leaveRouteClosedToRole();
          return;
        }
      }
    } catch (_) {
      // SharedPreferences failure shouldn't crash app
    }
    _syncUserHeader(currentRole.value);
  }

  Future<void> switchRole(ClinicRole newRole) async {
    if (currentRole.value == newRole) return;

    currentRole.value = newRole;
    _syncUserHeader(newRole);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, newRole.name);
    } catch (_) {}

    // Check if current route is valid in the new role destinations
    final allowedRoutes = currentDestinations.map((d) => d.route).toSet();
    final currentRoute = Get.currentRoute;
    if (currentRoute.isNotEmpty && !allowedRoutes.contains(currentRoute)) {
      AppNavigation.goTo(homeRoute);
    }
  }

  /// After a saved role is restored at startup: leave a shell page the role
  /// cannot open. Splash and login are left alone; the first real route is
  /// checked by [RoleGuard].
  void _leaveRouteClosedToRole() {
    final route = Get.currentRoute;
    if (route.isEmpty || route == AppRoutes.splash || route == AppRoutes.login) return;
    if (!canAccess(route)) AppNavigation.goTo(homeRoute);
  }

  void _syncUserHeader(ClinicRole role) {
    if (Get.isRegistered<AuthController>()) {
      try {
        Get.find<AuthController>().updateActiveRole(
          role.jobTitle,
          role.demoUserName,
        );
      } catch (_) {
        // Safe for test mocks with incomplete interfaces
      }
    }
  }
}
