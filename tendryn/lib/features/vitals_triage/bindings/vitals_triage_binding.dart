import 'package:get/get.dart';
import 'package:tendryn/features/vitals_triage/controllers/vitals_triage_controller.dart';

class VitalsTriageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VitalsTriageController>(() => VitalsTriageController());
  }
}
