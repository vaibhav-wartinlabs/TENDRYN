import 'package:get/get.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/services/queue_service.dart';

class QueueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => QueueController(service: Get.find<QueueService>()));
  }
}
