import 'package:flutter/material.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/routes/route_names.dart';

class NavDestination {
  const NavDestination({
    required this.route,
    required this.icon,
    this.customLabel,
    this.badgeCount,
  });

  final String route;
  final IconData icon;
  final String? customLabel;
  final int? badgeCount;

  String get label => customLabel ?? RouteNames.titleOf(route);
}

/// Single source for all navigation styles (side nav, bottom bar). Order and
/// icons follow the Figma navigation. Replace the list per role/product.
abstract class NavDestinations {
  static const String moreRoute = '__more__';

  static const List<NavDestination> doctor = [
    NavDestination(route: AppRoutes.dashboard, icon: AppIcons.home, customLabel: 'Dashboard'),
    NavDestination(route: AppRoutes.queue, icon: AppIcons.queue, customLabel: 'Queue', badgeCount: 3),
    NavDestination(route: AppRoutes.patients, icon: AppIcons.patients, customLabel: 'Patients'),
    NavDestination(route: AppRoutes.consultations, icon: AppIcons.consultations, customLabel: 'Consultations'),
    NavDestination(route: AppRoutes.labResults, icon: AppIcons.labResults, customLabel: 'Lab Results', badgeCount: 3),
    NavDestination(route: AppRoutes.appointments, icon: AppIcons.clinic, customLabel: 'Appointments'),
  ];

  /// Doctor mobile/tablet bottom navigation (5 tabs matching the Figma
  /// Appointments mobile and tablet designs).
  /// [Dashboard, Queue, Patients, Appointments, More].
  /// Tapping 'More' opens a bottom sheet with Consultations and Lab Results.
  static const List<NavDestination> doctorMobile = [
    NavDestination(route: AppRoutes.dashboard, icon: AppIcons.home, customLabel: 'Dashboard'),
    NavDestination(route: AppRoutes.queue, icon: AppIcons.queue, customLabel: 'Queue'),
    NavDestination(route: AppRoutes.patients, icon: AppIcons.patients, customLabel: 'Patients'),
    NavDestination(route: AppRoutes.appointments, icon: AppIcons.clinic, customLabel: 'Appointments'),
    NavDestination(route: moreRoute, icon: AppIcons.more, customLabel: 'More'),
  ];

  /// Doctor items accessible inside the "More" bottom sheet on mobile and tablet.
  static const List<NavDestination> doctorMoreItems = [
    NavDestination(
      route: AppRoutes.consultations,
      icon: AppIcons.consultations,
      customLabel: 'Consultations',
    ),
    NavDestination(
      route: AppRoutes.labResults,
      icon: AppIcons.labResults,
      customLabel: 'Lab Results',
      badgeCount: 3,
    ),
  ];

  /// Receptionist clinic navigation seen in prototypes (Dashboard, Queue, Patients, Appointments, Billing).
  static const List<NavDestination> receptionist = [
    NavDestination(route: AppRoutes.dashboard, icon: AppIcons.home, customLabel: 'Dashboard'),
    NavDestination(route: AppRoutes.queue, icon: AppIcons.queue, customLabel: 'Queue'),
    NavDestination(route: AppRoutes.patients, icon: AppIcons.patients, customLabel: 'Patients'),
    NavDestination(route: AppRoutes.appointments, icon: AppIcons.clinic, customLabel: 'Appointments'),
    NavDestination(route: AppRoutes.billing, icon: AppIcons.more, customLabel: 'Billing'),
  ];

  /// Nurse navigation (side and bottom): Queue, Patients, Vitals / Triage.
  static const List<NavDestination> nurse = [
    NavDestination(route: AppRoutes.queue, icon: AppIcons.queue, customLabel: 'Queue'),
    NavDestination(route: AppRoutes.patients, icon: AppIcons.patients, customLabel: 'Patients'),
    NavDestination(route: AppRoutes.vitalsTriage, icon: AppIcons.clinic, customLabel: 'Vitals / Triage'),
  ];

  /// Lab Staff navigation (Desktop side nav): Lab Referral, Result, Patient Lab Information
  static const List<NavDestination> labStaff = [
    NavDestination(route: AppRoutes.labReferral, icon: AppIcons.queue, customLabel: 'Lab Referral'),
    NavDestination(route: AppRoutes.labResults, icon: AppIcons.clinic, customLabel: 'Result'),
    NavDestination(route: AppRoutes.patientLabInfo, icon: AppIcons.consultations, customLabel: 'Patient Lab Information'),
  ];

  /// Lab Staff mobile & tablet bottom navigation: Lab Referral, Result, Patient Lab Info
  static const List<NavDestination> labStaffBottom = [
    NavDestination(route: AppRoutes.labReferral, icon: AppIcons.queue, customLabel: 'Lab Referral'),
    NavDestination(route: AppRoutes.labResults, icon: AppIcons.clinic, customLabel: 'Result'),
    NavDestination(route: AppRoutes.patientLabInfo, icon: AppIcons.consultations, customLabel: 'Patient Lab Info'),
  ];

  static const List<NavDestination> all = receptionist;

  static List<NavDestination> forRole(ClinicRole role) => switch (role) {
        ClinicRole.doctor => doctor,
        ClinicRole.receptionist => receptionist,
        ClinicRole.nurse => nurse,
        ClinicRole.labStaff => labStaff,
      };

  /// Bottom navigation destinations for mobile & tablet per role.
  static List<NavDestination> forRoleBottom(ClinicRole role) => switch (role) {
        ClinicRole.doctor => doctorMobile,
        ClinicRole.receptionist => receptionist,
        ClinicRole.nurse => nurse,
        ClinicRole.labStaff => labStaffBottom,
      };

  static int indexOf(String route, [List<NavDestination>? destinations]) {
    final list = destinations ?? all;
    final idx = list.indexWhere((d) => d.route == route);
    if (idx >= 0) return idx;

    // If the route belongs to the "More" items, highlight the More tab
    final moreIdx = list.indexWhere((d) => d.route == moreRoute);
    if (moreIdx >= 0) {
      if (doctorMoreItems.any((item) => item.route == route)) {
        return moreIdx;
      }
    }
    return 0;
  }
}
