import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/api/api_exception.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/appointments/controllers/doctor_appointments_controller.dart';
import 'package:tendryn/features/appointments/models/doctor_appointment.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_search_field.dart';

/// Doctor role, Appointments: the doctor's own appointments for one day or the
/// Monday to Friday week. Desktop uses a table (day) or a five-column grid
/// (week); tablet a two-column card grid; phone a single column.

TextStyle _inter(double size, int weight, Color color, {double? height}) => TextStyle(
      fontFamily: AppTextStyles.bodyFamily,
      fontSize: size,
      height: height == null ? null : height / size,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [FontVariation.weight(weight.toDouble())],
      color: color,
    );

TextStyle _jakarta(double size, int weight, Color color, {double? height}) => TextStyle(
      fontFamily: AppTextStyles.headingFamily,
      fontSize: size,
      height: height == null ? null : height / size,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [FontVariation.weight(weight.toDouble())],
      color: color,
    );

const _noAppointments = 'No appointments for this day.';

class DoctorAppointmentsDesktop extends GetView<DoctorAppointmentsController> {
  const DoctorAppointmentsDesktop({super.key});

  @override
  Widget build(BuildContext context) => Obx(() => controller.isAvailabilityTab ? _availability() : _days(context));

  Widget _days(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
      children: [
        const _Heading(subtitleSize: 13),
        const SizedBox(height: 20),
        const _Tabs(),
        const SizedBox(height: 20),
        const Row(
          children: [
            SizedBox(width: 315, child: _Search()),
            Spacer(),
            _DayStepper(),
            SizedBox(width: 6),
            SizedBox(width: 229, child: _DateField(iconAtEnd: true, fontSize: 12)),
            SizedBox(width: 16),
            _ScopeButton(width: 128),
          ],
        ),
        const SizedBox(height: 20),
        Obx(() => controller.isWeek ? const _DesktopWeekGrid() : const _DesktopTable()),
      ],
    );
  }

  Widget _availability() {
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
      children: const [
        _Heading(subtitleSize: 13, trailing: _RequestLeaveButton()),
        SizedBox(height: 20),
        _Tabs(),
        SizedBox(height: 20),
        _AvailabilityContent(layout: _AvailabilityLayout.desktop),
      ],
    );
  }
}

class DoctorAppointmentsTablet extends GetView<DoctorAppointmentsController> {
  const DoctorAppointmentsTablet({super.key});

  @override
  Widget build(BuildContext context) => Obx(() => controller.isAvailabilityTab ? _availability() : _days(context));

  Widget _days(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginDesktop, 28, Dimensions.pageMarginDesktop, 36),
      children: [
        const _Heading(subtitleSize: 13),
        const SizedBox(height: 16),
        const _Tabs(),
        const SizedBox(height: 16),
        const _Search(),
        const SizedBox(height: 16),
        const _DateControls(dateFontSize: 13, headingSize: 20, sideBySideWeek: true),
        Obx(() {
          if (controller.isWeek) {
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  const _WeekAgenda(maxColumns: 2, dayHeadingSize: 18, cardSpacing: 16),
                  Text(controller.weekFooterLabel, style: _inter(12, 400, AppColors.textSecondary, height: 16)),
                ],
              ),
            );
          }
          final entries = controller.pageEntries;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              spacing: 16,
              children: [
                entries.isEmpty ? const _Empty() : _CardGrid(entries, maxColumns: 2, spacing: 16),
                Row(
                  children: [
                    Expanded(child: Text(controller.footerLabel, style: _inter(12, 400, AppColors.textSecondary, height: 16))),
                    const _PageControls(),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _availability() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginDesktop, 28, Dimensions.pageMarginDesktop, 36),
      children: const [
        _Heading(subtitleSize: 13, subtitleHeight: 18),
        SizedBox(height: 16),
        _Tabs(),
        SizedBox(height: 16),
        _AvailabilityContent(layout: _AvailabilityLayout.tablet),
      ],
    );
  }
}

class DoctorAppointmentsMobile extends GetView<DoctorAppointmentsController> {
  const DoctorAppointmentsMobile({super.key});

  @override
  Widget build(BuildContext context) => Obx(() => controller.isAvailabilityTab ? _availability() : _days(context));

  Widget _days(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, Dimensions.pageMarginMobile, Dimensions.pageMarginMobile, Dimensions.spaceLg),
      children: [
        const _Heading(subtitleSize: 11, subtitleHeight: 18),
        const SizedBox(height: 16),
        const _Tabs(),
        const SizedBox(height: 16),
        const _Search(),
        const SizedBox(height: 16),
        const _DateControls(dateFontSize: 12, headingSize: 16),
        Obx(() {
          if (controller.isWeek) {
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  const _WeekAgenda(maxColumns: 1, dayHeadingSize: 16, cardSpacing: 12),
                  Text(controller.weekFooterLabel, style: _inter(12, 400, AppColors.textSecondary, height: 16)),
                ],
              ),
            );
          }
          final entries = controller.pageEntries;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              spacing: 16,
              children: [
                entries.isEmpty ? const _Empty() : _CardGrid(entries, maxColumns: 1, spacing: 12),
                Row(
                  spacing: Dimensions.componentGap,
                  children: [
                    Expanded(child: AppButton.secondary(label: 'Previous', onPressed: controller.hasPrevious ? controller.previousPage : null)),
                    Expanded(child: AppButton.secondary(label: 'Next', onPressed: controller.hasNext ? controller.nextPage : null)),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _availability() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, Dimensions.pageMarginMobile, Dimensions.pageMarginMobile, Dimensions.spaceLg),
      children: const [
        _Heading(subtitleSize: 11, subtitleHeight: 18),
        SizedBox(height: 16),
        _Tabs(),
        SizedBox(height: 16),
        _AvailabilityContent(layout: _AvailabilityLayout.mobile),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.subtitleSize, this.subtitleHeight, this.trailing});

  final double subtitleSize;
  final double? subtitleHeight;

  /// Action at the end of the heading row (Request Leave on desktop).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Semantics(header: true, child: Text('Appointments', style: _jakarta(24, 700, AppColors.textPrimary))),
        Text(
          'View your scheduled appointments and manage your availability.',
          style: _inter(subtitleSize, 400, AppColors.textSecondary, height: subtitleHeight),
        ),
      ],
    );
    if (trailing == null) return heading;
    return Row(
      spacing: Dimensions.spaceMd,
      children: [Expanded(child: heading), trailing!],
    );
  }
}

/// Appointments / My Availability: the selected tab is tinted, the other switches to it.
class _Tabs extends GetView<DoctorAppointmentsController> {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        spacing: 24,
        children: [
          Expanded(child: _Tab(label: 'Appointments', selected: controller.tab.value == DoctorTab.appointments, onTap: () => controller.setTab(DoctorTab.appointments))),
          Expanded(child: _Tab(label: 'My Availability', selected: controller.tab.value == DoctorTab.availability, onTap: () => controller.setTab(DoctorTab.availability))),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.brandTint : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: selected ? null : onTap,
          child: Container(
            height: 38,
            alignment: Alignment.center,
            child: Text(label, style: _inter(14, 500, selected ? AppColors.brandPrimary : AppColors.textSecondary, height: 20)),
          ),
        ),
      ),
    );
  }
}

class _Search extends GetView<DoctorAppointmentsController> {
  const _Search();

  @override
  Widget build(BuildContext context) {
    return AppSearchField(
      hint: 'Search patient name or folder no.',
      hintStyle: _inter(13, 400, AppColors.textSecondary),
      onChanged: controller.setSearch,
    );
  }
}

/// ‹ › circles: previous / next day, or week in the week scope.
class _DayStepper extends GetView<DoctorAppointmentsController> {
  const _DayStepper();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final unit = controller.isWeek ? 'week' : 'day';
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Dimensions.componentGap,
        children: [
          _StepButton(glyph: '‹', label: 'Previous $unit', onTap: () => controller.step(-1)),
          _StepButton(glyph: '›', label: 'Next $unit', onTap: () => controller.step(1)),
        ],
      );
    });
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.glyph, required this.label, required this.onTap});

  final String glyph;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.backgroundSurface,
        shape: const CircleBorder(side: BorderSide(color: AppColors.borderDefault)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(child: ExcludeSemantics(child: Text(glyph, style: _inter(22, 500, AppColors.brandPrimary, height: 24)))),
          ),
        ),
      ),
    );
  }
}

/// Tappable selected-day field that opens a date picker.
class _DateField extends GetView<DoctorAppointmentsController> {
  const _DateField({this.iconAtEnd = false, required this.fontSize});

  final bool iconAtEnd;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(AppIcons.calendarDays, size: iconAtEnd ? 24 : 16, color: AppColors.brandPrimary);
    final text = Obx(
      () => Text(
        controller.dateFieldLabel,
        style: _inter(fontSize, 500, AppColors.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    return Semantics(
      button: true,
      label: 'Choose date',
      child: Material(
        color: AppColors.backgroundSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          onTap: () => controller.pickDate(context),
          child: Container(
            height: Dimensions.buttonMinHeight,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.statusX),
            child: Row(
              spacing: iconAtEnd ? 16 : Dimensions.componentGap,
              children: iconAtEnd ? [Expanded(child: text), icon] : [icon, Expanded(child: text)],
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary "Today ⌄" / "Week ⌄" selector that switches between the day and
/// week schedule.
class _ScopeButton extends GetView<DoctorAppointmentsController> {
  const _ScopeButton({this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    final button = PopupMenuButton<DoctorScheduleScope>(
      tooltip: 'Choose schedule view',
      position: PopupMenuPosition.under,
      onSelected: controller.setScope,
      itemBuilder: (context) => [
        for (final option in DoctorScheduleScope.values)
          PopupMenuItem(
            value: option,
            height: Dimensions.touchTarget,
            child: Text(option.label, style: AppTextStyles.label),
          ),
      ],
      child: Container(
        height: Dimensions.buttonMinHeight,
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX),
        decoration: BoxDecoration(color: AppColors.brandPrimary, borderRadius: BorderRadius.circular(Dimensions.radiusControl)),
        child: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 7,
            children: [
              Text(controller.scope.value.label, style: _inter(14, 500, AppColors.textOnBrand, height: 20)),
              const Icon(AppIcons.chevronDown, size: 16, color: AppColors.textOnBrand),
            ],
          ),
        ),
      ),
    );
    return Semantics(button: true, label: 'Schedule view', child: button);
  }
}

/// Tablet and phone date controls. Day scope: date field + selector, then the
/// day heading with ‹ ›. Week scope: week range and summary with ‹ ›, beside
/// (tablet) or under (phone) the date field + selector.
class _DateControls extends GetView<DoctorAppointmentsController> {
  const _DateControls({required this.dateFontSize, required this.headingSize, this.sideBySideWeek = false});

  final double dateFontSize;
  final double headingSize;
  final bool sideBySideWeek;

  @override
  Widget build(BuildContext context) {
    final dateRow = Row(
      spacing: Dimensions.componentGap,
      children: [Expanded(child: _DateField(fontSize: dateFontSize)), const _ScopeButton()],
    );
    return Obx(() {
      if (!controller.isWeek) {
        return Column(
          spacing: 10,
          children: [
            dateRow,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(controller.dayHeading, style: _jakarta(headingSize, 600, AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: Dimensions.componentGap),
                const _DayStepper(),
              ],
            ),
          ],
        );
      }
      final weekContext = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(controller.weekHeading, style: _jakarta(headingSize, 600, AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(controller.weekSummary, style: _inter(12, 400, AppColors.textSecondary, height: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.componentGap),
          const _DayStepper(),
        ],
      );
      return LayoutBuilder(
        builder: (context, constraints) {
          if (sideBySideWeek && constraints.maxWidth >= 680) {
            return Row(
              spacing: 10,
              children: [Expanded(child: weekContext), Expanded(child: dateRow)],
            );
          }
          return Column(spacing: 10, children: [dateRow, weekContext]);
        },
      );
    });
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status, {required this.weight, this.size = 12});

  final DoctorAppointmentStatus status;
  final int weight;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.badgePaddingX, vertical: Dimensions.badgePaddingY),
      decoration: BoxDecoration(color: status.background, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
      child: Text(status.label, style: _inter(size, weight, status.foreground, height: 16), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
    );
  }
}

/// Tablet and phone card: time + status, patient, visit + View.
class _AppointmentCard extends GetView<DoctorAppointmentsController> {
  const _AppointmentCard(this.appointment, {this.compactAction = false});

  final DoctorAppointment appointment;

  /// Week scope uses the shorter 28px View action.
  final bool compactAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appointment.time, style: _inter(14, 500, AppColors.textPrimary, height: 20)),
                const SizedBox(width: Dimensions.componentGap),
                Flexible(child: _StatusBadge(appointment.status, weight: 400)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(appointment.patient, style: _inter(16, 500, AppColors.textPrimary, height: 24)),
                Text(appointment.folderLabel, style: _inter(12, 400, AppColors.textSecondary, height: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 4, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(appointment.visit ?? ' ', style: _inter(13, 400, AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(0, compactAction ? 28 : 36),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: compactAction ? 4 : 0),
                  ),
                  onPressed: () => controller.viewAppointment(context, appointment),
                  child: Text('View', style: _inter(14, 500, AppColors.brandPrimary, height: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Appointment cards in one or two equal columns (two when there is room).
class _CardGrid extends StatelessWidget {
  const _CardGrid(this.entries, {required this.maxColumns, required this.spacing, this.compactAction = false});

  final List<DoctorAppointment> entries;
  final int maxColumns;
  final double spacing;
  final bool compactAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 480 ? 1 : maxColumns;
        return Column(
          spacing: spacing,
          children: [
            for (var i = 0; i < entries.length; i += columns)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: spacing,
                  children: [
                    for (var c = 0; c < columns; c++)
                      Expanded(
                        child: i + c < entries.length ? _AppointmentCard(entries[i + c], compactAction: compactAction) : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Tablet and phone week scope: one section per weekday.
class _WeekAgenda extends GetView<DoctorAppointmentsController> {
  const _WeekAgenda({required this.maxColumns, required this.dayHeadingSize, required this.cardSpacing});

  final int maxColumns;
  final double dayHeadingSize;
  final double cardSpacing;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        spacing: 24,
        children: [
          for (final day in controller.weekDays) _agendaDay(day),
        ],
      ),
    );
  }

  Widget _agendaDay(DateTime day) {
    final entries = controller.appointmentsOn(day);
    final today = controller.isToday(day);
    final dayStyle = _jakarta(dayHeadingSize, 600, today ? AppColors.brandPrimary : AppColors.textPrimary);
    return Column(
      spacing: 12,
      children: [
        Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: today ? 10 : 0),
          decoration: BoxDecoration(color: today ? AppColors.brandTint : null, borderRadius: BorderRadius.circular(Dimensions.radiusControl)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Flexible(child: Text(DoctorAppointmentsController.dayLabel(day), style: dayStyle, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (today) Text('Today', style: _inter(12, 500, AppColors.brandPrimary)),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.componentGap),
              Text(DoctorAppointmentsController.countLabel(entries.length), style: _inter(12, 400, AppColors.textSecondary)),
            ],
          ),
        ),
        if (entries.isNotEmpty) _CardGrid(entries, maxColumns: maxColumns, spacing: cardSpacing, compactAction: !today),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.spaceXl),
      child: Center(child: Text(_noAppointments, style: _inter(13, 400, AppColors.textSecondary))),
    );
  }
}

/// Previous / page numbers / Next (tablet and desktop, day scope).
class _PageControls extends GetView<DoctorAppointmentsController> {
  const _PageControls();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.currentPage;
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Dimensions.componentGap,
        children: [
          AppButton.secondary(label: 'Previous', onPressed: controller.hasPrevious ? controller.previousPage : null),
          for (var i = 0; i < controller.pageCount; i++)
            i == current
                ? AppButton.primary(label: '${i + 1}', onPressed: () {})
                : AppButton.secondary(label: '${i + 1}', onPressed: () => controller.page.value = i),
          AppButton.secondary(label: 'Next', onPressed: controller.hasNext ? controller.nextPage : null),
        ],
      );
    });
  }
}

class _DesktopTable extends GetView<DoctorAppointmentsController> {
  const _DesktopTable();

  static const _gap = 29.0;
  static const _detailsWidth = 80.0;

  /// Time, Patient, Visit, Status share the row in the Figma proportions.
  static Widget _cells(Widget time, Widget patient, Widget visit, Widget status, Widget details) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        spacing: _gap,
        children: [
          Expanded(flex: 100, child: time),
          Expanded(flex: 240, child: patient),
          Expanded(flex: 180, child: visit),
          Expanded(flex: 220, child: Align(alignment: Alignment.centerLeft, child: status)),
          SizedBox(width: _detailsWidth, child: Center(child: details)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heading = _inter(11, 600, AppColors.textSecondary);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Obx(() => Text(controller.dayHeading, style: _inter(16, 600, AppColors.textPrimary))),
          ),
          ColoredBox(
            color: AppColors.backgroundApp,
            child: _cells(
              Text('Time', style: heading),
              Text('Patient', style: heading),
              Text('Visit', style: heading),
              Text('Status', style: heading),
              Text('Details', style: heading),
            ),
          ),
          Obx(() {
            final entries = controller.pageEntries;
            if (entries.isEmpty) {
              return const DecoratedBox(
                decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderDefault))),
                child: _Empty(),
              );
            }
            return Column(
              children: [
                for (final a in entries)
                  DecoratedBox(
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderDefault))),
                    child: _cells(
                      Text(a.time, style: _inter(12, 600, AppColors.textPrimary)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(a.patient, style: _inter(13, 500, AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(a.folderLabel, style: _inter(11, 400, AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      Text(a.visit ?? '', style: _inter(12, 400, AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      _StatusBadge(a.status, weight: 500),
                      TextButton(
                        style: TextButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                        onPressed: () => controller.viewAppointment(context, a),
                        child: Text('View', style: _inter(13, 600, AppColors.brandPrimary)),
                      ),
                    ),
                  ),
              ],
            );
          }),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(controller.footerLabel, style: _inter(12, 400, AppColors.textSecondary, height: 16))),
                const _PageControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Desktop week scope: Monday to Friday columns of compact appointment cards.
class _DesktopWeekGrid extends GetView<DoctorAppointmentsController> {
  const _DesktopWeekGrid();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(controller.weekHeading, style: _inter(16, 600, AppColors.textPrimary))),
                Text('Mon – Fri working week', style: _inter(12, 400, AppColors.textSecondary)),
              ],
            ),
          ),
          Obx(
            () => IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, day) in controller.weekDays.indexed) Expanded(child: _DayColumn(day: day, showLeftBorder: i > 0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayColumn extends GetView<DoctorAppointmentsController> {
  const _DayColumn({required this.day, required this.showLeftBorder});

  final DateTime day;
  final bool showLeftBorder;

  @override
  Widget build(BuildContext context) {
    final today = controller.isToday(day);
    final entries = controller.appointmentsOn(day);
    const side = BorderSide(color: AppColors.borderDefault);
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
      decoration: BoxDecoration(
        color: today ? AppColors.weekTodayTint : null,
        border: Border(top: side, left: showLeftBorder ? side : BorderSide.none),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            today ? '${DoctorAppointmentsController.shortDayLabel(day)} · Today' : DoctorAppointmentsController.shortDayLabel(day),
            style: _inter(12, 600, today ? AppColors.brandPrimary : AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          for (final a in entries) _WeekCard(a),
        ],
      ),
    );
  }
}

class _WeekCard extends GetView<DoctorAppointmentsController> {
  const _WeekCard(this.appointment);

  final DoctorAppointment appointment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${appointment.time} ${appointment.patient}, ${appointment.status.label}',
      child: Material(
        color: AppColors.backgroundApp,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          onTap: () => controller.viewAppointment(context, appointment),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(appointment.time, style: _inter(10, 500, AppColors.textSecondary)),
                    Text(appointment.patient, style: _inter(12, 500, AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: _StatusBadge(appointment.status, weight: 400, size: 10)),
                    const SizedBox(width: Dimensions.componentGap),
                    Text('View', style: _inter(10, 600, AppColors.brandPrimary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Appointment details (opened from "View")
// -----------------------------------------------------------------------------

const _drawerWidth = 472.0;

enum _DetailsVariant { drawer, sheet, page }

/// Desktop: the details slide in from the right over the Appointments list.
void showDoctorAppointmentDrawer(BuildContext context, DoctorAppointment appointment) {
  _showSideDrawer(context, (close) => _DetailsPanel(appointment: appointment, variant: _DetailsVariant.drawer, onClose: close));
}

/// Slides [builder]'s panel in from the right over a dimmed page.
void _showSideDrawer(BuildContext context, Widget Function(VoidCallback close) builder) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, animation, secondaryAnimation) => Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: AppColors.backgroundSurface,
        elevation: 16,
        child: SizedBox(
          width: _drawerWidth,
          height: double.infinity,
          child: builder(() => Navigator.of(dialogContext).pop()),
        ),
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

/// Phone: the details rise from the bottom over the Appointments list.
Future<void> showDoctorAppointmentSheet(BuildContext context, DoctorAppointment appointment) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.backgroundSurface,
    barrierColor: AppColors.scrim,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    builder: (sheetContext) => _DetailsPanel(
      appointment: appointment,
      variant: _DetailsVariant.sheet,
      onClose: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

/// Tablet: the details as a page of their own, inside the navigation shell.
class DoctorAppointmentDetailsPage extends GetView<DoctorAppointmentsController> {
  const DoctorAppointmentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final appointment = controller.selected.value;
      if (appointment == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Dimensions.spaceMd,
              children: [
                Text('Appointment not found', style: _jakarta(20, 600, AppColors.textPrimary)),
                Text('Open an appointment from the Appointments list.', style: _inter(13, 400, AppColors.textSecondary)),
                AppButton.secondary(label: 'Back to appointments', onPressed: controller.closeDetailsPage),
              ],
            ),
          ),
        );
      }
      return _DetailsPanel(appointment: appointment, variant: _DetailsVariant.page, onClose: controller.closeDetailsPage);
    });
  }
}

/// Header, details and the Cancel / View Patient Profile actions for one
/// appointment, laid out for a [_DetailsVariant].
class _DetailsPanel extends GetView<DoctorAppointmentsController> {
  const _DetailsPanel({required this.appointment, required this.variant, required this.onClose});

  final DoctorAppointment appointment;
  final _DetailsVariant variant;
  final VoidCallback onClose;

  /// `Thursday · 22 October 2026 · 10:30`
  String get _subtitle => '${Formatters.longDate(appointment.date).replaceFirst(',', ' ·')} · ${appointment.time}';

  @override
  Widget build(BuildContext context) {
    final body = _DetailsBody(appointment: appointment, variant: variant);
    final footer = _DetailsFooter(
      onCancel: onClose,
      onViewProfile: () => controller.openPatientProfile(appointment, onClose),
    );
    switch (variant) {
      case _DetailsVariant.drawer:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderDefault))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Title(title: 'Appointment details', subtitle: _subtitle)),
                  _CloseButton(onTap: onClose, size: 32, child: Text('×', style: _inter(20, 400, AppColors.textSecondary))),
                ],
              ),
            ),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: body)),
            footer,
          ],
        );
      case _DetailsVariant.sheet:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.borderDefault, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _Title(title: 'Appointment details', subtitle: _subtitle)),
                        _CloseButton(onTap: onClose, size: Dimensions.touchTarget, child: const Icon(AppIcons.close, size: 20, color: AppColors.textPrimary)),
                      ],
                    ),
                    body,
                  ],
                ),
              ),
            ),
            footer,
          ],
        );
      case _DetailsVariant.page:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginDesktop, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 20,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Back to appointments',
                          child: Material(
                            color: AppColors.backgroundSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                              side: const BorderSide(color: AppColors.borderDefault),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                              onTap: onClose,
                              child: SizedBox(
                                width: 36,
                                height: 36,
                                child: Center(child: ExcludeSemantics(child: Text('‹', style: _inter(32, 400, AppColors.brandPrimary, height: 32)))),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: _Title(title: 'Appointment details', subtitle: _subtitle)),
                      ],
                    ),
                    body,
                  ],
                ),
              ),
            ),
            footer,
          ],
        );
    }
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Semantics(header: true, child: Text(title, style: _jakarta(20, 600, AppColors.textPrimary))),
        Text(subtitle, style: _inter(12, 400, AppColors.textSecondary, height: 16)),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap, required this.size, required this.child});

  final VoidCallback onTap;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        onTap: onTap,
        child: SizedBox(width: size, height: size, child: Center(child: ExcludeSemantics(child: child))),
      ),
    );
  }
}

/// Patient identity, the appointment facts and the read-only notes.
class _DetailsBody extends GetView<DoctorAppointmentsController> {
  const _DetailsBody({required this.appointment, required this.variant});

  final DoctorAppointment appointment;
  final _DetailsVariant variant;

  @override
  Widget build(BuildContext context) {
    final compact = variant == _DetailsVariant.sheet;
    final rows = <(String, Widget)>[
      ('Date', _value('${Formatters.longDate(appointment.date).substring(0, 3)} ${Formatters.shortDate(appointment.date)}')),
      ('Time', _value('${appointment.time} – ${appointment.endTime}')),
      ('Visit type', _value(appointment.visit ?? 'Not recorded')),
      ('Clinician', _value(appointment.clinician)),
      ('Status', Align(alignment: variant == _DetailsVariant.page ? Alignment.centerRight : Alignment.centerLeft, child: _StatusBadge(appointment.status, weight: 500))),
      ('Check-in', _value(appointment.checkInLabel)),
      ('Booked by', _value(appointment.bookedBy)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _Identity(appointment: appointment, variant: variant, meta: controller.patientMeta(appointment)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(color: AppColors.backgroundApp, borderRadius: BorderRadius.circular(5)),
          child: Column(
            spacing: 16,
            children: [
              for (final (label, value) in rows)
                Row(
                  spacing: 12,
                  children: [
                    SizedBox(width: compact ? 110 : 150, child: Text(label, style: _inter(12, 400, AppColors.textSecondary))),
                    Expanded(child: value),
                  ],
                ),
            ],
          ),
        ),
        const _ReadOnlyAlert(),
        _StatusNote(text: appointment.statusNote, topAligned: compact),
      ],
    );
  }

  Widget _value(String text) => Text(
        text,
        style: _inter(14, 400, AppColors.textPrimary),
        textAlign: variant == _DetailsVariant.page ? TextAlign.right : TextAlign.left,
      );
}

class _Identity extends StatelessWidget {
  const _Identity({required this.appointment, required this.variant, required this.meta});

  final DoctorAppointment appointment;
  final _DetailsVariant variant;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final compact = variant == _DetailsVariant.sheet;
    final avatar = variant == _DetailsVariant.drawer ? 54.0 : 40.0;
    return Container(
      padding: compact ? const EdgeInsets.all(14) : const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        border: Border.all(color: AppColors.borderDefault),
        borderRadius: BorderRadius.circular(compact ? Dimensions.radiusControl : Dimensions.radius),
      ),
      child: Row(
        spacing: compact ? 12 : 11,
        children: [
          Container(
            width: avatar,
            height: avatar,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.backgroundSurface, shape: BoxShape.circle),
            child: Text(Formatters.initials(appointment.patient), style: _inter(14, 500, AppColors.brandPrimary, height: 20)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: compact ? 3 : 0,
              children: [
                Text(
                  appointment.patient,
                  style: compact ? _inter(14, 500, AppColors.textPrimary, height: 20) : _jakarta(20, 600, AppColors.textPrimary, height: 28),
                ),
                Text(meta, style: _inter(12, 400, AppColors.textSecondary, height: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyAlert extends StatelessWidget {
  const _ReadOnlyAlert();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.feedbackInfoTint,
        border: Border.all(color: AppColors.infoBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const Icon(AppIcons.alert, size: 18, color: AppColors.feedbackInfo),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text('Read-only', style: _inter(14, 600, AppColors.feedbackInfo)),
                Text('Booking, rescheduling, cancellation and no-show are managed by reception.', style: _inter(13, 400, AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusNote extends StatelessWidget {
  const _StatusNote({required this.text, required this.topAligned});

  final String text;
  final bool topAligned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: topAligned ? const EdgeInsets.fromLTRB(16, 10, 16, 16) : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.syncDeviceOnlyBackground,
        border: Border.all(color: AppColors.syncDeviceOnly, width: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      ),
      child: Row(
        crossAxisAlignment: topAligned ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        spacing: Dimensions.componentGap,
        children: [
          Text('●', style: _inter(18, 500, AppColors.syncDeviceOnly, height: 24)),
          Expanded(child: Text(text, style: _inter(12, 400, AppColors.textPrimary, height: 16))),
        ],
      ),
    );
  }
}

class _DetailsFooter extends StatelessWidget {
  const _DetailsFooter({
    required this.onCancel,
    required this.onViewProfile,
    this.primaryLabel = 'View Patient Profile',
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    this.busy = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onViewProfile;
  final String primaryLabel;
  final EdgeInsets padding;

  /// Shows a spinner in the primary action and disables both buttons.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final label = _inter(14, 600, AppColors.brandPrimary);
    const size = Size(0, 40);
    return Container(
      padding: padding,
      decoration: const BoxDecoration(color: AppColors.backgroundSurface, border: Border(top: BorderSide(color: AppColors.borderDefault))),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: size, padding: const EdgeInsets.symmetric(horizontal: 16)),
              onPressed: busy ? null : onCancel,
              child: Text('Cancel', style: label),
            ),
          ),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: size, padding: const EdgeInsets.symmetric(horizontal: 16)),
              onPressed: busy ? null : onViewProfile,
              child: busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandPrimary))
                  : Text(primaryLabel, style: label.copyWith(color: AppColors.textOnBrand), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// My Availability tab
// -----------------------------------------------------------------------------

enum _AvailabilityLayout { desktop, tablet, mobile }

/// The doctor's working hours, unavailable dates and leave requests, with the
/// Request Leave action (in the heading on desktop, at the end on tablet and phone).
class _AvailabilityContent extends GetView<DoctorAppointmentsController> {
  const _AvailabilityContent({required this.layout});

  final _AvailabilityLayout layout;

  @override
  Widget build(BuildContext context) {
    final desktop = layout == _AvailabilityLayout.desktop;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: desktop ? 20 : 16,
      children: [
        _WorkingHoursCard(layout: layout),
        _UnavailableDatesCard(layout: layout),
        _LeaveRequestsCard(layout: layout),
        if (!desktop) AppButton.primary(label: 'Request Leave', onPressed: () => controller.requestLeave(context), expand: true),
      ],
    );
  }
}

class _RequestLeaveButton extends GetView<DoctorAppointmentsController> {
  const _RequestLeaveButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 206,
      height: 40,
      child: FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
        onPressed: () => controller.requestLeave(context),
        child: Text('Request Leave', style: _inter(14, 600, AppColors.textOnBrand)),
      ),
    );
  }
}

Widget _card(Widget child) => Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: child,
    );

/// A table cell: fixed [width], or a share of the remaining row ([flex]).
class _Cell {
  const _Cell(this.child, {this.width, this.flex = 1, this.center = false});

  final Widget child;
  final double? width;
  final int flex;
  final bool center;
}

Widget _cellsRow(List<_Cell> cells, {required double gap}) => Row(
      spacing: gap,
      children: [
        for (final c in cells)
          if (c.width != null)
            SizedBox(width: c.width, child: Align(alignment: c.center ? Alignment.center : Alignment.centerLeft, child: c.child))
          else
            Expanded(flex: c.flex, child: Align(alignment: c.center ? Alignment.center : Alignment.centerLeft, child: c.child)),
      ],
    );

/// Brand-tint column headings.
Widget _tableHeader(List<_Cell> cells, {required EdgeInsets padding, required double gap, bool borders = false}) => Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        border: borders ? const Border(top: BorderSide(color: AppColors.borderDefault), bottom: BorderSide(color: AppColors.borderDefault)) : null,
      ),
      child: _cellsRow(cells, gap: gap),
    );

Widget _rowDivider({required Widget child}) => DecoratedBox(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderDefault))),
      child: child,
    );

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.background, required this.foreground, required this.size, this.weight = 500});

  final String label;
  final Color background;
  final Color foreground;
  final double size;
  final int weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.badgePaddingX, vertical: Dimensions.badgePaddingY),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
      child: Text(label, style: _inter(size, weight, foreground, height: size >= 14 ? 20 : 16), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
    );
  }
}

class _WorkingPill extends StatelessWidget {
  const _WorkingPill({required this.working, required this.size});

  final bool working;
  final double size;

  @override
  Widget build(BuildContext context) => _Pill(
        label: working ? 'Working' : 'Not working',
        background: working ? AppColors.brandTint : AppColors.statusNoShowTint,
        foreground: working ? AppColors.brandPrimary : AppColors.textSecondary,
        size: size,
      );
}

class _EditButton extends GetView<DoctorAppointmentsController> {
  const _EditButton({required this.day, required this.size});

  final DoctorWorkingDay day;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Edit ${day.day} working hours',
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        onTap: () => controller.editWorkingHours(day),
        child: SizedBox(width: size, height: size, child: const ExcludeSemantics(child: Center(child: Icon(AppIcons.edit, size: 24, color: AppColors.brandPrimary)))),
      ),
    );
  }
}

class _WorkingHoursCard extends GetView<DoctorAppointmentsController> {
  const _WorkingHoursCard({required this.layout});

  final _AvailabilityLayout layout;

  @override
  Widget build(BuildContext context) {
    final days = DoctorAppointmentsController.workingWeek;
    switch (layout) {
      case _AvailabilityLayout.desktop:
        final head = _inter(12, 600, AppColors.textSecondary);
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 14), child: Text('Working hours', style: _inter(16, 600, AppColors.textPrimary))),
              _tableHeader(
                [
                  _Cell(Text('Day', style: head), flex: 210),
                  _Cell(Text('Hours', style: head), flex: 324),
                  _Cell(Text('Status', style: head), flex: 205),
                  _Cell(Text('Action', style: head), flex: 205, center: true),
                ],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                gap: 0,
                borders: true,
              ),
              for (final d in days)
                _rowDivider(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: _cellsRow(
                      [
                        _Cell(Text(d.day, style: _inter(13, 500, AppColors.textPrimary)), flex: 210),
                        _Cell(Text(d.hours(), style: _inter(13, 400, AppColors.textSecondary)), flex: 324),
                        _Cell(_WorkingPill(working: d.isWorking, size: 10), flex: 205),
                        _Cell(_EditButton(day: d, size: 32), flex: 205, center: true),
                      ],
                      gap: 0,
                    ),
                  ),
                ),
            ],
          ),
        );
      case _AvailabilityLayout.tablet:
        final head = _inter(12, 400, AppColors.textSecondary, height: 16);
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.all(16), child: Text('Working hours', style: _inter(16, 600, AppColors.textPrimary, height: 24))),
              _tableHeader(
                [
                  _Cell(Text('Day', style: head), width: 100),
                  _Cell(Text('Hours', style: head)),
                  _Cell(Text('Status', style: head), width: 112),
                  _Cell(Text('Action', style: head), width: 48, center: true),
                ],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gap: 8,
              ),
              for (final d in days)
                _rowDivider(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _cellsRow(
                      [
                        _Cell(Text(d.day, style: _inter(13, 500, AppColors.textPrimary)), width: 100),
                        _Cell(Text(d.hours(), style: _inter(13, 400, AppColors.textSecondary, height: 20))),
                        _Cell(_WorkingPill(working: d.isWorking, size: 12), width: 112),
                        _Cell(_EditButton(day: d, size: 48), width: 48, center: true),
                      ],
                      gap: 8,
                    ),
                  ),
                ),
            ],
          ),
        );
      case _AvailabilityLayout.mobile:
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.all(16), child: Text('Working hours', style: _inter(16, 600, AppColors.textPrimary, height: 24))),
              for (final d in days)
                _rowDivider(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 8,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                spacing: 8,
                                children: [
                                  Flexible(child: Text(d.day, style: _inter(14, 500, AppColors.textPrimary, height: 20), overflow: TextOverflow.ellipsis)),
                                  Flexible(child: _WorkingPill(working: d.isWorking, size: 12)),
                                ],
                              ),
                              Text(d.hours(separator: '  |\n'), style: _inter(13, 400, AppColors.textSecondary, height: 20)),
                            ],
                          ),
                        ),
                        _EditButton(day: d, size: 32),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
    }
  }
}

class _UnavailableDatesCard extends StatelessWidget {
  const _UnavailableDatesCard({required this.layout});

  final _AvailabilityLayout layout;

  static const _subtitle = 'Public holidays and approved leave. No appointments can be booked on these dates.';

  @override
  Widget build(BuildContext context) {
    final dates = DoctorAppointmentsController.unavailableDates;
    switch (layout) {
      case _AvailabilityLayout.desktop:
        final head = _inter(12, 600, AppColors.textSecondary);
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text('Unavailable dates', style: _inter(16, 600, AppColors.textPrimary)),
                    Text(_subtitle, style: _inter(13, 400, AppColors.textSecondary)),
                  ],
                ),
              ),
              _tableHeader(
                [_Cell(Text('Date', style: head), flex: 40), _Cell(Text('Reason', style: head), flex: 45), _Cell(Text('Status', style: head), flex: 15)],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                gap: 0,
                borders: true,
              ),
              for (final d in dates)
                _rowDivider(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: _cellsRow(
                      [
                        _Cell(Text(DoctorAppointmentsController.unavailableDateLabel(d.date), style: _inter(13, 500, AppColors.textPrimary)), flex: 40),
                        _Cell(Text(d.reason, style: _inter(13, 400, AppColors.textSecondary)), flex: 45),
                        _Cell(_Pill(label: d.kind, background: AppColors.statusNoShowTint, foreground: AppColors.textSecondary, size: 10), flex: 15),
                      ],
                      gap: 0,
                    ),
                  ),
                ),
            ],
          ),
        );
      case _AvailabilityLayout.tablet:
        final head = _inter(12, 400, AppColors.textSecondary, height: 16);
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CardHeading(title: 'Unavailable dates', subtitle: _subtitle),
              _tableHeader(
                [_Cell(Text('Date', style: head), width: 200), _Cell(Text('Reason', style: head)), _Cell(Text('Status', style: head), width: 120)],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gap: 16,
              ),
              for (final d in dates)
                _rowDivider(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _cellsRow(
                      [
                        _Cell(Text(DoctorAppointmentsController.unavailableDateLabel(d.date), style: _inter(13, 500, AppColors.textPrimary)), width: 200),
                        _Cell(Text(d.reason, style: _inter(13, 400, AppColors.textSecondary))),
                        _Cell(_Pill(label: d.kind, background: AppColors.statusNoShowTint, foreground: AppColors.textSecondary, size: 12), width: 120),
                      ],
                      gap: 16,
                    ),
                  ),
                ),
            ],
          ),
        );
      case _AvailabilityLayout.mobile:
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CardHeading(title: 'Unavailable dates', subtitle: _subtitle),
              for (final d in dates)
                _rowDivider(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Flexible(child: Text(DoctorAppointmentsController.unavailableDateLabel(d.date), style: _inter(13, 500, AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                            Flexible(child: _Pill(label: d.kind, background: AppColors.statusNoShowTint, foreground: AppColors.textSecondary, size: 12)),
                          ],
                        ),
                        Text(d.reason, style: _inter(13, 400, AppColors.textSecondary, height: 20)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
    }
  }
}

/// Tablet and phone card heading: title with a 12px description.
class _CardHeading extends StatelessWidget {
  const _CardHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(title, style: _inter(16, 600, AppColors.textPrimary, height: 24)),
          Text(subtitle, style: _inter(12, 400, AppColors.textSecondary, height: 16)),
        ],
      ),
    );
  }
}

class _LeaveRequestsCard extends GetView<DoctorAppointmentsController> {
  const _LeaveRequestsCard({required this.layout});

  final _AvailabilityLayout layout;

  static const _subtitle = 'Leave you have requested and its review status.';

  Widget _status(DoctorLeaveRequest r) =>
      _Pill(label: r.status.label, background: r.status.background, foreground: r.status.foreground, size: 14, weight: 500);

  @override
  Widget build(BuildContext context) => Obx(() => _content(controller.leaveRequests.toList()));

  Widget _content(List<DoctorLeaveRequest> requests) {
    switch (layout) {
      case _AvailabilityLayout.desktop:
        final head = _inter(14, 500, AppColors.textSecondary, height: 20);
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text('Leave requests', style: _jakarta(20, 600, AppColors.textPrimary, height: 28)),
                    Text(_subtitle, style: _inter(16, 400, AppColors.textSecondary, height: 24)),
                  ],
                ),
              ),
              if (requests.isEmpty)
                const _LeaveEmptyState()
              else ...[
                const Divider(height: 1, thickness: 1, color: AppColors.borderDefault),
                Container(
                  color: AppColors.brandTint,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _cellsRow(
                    [_Cell(Text('Dates', style: head), width: 220), _Cell(Text('Duration', style: head), width: 260), _Cell(Text('Status', style: head), width: 220), _Cell(Text('Action', style: head))],
                    gap: 41,
                  ),
                ),
                for (final (i, r) in requests.indexed)
                  DecoratedBox(
                    decoration: BoxDecoration(border: i < requests.length - 1 ? const Border(bottom: BorderSide(color: AppColors.borderDefault)) : null),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: _cellsRow(
                        [
                          _Cell(Text(DoctorAppointmentsController.leaveDatesLabel(r), style: _inter(16, 500, AppColors.textPrimary, height: 24)), width: 220),
                          _Cell(Text(DoctorAppointmentsController.leaveDurationLabel(r), style: _inter(16, 400, AppColors.textSecondary, height: 24)), width: 260),
                          _Cell(_status(r), width: 220),
                          _Cell(
                            TextButton(
                              style: TextButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                              onPressed: () => controller.viewLeaveRequest(r),
                              child: Text('View', style: _inter(14, 500, AppColors.brandPrimary, height: 20)),
                            ),
                          ),
                        ],
                        gap: 41,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      case _AvailabilityLayout.tablet:
        final head = _inter(12, 400, AppColors.textSecondary, height: 16);
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CardHeading(title: 'Leave requests', subtitle: _subtitle),
              if (requests.isEmpty)
                const _LeaveEmptyState()
              else ...[
                _tableHeader(
                  [
                    _Cell(Text('Dates', style: head), width: 200),
                    _Cell(Text('Duration', style: head)),
                    _Cell(Text('Status', style: head), width: 112),
                    _Cell(Text('Action', style: head), width: 64, center: true),
                  ],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gap: 16,
                ),
                for (final r in requests)
                  _rowDivider(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: _cellsRow(
                        [
                          _Cell(Text(DoctorAppointmentsController.leaveDatesLabel(r), style: _inter(14, 500, AppColors.textPrimary)), width: 200),
                          _Cell(Text(DoctorAppointmentsController.leaveDurationLabel(r), style: _inter(13, 400, AppColors.textSecondary))),
                          _Cell(_status(r), width: 112),
                          _Cell(_ViewLeaveButton(request: r), width: 64, center: true),
                        ],
                        gap: 16,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      case _AvailabilityLayout.mobile:
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CardHeading(title: 'Leave requests', subtitle: _subtitle),
              if (requests.isEmpty)
                const _LeaveEmptyState()
              else
                for (final r in requests)
                  _rowDivider(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 4,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              spacing: 8,
                              children: [
                                Flexible(child: Text(DoctorAppointmentsController.leaveDatesLabel(r), style: _inter(14, 500, AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                                Flexible(child: _status(r)),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Text(DoctorAppointmentsController.leaveDurationLabel(r), style: _inter(13, 400, AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                              _ViewLeaveButton(request: r),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
    }
  }
}

/// "No leave requests" with the empty-state illustration.
class _LeaveEmptyState extends StatelessWidget {
  const _LeaveEmptyState();

  @override
  Widget build(BuildContext context) {
    return _rowDivider(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: Column(
          spacing: 6,
          children: [
            SvgPicture.asset('assets/images/leave_requests_empty.svg', width: 62, height: 47, excludeFromSemantics: true),
            Text('No leave requests', style: _inter(15, 600, AppColors.textPrimary)),
            Text(
              'Requests you submit will appear here with their approval status.',
              textAlign: TextAlign.center,
              style: _inter(13, 400, AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 64 × 48 "View" action beside a leave request (tablet and phone).
class _ViewLeaveButton extends GetView<DoctorAppointmentsController> {
  const _ViewLeaveButton({required this.request});

  final DoctorLeaveRequest request;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: Dimensions.touchTarget,
      child: TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () => controller.viewLeaveRequest(request),
        child: Text('View', style: _inter(14, 500, AppColors.brandPrimary, height: 20)),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Request Leave
// -----------------------------------------------------------------------------

enum _LeaveVariant { drawer, sheet, page }

/// Desktop: Request Leave slides in from the right over the Availability tab.
void showLeaveRequestDrawer(BuildContext context) {
  _showSideDrawer(context, (close) => _LeavePanel(variant: _LeaveVariant.drawer, onClose: close));
}

/// Phone: Request Leave rises from the bottom over the Availability tab.
Future<void> showLeaveRequestSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.backgroundSurface,
    barrierColor: AppColors.scrim,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    builder: (sheetContext) => AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
      child: _LeavePanel(variant: _LeaveVariant.sheet, onClose: () => Navigator.of(sheetContext).pop()),
    ),
  );
}

/// Tablet: Request Leave as a page of its own, inside the navigation shell.
class DoctorLeaveRequestPage extends StatelessWidget {
  const DoctorLeaveRequestPage({super.key});

  @override
  Widget build(BuildContext context) => _LeavePanel(variant: _LeaveVariant.page, onClose: Get.back);
}

/// Header, fields and the Cancel / Submit Request actions.
class _LeavePanel extends GetView<DoctorAppointmentsController> {
  const _LeavePanel({required this.variant, required this.onClose});

  final _LeaveVariant variant;
  final VoidCallback onClose;

  static const _title = 'Request Leave';
  static const _subtitle = 'Select the dates you will be unavailable.';

  /// Cancel and × throw the draft away.
  void _discard() {
    controller.resetLeaveDraft();
    onClose();
  }

  /// Closes the form and shows the confirmation only once the service confirms.
  Future<void> _submit() async {
    if (await controller.submitLeaveRequest()) {
      onClose();
      controller.showLeaveSubmitted();
    }
  }

  Widget _footer({EdgeInsets? padding}) => Obx(
        () => _DetailsFooter(
          onCancel: _discard,
          onViewProfile: _submit,
          primaryLabel: 'Submit Request',
          busy: controller.isSubmittingLeave.value,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final body = _LeaveBody(variant: variant);
    switch (variant) {
      case _LeaveVariant.drawer:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderDefault))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: _Title(title: _title, subtitle: _subtitle)),
                  _CloseButton(onTap: _discard, size: 32, child: Text('×', style: _inter(20, 400, AppColors.textSecondary))),
                ],
              ),
            ),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: body)),
            _footer(),
          ],
        );
      case _LeaveVariant.sheet:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.borderDefault, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: _Title(title: _title, subtitle: _subtitle)),
                        _CloseButton(onTap: _discard, size: Dimensions.touchTarget, child: const Icon(AppIcons.close, size: 20, color: AppColors.textPrimary)),
                      ],
                    ),
                    body,
                  ],
                ),
              ),
            ),
            _footer(),
          ],
        );
      case _LeaveVariant.page:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginDesktop, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() {
                      final error = controller.leaveSubmitError.value;
                      return error == null ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(bottom: 20), child: _SubmitErrorBanner(error: error));
                    }),
                    Row(
                      spacing: 12,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Back to My Availability',
                          child: Material(
                            color: AppColors.backgroundSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                              side: const BorderSide(color: AppColors.borderDefault),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                              onTap: _discard,
                              child: SizedBox(
                                width: 40,
                                height: 36,
                                child: Center(child: ExcludeSemantics(child: Text('‹', style: _inter(32, 400, AppColors.brandPrimary, height: 32)))),
                              ),
                            ),
                          ),
                        ),
                        const Expanded(child: _Title(title: _title, subtitle: _subtitle)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    body,
                  ],
                ),
              ),
            ),
            _footer(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          ],
        );
    }
  }
}

/// Date fields, reason and the note or warning under them.
class _LeaveBody extends GetView<DoctorAppointmentsController> {
  const _LeaveBody({required this.variant});

  final _LeaveVariant variant;

  @override
  Widget build(BuildContext context) {
    final page = variant == _LeaveVariant.page;
    final start = _DateInput(label: 'Start Date', start: true, controller: controller);
    final end = _DateInput(label: 'End Date', start: false, controller: controller);
    return Obx(() {
      final submitError = controller.leaveSubmitError.value;
      final error = page ? null : submitError;
      return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: page ? 20 : 16,
      children: [
        if (error != null) _SubmitErrorBanner(error: error),
        page
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: [Expanded(child: start), Expanded(child: end)])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: [start, end]),
        _ReasonField(controller: controller.reasonController),
        Obx(() {
          final affected = controller.affectedAppointments;
          return affected.isEmpty ? const _UnitAdminNote() : _AffectedBlock(appointments: affected);
        }),
      ],
      );
    });
  }
}

/// "Start Date*" / "End Date*": a tappable field that opens a date picker, with a
/// red border and message when invalid.
class _DateInput extends StatelessWidget {
  const _DateInput({required this.label, required this.start, required this.controller});

  final String label;
  final bool start;
  final DoctorAppointmentsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final value = start ? controller.leaveStart.value : controller.leaveEnd.value;
      final error = start ? controller.startError : controller.endError;
      final invalid = error != null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Text.rich(
            TextSpan(
              style: _inter(13, 500, AppColors.textPrimary),
              children: [
                TextSpan(text: label),
                TextSpan(text: '*', style: TextStyle(color: invalid ? AppColors.textPrimary : AppColors.fieldErrorBorder)),
              ],
            ),
          ),
          Semantics(
            key: Key(start ? 'leave-start-date' : 'leave-end-date'),
            button: true,
            label: '$label, required',
            value: value == null ? 'Not set' : DoctorAppointmentsController.leaveDateLabel(value),
            child: Material(
              color: AppColors.backgroundSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                side: BorderSide(color: invalid ? AppColors.fieldErrorBorder : AppColors.borderDefault, width: invalid ? 1.5 : 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                onTap: () => controller.pickLeaveDate(context, start: start),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 41),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Text(
                          value == null ? 'DD MMM YYYY' : DoctorAppointmentsController.leaveDateLabel(value),
                          style: _inter(14, 400, value == null ? AppColors.textSecondary : AppColors.textPrimary),
                        ),
                      ),
                      if (!invalid) const Icon(AppIcons.calendarDays, size: 24, color: AppColors.brandPrimary),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (error != null) Text(error, style: _inter(12, 400, AppColors.safetyCriticalText)),
        ],
      );
    });
  }
}

class _ReasonField extends StatelessWidget {
  const _ReasonField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Text('Reason', style: _inter(13, 500, AppColors.textPrimary)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            border: Border.all(color: AppColors.borderDefault),
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          ),
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            style: _inter(12, 400, AppColors.textPrimary),
            decoration: InputDecoration(
              isCollapsed: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'Optional  e.g. annual leave',
              hintStyle: _inter(12, 400, AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Your Unit Admin reviews the request…" (shown while no booked appointment is affected).
class _UnitAdminNote extends StatelessWidget {
  const _UnitAdminNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.feedbackInfoTint,
        border: Border.all(color: AppColors.infoBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          const Icon(AppIcons.info, size: 16, color: AppColors.feedbackInfo),
          Expanded(
            child: Text(
              'Your Unit Admin reviews the request. Booked appointments are never cancelled automatically.',
              style: _inter(13, 400, AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// "N booked appointments fall in these dates" with each affected appointment.
class _AffectedBlock extends StatelessWidget {
  const _AffectedBlock({required this.appointments});

  final List<DoctorAppointment> appointments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.statusRescheduledTint,
            border: Border.all(color: AppColors.warningAlertBorder),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              const Icon(AppIcons.alert, size: 18, color: AppColors.feedbackWarning),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(DoctorAppointmentsController.affectedHeading(appointments.length), style: _inter(13, 500, AppColors.feedbackWarning)),
                    Text('You can still submit. If approved, reception will reschedule them.', style: _inter(11, 400, AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (final a in appointments)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderDefault),
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(a.patient, style: _inter(13, 500, AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                      Text(DoctorAppointmentsController.affectedLabel(a), style: _inter(10, 400, AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const _Pill(label: 'Needs attention', background: AppColors.statusRescheduledTint, foreground: AppColors.feedbackWarning, size: 10, weight: 400),
              ],
            ),
          ),
      ],
    );
  }
}

/// "Request not submitted": the submission failed and the details were kept.
class _SubmitErrorBanner extends StatelessWidget {
  const _SubmitErrorBanner({required this.error});

  final ApiException error;

  @override
  Widget build(BuildContext context) {
    final message = error.type == ApiErrorType.network
        ? 'We could not reach the server. Your details are kept — check your connection and try again.'
        : '${error.message} Your details are kept.';
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.statusCancelledTint,
          border: Border.all(color: AppColors.errorAlertBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            const Icon(AppIcons.alert, size: 18, color: AppColors.safetyCriticalText),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text('Request not submitted', style: _inter(14, 600, AppColors.safetyCriticalText)),
                  Text(message, style: _inter(11, 400, AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Leave Request Submitted
// -----------------------------------------------------------------------------

/// Success icon, title and message, with the Done action.
class _LeaveSubmittedContent extends StatelessWidget {
  const _LeaveSubmittedContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 14,
      children: [
        SvgPicture.asset('assets/images/leave_submitted_success.svg', width: 48, height: 48, excludeFromSemantics: true),
        Semantics(header: true, child: Text('Leave Request Submitted', textAlign: TextAlign.center, style: _jakarta(20, 600, AppColors.textPrimary))),
        Text(
          'Your leave request has been submitted for review.',
          textAlign: TextAlign.center,
          style: _inter(14, 400, AppColors.textSecondary),
        ),
      ],
    );
  }
}

/// Desktop and tablet: a centred confirmation dialog over the Availability tab.
void showLeaveSubmittedDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: AppColors.scrim,
    builder: (dialogContext) => Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 90, 24, 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Material(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(16),
            elevation: 12,
            shadowColor: const Color(0x29000000),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 14,
                children: [
                  const _LeaveSubmittedContent(),
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(0, 39), padding: const EdgeInsets.symmetric(horizontal: 16)),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text('Done', style: _inter(14, 600, AppColors.textOnBrand)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Phone: the confirmation rises from the bottom over the Availability tab.
Future<void> showLeaveSubmittedSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: AppColors.backgroundSurface,
    barrierColor: AppColors.scrim,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.borderDefault, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 16), child: _LeaveSubmittedContent()),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderDefault))),
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 39), padding: const EdgeInsets.symmetric(horizontal: 16)),
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: Text('Done', style: _inter(14, 600, AppColors.textOnBrand)),
          ),
        ),
      ],
    ),
  );
}
