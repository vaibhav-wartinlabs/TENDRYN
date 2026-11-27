import 'package:get/get.dart';
import 'package:tendryn/features/patients/controllers/patient_edit_controller.dart';

class PatientEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PatientEditController());
  }
}
