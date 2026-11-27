import 'package:get/get.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';

class PatientsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientsController>(() => PatientsController());
  }
}
