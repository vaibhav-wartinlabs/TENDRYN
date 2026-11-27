import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/queue/models/queue_model.dart';
import 'package:tendryn/widgets/common/app_card.dart';

/// The Queue headline figures. Desktop and tablet: three cards in a row, each
/// with a detail line. Mobile: two compact cards (Waiting, Average wait).
class QueueSummary extends StatelessWidget {
  const QueueSummary({
    super.key,
    required this.queue,
    required this.screenType,
  });

  final QueueModel queue;
  final LayoutType screenType;

  @override
  Widget build(BuildContext context) {
    final compact = screenType == LayoutType.mobile;
    final average = '${queue.averageWaitMinutes} min';

    if (compact) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Dimensions.spaceMd,
          children: [
            Expanded(
              child: _QueueSummaryCard.compact(
                label: 'Waiting',
                value: '${queue.patientsWaiting}',
              ),
            ),
            Expanded(
              child: _QueueSummaryCard.compact(
                label: 'Average wait',
                value: average,
              ),
            ),
          ],
        ),
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Dimensions.spaceMd,
        children: [
          Expanded(
            child: _QueueSummaryCard(
              label: 'Patients waiting',
              value: '${queue.patientsWaiting}',
              detail: 'Currently in queue',
            ),
          ),
          Expanded(
            child: _QueueSummaryCard(
              label: 'Seen today',
              value: '${queue.seenToday}',
              detail: 'Completed visits',
            ),
          ),
          Expanded(
            child: _QueueSummaryCard(
              label: 'Average wait',
              value: average,
              detail: 'Across today’s queue',
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueSummaryCard extends StatelessWidget {
  const _QueueSummaryCard({
    required this.label,
    required this.value,
    required this.detail,
  }) : compact = false;

  const _QueueSummaryCard.compact({required this.label, required this.value})
    : detail = null,
      compact = true;

  final String label;
  final String value;
  final String? detail;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valueStyle = compact ? AppTextStyles.h3Mobile : AppTextStyles.h3;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: compact ? 74 : 112),
      child: AppCard(
        padding: EdgeInsets.all(compact ? 10 : Dimensions.spaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: compact ? 3 : 6,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              value,
              style: AppTextStyles.tabular(valueStyle)
                  .copyWith(color: scheme.onSurface),
            ),
            if (detail != null)
              Text(
                detail!,
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
