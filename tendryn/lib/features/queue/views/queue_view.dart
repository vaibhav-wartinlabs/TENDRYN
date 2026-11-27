import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/features/queue/widgets/queue_desktop.dart';
import 'package:tendryn/features/queue/widgets/queue_mobile.dart';
import 'package:tendryn/features/queue/widgets/queue_nurse.dart';
import 'package:tendryn/features/queue/widgets/queue_tablet.dart';
import 'package:tendryn/widgets/common/status_view.dart';

class QueueView extends GetView<QueueController> {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        // Nurse keeps the last saved queue on screen when an update fails
        // (the banner says so), instead of replacing it with the error page.
        if (controller.isNurse && controller.queue.value != null) {
          return const NurseQueue();
        }
        return StatusView(
          controller: controller,
          onRetry: controller.load,
          builder: (_) => controller.isNurse
              ? const NurseQueue()
              : const ResponsiveLayout(
                  mobile: QueueMobile(),
                  tablet: QueueTablet(),
                  desktop: QueueDesktop(),
                ),
        );
      }),
    );
  }
}
