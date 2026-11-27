import 'package:flutter/material.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/widgets/common/status_pill.dart';

/// synced: local and cloud aligned. deviceOnly: saved locally, will sync.
/// syncing: transfer in progress. needsAttention: conflict or connectivity issue.
enum SyncState {
  synced('Synced', AppColors.syncSynced),
  deviceOnly('Device only', AppColors.syncDeviceOnly),
  syncing('Syncing', AppColors.syncSyncing),
  needsAttention('Needs attention', AppColors.syncNeedsAttention);

  const SyncState(this.label, this.color);

  final String label;
  final Color color;
}

/// Read-only sync status. Colors are fixed and system-controlled.
class SyncChip extends StatelessWidget {
  const SyncChip({super.key, required this.state, this.label});

  final SyncState state;

  /// Overrides the default label for [state].
  final String? label;

  @override
  Widget build(BuildContext context) => StatusPill(color: state.color, label: label ?? state.label);
}
