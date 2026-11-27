import 'package:get/get.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/features/appointments/controllers/doctor_appointments_controller.dart';

class AppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentsController());
    Get.lazyPut(() => DoctorAppointmentsController());
  }
}
