import 'package:get/get.dart';
import 'package:tendryn/features/patients/bindings/patients_binding.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/controllers/register_patient_controller.dart';

class RegisterPatientBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PatientsController>()) PatientsBinding().dependencies();
    Get.lazyPut(() => RegisterPatientController());
  }
}
