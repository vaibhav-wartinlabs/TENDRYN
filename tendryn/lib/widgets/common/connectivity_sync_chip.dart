import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/services/connectivity_service.dart';
import 'package:tendryn/widgets/common/sync_chip.dart';

/// Sync chip driven by connectivity: "Synced" online, "Device only" offline.
/// [offlineState] and [offlineLabel] restyle the offline chip (the Nurse
/// designs show "Sync pending" on phone and tablet, "Not synced" on desktop).
class ConnectivitySyncChip extends GetView<ConnectivityService> {
  const ConnectivitySyncChip({
    super.key,
    this.offlineState = SyncState.deviceOnly,
    this.offlineLabel,
  });

  final SyncState offlineState;
  final String? offlineLabel;

  @override
  Widget build(BuildContext context) => Obx(
        () => controller.isOnline.value
            ? const SyncChip(state: SyncState.synced)
            : SyncChip(state: offlineState, label: offlineLabel),
      );
}
