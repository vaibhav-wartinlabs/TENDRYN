import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/app_data_table.dart';
import 'package:tendryn/widgets/common/section_card.dart';
import 'package:tendryn/widgets/common/status_badge.dart';
import 'package:tendryn/widgets/common/status_pill.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/queue/widgets/queue_row_menu.dart';

/// Colors and tones for queue priority / status, per treatment.
/// Table badges (desktop) are tinted; card chips (tablet, mobile) use a coloured dot.
/// The two treatments differ intentionally in the Figma frames.
abstract class QueueStyles {
  static BadgeTone priorityTone(QueuePriority p) => switch (p) {
    QueuePriority.routine => BadgeTone.neutral,
    QueuePriority.urgent || QueuePriority.emergency => BadgeTone.warning,
  };

  static BadgeTone statusTone(QueueStatus s) => switch (s) {
    QueueStatus.waiting => BadgeTone.brand,
    QueueStatus.waitingForDoctor => BadgeTone.info,
    QueueStatus.withNurse => BadgeTone.success,
  };

  static Color priorityDot(QueuePriority p) => switch (p) {
    QueuePriority.routine => AppColors.triageGreen,
    QueuePriority.urgent => AppColors.triageOrange,
    QueuePriority.emergency => AppColors.triageRed,
  };

  static Color get statusDot => AppColors.triageGreen;
}

/// Desktop: the Live Queue card with its table.
class LiveQueueTable extends GetView<DashboardController> {
  const LiveQueueTable({super.key, required this.entries});

  final List<QueueEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      title: 'Live Queue',
      subtitle: 'Patients currently waiting or moving through the clinic',
      trailing: AppButton.text(
        label: 'View Full Queue',
        onPressed: controller.openQueue,
      ),
      child: AppDataTable<QueueEntry>(
      columnGap: Dimensions.tableColumnGap,
        rowMinHeight: Dimensions.queueRowMinHeight,
        minWidth: Dimensions.dashboardTableMinWidth,
        distributeColumnWidths: true,
        rows: entries,
        columns: [
          AppTableColumn(
            label: 'Queue',
            width: 56,
            cell: (_, e) => Text(
              e.number,
              style: AppTextStyles.label.copyWith(color: scheme.primary),
            ),
          ),
          AppTableColumn(
            label: 'Patient',
            width: 120,
            cell: (_, e) => Text(
              e.patient,
              style: AppTextStyles.label.copyWith(color: scheme.onSurface),
            ),
          ),
          AppTableColumn(
            label: 'Arrival',
            width: 56,
            cell: (_, e) => Text(
              e.arrival,
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          AppTableColumn(
            label: 'Waiting',
            width: 64,
            cell: (_, e) => Text(
              '${e.waitingMinutes} min',
              style: AppTextStyles.label.copyWith(color: scheme.onSurface),
            ),
          ),
          AppTableColumn(
            label: 'Reason',
            width: 120,
            cell: (_, e) => Text(
              e.reason,
              style: AppTextStyles.caption.copyWith(color: scheme.onSurface),
            ),
          ),
          AppTableColumn(
            label: 'Priority',
            width: 80,
            cell: (_, e) => StatusBadge(
              label: e.priority.label,
              tone: QueueStyles.priorityTone(e.priority),
            ),
          ),
          AppTableColumn(
            label: 'Status',
            width: 120,
            cell: (_, e) => StatusBadge(
              label: e.status.label,
              tone: QueueStyles.statusTone(e.status),
            ),
          ),
          AppTableColumn(
            label: 'Practitioner',
            flex: 80,
            cell: (_, e) => Text(
              e.practitioner ?? '—',
              style: AppTextStyles.caption.copyWith(color: scheme.onSurface),
            ),
          ),
          AppTableColumn(
            label: 'Actions',
            width: Dimensions.touchTarget,
            alignment: Alignment.center,
            cell: (_, e) => QueueRowMenu(
              entry: e,
              onViewPatient: controller.viewPatient,
              onAssignPractitioner: controller.assignPractitioner,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tablet and mobile: one queue entry as a card. The row menu is supplied by
/// the page (Dashboard: a notice; Queue: the actions popup).
class QueueCard extends StatelessWidget {
  const QueueCard({
    super.key,
    required this.entry,
    required this.menu,
    this.wide = false,
  });

  final QueueEntry entry;
  final Widget menu;

  /// Tablet: two columns of details and a 16px name. Mobile: stacked details.
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chips = Wrap(
      spacing: Dimensions.componentGap,
      runSpacing: Dimensions.componentGap,
      children: [
        StatusPill(
          color: QueueStyles.priorityDot(entry.priority),
          label: entry.priority.label,
        ),
        StatusPill(color: QueueStyles.statusDot, label: entry.status.label),
      ],
    );
    final practitioner = entry.practitioner ?? 'Not Assigned';
    final detailStyle = AppTextStyles.label.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimensions.spaceMd,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimensions.componentGap,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${entry.number} ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                            TextSpan(
                              text: entry.patient,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Dimensions.componentGap,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Arrival: ${entry.arrival}',
                                  style: detailStyle,
                                ),
                                Text(
                                  'Waiting: ${entry.waitingMinutes} min',
                                  style: detailStyle.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _Labelled(
                              label: 'Reason',
                              value: entry.reason,
                            ),
                          ),
                        ],
                      ),
                      _Labelled(label: 'Practitioner', value: practitioner),
                      chips,
                    ],
                  ),
                ),
                menu,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimensions.statusX,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            entry.number,
                            style: AppTextStyles.label.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                          Text(
                            entry.patient,
                            style: AppTextStyles.h3Mobile.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    menu,
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Dimensions.componentGap,
                  children: [
                    Row(
                      spacing: Dimensions.componentGap,
                      children: [
                        Expanded(
                          child: Text(
                            'Arrival: ${entry.arrival}',
                            style: detailStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Waiting: ${entry.waitingMinutes} min',
                            style: detailStyle.copyWith(
                              color: scheme.onSurface,
                            ),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text('Reason: ${entry.reason}', style: detailStyle),
                    Text(
                      'Practitioner: ${entry.practitioner ?? 'Not Assigned'}',
                      style: detailStyle,
                    ),
                  ],
                ),
                chips,
              ],
            ),
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: AppTextStyles.label.copyWith(color: scheme.onSurface),
        ),
      ],
    );
  }
}

class DoctorQueueItemData {
  const DoctorQueueItemData({
    required this.queue,
    required this.patient,
    required this.reason,
    required this.priority,
    required this.priorityBg,
    required this.priorityColor,
    required this.action,
  });

  final String queue;
  final String patient;
  final String reason;
  final String priority;
  final Color priorityBg;
  final Color priorityColor;
  final String action;

  static const items = [
    DoctorQueueItemData(
      queue: 'Q-004',
      patient: 'Thabo Mokoena',
      reason: 'Chest pain',
      priority: 'Emergency',
      priorityBg: AppColors.safetyCriticalBackground,
      priorityColor: AppColors.triageRed,
      action: 'Start',
    ),
    DoctorQueueItemData(
      queue: 'Q-005',
      patient: 'Nomsa Dlamini',
      reason: 'Follow-up',
      priority: 'Urgent',
      priorityBg: AppColors.feedbackWarningTint,
      priorityColor: AppColors.feedbackWarning,
      action: 'Open',
    ),
    DoctorQueueItemData(
      queue: 'Q-006',
      patient: 'Sipho Khumalo',
      reason: 'Review',
      priority: 'Routine',
      priorityBg: AppColors.feedbackSuccessTint,
      priorityColor: AppColors.triageGreen,
      action: 'Open',
    ),
  ];

  static const tabletItems = [
    DoctorQueueItemData(
      queue: 'Q-004',
      patient: 'Thabo Mokoena',
      reason: 'Chest pain',
      priority: 'Emergency',
      priorityBg: AppColors.safetyCriticalBackground,
      priorityColor: AppColors.triageRed,
      action: 'Start',
    ),
    DoctorQueueItemData(
      queue: 'Q-005',
      patient: 'Nomsa Dlamini',
      reason: 'Follow-up',
      priority: 'Urgent',
      priorityBg: AppColors.feedbackWarningTint,
      priorityColor: AppColors.feedbackWarning,
      action: 'Open',
    ),
    DoctorQueueItemData(
      queue: 'Q-006',
      patient: 'Sipho Khumalo',
      reason: 'Review',
      priority: 'Routine',
      priorityBg: AppColors.feedbackSuccessTint,
      priorityColor: AppColors.triageGreen,
      action: 'Open',
    ),
  ];
}

/// Doctor: "Patients awaiting consultation" table on Desktop
class DoctorQueueTable extends StatelessWidget {
  const DoctorQueueTable({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(
          color: scheme.outline,
          width: Dimensions.strokeDivider,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.sectionPadding,
              vertical: Dimensions.spaceMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Patients awaiting consultation',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => AppNotice.unavailable('Queue'),
                  child: Text(
                    'View all',
                    style: AppTextStyles.label.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderDefault,
          ),
          ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.sectionPadding,
                vertical: Dimensions.controlY,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Queue',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Patient',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Reason',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Priority',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Action',
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderDefault,
          ),
          for (final item in DoctorQueueItemData.items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.sectionPadding,
                vertical: Dimensions.spaceLg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.queue,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.patient,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.reason,
                      style: AppTextStyles.body.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: item.priorityBg,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius,
                          ),
                        ),
                        child: Text(
                          item.priority,
                          style: TextStyle(
                            color: item.priorityColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => AppNotice.unavailable('Patient action'),
                        child: Text(
                          item.action,
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (item != DoctorQueueItemData.items.last)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderDefault,
              ),
          ],
        ],
      ),
    );
  }
}

/// Doctor queue single card for Mobile and Tablet
class DoctorQueueCardWidget extends StatelessWidget {
  const DoctorQueueCardWidget({super.key, required this.item});

  final DoctorQueueItemData item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(
          color: scheme.outline,
          width: Dimensions.strokeDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.queue,
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: item.priorityBg,
                  borderRadius: BorderRadius.circular(Dimensions.radius),
                ),
                child: Text(
                  item.priority,
                  style: TextStyle(
                    color: item.priorityColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.patient,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.reason,
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              InkWell(
                onTap: () => AppNotice.unavailable('Action'),
                child: Text(
                  item.action,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
