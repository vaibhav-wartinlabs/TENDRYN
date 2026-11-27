import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/core/utils/loadable_mixin.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/dashboard/widgets/card_grid.dart';
import 'package:tendryn/features/dashboard/widgets/queue_widgets.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';
import 'package:tendryn/features/queue/widgets/queue_row_menu.dart';
import 'package:tendryn/features/queue/widgets/queue_table.dart';
import 'package:tendryn/features/queue/widgets/queue_toolbar.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_data_table.dart';
import 'package:tendryn/widgets/common/status_pill.dart';

/// The Nurse "Triage queue" (Figma: desktop 1280, tablet 744, mobile 393).
/// It reads the same [QueueController] as the Receptionist and Doctor queues.
///
/// - Desktop: banner, heading + Call next, search + filter, table with footer.
/// - Tablet: banner, heading + Call next, search + filter, card grid, footer.
/// - Mobile: banner, heading, search + filter, single-column cards,
///   Previous / Next, full-width Call next.
class NurseQueue extends StatelessWidget {
  const NurseQueue({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _NurseQueueMobile(),
      tablet: _NurseQueueTablet(),
      desktop: _NurseQueueDesktop(),
    );
  }
}

const _searchHint = 'Search patients by name or ID';

// ---------------------------------------------------------------- desktop

class _NurseQueueDesktop extends GetView<QueueController> {
  const _NurseQueueDesktop();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
        children: [
          const _UpdateFailedBanner(gap: Dimensions.pageSectionGap),
          _PageHeader(
            titleGap: 4,
            callNextWidth: 180,
            onCallNext: controller.callNextForTriage,
          ),
          const SizedBox(height: Dimensions.pageSectionGap),
          const QueueToolbar(hint: 'Search name, ID or queue number'),
          const SizedBox(height: Dimensions.pageSectionGap),
          const _NurseQueueTable(),
        ],
      ),
    );
  }
}

class _NurseQueueTable extends GetView<QueueController> {
  const _NurseQueueTable();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: scheme.outline, width: Dimensions.strokeDivider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 68,
              child: _QueueSummary(titleStyle: AppTextStyles.h3),
            ),
          ),
          Obx(() {
            final rows = controller.pageEntries;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppDataTable<QueueEntry>(
                  horizontalPadding: Dimensions.spaceMd,
                  columnGap: Dimensions.spaceMd,
                  rowMinHeight: Dimensions.queueRowMinHeight,
                  minWidth: 860,
                  distributeColumnWidths: true,
                  rows: rows,
                  columns: _columns(scheme),
                ),
                if (rows.isEmpty) const QueueEmptyState(),
              ],
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.rangeLabel,
                      style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const _NursePagination(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<AppTableColumn<QueueEntry>> _columns(ColorScheme scheme) => [
        AppTableColumn(
          label: 'Queue',
          width: 72,
          cell: (_, e) => Text(
            e.number,
            style: AppTextStyles.label.copyWith(color: scheme.onSurface),
          ),
        ),
        AppTableColumn(
          label: 'Patient',
          width: 170,
          cell: (_, e) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.patient,
                style: AppTextStyles.label.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _patientMeta(e),
                style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        AppTableColumn(
          label: 'Waiting',
          width: 90,
          cell: (_, e) => Text(
            Formatters.waitingTime(e.waitingMinutes),
            style: AppTextStyles.tabular(AppTextStyles.bodySmall)
                .copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        AppTableColumn(
          label: 'Reason',
          width: 140,
          cell: (_, e) => Text(
            e.reason,
            style: AppTextStyles.label.copyWith(color: scheme.onSurface),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn(
          label: 'Status',
          width: 150,
          cell: (_, e) => _StatusBadge(entry: e),
        ),
        AppTableColumn(
          label: 'Priority',
          width: 130,
          cell: (_, e) => _PriorityTag(entry: e),
        ),
        AppTableColumn(
          label: 'Actions',
          width: Dimensions.touchTarget,
          alignment: Alignment.center,
          cell: (_, e) => QueueRowMenu(entry: e),
        ),
      ];
}



// ----------------------------------------------------------------- tablet

class _NurseQueueTablet extends GetView<QueueController> {
  const _NurseQueueTablet();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.pageMarginTablet,
          28,
          Dimensions.pageMarginTablet,
          36,
        ),
        children: [
          const _UpdateFailedBanner(gap: Dimensions.pageSectionGap),
          _PageHeader(
            titleGap: 6,
            callNextWidth: 176,
            onCallNext: controller.callNextForTriage,
          ),
          const SizedBox(height: Dimensions.pageSectionGap),
          QueueToolbar(
            hint: _searchHint,
            hintStyle: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: Dimensions.pageSectionGap),
          _QueueSummary(titleStyle: AppTextStyles.h3),
          const SizedBox(height: 12),
          const _NurseCards(),
          const SizedBox(height: Dimensions.spaceSm),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.spaceSm),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.rangeLabel,
                      style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const _NursePagination(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- mobile

class _NurseQueueMobile extends GetView<QueueController> {
  const _NurseQueueMobile();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.pageMarginMobile,
          Dimensions.pageMarginMobile,
          Dimensions.pageMarginMobile,
          Dimensions.pageSectionGap,
        ),
        children: [
          const _UpdateFailedBanner(gap: Dimensions.sectionContentGap),
          const _PageHeading(titleGap: 6),
          const SizedBox(height: Dimensions.sectionContentGap),
          QueueToolbar(
            hint: _searchHint,
            hintStyle: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: Dimensions.sectionContentGap),
          _QueueSummary(titleStyle: AppTextStyles.h3Mobile),
          const SizedBox(height: 12),
          const _NurseCards(),
          const SizedBox(height: Dimensions.sectionContentGap),
          const _MobilePagination(),
          const SizedBox(height: Dimensions.sectionContentGap),
          AppButton.primary(
            label: 'Call next',
            onPressed: controller.callNextForTriage,
            expand: true,
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- shared

/// Banner shown while the last queue update failed; the last saved queue stays
/// on screen underneath it. Colors are fixed (system-controlled).
class _UpdateFailedBanner extends GetView<QueueController> {
  const _UpdateFailedBanner({required this.gap});

  final double gap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.status.value != LoadStatus.error) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: gap),
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.controlX),
            decoration: BoxDecoration(
              color: AppColors.statusCancelledTint,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(AppIcons.error, size: 20, color: AppColors.safetyCriticalText),
                const SizedBox(width: Dimensions.statusX),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        'Queue couldn’t be updated',
                        style: AppTextStyles.label.copyWith(color: AppColors.safetyCriticalText),
                      ),
                      Text(
                        'Check your connection and try again. Showing the last saved queue.',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          height: 20 / 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.titleGap});

  final double titleGap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: titleGap,
      children: [
        Semantics(
          header: true,
          child: Text('Triage queue', style: AppTextStyles.h2Bold.copyWith(color: scheme.onSurface)),
        ),
        Text(
          'Patients checked in today. Call the next patient to record vitals and triage.',
          style: AppTextStyles.bodySmall.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Tablet and desktop: heading on the left, "Call next" on the right.
class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.titleGap,
    required this.callNextWidth,
    required this.onCallNext,
  });

  final double titleGap;
  final double callNextWidth;
  final VoidCallback onCallNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Dimensions.spaceLg,
      children: [
        Expanded(child: _PageHeading(titleGap: titleGap)),
        SizedBox(
          width: callNextWidth,
          height: Dimensions.buttonMinHeight,
          child: AppButton.primary(label: 'Call next', onPressed: onCallNext, expand: true),
        ),
      ],
    );
  }
}

/// "Today's queue" with the live patient count.
class _QueueSummary extends GetView<QueueController> {
  const _QueueSummary({required this.titleStyle});

  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      spacing: Dimensions.spaceSm,
      children: [
        Text('Today’s queue', style: titleStyle.copyWith(color: scheme.onSurface)),
        Expanded(
          child: Obx(() {
            final entries = controller.filtered;
            final waiting = entries.where((e) => e.status == QueueStatus.waiting).length;
            final count = entries.length;
            return Text(
              '$count ${count == 1 ? 'patient' : 'patients'} · $waiting awaiting triage',
              style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }),
        ),
      ],
    );
  }
}

/// Tablet & Desktop: a grid of cards (two columns on tablet, three on desktop).
/// Mobile: one column.
class _NurseCards extends GetView<QueueController> {
  const _NurseCards();

  static const double minColumnWidth = 300;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = controller.pageEntries;
      if (rows.isEmpty) return const QueueEmptyState();
      return CardGrid(
        minColumnWidth: minColumnWidth,
        spacing: Dimensions.spaceMd,
        children: [for (final e in rows) _NurseQueueCard(entry: e)],
      );
    });
  }
}

class _NurseQueueCard extends GetView<QueueController> {
  const _NurseQueueCard({required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label12 = AppTextStyles.label.copyWith(fontSize: 12, height: 20 / 12);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radius),
        onTap: () => controller.viewProfile(entry),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.spaceMd),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(color: scheme.outline, width: Dimensions.strokeDivider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: scheme.outline, width: Dimensions.strokeDivider)),
                ),
                child: Row(
                  spacing: Dimensions.spaceSm,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            entry.patient,
                            style: AppTextStyles.h3Mobile.copyWith(color: scheme.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _patientMeta(entry),
                            style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    QueueRowMenu(entry: entry),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.number, style: AppTextStyles.label.copyWith(color: scheme.onSurface)),
                  Text.rich(
                    TextSpan(
                      text: 'Waiting ',
                      style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant, height: 20 / 12),
                      children: [
                        TextSpan(
                          text: Formatters.waitingTime(entry.waitingMinutes),
                          style: AppTextStyles.tabular(label12).copyWith(color: scheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                spacing: Dimensions.spaceMd,
                children: [
                  Text('Reason', style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
                  Expanded(
                    child: Text(
                      entry.reason,
                      style: AppTextStyles.label.copyWith(color: scheme.onSurface),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _StatusBadge(entry: entry),
                  const SizedBox(width: Dimensions.spaceSm),
                  _PriorityTag(entry: entry),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Where the patient is. Tones follow the Figma status pills (Waiting amber,
/// Waiting for Doctor brand, with a practitioner blue).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (entry.status) {
      QueueStatus.waiting => (const Color(0xFFFFF7ED), const Color(0xFFC25E00)),
      QueueStatus.waitingForDoctor => (const Color(0xFFE6F4F2), const Color(0xFF006970)),
      QueueStatus.withNurse => (const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        entry.status.label,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.25,
        ),
      ),
    );
  }
}

/// Triage priority tag: colored dot plus text (never color alone).
class _PriorityTag extends StatelessWidget {
  const _PriorityTag({required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context) => StatusPill(
        color: QueueStyles.priorityDot(entry.priority),
        label: entry.priority.label,
      );
}

/// `TND-000124 · M · 42 yrs`.
String _patientMeta(QueueEntry entry) {
  final profile = NursePatientProfile.fromQueueEntry(entry);
  final parts = entry.demographics.split('/');
  final age = parts.length == 2 ? int.tryParse(parts[0].trim()) : null;
  final demo =
      age != null ? '${parts[1].trim()} · $age yrs' : entry.demographics;
  return '${profile.patientId} · $demo';
}

/// Page numbers to show: first, last, the current page and its neighbours,
/// with `null` marking a gap ("...").
List<int?> _pageItems(int current, int count) {
  if (count <= 5) return [for (var i = 1; i <= count; i++) i];
  final shown = <int>{1, count, current - 1, current, current + 1};
  if (current <= 2) shown.addAll([2, 3]);
  if (current >= count - 1) shown.addAll([count - 2, count - 1]);
  final pages = shown.where((p) => p >= 1 && p <= count).toList()..sort();
  return [
    for (var i = 0; i < pages.length; i++) ...[
      if (i > 0 && pages[i] - pages[i - 1] > 1) null,
      pages[i],
    ],
  ];
}

/// Pagination bar matching Figma: "Previous [1] [2] [3] [...] [10] [Next]" with rounded outline blocks.
class _NursePagination extends GetView<QueueController> {
  const _NursePagination();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.selectedNursePage.value;
      const count = 10;
      final hasPrevious = current > 1;
      final hasNext = current < count;

      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Dimensions.spaceSm,
        children: [
          _NursePageBlock(
            label: 'Previous',
            width: 88,
            enabled: hasPrevious,
            onTap: controller.previousNursePage,
          ),
          for (final p in _pageItems(current, count))
            if (p == null)
              _NursePageBlock(
                label: '...',
                width: 40,
                enabled: true,
                onTap: () {
                  if (current <= 3) {
                    controller.switchNursePage(4);
                  } else if (current >= count - 2) {
                    controller.switchNursePage(count - 3);
                  }
                },
              )
            else
              _NursePageBlock(
                label: '$p',
                width: p >= 10 ? 44 : 40,
                selected: p == current,
                onTap: () => controller.switchNursePage(p),
              ),
          _NursePageBlock(
            label: 'Next',
            width: 66,
            enabled: hasNext,
            onTap: controller.nextNursePage,
          ),
        ],
      );
    });
  }
}

class _NursePageBlock extends StatefulWidget {
  const _NursePageBlock({
    required this.label,
    required this.width,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final double width;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_NursePageBlock> createState() => _NursePageBlockState();
}

class _NursePageBlockState extends State<_NursePageBlock> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final enabled = widget.enabled;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      side: BorderSide(
        color: selected
            ? AppColors.brandPrimary
            : _hovered && enabled
                ? AppColors.brandPrimary
                : AppColors.borderDefault,
        width: Dimensions.strokeDivider,
      ),
    );

    final bgColor = selected
        ? AppColors.brandPrimary
        : _hovered && enabled
            ? AppColors.brandTint
            : Colors.white;

    final textColor = selected
        ? Colors.white
        : !enabled
            ? AppColors.textDisabled
            : _hovered
                ? AppColors.brandHover
                : AppColors.brandPrimary;

    return MouseRegion(
      onEnter: (_) {
        if (enabled && !selected) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (enabled && !selected) setState(() => _hovered = false);
      },
      cursor: enabled && !selected ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Material(
        color: bgColor,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          hoverColor: Colors.transparent,
          splashColor: AppColors.brandPrimary.withValues(alpha: 0.12),
          onTap: enabled && !selected ? widget.onTap : null,
          child: SizedBox(
            width: widget.width,
            height: Dimensions.buttonMinHeight,
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile: Previous and Next share the width, 48px high.
class _MobilePagination extends GetView<QueueController> {
  const _MobilePagination();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.page.value;
      final count = controller.pageCount;
      return Row(
        spacing: Dimensions.spaceSm,
        children: [
          Expanded(
            child: _MobilePageButton(
              label: 'Previous',
              onTap: () {
                if (current > 1) {
                  controller.goToPage(current - 1);
                }
              },
            ),
          ),
          Expanded(
            child: _MobilePageButton(
              label: 'Next',
              onTap: () {
                if (current < count) {
                  controller.goToPage(current + 1);
                }
              },
            ),
          ),
        ],
      );
    });
  }
}

class _MobilePageButton extends StatefulWidget {
  const _MobilePageButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<_MobilePageButton> createState() => _MobilePageButtonState();
}

class _MobilePageButtonState extends State<_MobilePageButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      side: BorderSide(
        color: _hovered ? AppColors.brandHover : AppColors.brandPrimary,
        width: 1.5,
      ),
    );

    final bgColor = _hovered ? AppColors.brandTint : Colors.white;
    final textColor = _hovered ? AppColors.brandHover : AppColors.brandPrimary;

    return Semantics(
      button: true,
      enabled: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: Material(
          color: bgColor,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            hoverColor: AppColors.brandTint,
            splashColor: AppColors.brandTint.withValues(alpha: 0.6),
            onTap: widget.onTap,
            child: Container(
              height: Dimensions.touchTarget,
              alignment: Alignment.center,
              child: Text(
                widget.label,
                style: AppTextStyles.label.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
