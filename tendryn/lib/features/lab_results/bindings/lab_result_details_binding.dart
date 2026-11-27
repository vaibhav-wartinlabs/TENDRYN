import 'package:get/get.dart';
import 'package:tendryn/features/lab_results/controllers/lab_result_details_controller.dart';

class LabResultDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LabResultDetailsController>(() => LabResultDetailsController());
  }
}

