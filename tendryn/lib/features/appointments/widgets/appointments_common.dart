import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/features/appointments/models/appointment_entry.dart';
import 'package:tendryn/widgets/common/app_action_menu.dart';
import 'package:tendryn/widgets/common/app_card.dart';

/// Booked / free slots / conflicts. Desktop: three compact cards. Tablet: three
/// cards with a detail line. Mobile: two compact cards, then one.
class AppointmentsSummary extends GetView<AppointmentsController> {
  const AppointmentsSummary({super.key, required this.screenType});

  final LayoutType screenType;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final booked = ('Booked this week', '${controller.bookedThisWeek}', 'Across all practitioners');
      final free = ('Free slots today', '${controller.freeSlotsToday}', 'Open on the selected day');
      final conflicts = ('Conflict to resolve', '${controller.conflictsThisWeek}', 'Double bookings to review');
      Widget card((String, String, String) c, {Widget? trailing}) => Expanded(child: _SummaryCard(label: c.$1, value: c.$2, detail: c.$3, screenType: screenType, trailing: trailing));

      switch (screenType) {
        case LayoutType.mobile:
          return Column(
            spacing: Dimensions.spaceMd,
            children: [
              IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Dimensions.spaceMd, children: [card(booked), card(free)])),
              IntrinsicHeight(child: Row(spacing: Dimensions.spaceMd, children: [card(conflicts), const Spacer()])),
            ],
          );
        case LayoutType.tablet:
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  spacing: Dimensions.spaceMd,
                  children: [
                    IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Dimensions.spaceMd, children: [card(booked), card(free)])),
                    IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [card(conflicts), const Spacer()])),
                  ],
                );
              }
              return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Dimensions.spaceMd, children: [card(booked), card(free), card(conflicts)]));
            },
          );
        case LayoutType.desktop:
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Dimensions.spaceMd,
              children: [card(booked), card(free), card(conflicts, trailing: controller.conflictsThisWeek > 0 ? _ReviewPill(onTap: () => controller.openEntry(_firstConflict())) : null)],
            ),
          );
      }
    });
  }

  AppointmentEntry _firstConflict() => AppointmentsController.schedule.firstWhere((e) => e.kind == AppointmentKind.conflict);
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.detail, required this.screenType, this.trailing});

  final String label;
  final String value;
  final String detail;
  final LayoutType screenType;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final compact = screenType == LayoutType.mobile;
    final desktop = screenType == LayoutType.desktop;
    final valueStyle = compact ? AppTextStyles.h3Mobile : (desktop ? AppTextStyles.h2 : AppTextStyles.h3);
    return AppCard(
      padding: EdgeInsets.all(compact ? 10 : (desktop ? 16 : Dimensions.spaceMd)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: compact ? 3 : (desktop ? 2 : 6),
              children: [
                if (desktop) ...[
                  Text(value, style: AppTextStyles.tabular(valueStyle).copyWith(color: scheme.onSurface)),
                  Text(label, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                ] else ...[
                  Text(label, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                  Text(value, style: AppTextStyles.tabular(valueStyle).copyWith(color: scheme.onSurface)),
                  if (!compact) Text(detail, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _ReviewPill extends StatelessWidget {
  const _ReviewPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(Dimensions.radiusPill),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: AppColors.warningSoftBackground, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
      child: Text('Review ›', style: AppTextStyles.caption.copyWith(color: AppColors.warningSoftText)),
    ),
  );
}

/// A bordered group of small buttons; the selected one sits on the brand tint.
class SegmentedButtons extends StatelessWidget {
  const SegmentedButtons({super.key, required this.labels, required this.selected, required this.onSelected, this.buttonWidth = 119, this.spacing = 17, this.expand = false});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  final double buttonWidth;
  final double spacing;

  /// Share the available width equally instead of using [buttonWidth].
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      spacing: spacing,
      children: [
        for (final (i, label) in labels.indexed)
          _wrap(
            SizedBox(
              width: expand ? null : buttonWidth,
              height: Dimensions.buttonMinHeight,
              child: Material(
              color: i == selected ? scheme.primaryContainer : scheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusControl), side: BorderSide(color: scheme.outline)),
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                onTap: () => onSelected(i),
                child: Center(child: Text(label, style: AppTextStyles.label.copyWith(color: scheme.primary))),
              ),
            ),
            ),
          ),
      ],
    );
  }

  Widget _wrap(Widget child) => expand ? Expanded(child: child) : child;
}

/// Bordered 50px bar that holds toolbar controls.
class ToolbarBar extends StatelessWidget {
  const ToolbarBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(Dimensions.radius), border: Border.all(color: scheme.outline)),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

/// Doctor / Patients switch.
class AppointmentsModeToggle extends GetView<AppointmentsController> {
  const AppointmentsModeToggle({super.key, this.spacing = 17, this.expand = false});

  final double spacing;
  final bool expand;

  @override
  Widget build(BuildContext context) => Obx(
    () => SegmentedButtons(
      labels: const ['Doctor', 'Patient'],
      selected: controller.mode.value.index,
      spacing: spacing,
      expand: expand,
      onSelected: (i) => controller.setMode(AppointmentsMode.values[i]),
    ),
  );
}

/// Opens the practitioner list. [child] is the visible control (a labelled
/// dropdown on desktop, the filter icon button on tablet and phone).
class PractitionerMenu extends GetView<AppointmentsController> {
  const PractitionerMenu({super.key, required this.childBuilder});

  final Widget Function(String? selected) childBuilder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(
      () => PopupMenuButton<String?>(
        tooltip: 'Filter by practitioner',
        position: PopupMenuPosition.under,
        color: scheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radius), side: BorderSide(color: scheme.outline)),
        initialValue: controller.practitioner.value,
        onSelected: controller.setPractitioner,
        itemBuilder: (_) => [
          PopupMenuItem(value: null, height: Dimensions.touchTarget, child: Text('All practitioners', style: AppTextStyles.label)),
          for (final p in AppointmentsController.practitioners) PopupMenuItem(value: p, height: Dimensions.touchTarget, child: Text(p, style: AppTextStyles.label)),
        ],
        child: childBuilder(controller.practitioner.value),
      ),
    );
  }
}

/// The 40px filter icon button (68px wide) used on tablet and phone; tinted
/// while a practitioner is selected.
class PractitionerFilterButton extends StatelessWidget {
  const PractitionerFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PractitionerMenu(
      childBuilder: (selected) => Container(
        width: Dimensions.touchTarget,
        height: Dimensions.touchTarget,
        decoration: BoxDecoration(
          color: selected == null ? scheme.surface : scheme.primaryContainer,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          border: Border.all(color: scheme.outline),
        ),
        child: Icon(AppIcons.filter, size: Dimensions.iconSize, color: scheme.primary),
      ),
    );
  }
}

/// Mon 28 … Sat 3. Desktop: one wide row with a pill on the selected day.
/// Tablet / phone: tiles with the weekday over the date.
class DayStrip extends GetView<AppointmentsController> {
  const DayStrip({super.key, required this.screenType});

  final LayoutType screenType;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final desktop = screenType == LayoutType.desktop;
    final mobile = screenType == LayoutType.mobile;
    return Obx(() {
      final days = controller.weekDays.take(mobile ? 5 : 6).toList();
      return Container(
        height: desktop ? 52 : 74,
        padding: EdgeInsets.symmetric(horizontal: desktop ? 8 : 11, vertical: desktop ? 11 : 9),
        decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(Dimensions.radius), border: Border.all(color: scheme.outline)),
        child: Row(
          children: [
            for (final (i, day) in days.indexed)
              Expanded(
                child: Center(
                  child: _DayTile(
                    weekday: _weekdays[i],
                    day: day.day,
                    selected: controller.isSelected(day),
                    desktop: desktop,
                    onTap: () => controller.selectDay(day),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.weekday, required this.day, required this.selected, required this.desktop, required this.onTap});

  final String weekday;
  final int day;
  final bool selected;
  final bool desktop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    final radius = BorderRadius.circular(desktop ? Dimensions.radiusPill : Dimensions.radiusControl);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: desktop
              ? Container(
                  constraints: const BoxConstraints(minWidth: 96),
                  height: 28,
                  alignment: Alignment.center,
                  child: Text('$weekday $day', style: (selected ? AppTextStyles.caption : AppTextStyles.label).copyWith(color: color)),
                )
              : Container(
                  constraints: const BoxConstraints(minWidth: 52),
                  height: 54,
                  alignment: Alignment.center,
                  child: Text('$weekday\n$day', textAlign: TextAlign.center, style: AppTextStyles.label.copyWith(color: color)),
                ),
        ),
      ),
    );
  }
}

/// One slot as a card (tablet and phone): time + name, status or Book, detail.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.entry, required this.onTap});

  final AppointmentEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final available = entry.kind == AppointmentKind.available;
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(15, 7, 15, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 28,
              child: Row(
                children: [
                  Text(entry.time, style: AppTextStyles.label.copyWith(color: scheme.primary)),
                  const SizedBox(width: 5),
                  Expanded(child: Text(available ? 'Available slot' : entry.patient!, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyMedium.copyWith(fontFamily: AppTextStyles.headingFamily, fontWeight: FontWeight.w600, color: scheme.onSurface))),
                  if (available)
                    Text('Book ›', style: AppTextStyles.label.copyWith(color: scheme.primary))
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                      decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
                      child: Text('Booked', style: AppTextStyles.caption.copyWith(color: scheme.primary)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Text(
              available ? '${entry.practitioner} · ${entry.minutes} min' : '${entry.type} · ${entry.practitionerShort}',
              style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Amber notice listing the day's double bookings (tablet and phone).
class ConflictNotice extends StatelessWidget {
  const ConflictNotice({super.key, required this.conflicts, required this.onReview});

  final List<AppointmentEntry> conflicts;
  final ValueChanged<AppointmentEntry> onReview;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.label.copyWith(color: AppColors.warningSoftText);
    final count = conflicts.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: AppColors.warningSoftBackground, borderRadius: BorderRadius.circular(Dimensions.radiusControl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Dimensions.spaceMd,
        children: [
          Text('$count double ${count == 1 ? 'booking needs' : 'bookings need'} attention', style: style),
          for (final c in conflicts)
            InkWell(
              onTap: () => onReview(c),
              child: Row(
                children: [
                  Expanded(child: Text('${c.time} · ${c.practitioner}', style: style)),
                  Text('Review ›', style: style),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A booked visit as a record card (Patient view, tablet and phone): name and
/// actions menu, then time, reason and practitioner.
class AppointmentRecordCard extends StatelessWidget {
  const AppointmentRecordCard({super.key, required this.entry, required this.onTap, this.wide = false});

  final AppointmentEntry entry;
  final VoidCallback onTap;

  /// Tablet: time and reason share a row.
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final detail = AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant);
    final time = Text('Time: ${entry.time}', style: detail);
    final reason = Text('Reason: ${entry.type}', style: detail);
    final practitioner = Text('Practitioner: ${entry.practitionerCard}', style: detail);
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: const EdgeInsets.all(Dimensions.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Dimensions.spaceMd,
          children: [
            Row(
              children: [
                Expanded(child: Text(entry.patient!, overflow: TextOverflow.ellipsis, style: AppTextStyles.h3Mobile.copyWith(color: scheme.onSurface))),
                RecordActionsButton(entry: entry),
              ],
            ),
            if (wide) ...[
              Row(children: [Expanded(child: time), Expanded(child: reason)]),
              practitioner,
            ] else
              Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Dimensions.spaceSm, children: [time, reason, practitioner]),
          ],
        ),
      ),
    );
  }
}

/// The 48px ⋮ button on a record; opens the 212px actions menu.
class RecordActionsButton extends GetView<AppointmentsController> {
  const RecordActionsButton({super.key, required this.entry});

  final AppointmentEntry entry;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: Color(0x1F000000),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      child: PopupMenuButton<RecordAction>(
        tooltip: 'Actions',
        position: PopupMenuPosition.under,
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 6,
        shadowColor: const Color(0x1F000000),
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints.tightFor(width: 212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        clipBehavior: Clip.antiAlias,
        onSelected: (action) => controller.onRecordAction(action, entry),
        itemBuilder: (_) => [
          for (final action in RecordAction.values)
            AppActionMenuItem<RecordAction>(
              value: action,
              label: action.label,
              alignment: Alignment.center,
            ),
        ],
        child: const AppActionsBoxButton(icon: AppIcons.rowMenu),
      ),
    );
  }
}

/// The selected day as cards: by practitioner schedule (Doctor) or as patient
/// records (Patient), with the conflict notice and an empty state.
class AppointmentList extends GetView<AppointmentsController> {
  const AppointmentList({super.key, this.wide = false});

  /// Tablet arrangement of the patient record cards.
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doctor = controller.mode.value == AppointmentsMode.doctor;
      final entries = controller.dayEntries;
      final cards = entries.where((e) => doctor ? e.kind != AppointmentKind.conflict : e.kind == AppointmentKind.booked).toList();
      final conflicts = entries.where((e) => e.kind == AppointmentKind.conflict).toList();
      if (cards.isEmpty && conflicts.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(Dimensions.spaceXl),
          child: Center(child: Text('No appointments match this day and filter.', textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        );
      }
      return Column(
        spacing: Dimensions.spaceMd,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = wide && constraints.maxWidth >= 900 ? 2 : 1;
              final appointmentCards = [
                for (final e in cards)
                  doctor
                      ? AppointmentCard(entry: e, onTap: () => controller.openEntry(e))
                      : AppointmentRecordCard(entry: e, wide: wide, onTap: () => controller.openEntry(e)),
              ];
              if (columns == 1) {
                return Column(
                  spacing: Dimensions.spaceMd,
                  children: appointmentCards,
                );
              }
              final spacing = Dimensions.spaceMd;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final card in appointmentCards)
                    SizedBox(width: cardWidth, child: card),
                ],
              );
            },
          ),
          if (conflicts.isNotEmpty)
            ConflictNotice(conflicts: conflicts, onReview: controller.openEntry),
        ],
      );
    });
  }
}
