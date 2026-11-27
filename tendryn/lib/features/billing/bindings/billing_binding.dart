import 'package:get/get.dart';
import 'package:tendryn/features/billing/controllers/billing_controller.dart';

class BillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillingController>(() => BillingController());
  }
}
