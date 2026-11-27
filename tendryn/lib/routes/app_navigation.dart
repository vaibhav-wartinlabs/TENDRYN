import 'package:get/get.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/routes/app_routes.dart';

abstract class AppNavigation {
  /// Switches top-level destination (replaces the current page, no stack growth).
  static void goTo(String route) {
    if (Get.currentRoute != route) Get.offNamed(route);
  }

  /// Opens the clinical workspace without a side transition and remembers
  /// which top-level page the workspace should return to and which patient is active.
  static void goToConsultationWorkspace({
    String returnRoute = AppRoutes.consultations,
    PatientRecord? patient,
    String? status,
  }) {
    if (Get.currentRoute != AppRoutes.consultationWorkspace) {
      Get.offNamed(
        AppRoutes.consultationWorkspace,
        arguments: {
          'returnRoute': returnRoute,
          'patient': ?patient,
          'status': ?status,
        },
      );
    }
  }
}
