import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/dashboard/widgets/queue_widgets.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/features/queue/widgets/queue_row_menu.dart';
import 'package:tendryn/widgets/common/app_data_table.dart';
import 'package:tendryn/widgets/common/status_badge.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';

/// Desktop: the "Today's queue" table. Columns and widths follow the Queue
/// Figma frame.
class QueueTable extends GetView<QueueController> {
  const QueueTable({super.key});

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
              vertical: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Today’s queue',
                    style: AppTextStyles.h3.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Updates across clinic devices',
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
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
          Obx(() {
            final rows = controller.pageEntries;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppDataTable<QueueEntry>(
                  horizontalPadding: Dimensions.sectionPadding,
                  columnGap: Dimensions.tableColumnGap,
                  rowMinHeight: Dimensions.queueRowMinHeight,
                  minWidth: Dimensions.dashboardTableMinWidth,
                  distributeColumnWidths: true,
                  rows: rows,
                  columns: _columns(scheme),
                ),
                if (rows.isEmpty) const QueueEmptyState(),
              ],
            );
          }),
        ],
      ),
    );
  }

  List<AppTableColumn<QueueEntry>> _columns(ColorScheme scheme) => [
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
        style: AppTextStyles.tabular(AppTextStyles.caption)
            .copyWith(color: scheme.onSurfaceVariant),
      ),
    ),
    AppTableColumn(
      label: 'Waiting',
      width: 64,
      cell: (_, e) => Text(
        '${e.waitingMinutes} min',
        style: AppTextStyles.tabular(AppTextStyles.label)
            .copyWith(color: scheme.onSurface),
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
        style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
      ),
    ),
    AppTableColumn(
      label: 'Actions',
      width: Dimensions.touchTarget,
      alignment: Alignment.center,
      cell: (_, e) => QueueRowMenu(entry: e),
    ),
  ];
}

/// Illustration shown on empty search state matching the design mockups.
class PatientSearchEmptyIllustration extends StatelessWidget {
  const PatientSearchEmptyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 76,
      child: CustomPaint(painter: _SearchEmptyPainter()),
    );
  }
}

class _SearchEmptyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Decorative background mint circle & dots
    final bgPaint = Paint()
      ..color = AppColors.brandTint
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 2, center.dy), 32, bgPaint);

    final dotPaint = Paint()
      ..color = AppColors.brandTint
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 36, center.dy - 6), 1.8, dotPaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 16), 1.8, dotPaint);
    canvas.drawCircle(Offset(center.dx + 34, center.dy + 8), 1.4, dotPaint);

    // 2. ID card
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - 6, center.dy - 3),
        width: 48,
        height: 38,
      ),
      const Radius.circular(6),
    );
    final cardFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final cardStroke = Paint()
      ..color = AppColors.brandTint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(cardRect, cardFill);
    canvas.drawRRect(cardRect, cardStroke);

    // 3. Avatar inside card
    final avatarPaint = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 20, center.dy - 12), 3, avatarPaint);
    final shoulderPath = Path()
      ..moveTo(center.dx - 24, center.dy - 5)
      ..quadraticBezierTo(
        center.dx - 20,
        center.dy - 9,
        center.dx - 16,
        center.dy - 5,
      )
      ..close();
    canvas.drawPath(shoulderPath, avatarPaint);

    // Placeholder lines
    final linePaint = Paint()
      ..color = AppColors.brandTint
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 12, center.dy - 14, 16, 2.5),
        const Radius.circular(1.5),
      ),
      linePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 12, center.dy - 9, 11, 2.5),
        const Radius.circular(1.5),
      ),
      linePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 23, center.dy - 1, 22, 2.5),
        const Radius.circular(1.5),
      ),
      linePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 23, center.dy + 4, 17, 2.5),
        const Radius.circular(1.5),
      ),
      linePaint,
    );

    // 4. Magnifying glass with minus inside
    final glassCenter = Offset(center.dx + 16, center.dy + 8);
    const glassRadius = 10.5;

    final lensFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(glassCenter, glassRadius, lensFill);

    final glassStroke = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(glassCenter, glassRadius, glassStroke);

    final minusPaint = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(glassCenter.dx - 4, glassCenter.dy),
      Offset(glassCenter.dx + 4, glassCenter.dy),
      minusPaint,
    );

    final handlePaint = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;
    canvas.drawLine(
      Offset(glassCenter.dx + 7.5, glassCenter.dy + 7.5),
      Offset(glassCenter.dx + 16, glassCenter.dy + 16),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector illustration with mint circle, 3 waiting chairs, and clock matching Figma empty queue.
class NoPatientsWaitingIllustration extends StatelessWidget {
  const NoPatientsWaitingIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 76,
      child: CustomPaint(painter: _NoPatientsWaitingPainter()),
    );
  }
}

class _NoPatientsWaitingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Mint background circle & sparkle dots
    final bgPaint = Paint()
      ..color = AppColors.brandTint
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 2, center.dy - 2), 32, bgPaint);

    final dotPaint = Paint()
      ..color = AppColors.brandTint
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 36, center.dy), 1.8, dotPaint);
    canvas.drawCircle(Offset(center.dx + 34, center.dy + 8), 1.6, dotPaint);

    // 2. Base ground line
    final linePaint = Paint()
      ..color = AppColors.brandTint
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(center.dx - 34, center.dy + 17),
      Offset(center.dx + 34, center.dy + 17),
      linePaint,
    );

    // 3. Three clinic chairs
    final chairCenters = [center.dx - 18, center.dx, center.dx + 18];

    final chairFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final chairStroke = Paint()
      ..color = AppColors.brandTint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final cx in chairCenters) {
      final backRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, center.dy + 3),
          width: 14,
          height: 18,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(backRect, chairFill);
      canvas.drawRRect(backRect, chairStroke);
    }

    // Horizontal seat cushion / bar across chairs
    final seatPaint = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.fill;
    for (final cx in chairCenters) {
      final seatRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, center.dy + 11.5),
          width: 15,
          height: 3.5,
        ),
        const Radius.circular(1),
      );
      canvas.drawRRect(seatRect, seatPaint);
    }

    // Chair legs (teal)
    final legPaint = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;

    for (final cx in chairCenters) {
      canvas.drawLine(
        Offset(cx - 5.5, center.dy + 13),
        Offset(cx - 5.5, center.dy + 17),
        legPaint,
      );
      canvas.drawLine(
        Offset(cx + 5.5, center.dy + 13),
        Offset(cx + 5.5, center.dy + 17),
        legPaint,
      );
    }

    // 4. Clock on top right
    final clockCenter = Offset(center.dx + 20, center.dy - 12);
    const clockRadius = 9.0;

    final clockFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(clockCenter, clockRadius, clockFill);

    final clockStroke = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(clockCenter, clockRadius, clockStroke);

    // Clock hands (pointing to ~12:15)
    final handsPaint = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;

    // Minute hand pointing up
    canvas.drawLine(
      clockCenter,
      Offset(clockCenter.dx, clockCenter.dy - 4.5),
      handsPaint,
    );
    // Hour hand pointing right
    canvas.drawLine(
      clockCenter,
      Offset(clockCenter.dx + 3.8, clockCenter.dy),
      handsPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Empty state shown when queue has no patients waiting to be consulted.
class NoPatientsWaitingEmptyState extends StatelessWidget {
  const NoPatientsWaitingEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NoPatientsWaitingIllustration(),
            SizedBox(height: Dimensions.pageSectionGap),
            Text(
              'No patients waiting',
              style: TextStyle(
                fontFamily: AppTextStyles.headingFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'New patients appear here when reception checks them in.',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorQueueEmptyState extends GetView<QueueController> {
  const DoctorQueueEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final query = controller.searchQuery.value.trim();
      final hasQuery = query.isNotEmpty;

      // When there is no search query, show "No patients waiting" with chairs & clock
      if (!hasQuery) {
        return const NoPatientsWaitingEmptyState();
      }

      // When search query is present but no match found, show magnifying glass empty state
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PatientSearchEmptyIllustration(),
              const SizedBox(height: Dimensions.pageSectionGap),
              Text(
                'No patients match “$query”',
                style: const TextStyle(
                  fontFamily: AppTextStyles.headingFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Check the spelling, or search by ID or queue number.',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: controller.clearSearch,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Clear search',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Shown when nothing matches the search/filter (or the queue is empty).
class QueueEmptyState extends GetView<QueueController> {
  const QueueEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDoctor =
          Get.isRegistered<RoleController>() &&
          RoleController.to.currentRole.value == ClinicRole.doctor;
      if (isDoctor) {
        return const DoctorQueueEmptyState();
      }

      final scheme = Theme.of(context).colorScheme;
      final filtering =
          controller.searchQuery.value.trim().isNotEmpty ||
          controller.statusFilter.value != null ||
          controller.priorityFilter.value != null;
      return Padding(
        padding: const EdgeInsets.all(Dimensions.spaceXl),
        child: Center(
          child: Text(
            filtering
                ? 'No patients match your search or filter.'
                : 'No patients in the queue yet.',
            style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }
}

/// "Showing 1–5 of 5 patients" with 48px previous / page / next buttons.
class QueuePagination extends GetView<QueueController> {
  const QueuePagination({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 80,
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: Obx(() {
        final current = controller.page.value;
        final count = controller.pageCount;
        return Row(
          children: [
            Expanded(
              child: Text(
                controller.rangeLabel,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Row(
              spacing: Dimensions.componentGap,
              children: [
                PaginationButton(
                  icon: AppIcons.chevronLeft,
                  tooltip: 'Previous page',
                  onPressed: current > 1
                      ? () => controller.goToPage(current - 1)
                      : null,
                ),
                for (var i = 1; i <= count; i++)
                  PaginationButton(
                    label: '$i',
                    selected: i == current,
                    onPressed: () => controller.goToPage(i),
                  ),
                PaginationButton(
                  icon: AppIcons.chevronRight,
                  tooltip: 'Next page',
                  onPressed: current < count
                      ? () => controller.goToPage(current + 1)
                      : null,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class PaginationButton extends StatelessWidget {
  const PaginationButton({
    super.key,
    this.label,
    this.icon,
    this.tooltip,
    this.selected = false,
    required this.onPressed,
  });

  final String? label;
  final IconData? icon;
  final String? tooltip;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      side: selected
          ? BorderSide.none
          : BorderSide(color: scheme.outline, width: Dimensions.strokeDivider),
    );
    final child = label != null
        ? Text(
            label!,
            style: AppTextStyles.label.copyWith(
              color: selected ? scheme.onPrimary : scheme.onSurface,
            ),
          )
        : Icon(icon, size: 16, color: scheme.primary);
    return Opacity(
      opacity: onPressed == null && !selected ? 0.4 : 1,
      child: Tooltip(
        message: tooltip ?? 'Page $label',
        child: Material(
          color: selected
              ? scheme.primary
              : Theme.of(context).scaffoldBackgroundColor,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onPressed,
            child: SizedBox.square(
              dimension: Dimensions.touchTarget,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill priority badge matching the Doctor Queue design frames.
class DoctorPriorityBadge extends StatelessWidget {
  const DoctorPriorityBadge({super.key, required this.priority});

  final QueuePriority priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (priority) {
      QueuePriority.emergency => (
        AppColors.safetyCriticalBackground,
        AppColors.safetyCriticalText,
      ),
      QueuePriority.urgent => (
        AppColors.feedbackWarningTint,
        AppColors.feedbackWarning,
      ),
      QueuePriority.routine => (
        AppColors.feedbackSuccessTint,
        AppColors.feedbackSuccess,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
      child: Text(
        priority.label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }
}

/// The "Call Next Patient" broadcast wave icon matching the Doctor mockup.
class DoctorCallIcon extends StatelessWidget {
  const DoctorCallIcon({super.key, this.color = Colors.white, this.size = 20});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DoctorCallIconPainter(color: color)),
    );
  }
}

class _DoctorCallIconPainter extends CustomPainter {
  _DoctorCallIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Person head
    canvas.drawCircle(Offset(w * 0.32, h * 0.32), w * 0.16, paint);

    // Person shoulders
    final path = Path();
    path.arcTo(
      Rect.fromLTWH(w * 0.08, h * 0.54, w * 0.48, h * 0.42),
      3.14159,
      3.14159,
      false,
    );
    canvas.drawPath(path, paint);

    // Sound wave 1
    final wave1 = Path();
    wave1.arcTo(
      Rect.fromCenter(
        center: Offset(w * 0.40, h * 0.42),
        width: w * 0.62,
        height: h * 0.62,
      ),
      -0.65,
      1.3,
      false,
    );
    canvas.drawPath(wave1, paint);

    // Sound wave 2
    final wave2 = Path();
    wave2.arcTo(
      Rect.fromCenter(
        center: Offset(w * 0.40, h * 0.42),
        width: w * 0.95,
        height: h * 0.95,
      ),
      -0.55,
      1.1,
      false,
    );
    canvas.drawPath(wave2, paint);
  }

  @override
  bool shouldRepaint(covariant _DoctorCallIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// "Call Next Patient" action button in brand teal.
class DoctorCallNextPatientButton extends StatelessWidget {
  const DoctorCallNextPatientButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.customIcon,
  });

  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? customIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandPrimary,
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Call Next Patient',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (customIcon != null) ...[
                const SizedBox(width: 8),
                customIcon!,
              ] else if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Queue entry card used on Tablet (2-column) and Mobile (1-column).
class DoctorPatientQueueCard extends StatelessWidget {
  const DoctorPatientQueueCard({
    super.key,
    required this.entry,
    required this.onStart,
    this.showBadge = true,
  });

  final QueueEntry entry;
  final VoidCallback onStart;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (entry.number.isNotEmpty)
                  Text(
                    entry.number,
                    style: const TextStyle(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (showBadge)
                  DoctorPriorityBadge(priority: entry.priority)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              if (Get.isRegistered<QueueController>()) {
                Get.find<QueueController>().viewProfile(entry);
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.patient,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.demographics} · Waiting ${entry.waitingMinutes} min',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  entry.reason,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              QueueRowMenu(entry: entry, isDoctor: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// Doctor queue pagination matching "Previous 1 2 3 ... 10 Next".
class DoctorPagination extends GetView<QueueController> {
  const DoctorPagination({
    super.key,
    this.isMobile = false,
    this.isDesktop = false,
  });

  final bool isMobile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.filtered.isEmpty) {
        return const SizedBox.shrink();
      }
      final current = controller.selectedDoctorPage.value;
      final rangeText = controller.rangeLabel;

      final textControls = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MobilePageTextButton(
            label: 'Previous',
            enabled: current > 1,
            onTap: current > 1 ? controller.previousDoctorPage : null,
          ),
          const SizedBox(width: 12),
          _MobilePageNumberButton(
            page: 1,
            isSelected: current == 1,
            onTap: () => controller.switchDoctorPage(1),
          ),
          const SizedBox(width: 8),
          _MobilePageNumberButton(
            page: 2,
            isSelected: current == 2,
            onTap: () => controller.switchDoctorPage(2),
          ),
          const SizedBox(width: 8),
          _MobilePageNumberButton(
            page: 3,
            isSelected: current == 3,
            onTap: () => controller.switchDoctorPage(3),
          ),
          const SizedBox(width: 8),
          _MobilePageTextButton(
            label: '...',
            enabled: true,
            onTap: () => controller.switchDoctorPage(
              current <= 3 ? 4 : (current == 10 ? 9 : current),
            ),
          ),
          const SizedBox(width: 8),
          _MobilePageNumberButton(
            page: 10,
            isSelected: current == 10,
            onTap: () => controller.switchDoctorPage(10),
          ),
          const SizedBox(width: 12),
          _MobilePageTextButton(
            label: 'Next',
            enabled: current < 10,
            onTap: current < 10 ? controller.nextDoctorPage : null,
          ),
        ],
      );

      if (isMobile) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: textControls,
          ),
        );
      }

      if (!isDesktop) {
        // Tablet: range text on left, text controls on right (matching tablet mockup)
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  rangeText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              textControls,
            ],
          ),
        );
      }

      final desktopControls = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          _DesktopPageControl(
            label: 'Previous',
            width: 88,
            enabled: current > 1,
            onPressed: current > 1 ? controller.previousDoctorPage : null,
          ),
          _DesktopPageControl(
            label: '1',
            width: 40,
            selected: current == 1,
            onPressed: () => controller.switchDoctorPage(1),
          ),
          _DesktopPageControl(
            label: '2',
            width: 40,
            selected: current == 2,
            onPressed: () => controller.switchDoctorPage(2),
          ),
          _DesktopPageControl(
            label: '3',
            width: 40,
            selected: current == 3,
            onPressed: () => controller.switchDoctorPage(3),
          ),
          _DesktopPageControl(
            label: '...',
            width: 40,
            selected: current > 3 && current < 10,
            onPressed: () => controller.switchDoctorPage(
              current <= 3 ? 4 : (current == 10 ? 9 : current),
            ),
          ),
          _DesktopPageControl(
            label: '10',
            width: 44,
            selected: current == 10,
            onPressed: () => controller.switchDoctorPage(10),
          ),
          _DesktopPageControl(
            label: 'Next',
            width: 66,
            enabled: current < 10,
            onPressed: current < 10 ? controller.nextDoctorPage : null,
          ),
        ],
      );

      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                rangeText,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            desktopControls,
          ],
        ),
      );
    });
  }
}

class _DesktopPageControl extends StatelessWidget {
  const _DesktopPageControl({
    required this.label,
    required this.width,
    this.selected = false,
    this.enabled = true,
    this.onPressed,
  });

  final String label;
  final double width;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      side: BorderSide(
        color: selected ? AppColors.brandPrimary : AppColors.borderDefault,
      ),
    );

    final textColor = selected
        ? Colors.white
        : (!enabled ? AppColors.textDisabled : AppColors.brandPrimary);

    return Material(
      color: selected ? AppColors.brandPrimary : Colors.white,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          width: width,
          height: Dimensions.buttonMinHeight,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobilePageTextButton extends StatelessWidget {
  const _MobilePageTextButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: enabled ? AppColors.textSecondary : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}

class _MobilePageNumberButton extends StatelessWidget {
  const _MobilePageNumberButton({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  final int page;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: Dimensions.touchTarget,
        height: Dimensions.touchTarget,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.brandPrimary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '$page',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: Dimensions.touchTarget,
        height: Dimensions.touchTarget,
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Doctor: "Patients Awaiting Consultation" desktop table inside a card container.
class DoctorQueueTableWidget extends GetView<QueueController> {
  const DoctorQueueTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(Dimensions.sectionPadding),
            child: Text(
              'Patients Awaiting Consultation',
              style: TextStyle(
                fontFamily: AppTextStyles.headingFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderDefault,
          ),
          ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.sectionPadding,
                vertical: Dimensions.controlY,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Queue',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Patient',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Waiting',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Reason',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Priority',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Actions',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
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
          Obx(() {
            // =========================================================================
            // [FUTURE LAUNCH CONDITION / NO PATIENTS WAITING TOGGLE]:
            // Jab future me project launch hoga aur queue me koi patient nahi hoga:
            // - IF FALSE -> normal patient list / table show hoga (current behavior)
            // - IF TRUE  -> "No patients waiting" empty state (chairs + clock) show hoga
            //
            // const bool forceNoPatientsWaiting = false; // Set to true to preview or use (controller.filtered.isEmpty)
            // if (forceNoPatientsWaiting) {
            //   return const NoPatientsWaitingEmptyState();
            // }
            // =========================================================================

            final rows = controller.pageEntries;
            if (rows.isEmpty) {
              return const DoctorQueueEmptyState();
            }
            return Column(
              children: [
                for (final item in rows) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.sectionPadding,
                      vertical: Dimensions.tableRowVerticalPadding,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.number,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.bodyFamily,
                              color: AppColors.brandPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => controller.viewProfile(item),
                            borderRadius: BorderRadius.circular(4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.patient,
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.bodyFamily,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.demographics,
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.bodyFamily,
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${item.waitingMinutes} min',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.bodyFamily,
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.reason,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.bodyFamily,
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: DoctorPriorityBadge(priority: item.priority),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: QueueRowMenu(entry: item, isDoctor: true),
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
                ],
              ],
            );
          }),
          Obx(() {
            final rows = controller.pageEntries;
            if (rows.isEmpty) return const SizedBox.shrink();
            return const DoctorPagination(isDesktop: true);
          }),
        ],
      ),
    );
  }
}

/// Modal dialog (desktop/tablet) or bottom sheet (mobile) shown when clicking "Call Next Patient".
Future<void> showCallNextPatientDialog(
  BuildContext context, {
  QueueEntry? patient,
}) {
  final isMobile = ResponsiveHelper.isMobile(context);
  if (isMobile) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: const Color(0x850F1F1D),
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => CallNextPatientSheet(patient: patient),
    );
  }
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x850F1F1D),
    builder: (ctx) => CallNextPatientDialog(patient: patient),
  );
}

class CallNextPatientDialog extends StatelessWidget {
  const CallNextPatientDialog({super.key, this.patient});

  final QueueEntry? patient;

  @override
  Widget build(BuildContext context) {
    const defaultName = 'John Smith';
    const defaultNumber = 'Q015';
    const defaultDemographics = '52 / Male';
    const defaultWaiting = 16;
    const defaultReason = 'Follow-up';

    final name = patient?.patient ?? defaultName;
    final number = patient?.number ?? defaultNumber;
    final demographics = (patient != null && patient!.demographics.isNotEmpty)
        ? (patient!.demographics == '45/M'
              ? '52 / Male'
              : patient!.demographics)
        : defaultDemographics;
    final waiting = patient?.waitingMinutes ?? defaultWaiting;
    final reason = patient?.reason ?? defaultReason;
    final priorityLabel = patient?.priority.label ?? 'Urgent';

    final nameParts = name.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : 'JS');

    final details = '$number · $demographics · Waiting $waiting min · $reason';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Container(
          width: 520,
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Call next patient?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'The patient will be called to Consultation room 2.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        AppIcons.close,
                        size: Dimensions.iconSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.pageSectionGap),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.feedbackSuccessTint,
                  borderRadius: BorderRadius.circular(Dimensions.radius),
                  border: Border.all(color: AppColors.brandTint),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            details,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.feedbackSuccessTint,
                        borderRadius: BorderRadius.circular(Dimensions.radius),
                      ),
                      child: Text(
                        priorityLabel,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Patients are called in priority order. You can mark the patient unavailable if they do not respond.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.borderDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusControl,
                          ),
                        ),
                        foregroundColor: AppColors.brandPrimary,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        AppNotice.info(
                          'Calling Patient',
                          'Calling $name ($number) to Consultation room 2.',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusControl,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Call patient',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mobile bottom sheet shown when clicking "Call Next Patient".
class CallNextPatientSheet extends StatelessWidget {
  const CallNextPatientSheet({super.key, this.patient});

  final QueueEntry? patient;

  @override
  Widget build(BuildContext context) {
    const defaultName = 'John Smith';
    const defaultNumber = 'Q015';
    const defaultDemographics = '52 / Male';
    const defaultWaiting = 16;
    const defaultReason = 'Follow-up';

    final name = patient?.patient ?? defaultName;
    final number = patient?.number ?? defaultNumber;
    final demographics = (patient != null && patient!.demographics.isNotEmpty)
        ? (patient!.demographics == '45/M'
              ? '52 / Male'
              : patient!.demographics)
        : defaultDemographics;
    final waiting = patient?.waitingMinutes ?? defaultWaiting;
    final reason = patient?.reason ?? defaultReason;
    final priorityLabel = patient?.priority.label ?? 'Urgent';

    final nameParts = name.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : 'JS');

    final details = '$number · $demographics · Waiting $waiting min · $reason';

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 4, bottom: 16),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Call next patient?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'The patient will be called to Consultation room 2.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      AppIcons.close,
                      size: Dimensions.iconSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.feedbackSuccessTint,
                borderRadius: BorderRadius.circular(Dimensions.radius),
                border: Border.all(color: AppColors.brandTint),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.feedbackSuccessTint,
                      borderRadius: BorderRadius.circular(Dimensions.radius),
                    ),
                    child: Text(
                      priorityLabel,
                      style: const TextStyle(
                        color: AppColors.brandPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Patients are called in priority order. You can mark the patient unavailable if they do not respond.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                      foregroundColor: AppColors.brandPrimary,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      AppNotice.info(
                        'Calling Patient',
                        'Calling $name ($number) to Consultation room 2.',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Call patient',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Responsive launcher for Doctor "Queue patient" profile view:
/// - Desktop (>= 1200): Dedicated side drawer (sliding from right)
/// - Tablet & Mobile (< 1200): Dedicated new full page without navigation bar
void showDoctorQueuePatientView(
  BuildContext context, {
  required QueueEntry entry,
}) {
  if (ResponsiveHelper.usesDrawer(context)) {
    showDoctorQueuePatientDrawer(context, entry: entry);
    return;
  }

  // Tablet & Mobile (< 1200): Open as dedicated new page without navigation bar
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          DoctorQueuePatientTabletPage(entry: entry),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}

void showDoctorQueuePatientDrawer(
  BuildContext context, {
  required QueueEntry entry,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x850F1F1D),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 16,
          color: Colors.transparent,
          child: DoctorQueuePatientDrawer(entry: entry),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slideAnimation, child: child);
    },
  );
}

void showDoctorQueuePatientBottomSheet(
  BuildContext context, {
  required QueueEntry entry,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    barrierColor: const Color(0x850F1F1D),
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
                child: Row(
                  children: [
                    const Text(
                      'Queue patient',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        AppIcons.close,
                        size: Dimensions.iconSize,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: DoctorQueuePatientContent(
                    entry: entry,
                    isMobile: true,
                  ),
                ),
              ),
              DoctorQueuePatientBottomBar(entry: entry),
            ],
          ),
        ),
      );
    },
  );
}

class DoctorQueuePatientDrawer extends StatelessWidget {
  const DoctorQueuePatientDrawer({super.key, required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = screenWidth < 768
        ? (screenWidth * 0.85).clamp(320.0, 420.0)
        : (screenWidth < 1100 ? 430.0 : Dimensions.drawerWidth);

    return Container(
      width: drawerWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Queue patient',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.number} · Waiting ${entry.waitingMinutes} min',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(
                    AppIcons.close,
                    size: Dimensions.iconSize,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderDefault,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: DoctorQueuePatientContent(entry: entry, isMobile: false),
            ),
          ),
          DoctorQueuePatientBottomBar(entry: entry),
        ],
      ),
    );
  }
}

class DoctorQueuePatientTabletPage extends StatelessWidget {
  const DoctorQueuePatientTabletPage({super.key, required this.entry});

  final QueueEntry entry;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.backgroundApp,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderDefault),
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusControl,
                      ),
                      child: Container(
                        width: Dimensions.touchTarget,
                        height: Dimensions.touchTarget,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusControl,
                          ),
                          border: Border.all(color: AppColors.borderDefault),
                        ),
                        child: const Center(
                          child: Icon(
                            AppIcons.chevronLeft,
                            size: Dimensions.iconSize,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.spaceMd),
                    const Text(
                      'Queue patient',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: DoctorQueuePatientContent(
                    entry: entry,
                    isMobile: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: DoctorQueuePatientBottomBar(entry: entry, hasTopBorder: true),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TabletHeader(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginDesktop,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusControl,
                    ),
                    child: Container(
                      width: Dimensions.touchTarget,
                      height: Dimensions.touchTarget,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: const Center(
                        child: Icon(
                          AppIcons.chevronLeft,
                          size: Dimensions.iconSize,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.spaceMd),
                  const Text(
                    'Queue patient',
                    style: TextStyle(
                      fontFamily: AppTextStyles.headingFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginDesktop,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.isTabletLandscape(context)
                          ? double.infinity
                          : 720,
                    ),
                    child: DoctorQueuePatientContent(
                      entry: entry,
                      isMobile: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderDefault, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.isTabletLandscape(context)
                    ? double.infinity
                    : 720,
              ),
              child: DoctorQueuePatientBottomBar(
                entry: entry,
                hasTopBorder: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DoctorQueuePatientContent extends StatelessWidget {
  const DoctorQueuePatientContent({
    super.key,
    required this.entry,
    required this.isMobile,
  });

  final QueueEntry entry;
  final bool isMobile;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'PT';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent =
        entry.priority == QueuePriority.emergency ||
        entry.priority == QueuePriority.urgent;
    final folderNumber = entry.number == 'Q015'
        ? '#SWC-10427'
        : '#SWC-${entry.number.replaceAll(RegExp(r'[^0-9]'), '').padLeft(5, '0')}';
    final reason = entry.reason == 'Follow-up'
        ? 'Follow-up · recurring headaches'
        : (entry.reason.isNotEmpty ? entry.reason : 'General consultation');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Patient Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandTint,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(color: AppColors.brandTint, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: isMobile ? 44 : 50,
                height: isMobile ? 44 : 50,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandPrimary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _initials(entry.patient),
                    style: TextStyle(
                      fontFamily: AppTextStyles.headingFamily,
                      fontSize: isMobile ? 15 : 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.patient,
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          entry.demographics.isNotEmpty
                              ? entry.demographics
                              : '52 / Male',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '·',
                            style: TextStyle(
                              color: AppColors.textDisabled,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            'Folder $folderNumber',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.bodyFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Allergy Warning Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.safetyCriticalBackground,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(
              color: AppColors.safetyCriticalBackground,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.safetyCriticalBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.alert,
                  size: 16,
                  color: AppColors.triageRed,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Allergy: Penicillin (anaphylaxis)',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.triageRed,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Patient Details Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radius),
            border: Border.all(color: AppColors.borderDefault, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailItem(
                label: 'Queue number',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandTint,
                    borderRadius: BorderRadius.circular(Dimensions.radius),
                  ),
                  child: Text(
                    entry.number,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.backgroundApp,
              ),
              _buildDetailItem(
                label: 'Waiting',
                child: Text(
                  '${entry.waitingMinutes} min',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.backgroundApp,
              ),
              _buildDetailItem(
                label: 'Reason for visit',
                child: Text(
                  reason,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.backgroundApp,
              ),
              _buildDetailItem(
                label: 'Priority',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? AppColors.feedbackWarningTint
                        : AppColors.feedbackSuccessTint,
                    borderRadius: BorderRadius.circular(Dimensions.radius),
                  ),
                  child: Text(
                    entry.priority.label,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isUrgent
                          ? AppColors.feedbackWarning
                          : AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.backgroundApp,
              ),
              _buildDetailItem(
                label: 'Status',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandTint,
                    borderRadius: BorderRadius.circular(Dimensions.radius),
                  ),
                  child: const Text(
                    'Waiting',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.backgroundApp,
              ),
              _buildDetailItem(
                label: 'Checked in by',
                child: Text(
                  'Reception · ${entry.arrival.isNotEmpty ? entry.arrival : '11:16'}',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: child),
          ),
        ],
      ),
    );
  }
}

class DoctorQueuePatientBottomBar extends StatelessWidget {
  const DoctorQueuePatientBottomBar({
    super.key,
    required this.entry,
    this.hasTopBorder = true,
  });

  final QueueEntry entry;
  final bool hasTopBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: hasTopBorder
            ? const Border(
                top: BorderSide(color: AppColors.borderDefault, width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () =>
                  openDoctorPatientProfile(context: context, entry: entry),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.borderDefault),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
                foregroundColor: AppColors.brandPrimary,
              ),
              child: const Text(
                'Open profile',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (Get.isRegistered<QueueController>()) {
                  Get.find<QueueController>().startConsultation(entry);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                ),
              ),
              child: const Text(
                'Start consultation',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void openDoctorPatientProfile({BuildContext? context, QueueEntry? entry}) {
  AppNotice.unavailable('Open profile', 'Page is not available');
}

/// Doctor Queue "Update Status" selection options matching the designs.
enum DoctorPatientStatus {
  waiting(
    title: 'Waiting',
    description: 'Patient stays in the queue',
    queueStatus: QueueStatus.waiting,
  ),
  called(
    title: 'Called',
    description: 'Patient has been called to the room',
    queueStatus: QueueStatus.waitingForDoctor,
  ),
  inConsultation(
    title: 'In consultation',
    description: 'Consultation has started',
    queueStatus: QueueStatus.withNurse,
  );

  const DoctorPatientStatus({
    required this.title,
    required this.description,
    required this.queueStatus,
  });

  final String title;
  final String description;
  final QueueStatus queueStatus;

  static DoctorPatientStatus fromQueueStatus(QueueStatus status) {
    switch (status) {
      case QueueStatus.waitingForDoctor:
        return DoctorPatientStatus.called;
      case QueueStatus.withNurse:
        return DoctorPatientStatus.inConsultation;
      case QueueStatus.waiting:
        return DoctorPatientStatus.waiting;
    }
  }
}

/// Responsive launcher for Doctor "Update status" view:
/// - Desktop (>= 1200): Dedicated side drawer (sliding from right)
/// - Tablet (600..1199): Dedicated page with header, content & bottom navigation
/// - Mobile (< 600): Modal bottom sheet
void showDoctorUpdateStatusView(
  BuildContext context, {
  required QueueEntry entry,
}) {
  final screenType = ResponsiveHelper.screenType(context);

  if (screenType == LayoutType.desktop) {
    showDoctorUpdateStatusDrawer(context, entry: entry);
    return;
  }

  if (screenType == LayoutType.tablet) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DoctorUpdateStatusTabletPage(entry: entry),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    return;
  }

  // Mobile (< 600): Open modal bottom sheet
  showDoctorUpdateStatusBottomSheet(context, entry: entry);
}

void showDoctorUpdateStatusDrawer(
  BuildContext context, {
  required QueueEntry entry,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x850F1F1D),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 16,
          color: Colors.transparent,
          child: DoctorUpdateStatusDrawer(entry: entry),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slideAnimation, child: child);
    },
  );
}

void showDoctorUpdateStatusBottomSheet(
  BuildContext context, {
  required QueueEntry entry,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    barrierColor: const Color(0x850F1F1D),
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return DoctorUpdateStatusBottomSheet(entry: entry);
    },
  );
}

/// Shared body content for Update Status across Desktop Drawer, Mobile Sheet, and Tablet Page.
class DoctorUpdateStatusContent extends StatefulWidget {
  const DoctorUpdateStatusContent({
    super.key,
    required this.entry,
    this.isTablet = false,
    required this.onStatusChanged,
    required this.initialStatus,
    required this.noteController,
  });

  final QueueEntry entry;
  final bool isTablet;
  final ValueChanged<DoctorPatientStatus> onStatusChanged;
  final DoctorPatientStatus initialStatus;
  final TextEditingController noteController;

  @override
  State<DoctorUpdateStatusContent> createState() =>
      _DoctorUpdateStatusContentState();
}

class _DoctorUpdateStatusContentState extends State<DoctorUpdateStatusContent> {
  late DoctorPatientStatus _selected = widget.initialStatus;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final nameParts = entry.patient.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (entry.patient.isNotEmpty ? entry.patient[0].toUpperCase() : 'JS');

    final subtitle = widget.isTablet
        ? '${entry.demographics} · Folder #SWC-10427'
        : '${entry.number} · ${entry.demographics} · Waiting ${entry.waitingMinutes} min · ${entry.reason.split('·').first.trim()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Patient banner card (soft mint matching designs)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandTint,
            borderRadius: BorderRadius.circular(Dimensions.radius),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.patient,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3 status selection cards
        for (final status in DoctorPatientStatus.values) ...[
          _buildStatusCard(status),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),

        // Note (optional)
        const Text(
          'Note (optional)',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.noteController,
          minLines: 3,
          maxLines: 4,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Add a note for the queue',
            hintStyle: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textDisabled,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(
                color: AppColors.brandPrimary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(DoctorPatientStatus status) {
    final isSelected = _selected == status;
    return InkWell(
      onTap: () {
        setState(() => _selected = status);
        widget.onStatusChanged(status);
      },
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandTint : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          border: Border.all(
            color: isSelected
                ? AppColors.brandPrimary
                : AppColors.borderDefault,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.title,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    status.description,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isSelected ? 'Selected' : 'Select',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: AppColors.brandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop: Side Drawer for Update Status.
class DoctorUpdateStatusDrawer extends StatefulWidget {
  const DoctorUpdateStatusDrawer({super.key, required this.entry});

  final QueueEntry entry;

  @override
  State<DoctorUpdateStatusDrawer> createState() =>
      _DoctorUpdateStatusDrawerState();
}

class _DoctorUpdateStatusDrawerState extends State<DoctorUpdateStatusDrawer> {
  late DoctorPatientStatus _status = DoctorPatientStatus.fromQueueStatus(
    widget.entry.status,
  );
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (Get.isRegistered<QueueController>()) {
      Get.find<QueueController>().updatePatientStatus(
        widget.entry.number,
        _status.queueStatus,
        _noteController.text.trim(),
      );
    }
    Navigator.of(context).pop();
    AppNotice.info(
      'Status updated',
      '${widget.entry.patient} marked as ${_status.title}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = screenWidth < 768
        ? (screenWidth * 0.85).clamp(320.0, 420.0)
        : (screenWidth < 1100 ? 430.0 : Dimensions.drawerWidth);

    return Container(
      width: drawerWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update status',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.entry.patient} · ${widget.entry.number}',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(
                    AppIcons.close,
                    size: Dimensions.iconSize,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderDefault,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: DoctorUpdateStatusContent(
                entry: widget.entry,
                isTablet: false,
                initialStatus: _status,
                noteController: _noteController,
                onStatusChanged: (s) => setState(() => _status = s),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderDefault, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                      foregroundColor: AppColors.brandPrimary,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Save status',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile: Modal Bottom Sheet for Update Status.
class DoctorUpdateStatusBottomSheet extends StatefulWidget {
  const DoctorUpdateStatusBottomSheet({super.key, required this.entry});

  final QueueEntry entry;

  @override
  State<DoctorUpdateStatusBottomSheet> createState() =>
      _DoctorUpdateStatusBottomSheetState();
}

class _DoctorUpdateStatusBottomSheetState
    extends State<DoctorUpdateStatusBottomSheet> {
  late DoctorPatientStatus _status = DoctorPatientStatus.fromQueueStatus(
    widget.entry.status,
  );
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (Get.isRegistered<QueueController>()) {
      Get.find<QueueController>().updatePatientStatus(
        widget.entry.number,
        _status.queueStatus,
        _noteController.text.trim(),
      );
    }
    Navigator.of(context).pop();
    AppNotice.info(
      'Status updated',
      '${widget.entry.patient} marked as ${_status.title}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Update status',
                          style: TextStyle(
                            fontFamily: AppTextStyles.headingFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.entry.patient} · ${widget.entry.number}',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      AppIcons.close,
                      size: Dimensions.iconSize,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: DoctorUpdateStatusContent(
                  entry: widget.entry,
                  isTablet: false,
                  initialStatus: _status,
                  noteController: _noteController,
                  onStatusChanged: (s) => setState(() => _status = s),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderDefault, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.borderDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusControl,
                          ),
                        ),
                        foregroundColor: AppColors.brandPrimary,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusControl,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Save status',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tablet: Dedicated Page for Update Status matching mockup.
class DoctorUpdateStatusTabletPage extends StatefulWidget {
  const DoctorUpdateStatusTabletPage({super.key, required this.entry});

  final QueueEntry entry;

  @override
  State<DoctorUpdateStatusTabletPage> createState() =>
      _DoctorUpdateStatusTabletPageState();
}

class _DoctorUpdateStatusTabletPageState
    extends State<DoctorUpdateStatusTabletPage> {
  late DoctorPatientStatus _status = DoctorPatientStatus.fromQueueStatus(
    widget.entry.status,
  );
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onPrimaryAction() {
    if (Get.isRegistered<QueueController>()) {
      Get.find<QueueController>().updatePatientStatus(
        widget.entry.number,
        _status.queueStatus,
        _noteController.text.trim(),
      );
    }
    Navigator.of(context).pop();
    AppNotice.info(
      'Status updated',
      '${widget.entry.patient} marked as ${_status.title}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TabletHeader(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginDesktop,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusControl,
                    ),
                    child: Container(
                      width: Dimensions.touchTarget,
                      height: Dimensions.touchTarget,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: const Center(
                        child: Icon(
                          AppIcons.chevronLeft,
                          size: Dimensions.iconSize,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.spaceMd),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Update status',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.entry.patient} · ${widget.entry.number}',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginDesktop,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.isTabletLandscape(context)
                          ? double.infinity
                          : 720,
                    ),
                    child: DoctorUpdateStatusContent(
                      entry: widget.entry,
                      isTablet: true,
                      initialStatus: _status,
                      noteController: _noteController,
                      onStatusChanged: (s) => setState(() => _status = s),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderDefault, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => openDoctorPatientProfile(
                      context: context,
                      entry: widget.entry,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                      foregroundColor: AppColors.brandPrimary,
                    ),
                    child: const Text(
                      'Open profile',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onPrimaryAction,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Save status',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Actions available when marking a patient unavailable.
enum UnavailableAction {
  returnToQueue(
    title: 'Return to queue',
    description: 'Call again later; patient keeps their place',
  ),
  markNoShow(
    title: 'Mark as no-show',
    description: "Remove from today's queue",
  );

  const UnavailableAction({required this.title, required this.description});
  final String title;
  final String description;
}

/// Responsive launcher for Doctor "Patient unavailable" view:
/// - Desktop (>= 1200): Dedicated side drawer (sliding from right)
/// - Tablet (600..1199): Dedicated page with header, content & cancel/confirm bar (no bottom nav)
/// - Mobile (< 600): Modal bottom sheet
void showDoctorMarkUnavailableView(
  BuildContext context, {
  required QueueEntry entry,
}) {
  final screenType = ResponsiveHelper.screenType(context);

  if (screenType == LayoutType.desktop) {
    showDoctorMarkUnavailableDrawer(context, entry: entry);
    return;
  }

  if (screenType == LayoutType.tablet) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DoctorMarkUnavailableTabletPage(entry: entry),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    return;
  }

  // Mobile (< 600): Open modal bottom sheet
  showDoctorMarkUnavailableBottomSheet(context, entry: entry);
}

void showDoctorMarkUnavailableDrawer(
  BuildContext context, {
  required QueueEntry entry,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x850F1F1D),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 16,
          color: Colors.transparent,
          child: DoctorMarkUnavailableDrawer(entry: entry),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slideAnimation, child: child);
    },
  );
}

void showDoctorMarkUnavailableBottomSheet(
  BuildContext context, {
  required QueueEntry entry,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    barrierColor: const Color(0x850F1F1D),
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return DoctorMarkUnavailableBottomSheet(entry: entry);
    },
  );
}

/// Shared body content for Patient Unavailable across Desktop Drawer, Mobile Sheet, and Tablet Page.
class DoctorMarkUnavailableContent extends StatelessWidget {
  const DoctorMarkUnavailableContent({
    super.key,
    required this.entry,
    required this.selectedAction,
    required this.onActionChanged,
    required this.reasonController,
  });

  final QueueEntry entry;
  final UnavailableAction selectedAction;
  final ValueChanged<UnavailableAction> onActionChanged;
  final TextEditingController reasonController;

  @override
  Widget build(BuildContext context) {
    final nameParts = entry.patient.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (entry.patient.isNotEmpty ? entry.patient[0].toUpperCase() : 'JS');

    final demo = entry.demographics
        .replaceAll('/M', ' / Male')
        .replaceAll('/F', ' / Female');
    final subtitle =
        '${entry.number.isNotEmpty ? '${entry.number} · ' : ''}$demo · Waiting ${entry.waitingMinutes} min · ${entry.reason.split('·').first.trim()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Patient banner card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandTint,
            borderRadius: BorderRadius.circular(Dimensions.radius),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.patient,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action cards
        for (final action in UnavailableAction.values) ...[
          _buildActionCard(action),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),

        // Reason field
        const Text(
          'Reason',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: reasonController,
          minLines: 3,
          maxLines: 4,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFamily,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Reason for unavailability',
            hintStyle: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              color: AppColors.textDisabled,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              borderSide: const BorderSide(
                color: AppColors.brandPrimary,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Blue reception notice banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.feedbackInfoTint,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.syncSyncing),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reception is notified of the change.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.syncSyncing,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(UnavailableAction action) {
    final isSelected = selectedAction == action;
    return InkWell(
      onTap: () => onActionChanged(action),
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandTint : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          border: Border.all(
            color: isSelected
                ? AppColors.brandPrimary
                : AppColors.borderDefault,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.description,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isSelected ? 'Selected' : 'Select',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: AppColors.brandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop: Side Drawer for Patient Unavailable.
class DoctorMarkUnavailableDrawer extends StatefulWidget {
  const DoctorMarkUnavailableDrawer({super.key, required this.entry});

  final QueueEntry entry;

  @override
  State<DoctorMarkUnavailableDrawer> createState() =>
      _DoctorMarkUnavailableDrawerState();
}

class _DoctorMarkUnavailableDrawerState
    extends State<DoctorMarkUnavailableDrawer> {
  UnavailableAction _action = UnavailableAction.returnToQueue;
  final TextEditingController _reasonController = TextEditingController(
    text: 'Not in waiting area when called',
  );

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final controller = Get.isRegistered<QueueController>()
        ? Get.find<QueueController>()
        : null;
    if (_action == UnavailableAction.returnToQueue) {
      controller?.returnPatientToQueue(
        widget.entry.number,
        _reasonController.text.trim(),
      );
      AppNotice.info(
        'Return to queue',
        '${widget.entry.patient} returned to queue',
      );
    } else {
      controller?.markPatientNoShow(
        widget.entry.number,
        _reasonController.text.trim(),
      );
      AppNotice.info(
        'Marked as no-show',
        '${widget.entry.patient} removed from today’s queue',
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = screenWidth < 768
        ? (screenWidth * 0.85).clamp(320.0, 420.0)
        : (screenWidth < 1100 ? 430.0 : Dimensions.drawerWidth);

    return Container(
      width: drawerWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient unavailable',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.entry.patient} · ${widget.entry.number} · called once',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(
                    AppIcons.close,
                    size: Dimensions.iconSize,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderDefault,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: DoctorMarkUnavailableContent(
                entry: widget.entry,
                selectedAction: _action,
                onActionChanged: (a) => setState(() => _action = a),
                reasonController: _reasonController,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderDefault, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                      foregroundColor: AppColors.brandPrimary,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onConfirm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile: Modal Bottom Sheet for Patient Unavailable.
class DoctorMarkUnavailableBottomSheet extends StatefulWidget {
  const DoctorMarkUnavailableBottomSheet({super.key, required this.entry});

  final QueueEntry entry;

  @override
  State<DoctorMarkUnavailableBottomSheet> createState() =>
      _DoctorMarkUnavailableBottomSheetState();
}

class _DoctorMarkUnavailableBottomSheetState
    extends State<DoctorMarkUnavailableBottomSheet> {
  UnavailableAction _action = UnavailableAction.returnToQueue;
  final TextEditingController _reasonController = TextEditingController(
    text: 'Not in waiting area when called',
  );

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final controller = Get.isRegistered<QueueController>()
        ? Get.find<QueueController>()
        : null;
    if (_action == UnavailableAction.returnToQueue) {
      controller?.updatePatientStatus(
        widget.entry.number,
        QueueStatus.waitingForDoctor,
        _reasonController.text.trim(),
      );
      AppNotice.info(
        'Call patient',
        '${widget.entry.patient} called to consultation room',
      );
    } else {
      controller?.markPatientNoShow(
        widget.entry.number,
        _reasonController.text.trim(),
      );
      AppNotice.info(
        'Marked as no-show',
        '${widget.entry.patient} removed from today’s queue',
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Patient unavailable',
                          style: TextStyle(
                            fontFamily: AppTextStyles.headingFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.entry.patient} · ${widget.entry.number}',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      AppIcons.close,
                      size: Dimensions.iconSize,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: DoctorMarkUnavailableContent(
                  entry: widget.entry,
                  selectedAction: _action,
                  onActionChanged: (a) => setState(() => _action = a),
                  reasonController: _reasonController,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderDefault, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.borderDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusControl,
                          ),
                        ),
                        foregroundColor: AppColors.brandPrimary,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusControl,
                          ),
                        ),
                      ),
                      child: Text(
                        _action == UnavailableAction.returnToQueue
                            ? 'Call patient'
                            : 'Confirm',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tablet: Dedicated Page for Patient Unavailable.
class DoctorMarkUnavailableTabletPage extends StatefulWidget {
  const DoctorMarkUnavailableTabletPage({super.key, required this.entry});

  final QueueEntry entry;

  @override
  State<DoctorMarkUnavailableTabletPage> createState() =>
      _DoctorMarkUnavailableTabletPageState();
}

class _DoctorMarkUnavailableTabletPageState
    extends State<DoctorMarkUnavailableTabletPage> {
  UnavailableAction _action = UnavailableAction.returnToQueue;
  final TextEditingController _reasonController = TextEditingController(
    text: 'Not in waiting area when called',
  );

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final controller = Get.isRegistered<QueueController>()
        ? Get.find<QueueController>()
        : null;
    if (_action == UnavailableAction.returnToQueue) {
      controller?.returnPatientToQueue(
        widget.entry.number,
        _reasonController.text.trim(),
      );
      AppNotice.info(
        'Return to queue',
        '${widget.entry.patient} returned to queue',
      );
    } else {
      controller?.markPatientNoShow(
        widget.entry.number,
        _reasonController.text.trim(),
      );
      AppNotice.info(
        'Marked as no-show',
        '${widget.entry.patient} removed from today’s queue',
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TabletHeader(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.pageMarginDesktop,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusControl,
                    ),
                    child: Container(
                      width: Dimensions.touchTarget,
                      height: Dimensions.touchTarget,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: const Center(
                        child: Icon(
                          AppIcons.chevronLeft,
                          size: Dimensions.iconSize,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.spaceMd),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient unavailable',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.entry.patient} · ${widget.entry.number}',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginDesktop,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.isTabletLandscape(context)
                          ? double.infinity
                          : 720,
                    ),
                    child: DoctorMarkUnavailableContent(
                      entry: widget.entry,
                      selectedAction: _action,
                      onActionChanged: (a) => setState(() => _action = a),
                      reasonController: _reasonController,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderDefault, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                      foregroundColor: AppColors.brandPrimary,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onConfirm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusControl,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
