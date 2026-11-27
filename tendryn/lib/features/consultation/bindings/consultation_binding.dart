import 'package:get/get.dart';
import 'package:tendryn/features/consultation/controllers/consultation_controller.dart';

class ConsultationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsultationController>(() => ConsultationController());
  }
}
