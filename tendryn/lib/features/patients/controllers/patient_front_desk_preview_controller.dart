import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/features/appointments/views/book_appointment_view.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Controller for the Front Desk Patient Search preview / dialogue box.
class PatientFrontDeskPreviewController extends GetxController {
  PatientFrontDeskPreviewController({
    PatientQuickViewModel? initialPatient,
    String? returnRoute,
  }) : patient = (initialPatient ?? PatientQuickViewModel.thaboNkosi).obs,
       returnRoute = returnRoute ?? AppRoutes.dashboard;

  final String returnRoute;
  final Rx<PatientQuickViewModel> patient;

  void onBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(returnRoute);
    }
  }

  void viewPatientProfile() {
    Get.toNamed(
      AppRoutes.patientDetails,
      arguments: {
        'patient': patient.value,
        'returnRoute': returnRoute,
      },
    );
  }

  void addToQueue() {
    Get.toNamed(
      AppRoutes.addWalkIn,
      arguments: {'returnRoute': returnRoute},
    );
  }

  void bookAppointment() {
    final context = Get.context;

    if (context != null && ResponsiveHelper.usesDrawer(context)) {
      showBookAppointmentDrawer(
        context,
        returnRoute: returnRoute,
        initialQuickPatient: patient.value,
      );
    } else {
      Get.toNamed(
        AppRoutes.bookAppointment,
        arguments: {
          'patient': patient.value,
          'returnRoute': returnRoute,
        },
      );
    }
  }
}
