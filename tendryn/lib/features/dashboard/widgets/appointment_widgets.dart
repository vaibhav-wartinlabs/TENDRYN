import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/app_data_table.dart';
import 'package:tendryn/widgets/common/app_icon_button.dart';
import 'package:tendryn/widgets/common/section_card.dart';
import 'package:tendryn/widgets/common/status_badge.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/widgets/common/status_pill.dart';

/// "24 booked   3 remaining   2 no-shows"
class AppointmentCounts extends StatelessWidget {
  const AppointmentCounts({
    super.key,
    required this.summary,
    this.inline = false,
  });

  final AppointmentsSummary summary;

  /// Tablet: one 14/20 Medium line, dot separated. Otherwise three 12px captions.
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (inline) {
      return Text(
        '${summary.booked} booked · ${summary.remaining} remaining · ${summary.noShows} no-shows',
        style: AppTextStyles.label.copyWith(color: scheme.onSurfaceVariant),
      );
    }
    final style = AppTextStyles.caption.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Wrap(
      spacing: Dimensions.spaceMd,
      children: [
        Text('${summary.booked} booked', style: style),
        Text('${summary.remaining} remaining', style: style),
        Text('${summary.noShows} no-shows', style: style),
      ],
    );
  }
}

BadgeTone _tone(AppointmentStatus s) =>
    s == AppointmentStatus.checkedIn ? BadgeTone.success : BadgeTone.info;
Color _dot(AppointmentStatus s) => s == AppointmentStatus.checkedIn
    ? AppColors.triageGreen
    : AppColors.triageOrange;

/// Desktop: Today's Appointments card with its table.
class AppointmentsTable extends GetView<DashboardController> {
  const AppointmentsTable({super.key, required this.summary});

  final AppointmentsSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      title: 'Today’s Appointments',
      summary: AppointmentCounts(summary: summary),
      trailing: AppButton.text(
        label: 'View All Appointments',
        onPressed: controller.openAppointments,
      ),
      child: AppDataTable<AppointmentEntry>(
        horizontalPadding: Dimensions.sectionPadding,
        columnGap: Dimensions.tableColumnGap,
        rowMinHeight: Dimensions.appointmentRowMinHeight,
        minWidth: 880,
        distributeColumnWidths: true,
        rows: summary.items,
        columns: [
          AppTableColumn(
            label: 'Time',
            width: 90,
            cell: (_, a) => Text(
              a.time,
              style: AppTextStyles.tabular(AppTextStyles.label)
                  .copyWith(color: scheme.onSurface),
            ),
          ),
          AppTableColumn(
            label: 'Patient',
            width: 200,
            cell: (_, a) => Text(
              a.patient,
              style: AppTextStyles.label.copyWith(color: scheme.onSurface),
            ),
          ),
          AppTableColumn(
            label: 'Practitioner',
            width: 210,
            cell: (_, a) => Text(
              a.practitioner,
              style: AppTextStyles.caption.copyWith(color: scheme.onSurface),
            ),
          ),
          AppTableColumn(
            label: 'Visit type',
            width: 170,
            cell: (_, a) => Text(
              a.visitType,
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          AppTableColumn(
            label: 'Status',
            width: 160,
            cell: (_, a) =>
                StatusBadge(label: a.status.label, tone: _tone(a.status)),
          ),
          AppTableColumn(
            label: 'Action',
            flex: 122,
            alignment: Alignment.centerRight,
            cell: (_, a) => Align(
              alignment: Alignment.centerRight,
              child: AppButton.text(
                label: a.status == AppointmentStatus.checkedIn
                    ? 'View'
                    : 'Check In',
                onPressed: () => a.status == AppointmentStatus.checkedIn
                    ? controller.openAppointment(a, context: context)
                    : controller.checkInAppointment(a, context: context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tablet and mobile: one appointment as a card.
class AppointmentCard extends GetView<DashboardController> {
  const AppointmentCard({
    super.key,
    required this.appointment,
    this.wide = false,
  });

  final AppointmentEntry appointment;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCheckedIn = appointment.status == AppointmentStatus.checkedIn;
    final menu = AppIconButton(
      icon: AppIcons.rowMenu,
      tooltip: 'Appointment actions',
      onPressed: () => isCheckedIn
          ? controller.openAppointment(appointment, context: context)
          : controller.checkInAppointment(appointment, context: context),
    );
    final chip = StatusPill(
      color: _dot(appointment.status),
      label: appointment.status.label,
    );
    final micro = AppTextStyles.micro.copyWith(color: scheme.onSurfaceVariant);
    final value = AppTextStyles.caption.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      onTap: () => isCheckedIn
          ? controller.openAppointment(appointment, context: context)
          : controller.checkInAppointment(appointment, context: context),
      child: wide
          // Tablet (Figma): a 76px time column, then name + details + chip, then the row menu.
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimensions.spaceMd + Dimensions.spaceXs,
              children: [
                SizedBox(
                  width: 76,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimensions.spaceXs,
                    children: [
                      Text(
                        'Time',
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        appointment.time,
                        style: AppTextStyles.tabular(AppTextStyles.h3)
                            .copyWith(color: scheme.primary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Dimensions.statusX,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Dimensions.componentGap,
                        children: [
                          Text(
                            appointment.patient,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Practitioner: ${appointment.practitioner}',
                                style: AppTextStyles.label.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Visit type: ${appointment.visitType}',
                                style: AppTextStyles.label.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      chip,
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
                      child: Text(
                        appointment.patient,
                        style: AppTextStyles.h3Mobile.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    menu,
                  ],
                ),
                Column(
                  spacing: Dimensions.spaceXs,
                  children: [
                    _Line(
                      label: 'Practitioner',
                      value: appointment.practitioner,
                      labelStyle: micro,
                      valueStyle: value,
                    ),
                    _Line(
                      label: 'Visit type',
                      value: appointment.visitType,
                      labelStyle: micro,
                      valueStyle: value,
                    ),
                    _Line(
                      label: 'Time',
                      value: appointment.time,
                      labelStyle: micro,
                      valueStyle: AppTextStyles.tabular(AppTextStyles.caption)
                          .copyWith(color: scheme.primary),
                    ),
                  ],
                ),
                chip,
              ],
            ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: labelStyle),
      Flexible(
        child: Text(value, style: valueStyle, textAlign: TextAlign.end),
      ),
    ],
  );
}

class DoctorAppointmentItemData {
  const DoctorAppointmentItemData({
    required this.time,
    required this.patient,
    required this.visit,
    required this.status,
    required this.statusBg,
    required this.statusColor,
    required this.action,
  });

  final String time;
  final String patient;
  final String visit;
  final String status;
  final Color statusBg;
  final Color statusColor;
  final String action;

  static const items = [
    DoctorAppointmentItemData(
      time: '09:00',
      patient: 'Nomsa Dlamini',
      visit: 'Follow-up',
      status: 'Checked in',
      statusBg: AppColors.feedbackSuccessTint,
      statusColor: AppColors.triageGreen,
      action: 'Open',
    ),
    DoctorAppointmentItemData(
      time: '10:30',
      patient: 'Thabo Mokoena',
      visit: 'Urgent visit',
      status: 'In queue',
      statusBg: AppColors.feedbackInfoTint,
      statusColor: AppColors.feedbackInfo,
      action: 'Open',
    ),
    DoctorAppointmentItemData(
      time: '14:00',
      patient: 'Sipho Khumalo',
      visit: 'Follow-up',
      status: 'Scheduled',
      statusBg: AppColors.backgroundApp,
      statusColor: AppColors.textSecondary,
      action: 'Open',
    ),
  ];

  static const tabletItems = [
    DoctorAppointmentItemData(
      time: '09:00',
      patient: 'Nomsa Dlamini',
      visit: 'Follow-up',
      status: 'Checked in',
      statusBg: AppColors.feedbackSuccessTint,
      statusColor: AppColors.triageGreen,
      action: 'Open',
    ),
    DoctorAppointmentItemData(
      time: '10:30',
      patient: 'Thabo Mokoena',
      visit: 'Urgent visit',
      status: 'In queue',
      statusBg: AppColors.feedbackInfoTint,
      statusColor: AppColors.feedbackInfo,
      action: 'Open',
    ),
    DoctorAppointmentItemData(
      time: '14:00',
      patient: 'Sipho Khumalo',
      visit: 'Follow-up',
      status: 'Scheduled',
      statusBg: AppColors.backgroundApp,
      statusColor: AppColors.textSecondary,
      action: 'Open',
    ),
  ];
}

/// Doctor: "Today’s appointments" table on Desktop
class DoctorAppointmentsTable extends StatelessWidget {
  const DoctorAppointmentsTable({super.key});

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
                    'Today’s appointments',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => AppNotice.unavailable('Appointments'),
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
                      'Time',
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
                      'Visit',
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Status',
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
          for (final item in DoctorAppointmentItemData.items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.sectionPadding,
                vertical: Dimensions.spaceLg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.time,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: scheme.onSurface,
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
                      item.visit,
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
                          color: item.statusBg,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius,
                          ),
                        ),
                        child: Text(
                          item.status,
                          style: TextStyle(
                            color: item.statusColor,
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
                        onTap: () => AppNotice.unavailable('Appointment action'),
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
            if (item != DoctorAppointmentItemData.items.last)
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

/// Doctor appointment single card for Mobile and Tablet
class DoctorAppointmentCardWidget extends StatelessWidget {
  const DoctorAppointmentCardWidget({super.key, required this.item});

  final DoctorAppointmentItemData item;

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
                item.time,
                style: TextStyle(
                  color: scheme.onSurface,
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
                  color: item.statusBg,
                  borderRadius: BorderRadius.circular(Dimensions.radius),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: item.statusColor,
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
                item.visit,
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
