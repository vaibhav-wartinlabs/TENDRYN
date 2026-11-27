import 'package:get/get.dart';
import 'package:tendryn/features/appointments/controllers/appointment_conflicts_controller.dart';

class AppointmentConflictsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppointmentConflictsController>(() => AppointmentConflictsController());
  }
}
