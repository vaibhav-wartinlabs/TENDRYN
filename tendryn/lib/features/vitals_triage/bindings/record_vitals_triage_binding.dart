import 'package:get/get.dart';
import 'package:tendryn/features/vitals_triage/controllers/record_vitals_triage_controller.dart';

class RecordVitalsTriageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecordVitalsTriageController>(() => RecordVitalsTriageController());
  }
}
