import 'package:get/get.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Patient Details for the patient picked in the Patients directory (passed
/// as the route argument). One controller for all three layouts.
class PatientDetailsController extends GetxController {
  PatientDetailsController() : patient = (Get.arguments is PatientRecord ? Get.arguments as PatientRecord : PatientsController.seed.first).obs;

  final Rx<PatientRecord> patient;

  /// Not part of the directory record yet; shown as in the design.
  static const popiaConsent = 'Recorded and verified';
  static const appointment = 'No upcoming booking';

  /// `Q019 · Waiting`
  String get currentQueue => patient.value.queueNumber == null ? 'Not in queue' : '${patient.value.queueNumber} · Waiting';

  /// Back to the Patients directory.
  void onBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.patients);
    }
  }

  /// Opens the edit form for the patient shown here.
  void editDetails() => Get.toNamed(AppRoutes.patientEdit, arguments: patient.value);

  /// Shows a saved edit.
  void updatePatient(PatientRecord updated) => patient.value = updated;

  void viewQueue() => AppNavigation.goTo(AppRoutes.queue);
}
