import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/features/appointments/models/appointment_entry.dart';
import 'package:tendryn/features/appointments/widgets/appointments_common.dart';
import 'package:tendryn/widgets/common/app_button.dart';

const _timeColumn = 84.0;
const _rowHeight = 62.0;

/// Desktop: heading with actions, toolbar (view, week/day, date range,
/// practitioner), summary, day strip and the practitioner week grid.
class AppointmentsDesktop extends GetView<AppointmentsController> {
  const AppointmentsDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final doctor = controller.mode.value == AppointmentsMode.doctor;
      const summary = AppointmentsSummary(screenType: LayoutType.desktop);
      final toolbar = Row(
        spacing: 24,
        children: [
          const ToolbarBar(child: AppointmentsModeToggle()),
          Expanded(child: ToolbarBar(child: _RangeToolbar(controller: controller))),
        ],
      );
      return ListView(
        padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
        children: [
          Row(
            spacing: Dimensions.spaceMd,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Dimensions.spaceXs,
                  children: [
                    Semantics(header: true, child: Text('Appointments', style: AppTextStyles.h1.copyWith(color: scheme.onSurface))),
                    Text(controller.desktopSubtitle, style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              SizedBox(width: 172, child: AppButton.primary(label: 'Book appointment', onPressed: controller.bookAppointment, expand: true)),
              if (doctor) SizedBox(width: 172, child: AppButton.secondary(label: 'Manage availability', onPressed: controller.manageAvailability, expand: true)),
            ],
          ),
          const SizedBox(height: Dimensions.spaceLg),
          // Doctor: toolbar, summary, day strip, grid. Patient: summary, toolbar, schedule table.
          if (doctor) ...[
            toolbar,
            const SizedBox(height: Dimensions.pageSectionGap),
            summary,
            const SizedBox(height: Dimensions.pageSectionGap),
            if (controller.scope.value == AppointmentsScope.week) const Padding(padding: EdgeInsets.only(bottom: Dimensions.sectionContentGap), child: DayStrip(screenType: LayoutType.desktop)),
            _WeekGrid(controller: controller),
          ] else ...[
            summary,
            const SizedBox(height: Dimensions.pageSectionGap),
            toolbar,
            const SizedBox(height: Dimensions.pageSectionGap),
            _ScheduleTable(controller: controller),
          ],
        ],
      );
    });
  }
}

/// Week / Day, the date range with previous and next, and the practitioner dropdown.
class _RangeToolbar extends StatelessWidget {
  const _RangeToolbar({required this.controller});

  final AppointmentsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Obx(
          () => SegmentedButtons(
            labels: const ['Week', 'Day'],
            selected: controller.scope.value.index,
            buttonWidth: 78,
            spacing: 6,
            onSelected: (i) => controller.setScope(AppointmentsScope.values[i]),
          ),
        ),
        const Spacer(),
        IconButton(tooltip: 'Previous', onPressed: () => controller.step(-1), icon: Icon(AppIcons.chevronLeft, size: 18, color: scheme.onSurface)),
        Obx(() => Text(controller.rangeLabel, style: AppTextStyles.label.copyWith(color: scheme.onSurface))),
        IconButton(tooltip: 'Next', onPressed: () => controller.step(1), icon: Icon(AppIcons.chevronRight, size: 18, color: scheme.onSurface)),
        const Spacer(),
        PractitionerMenu(
          childBuilder: (selected) => Container(
            width: 175,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(Dimensions.radiusControl), border: Border.all(color: scheme.outline)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text(selected ?? 'All practitioners', overflow: TextOverflow.ellipsis, style: AppTextStyles.label.copyWith(color: scheme.primary))),
                const SizedBox(width: Dimensions.spaceSm),
                Icon(AppIcons.chevronDown, size: 14, color: scheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Time rows by practitioner column for the selected day.
class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.controller});

  final AppointmentsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final columns = controller.visiblePractitioners;
      final entries = controller.dayEntries;
      final border = BorderSide(color: scheme.outline);
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(Dimensions.radius), border: Border.all(color: scheme.outline)),
        child: Column(
          children: [
            Container(
              height: 52,
              color: AppColors.gridHeader,
              child: Row(
                children: [
                  SizedBox(width: _timeColumn, child: Padding(padding: const EdgeInsets.only(left: 14), child: Text('Time', style: AppTextStyles.label.copyWith(color: scheme.onSurface)))),
                  for (final p in columns) Expanded(child: Padding(padding: const EdgeInsets.only(left: 12), child: Text(p, overflow: TextOverflow.ellipsis, style: AppTextStyles.label.copyWith(color: scheme.onSurface)))),
                ],
              ),
            ),
            for (final slot in AppointmentsController.hourSlots)
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _rowHeight),
                child: IntrinsicHeight(
                  child: DecoratedBox(
                    decoration: BoxDecoration(border: Border(top: border)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: _timeColumn, child: Padding(padding: const EdgeInsets.only(left: 13, top: 16), child: Text(slot, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)))),
                        for (final p in columns)
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(border: Border(left: border)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (final e in entries.where((e) => e.hourSlot == slot && e.practitioner == p))
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                      child: _SlotCard(entry: e, onTap: () => controller.openEntry(e)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.entry, required this.onTap});

  final AppointmentEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final conflict = entry.kind == AppointmentKind.conflict;
    final available = entry.kind == AppointmentKind.available;
    final title = available ? '${entry.time} available' : entry.patient!;
    final detail = available ? 'Book appointment' : '${entry.type} · ${entry.time}';
    return Material(
      color: conflict ? AppColors.warningSoftBackground : scheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusControl), side: BorderSide(color: scheme.outline)),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.fromLTRB(9, 6, 9, 6),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, overflow: TextOverflow.ellipsis, style: AppTextStyles.label.copyWith(color: conflict ? AppColors.warningSoftText : scheme.onSurface)),
              Text(detail, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption.copyWith(color: conflict ? AppColors.warningSoftText : scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Patient view: the selected day as a table, one row per patient.
class _ScheduleTable extends StatelessWidget {
  const _ScheduleTable({required this.controller});

  final AppointmentsController controller;

  // Column weights from the design: Time 82, Patient 240, Visit 180, Practitioner 205, Status 176.
  static const _flex = [82, 240, 180, 205, 176];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final rows = controller.patientRows;
      final head = AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant);
      final cell = AppTextStyles.body.copyWith(color: scheme.onSurface);
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(Dimensions.radius), border: Border.all(color: scheme.outline)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 17, 19, 16),
              child: Row(
                children: [
                  Expanded(child: Text('Today’s schedule', style: AppTextStyles.h3.copyWith(color: scheme.onSurface))),
                  Text(controller.patientSummary, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderDefault,
            ),
            Container(
              height: 40,
              color: AppColors.gridHeader,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (final (i, label) in ['Time', 'Patient', 'Visit', 'Practitioner', 'Status'].indexed) Expanded(flex: _flex[i], child: Text(label, style: head)),
                  const SizedBox(width: 64),
                ],
              ),
            ),
            if (rows.isEmpty)
              const Padding(padding: EdgeInsets.all(Dimensions.spaceXl), child: Center(child: Text('No appointments match this day and filter.')))
            else
              for (final e in rows)
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: scheme.outline))),
                  child: Row(
                    children: [
                      Expanded(flex: _flex[0], child: Text(e.time, style: cell)),
                      Expanded(flex: _flex[1], child: Text(e.patient!, overflow: TextOverflow.ellipsis, style: cell)),
                      Expanded(flex: _flex[2], child: Text(e.type ?? '', overflow: TextOverflow.ellipsis, style: cell)),
                      Expanded(flex: _flex[3], child: Text(e.practitioner, overflow: TextOverflow.ellipsis, style: cell)),
                      Expanded(
                        flex: _flex[4],
                        child: Align(alignment: Alignment.centerLeft, child: _StatusPill(conflict: e.kind == AppointmentKind.conflict)),
                      ),
                      SizedBox(width: 64, child: Align(alignment: Alignment.centerRight, child: RecordActionsButton(entry: e))),
                    ],
                  ),
                ),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.conflict});

  final bool conflict;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 112,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: conflict ? AppColors.warningSoftBackground : scheme.primaryContainer, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
      child: Text(conflict ? 'Conflict' : 'Booked', style: AppTextStyles.caption.copyWith(color: conflict ? AppColors.warningSoftText : scheme.primary)),
    );
  }
}
