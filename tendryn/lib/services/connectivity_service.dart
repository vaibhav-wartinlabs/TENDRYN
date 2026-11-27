import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/app_logger.dart';

/// Reactive online/offline flag. connectivity_plus supports Android and Windows;
/// if the platform plugin is unavailable we assume online rather than fail.
class ConnectivityService extends GetxService {
  final isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  Future<void> _start() async {
    try {
      final connectivity = Connectivity();
      _update(await connectivity.checkConnectivity());
      _subscription = connectivity.onConnectivityChanged.listen(_update);
    } catch (e) {
      AppLogger.error(e);
    }
  }

  void _update(List<ConnectivityResult> results) {
    isOnline.value = results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
