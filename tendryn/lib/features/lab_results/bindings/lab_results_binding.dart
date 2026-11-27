import 'package:get/get.dart';
import 'package:tendryn/features/lab_results/controllers/lab_referral_controller.dart';
import 'package:tendryn/features/lab_results/controllers/lab_results_controller.dart';

class LabResultsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LabResultsController>(() => LabResultsController(), fenix: true);
    Get.lazyPut<LabReferralController>(() => LabReferralController(), fenix: true);
  }
}
