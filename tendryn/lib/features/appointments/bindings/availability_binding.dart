import 'package:get/get.dart';
import 'package:tendryn/features/appointments/controllers/availability_controller.dart';

class AvailabilityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AvailabilityController());
  }
}
