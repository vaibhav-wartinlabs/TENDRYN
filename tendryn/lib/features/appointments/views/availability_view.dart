import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/appointments/controllers/availability_controller.dart';
import 'package:tendryn/features/appointments/models/practitioner.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_action_menu.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/app_search_field.dart';
import 'package:tendryn/widgets/common/app_shell.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

const _subtitle = 'Working hours, leave, and public holidays determine free appointment slots.';
const _illustration = 'assets/images/empty_queue.jpg';
const _searchHint = 'Search By Doctor’s Name, Doctor’s Id';

/// Manage Practitioners, opened from Appointments: a searchable table of
/// practitioners; ⋮ → View availability opens one practitioner's working hours,
/// leave and public holidays. Desktop sits inside the navigation shell;
/// tablet and phone are focused pages without the bottom bar.
class AvailabilityView extends GetView<AvailabilityController> {
  const AvailabilityView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _Mobile(controller: controller),
      // Tablet is a focused page: header, no bottom navigation bar.
      tablet: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(children: [const TabletHeader(), Expanded(child: _Tablet(controller: controller))]),
        ),
      ),
      desktop: AppShell(route: AppRoutes.appointments, child: _Desktop(controller: controller)),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop
// ---------------------------------------------------------------------------

class _Desktop extends StatelessWidget {
  const _Desktop({required this.controller});

  final AvailabilityController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final detail = controller.selected.value != null;
        return ListView(
          padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
          children: [
            _BackPill(label: detail ? 'Back to Practitioners' : 'Back to Appointments', onTap: controller.onBack),
            const SizedBox(height: Dimensions.pageSectionGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimensions.spaceMd,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimensions.spaceXs,
                    children: [
                      Semantics(header: true, child: Text(detail ? 'Manage Practitioner availability' : 'Manage Practitioners', style: AppTextStyles.h1.copyWith(color: scheme.onSurface))),
                      Text(_subtitle, style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (detail) _EditButton(onTap: controller.editAvailability),
              ],
            ),
            const SizedBox(height: Dimensions.pageSectionGap),
            if (detail) ...[
              _SelectedPractitioner(controller: controller, bottomGap: 20),
              SizedBox(
                height: 474,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Dimensions.spaceMd,
                  children: [
                    Expanded(child: _WorkingHoursCard(rows: controller.hoursRows, compact: false)),
                    Expanded(
                      child: Column(
                        spacing: Dimensions.sectionContentGap,
                        children: [
                          Expanded(child: _LeaveCard(title: 'Leave and blocked time', detail: controller.leaveDetail, status: controller.leaveStatus, warning: true, compact: false)),
                          Expanded(child: _LeaveCard(title: 'Public holidays', detail: AvailabilityController.holiday, status: AvailabilityController.holidayKind, warning: false, compact: false)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _Search(controller: controller, hint: _searchHint),
              const SizedBox(height: Dimensions.pageSectionGap),
              _PractitionersTable(controller: controller),
            ],
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet (no dedicated frame: the desktop content, adapted to the width)
// ---------------------------------------------------------------------------

class _Tablet extends StatelessWidget {
  const _Tablet({required this.controller});

  final AvailabilityController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final detail = controller.selected.value != null;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginDesktop,
                vertical: Dimensions.spaceMd,
              ),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(bottom: BorderSide(color: scheme.outline)),
              ),
              child: Row(
                spacing: 12,
                children: [
                  _BackButton(onTap: controller.onBack),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        detail ? 'Manage Availability' : 'Manage Practitioners',
                        style: AppTextStyles.h2.copyWith(color: scheme.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.pageMarginDesktop,
                  Dimensions.spaceMd,
                  Dimensions.pageMarginDesktop,
                  Dimensions.spaceMd,
                ),
                children: [
                  if (detail) ...[
                    _SelectedPractitioner(controller: controller, bottomGap: Dimensions.spaceMd),
                    SizedBox(
                      height: 501,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Dimensions.spaceMd,
                        children: [
                          Expanded(child: _WorkingHoursCard(rows: controller.hoursRows, compact: false)),
                          Expanded(
                            child: Column(
                              spacing: Dimensions.sectionContentGap,
                              children: [
                                Expanded(flex: 14, child: _LeaveCard(title: 'Leave and blocked time', detail: controller.leaveDetail, status: controller.leaveStatus, warning: true, compact: false)),
                                Expanded(flex: 10, child: _LeaveCard(title: 'Public holidays', detail: AvailabilityController.holiday, status: AvailabilityController.holidayKind, warning: false, compact: false)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(_subtitle, style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: Dimensions.spaceMd),
                    _Search(controller: controller, hint: _searchHint),
                    const SizedBox(height: Dimensions.pageSectionGap),
                    _PractitionerCards(controller: controller, columns: 2, showHeading: true),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.selected.value == null) return const SizedBox.shrink();
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outline)),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginDesktop,
                vertical: Dimensions.spaceMd,
              ),
              child: Row(
                spacing: Dimensions.spaceSm,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: Dimensions.buttonMinHeight,
                      child: OutlinedButton(
                        onPressed: controller.onBack,
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: Dimensions.buttonMinHeight,
                      child: FilledButton(
                        onPressed: controller.editAvailability,
                        child: const Text('Edit availability'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile (no frame for the new list: practitioner cards)
// ---------------------------------------------------------------------------

class _Mobile extends StatelessWidget {
  const _Mobile({required this.controller});

  final AvailabilityController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => Container(
                height: Dimensions.mobileHeaderHeight,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(bottom: BorderSide(color: scheme.outline)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginMobile),
                  child: Row(
                    spacing: Dimensions.spaceSm,
                    children: [
                      _BackButton(onTap: controller.onBack),
                      Expanded(child: Semantics(header: true, child: Text(controller.selected.value == null ? 'Manage Practitioners' : 'Manage Availability', style: AppTextStyles.h2Mobile.copyWith(color: scheme.onSurface)))),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final detail = controller.selected.value != null;
                return ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, 0, Dimensions.pageMarginMobile, Dimensions.spaceMd),
                  children: [
                    if (detail) ...[
                      _SelectedPractitioner(controller: controller, bottomGap: Dimensions.spaceMd),
                      _WorkingHoursCard(rows: controller.hoursRows, compact: true),
                      const SizedBox(height: 12),
                      _LeaveCard(title: 'Leave and blocked time', detail: controller.leaveDetail, status: controller.leaveStatus, warning: true, compact: true, note: 'No bookable slots during leave.'),
                      const SizedBox(height: 12),
                      _LeaveCard(title: 'Public holidays', detail: AvailabilityController.holiday, status: AvailabilityController.holidayKind, warning: false, compact: true, note: 'Holiday slots are unavailable in the calendar.'),
                    ] else ...[
                      _Search(controller: controller, hint: 'Search by Doctor’s Name & Id'),
                      const SizedBox(height: Dimensions.spaceMd),
                      _PractitionerCards(controller: controller, columns: 1, showHeading: false),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.selected.value == null) return const SizedBox.shrink();
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outline)),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginMobile,
                vertical: Dimensions.spaceSm + 4,
              ),
              child: AppButton.primary(
                label: 'Edit availability',
                onPressed: controller.editAvailability,
                expand: true,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Search, table, cards, pagination
// ---------------------------------------------------------------------------

class _Search extends StatelessWidget {
  const _Search({required this.controller, required this.hint});

  final AvailabilityController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return AppSearchField(
      controller: controller.searchText,
      hint: hint,
      onChanged: controller.search,
      hintStyle: AppTextStyles.label.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

TextStyle _semibold(double size, {double? height}) => AppTextStyles.body.copyWith(
  fontSize: size,
  height: height,
  fontWeight: FontWeight.w600,
  fontVariations: const [FontVariation.weight(600)],
);

({Color background, Color text}) _statusColors(PractitionerStatus status, ColorScheme scheme) => switch (status) {
  PractitionerStatus.available => (background: scheme.primaryContainer, text: scheme.primary),
  PractitionerStatus.onLeave => (background: AppColors.leavePillBackground, text: AppColors.feedbackWarning),
  PractitionerStatus.fullyBooked => (background: AppColors.neutralPillBackground, text: scheme.onSurfaceVariant),
};

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final PractitionerStatus status;

  @override
  Widget build(BuildContext context) {
    final c = _statusColors(status, Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.badgePaddingX, vertical: Dimensions.badgePaddingY),
      decoration: BoxDecoration(color: c.background, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
      child: Text(status.label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, height: 1.2, color: c.text)),
    );
  }
}

/// The 32px ⋮ button; its menu opens the practitioner's availability.
class _RowActions extends StatelessWidget {
  const _RowActions({required this.onView, this.size = 32});

  final VoidCallback onView;
  final double size;

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
      child: PopupMenuButton<int>(
        tooltip: 'Actions',
        position: PopupMenuPosition.under,
        color: Colors.white,
        elevation: 6,
        shadowColor: const Color(0x1F000000),
        surfaceTintColor: Colors.transparent,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        onSelected: (_) => onView(),
        itemBuilder: (_) => const [
          AppActionMenuItem<int>(
            value: 0,
            label: 'View availability',
            alignment: Alignment.center,
          ),
        ],
        child: AppActionsBoxButton(size: size, icon: AppIcons.rowMenu),
      ),
    );
  }
}

/// Practitioners card: heading, table (Doctor, Doctor ID, Specialization, Slot
/// length, Status, Action) and pagination. Scrolls sideways below 882px.
class _PractitionersTable extends StatelessWidget {
  const _PractitionersTable({required this.controller});

  final AvailabilityController controller;

  static const _minWidth = 882.0;
  static const _fixed = [120.0, 220.0, 110.0, 152.0, 80.0];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(Dimensions.radius), border: Border.all(color: scheme.outline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 2,
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 18), child: Text('Practitioners', style: _semibold(20).copyWith(color: scheme.onSurface))),
          LayoutBuilder(
            builder: (context, constraints) {
              final table = Obx(() {
                final rows = controller.pageEntries;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 2,
                  children: [
                    _row(
                      color: scheme.primaryContainer,
                      height: 44,
                      cells: [
                        for (final label in ['Doctor', 'Doctor ID', 'Specialization', 'Slot length', 'Status'])
                          Text(label, style: _semibold(13).copyWith(color: scheme.primary)),
                        Center(child: Text('Action', style: _semibold(13).copyWith(color: scheme.primary))),
                      ],
                    ),
                    if (rows.isEmpty)
                      Padding(padding: const EdgeInsets.all(Dimensions.spaceXl), child: Center(child: Text('No practitioners match your search.', style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant))))
                    else
                      for (final (i, p) in rows.indexed)
                        _row(
                          color: i.isOdd ? AppColors.gridHeader : scheme.surface,
                          height: 56,
                          onTap: () => controller.select(p),
                          cells: [
                            Text(p.name, style: AppTextStyles.label.copyWith(color: scheme.onSurface)),
                            Text(p.id, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                            Text(p.specialization, style: AppTextStyles.label.copyWith(color: scheme.onSurface)),
                            Text('${p.slotMinutes} min', style: AppTextStyles.label.copyWith(color: scheme.onSurface)),
                            Align(alignment: Alignment.centerLeft, child: _StatusPill(status: p.status)),
                            Center(child: _RowActions(onView: () => controller.select(p))),
                          ],
                        ),
                  ],
                );
              });
              if (constraints.maxWidth >= _minWidth) return table;
              return SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: _minWidth, child: table));
            },
          ),
          _Pagination(controller: controller),
        ],
      ),
    );
  }

  /// One table line: the Doctor column takes the leftover width, the others are fixed.
  static Widget _row({required Color color, required double height, required List<Widget> cells, VoidCallback? onTap}) {
    Widget cell(Widget child, {double? width, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 14)}) {
      final padded = Padding(padding: padding, child: Align(alignment: Alignment.centerLeft, child: child));
      return width == null ? Expanded(child: padded) : SizedBox(width: width, child: padded);
    }

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              cell(cells[0]),
              for (var i = 1; i < 5; i++) cell(cells[i], width: _fixed[i - 1]),
              cell(cells[5], width: _fixed[4], padding: const EdgeInsets.symmetric(horizontal: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tablet and phone: practitioners as cards (name and ⋮, ID, then specialization,
/// slot length and status), [columns] across, with pagination below.
class _PractitionerCards extends StatelessWidget {
  const _PractitionerCards({required this.controller, required this.columns, required this.showHeading});

  final AvailabilityController controller;
  final int columns;

  /// Tablet shows a "Practitioners" heading over the cards.
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final rows = controller.pageEntries;
      final lines = <Widget>[];
      for (var i = 0; i < rows.length; i += columns) {
        lines.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Dimensions.spaceMd,
              children: [
                for (var c = 0; c < columns; c++)
                  Expanded(child: i + c < rows.length ? _PractitionerCard(practitioner: rows[i + c], onView: () => controller.select(rows[i + c])) : const SizedBox.shrink()),
              ],
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeading) ...[
            Text('Practitioners', style: _semibold(24, height: 1.3).copyWith(color: scheme.onSurface)),
            const SizedBox(height: Dimensions.spaceXs),
            Text('Ubuntu Family Clinic · 30-minute appointment slots', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: Dimensions.spaceMd),
          ],
          if (rows.isEmpty)
            Padding(padding: const EdgeInsets.all(Dimensions.spaceXl), child: Center(child: Text('No practitioners match your search.', style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant))))
          else
            Column(spacing: 12, children: lines),
          _Pagination(controller: controller, buttonSize: Dimensions.touchTarget),
        ],
      );
    });
  }
}

class _PractitionerCard extends StatelessWidget {
  const _PractitionerCard({required this.practitioner, required this.onView});

  final Practitioner practitioner;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Label on the left; the value takes the rest of the row and sits flush right,
    // so every value ends on the same edge.
    Widget line(String label, Widget value) => Row(
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(width: 12),
        Expanded(child: Align(alignment: Alignment.centerRight, child: value)),
      ],
    );
    final valueStyle = AppTextStyles.bodyMedium.copyWith(fontSize: 15, color: scheme.onSurface);
    return AppCard(
      padding: const EdgeInsets.all(18),
      onTap: onView,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(practitioner.name, style: _semibold(18, height: 1.3).copyWith(color: scheme.onSurface)),
                    Text(practitioner.id, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              _RowActions(onView: onView, size: 36),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 1, color: scheme.outline),
          const SizedBox(height: 12),
          line('Specialization', Text(practitioner.specialization, textAlign: TextAlign.right, style: valueStyle)),
          const SizedBox(height: 12),
          line('Slot length', Text('${practitioner.slotMinutes} min', style: valueStyle)),
          const SizedBox(height: 10),
          line('Status', _StatusPill(status: practitioner.status)),
        ],
      ),
    );
  }
}

/// `Showing 1–4 of 12 practitioners` with 48px previous / page / next buttons.
class _Pagination extends StatelessWidget {
  const _Pagination({required this.controller, this.buttonSize = Dimensions.touchTarget});

  final AvailabilityController controller;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Obx(() {
        final current = controller.page.value;
        final count = controller.pageCount;
        final label = Text(controller.rangeLabel, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant));
        final controls = Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Dimensions.spaceSm,
          children: [
            _PageButton(size: buttonSize, icon: AppIcons.chevronLeft, tooltip: 'Previous page', onPressed: current > 1 ? () => controller.goToPage(current - 1) : null),
            for (var i = 1; i <= count; i++) _PageButton(size: buttonSize, label: '$i', selected: i == current, onPressed: () => controller.goToPage(i)),
            _PageButton(size: buttonSize, icon: AppIcons.chevronRight, tooltip: 'Next page', onPressed: current < count ? () => controller.goToPage(current + 1) : null),
          ],
        );
        return LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth < 520
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: [label, controls])
              : Row(children: [Expanded(child: label), controls]),
        );
      }),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({this.label, this.icon, this.tooltip, this.selected = false, this.size = 32, required this.onPressed});

  final double size;

  final String? label;
  final IconData? icon;
  final String? tooltip;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusControl), side: selected ? BorderSide.none : BorderSide(color: scheme.outline));
    return Opacity(
      opacity: onPressed == null && !selected ? 0.6 : 1,
      child: Tooltip(
        message: tooltip ?? 'Page $label',
        child: Material(
          color: selected ? scheme.primary : scheme.surface,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onPressed,
            child: SizedBox.square(
              dimension: size,
              child: Center(
                child: label != null
                    ? Text(label!, style: (selected ? _semibold(14) : AppTextStyles.label).copyWith(color: selected ? scheme.onPrimary : scheme.onSurface))
                    : Icon(icon, size: Dimensions.iconSize, color: scheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The tinted "‹ Back to …" pill used on desktop and tablet.
class _BackPill extends StatelessWidget {
  const _BackPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Dimensions.spaceSm,
              children: [
                Icon(AppIcons.arrowLeft, size: Dimensions.iconSize, color: scheme.primary),
                Text(label, style: AppTextStyles.label.copyWith(color: scheme.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The 172 x 44 Edit availability button of the availability frame.
class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(Dimensions.radiusControl);
    return SizedBox(
      width: 172,
      height: Dimensions.buttonMinHeight,
      child: Material(
        color: scheme.primary,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Center(child: Text('Edit availability', style: AppTextStyles.label.copyWith(color: scheme.onPrimary))),
        ),
      ),
    );
  }
}

/// The chosen practitioner, shown under the search box.
class _SelectedPractitioner extends StatelessWidget {
  const _SelectedPractitioner({required this.controller, required this.bottomGap});

  final AvailabilityController controller;
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final p = controller.selected.value;
      if (p == null) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: bottomGap),
        child: Container(
          height: 80,
          padding: const EdgeInsets.all(Dimensions.spaceMd),
          decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(Dimensions.radius), border: Border.all(color: scheme.outline)),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: scheme.surface, shape: BoxShape.circle),
                child: Text(p.initials, style: AppTextStyles.label.copyWith(color: scheme.primary)),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(p.name, style: AppTextStyles.h3Mobile.copyWith(color: scheme.onSurface)),
                    Text(p.summary, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(AppIcons.circleCheck, size: 20, color: scheme.primary),
            ],
          ),
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Cards
// ---------------------------------------------------------------------------

class _WorkingHoursCard extends StatelessWidget {
  const _WorkingHoursCard({required this.rows, required this.compact});

  /// Day and hours (null = closed) for the practitioner shown.
  final List<(String, String?)> rows;

  /// Phone: tighter title and a 341px-wide row.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(19, 17, 19, 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Working hours', style: AppTextStyles.h3.copyWith(color: scheme.onSurface)),
          const SizedBox(height: Dimensions.spaceXs),
          Text(AvailabilityController.slotLabel, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: Dimensions.pageSectionGap),
          for (final (i, (day, hours)) in rows.indexed)
            Padding(
              padding: EdgeInsets.only(bottom: i == rows.length - 1 ? 0 : 2),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: i.isOdd ? AppColors.gridHeader : scheme.surface, borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(day, style: AppTextStyles.label.copyWith(color: scheme.onSurface))),
                    Expanded(child: Text(hours ?? 'Closed', style: AppTextStyles.label.copyWith(color: hours == null ? scheme.onSurfaceVariant : scheme.onSurface))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Leave or public-holiday card: title with a status pill, the date, and an
/// empty-state illustration (desktop / tablet) or a one-line note (phone).
class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.title, required this.detail, required this.status, required this.warning, required this.compact, this.note});

  final String title;
  final String detail;
  final String status;
  final bool warning;
  final bool compact;

  /// Phone note under the header.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pill = Container(
      width: 94,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: warning ? AppColors.warningSoftBackground : AppColors.gridHeader, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
      child: Text(status, style: AppTextStyles.caption.copyWith(color: warning ? AppColors.warningSoftText : scheme.primary)),
    );
    final card = AppCard(
      padding: const EdgeInsets.fromLTRB(19, 17, 19, 17),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Dimensions.pageSectionGap,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Dimensions.spaceMd,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Dimensions.spaceXs,
                        children: [
                          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: scheme.onSurface)),
                          Text(detail, style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    pill,
                  ],
                ),
                Text(note ?? '', style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(title, style: AppTextStyles.h3.copyWith(color: scheme.onSurface))),
                    pill,
                  ],
                ),
                const SizedBox(height: 12),
                Text(detail, style: AppTextStyles.body.copyWith(color: scheme.onSurface)),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        Image.asset(_illustration, width: 139, height: 68, fit: BoxFit.contain),
                        Text('No bookable slots during leave.', style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
    return card;
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Back',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          onTap: onTap,
          child: SizedBox.square(
            dimension: Dimensions.touchTarget,
            child: Center(
              child: Container(
                width: Dimensions.touchTarget,
                height: Dimensions.touchTarget,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  border: Border.all(color: scheme.outline),
                ),
                child: Icon(AppIcons.chevronLeft, size: Dimensions.iconSize, color: scheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
