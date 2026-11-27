import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/validators.dart';
import 'package:tendryn/features/patients/controllers/patient_details_controller.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Form state for Edit Patient Details, prefilled from the patient passed as
/// the route argument. Shared by the desktop, tablet and phone layouts.
///
/// There is no patient-update API yet: saving updates the in-memory record
/// (Patient Details and the directory) for this session only.
class PatientEditController extends GetxController {
  PatientEditController() : patient = Get.arguments is PatientRecord ? Get.arguments as PatientRecord : PatientsController.seed.first {
    final nameParts = patient.name.split(' ');
    firstName = nameParts.first;
    surname = nameParts.skip(1).join(' ');
    mobile = TextEditingController(text: patient.mobile);
    whatsApp = TextEditingController(text: patient.whatsApp ?? patient.mobile);
    address = TextEditingController(text: patient.address);
    nextOfKin = TextEditingController(text: patient.nextOfKin);
  }

  final PatientRecord patient;

  /// Identity is verified elsewhere, so these are shown read-only.
  late final String firstName;
  late final String surname;

  late final TextEditingController mobile;
  late final TextEditingController whatsApp;
  late final TextEditingController address;
  late final TextEditingController nextOfKin;

  final mobileError = RxnString();
  final addressError = RxnString();

  /// Validates, then shows the changes on Patient Details and returns to it.
  void save() {
    mobileError.value = Validators.required(mobile.text, field: 'Mobile number');
    addressError.value = Validators.required(address.text, field: 'Residential address');
    if (mobileError.value != null || addressError.value != null) return;

    final updated = patient.copyWith(
      mobile: mobile.text.trim(),
      whatsApp: whatsApp.text.trim(),
      address: address.text.trim(),
      nextOfKin: nextOfKin.text.trim().isEmpty ? 'Not recorded' : nextOfKin.text.trim(),
    );
    if (Get.isRegistered<PatientDetailsController>()) Get.find<PatientDetailsController>().updatePatient(updated);
    if (Get.isRegistered<PatientsController>()) Get.find<PatientsController>().updatePatient(updated);
    onBack();
    Get.snackbar('Patient details', 'Changes saved.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
  }

  /// Back to Patient Details for the same patient (Cancel and the back arrows).
  void onBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.patientDetails, arguments: patient);
    }
  }

  @override
  void onClose() {
    mobile.dispose();
    whatsApp.dispose();
    address.dispose();
    nextOfKin.dispose();
    super.onClose();
  }
}
