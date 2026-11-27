import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/widgets/common/clinical_banners.dart';

/// Shows the persistent offline notice while the device has no connection.
class ConnectivityBanner extends GetView<ConnectivityService> {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isOnline.value
          ? const SizedBox.shrink()
          : const Padding(padding: EdgeInsets.fromLTRB(Dimensions.spaceMd, Dimensions.spaceMd, Dimensions.spaceMd, 0), child: OfflineBanner()),
    );
  }
}
