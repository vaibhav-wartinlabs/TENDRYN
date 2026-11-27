import 'package:get/get.dart';
import 'package:tendryn/features/queue/controllers/add_walk_in_controller.dart';
import 'package:tendryn/routes/app_routes.dart';

class AddWalkInBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final returnRoute = args?['returnRoute'] as String? ?? AppRoutes.queue;
    Get.lazyPut(() => AddWalkInController(returnRoute: returnRoute));
  }
}
