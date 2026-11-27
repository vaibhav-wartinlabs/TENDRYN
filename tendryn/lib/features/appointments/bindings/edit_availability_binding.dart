import 'package:get/get.dart';
import 'package:tendryn/features/appointments/bindings/availability_binding.dart';
import 'package:tendryn/features/appointments/controllers/availability_controller.dart';
import 'package:tendryn/features/appointments/controllers/edit_availability_controller.dart';

class EditAvailabilityBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AvailabilityController>()) AvailabilityBinding().dependencies();
    Get.lazyPut(() => EditAvailabilityController());
  }
}
