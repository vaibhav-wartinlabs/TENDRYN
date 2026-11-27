import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// Read-only pill: fixed state color dot + text. Status is never conveyed by
/// color alone, so the label is mandatory. Base of [SyncChip] and [TriageTag].
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: label,
      child: Container(
        constraints: const BoxConstraints(minHeight: Dimensions.chipHeight),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.statusX, vertical: Dimensions.statusY),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusPill),
          border: Border.all(color: scheme.outline, width: Dimensions.strokeDivider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Dimensions.stateDot,
              height: Dimensions.stateDot,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: Dimensions.componentGap),
            Text(label, style: AppTextStyles.label.copyWith(color: scheme.onSurface), softWrap: false, overflow: TextOverflow.fade),
          ],
        ),
      ),
    );
  }
}
