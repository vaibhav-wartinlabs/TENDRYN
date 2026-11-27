import 'package:get/get.dart';
import 'package:tendryn/features/appointments/controllers/reschedule_controller.dart';

class RescheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RescheduleController.fromArguments(Get.arguments));
  }
}
