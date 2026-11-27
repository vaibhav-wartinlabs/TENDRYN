import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/appointments/controllers/appointment_detail_controller.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

/// Appointment Details, opened from a record's ⋮ → View Detail. Desktop sits
/// inside the navigation shell; tablet and phone are focused pages without the
/// bottom bar.
class AppointmentDetailView extends GetView<AppointmentDetailController> {
  const AppointmentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild when a reschedule replaces the entry.
    Widget reactive(Widget Function() build) => Obx(() {
      final entry = controller.entry;
      final cancelled = controller.isCancelled.value;
      return KeyedSubtree(key: ValueKey((entry, cancelled)), child: build());
    });
    return ResponsiveLayout(
      mobile: reactive(() => _Mobile(controller: controller)),
      // Tablet is a focused page: header, no bottom navigation bar.
      tablet: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(children: [const TabletHeader(), Expanded(child: reactive(() => _Wide(controller: controller, desktop: false)))]),
        ),
      ),
      desktop: AppShell(route: AppRoutes.appointments, child: reactive(() => _Wide(controller: controller, desktop: true))),
    );
  }
}

/// Desktop and tablet: back button and title, the details card, the actions card.
class _Wide extends StatelessWidget {
  const _Wide({required this.controller, required this.desktop});

  final AppointmentDetailController controller;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = controller;
    final detailRows = c.rows;
    final pill = _StatusPill(status: c.status, width: desktop ? 102 : 112);

    final details = Container(
      padding: EdgeInsets.fromLTRB(desktop ? 24 : Dimensions.cardInner, desktop ? 25 : Dimensions.cardInner, desktop ? 24 : Dimensions.cardInner, desktop ? 28 : Dimensions.cardInner),
      decoration: _cardDecoration(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(c.patient, style: (desktop ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(color: scheme.onSurface))),
              pill,
            ],
          ),
          SizedBox(height: desktop ? 20 : 31),
          if (desktop) ...[
            Divider(height: 1, thickness: 1, color: scheme.outline),
            const SizedBox(height: 21),
          ],
          for (final (i, (label, value)) in detailRows.indexed) ...[
            if (i > 0) SizedBox(height: desktop ? 17 : Dimensions.spaceSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: desktop ? 160 : null, child: Text(label, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant))),
                const SizedBox(width: Dimensions.spaceMd),
                Expanded(child: Text(value, textAlign: TextAlign.right, style: (desktop ? AppTextStyles.body : AppTextStyles.label).copyWith(color: scheme.onSurface))),
              ],
            ),
          ],
        ],
      ),
    );

    // Desktop: Reschedule | Check in over Cancel | No-show. Tablet: Check in | Reschedule over the same.
    final first = desktop ? [RecordAction.reschedule, RecordAction.checkIn] : [RecordAction.checkIn, RecordAction.reschedule];
    final actions = Container(
      padding: EdgeInsets.all(desktop ? 19 : Dimensions.cardInner),
      decoration: _cardDecoration(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Front desk actions', style: AppTextStyles.h3.copyWith(color: scheme.onSurface)),
          const SizedBox(height: Dimensions.spaceXs),
          Text('Manage this booked visit from the front desk.', style: (desktop ? AppTextStyles.body : AppTextStyles.label).copyWith(color: scheme.onSurfaceVariant)),
          SizedBox(height: desktop ? 16 : Dimensions.spaceMd),
          if (c.isFinished)
            Text(c.isCancelled.value ? 'This visit has been cancelled. No further front desk actions are available.' : 'This visit was marked as a no-show. No further front desk actions are available.', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant))
          else ...[
            _ActionRow(controller: c, actions: first, gap: desktop ? 12 : 8),
            SizedBox(height: desktop ? 12 : 8),
            _ActionRow(controller: c, actions: const [RecordAction.cancel, RecordAction.markNoShow], gap: desktop ? 12 : 8),
          ],
        ],
      ),
    );

    final header = Row(
      spacing: 12,
      children: [
        _BackButton(onTap: c.onBack),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              desktop ? 'Appointment Details' : 'Appointment Detail',
              style: AppTextStyles.h2.copyWith(color: scheme.onSurface),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
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
            child: header,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                Dimensions.pageMarginDesktop,
                desktop ? 24 : Dimensions.spaceMd,
                Dimensions.pageMarginDesktop,
                Dimensions.pageMarginDesktop,
              ),
              children: [
                details,
                if (desktop || c.isFinished) ...[
                  SizedBox(height: Dimensions.pageSectionGap),
                  actions,
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: desktop || c.isFinished
          ? null
          : _FixedAppointmentActions(controller: c, mobile: false),
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile({required this.controller});

  final AppointmentDetailController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = controller;
    final dob = c.dateOfBirth;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
                    _BackButton(onTap: c.onBack),
                    Expanded(child: Semantics(header: true, child: Text('Appointment Detail', style: AppTextStyles.h2Mobile.copyWith(color: scheme.onSurface)))),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, 0, Dimensions.pageMarginMobile, Dimensions.spaceMd),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                    decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(Dimensions.radius), border: Border.all(color: scheme.outline)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 5,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(c.patient, style: AppTextStyles.h3Mobile.copyWith(color: scheme.onSurface))),
                            Text(c.status, style: AppTextStyles.caption.copyWith(color: _statusColors(scheme, c.status).$2)),
                          ],
                        ),
                        Text('File #${c.fileNumber}${dob == null ? '' : ' · $dob'}', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.spaceMd),
                  Container(
                    padding: const EdgeInsets.all(Dimensions.cardInner),
                    decoration: _cardDecoration(scheme),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Dimensions.spaceSm,
                      children: [
                        Text('Patient Information', style: AppTextStyles.h3.copyWith(color: scheme.onSurface)),
                        for (final (label, value) in c.rows)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                              const SizedBox(width: Dimensions.spaceMd),
                              Expanded(child: Text(value, textAlign: TextAlign.right, style: AppTextStyles.label.copyWith(color: scheme.onSurface))),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (c.isFinished) ...[
                    const SizedBox(height: Dimensions.spaceMd),
                    Container(
                      padding: const EdgeInsets.all(Dimensions.cardInner),
                      decoration: _cardDecoration(scheme),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: Dimensions.spaceSm,
                        children: [
                          Text('Front desk actions', style: AppTextStyles.h3.copyWith(color: scheme.onSurface)),
                          Text('Manage this booked visit from the front desk.', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                          Text(c.isCancelled.value ? 'This visit has been cancelled. No further front desk actions are available.' : 'This visit was marked as a no-show. No further front desk actions are available.', style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: c.isFinished
          ? null
          : _FixedAppointmentActions(controller: c, mobile: true),
    );
  }
}

BoxDecoration _cardDecoration(ColorScheme scheme) => BoxDecoration(color: scheme.surface, borderRadius: BorderRadius.circular(Dimensions.radius), border: Border.all(color: scheme.outline));

/// Background and text colour for Booked, Conflict, Cancelled and No-show.
(Color, Color) _statusColors(ColorScheme scheme, String status) => switch (status) {
  'Conflict' => (AppColors.warningSoftBackground, AppColors.warningSoftText),
  'Cancelled' => (AppColors.safetyCriticalBackground, AppColors.safetyCriticalText),
  'No-show' => (AppColors.warningSoftBackground, AppColors.warningSoftText),
  _ => (scheme.primaryContainer, scheme.primary),
};

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.width});

  final String status;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: _statusColors(scheme, status).$1, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
      child: Text(status, style: AppTextStyles.caption.copyWith(color: _statusColors(scheme, status).$2)),
    );
  }
}

/// Two equal-width action buttons side by side.
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.controller, required this.actions, required this.gap});

  final AppointmentDetailController controller;
  final List<RecordAction> actions;
  final double gap;

  @override
  Widget build(BuildContext context) => Row(
    spacing: gap,
    children: [for (final a in actions) Expanded(child: _ActionButton(controller: controller, action: a))],
  );
}

/// Keeps appointment actions visible while the details above them scroll.
class _FixedAppointmentActions extends StatelessWidget {
  const _FixedAppointmentActions({required this.controller, required this.mobile});

  final AppointmentDetailController controller;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final padding = mobile ? Dimensions.pageMarginMobile : Dimensions.pageMarginDesktop;
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
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: mobile ? Dimensions.spaceSm : Dimensions.spaceMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Dimensions.spaceSm,
            children: [
              _ActionRow(
                controller: controller,
                actions: const [RecordAction.checkIn, RecordAction.reschedule],
                gap: Dimensions.spaceSm,
              ),
              _ActionRow(
                controller: controller,
                actions: const [RecordAction.cancel, RecordAction.markNoShow],
                gap: Dimensions.spaceSm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 44px action; Check in patient is the primary action.
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.controller, required this.action});

  final AppointmentDetailController controller;
  final RecordAction action;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;
    final label = switch (action) {
      RecordAction.cancel => compact ? 'Cancel' : 'Cancel appointment',
      RecordAction.checkIn => compact ? 'Check in' : action.label,
      RecordAction.markNoShow => compact ? 'No-show' : action.label,
      _ => action.label,
    };
    void onPressed() => controller.perform(action, context);
    return SizedBox(
      height: Dimensions.buttonMinHeight,
      child: action == RecordAction.checkIn ? FilledButton(onPressed: onPressed, child: Text(label)) : OutlinedButton(onPressed: onPressed, child: Text(label)),
    );
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
