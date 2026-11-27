import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/vitals_triage/controllers/vitals_triage_controller.dart';
import 'package:tendryn/features/vitals_triage/models/vitals_triage_model.dart';
import 'package:tendryn/widgets/common/app_action_menu.dart';
import 'package:tendryn/widgets/common/app_search_field.dart';

// ----------------------------------------------------------------- Badges

/// Status badge pill matching Figma Vitals & Triage designs.
class VitalsTriageStatusBadge extends StatelessWidget {
  const VitalsTriageStatusBadge({super.key, required this.status});

  final VitalsTriageStatus status;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, border) = switch (status) {
      VitalsTriageStatus.waiting => (
          const Color(0xFFFFF7ED),
          const Color(0xFFC25E00),
          null,
        ),
      VitalsTriageStatus.waitingForDoctor => (
          const Color(0xFFE6F4F2),
          const Color(0xFF006970),
          null,
        ),
      VitalsTriageStatus.withDoctor => (
          const Color(0xFFEFF6FF),
          const Color(0xFF2563EB),
          null,
        ),
      VitalsTriageStatus.payment => (
          const Color(0xFFF8FAFC),
          const Color(0xFF475569),
          Border.all(color: const Color(0xFFDDE7E5), width: 1),
        ),
      VitalsTriageStatus.done => (
          const Color(0xFFECFDF5),
          const Color(0xFF059669),
          null,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: border,
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.25,
        ),
      ),
    );
  }
}

/// Priority tag with coloured dot indicator matching Figma.
class VitalsTriagePriorityTag extends StatelessWidget {
  const VitalsTriagePriorityTag({super.key, required this.priority});

  final QueuePriority priority;

  @override
  Widget build(BuildContext context) {
    final (dotColor, label) = switch (priority) {
      QueuePriority.routine => (const Color(0xFF10B981), 'Routine'),
      QueuePriority.urgent => (const Color(0xFFF59E0B), 'Urgent'),
      QueuePriority.emergency => (const Color(0xFFEF4444), 'Emergency'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1E),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- 3-Dots Action Menu

/// Popup menu button providing 'View Patient' and 'Begin Triage'.
class VitalsTriageActionMenu extends StatelessWidget {
  const VitalsTriageActionMenu({
    super.key,
    required this.entry,
    this.inCard = false,
  });

  final VitalsTriageEntry entry;
  final bool inCard;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VitalsTriageController>();

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
      child: PopupMenuButton<String>(
        tooltip: 'Actions for ${entry.patientName}',
        position: PopupMenuPosition.under,
        offset: const Offset(0, 4),
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 6,
        shadowColor: const Color(0x1F000000),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        constraints: const BoxConstraints.tightFor(width: 212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault, width: 1),
        ),
        itemBuilder: (context) => [
          const AppActionMenuItem<String>(
            value: 'view',
            label: 'View Patient',
            alignment: Alignment.center,
          ),
          const AppActionMenuItem<String>(
            value: 'triage',
            label: 'Begin Triage',
            alignment: Alignment.center,
          ),
        ],
        onSelected: (value) {
          if (value == 'view') {
            controller.openPatient(entry);
          } else if (value == 'triage') {
            controller.beginTriage(entry);
          }
        },
        child: const AppActionsBoxButton(
          icon: Icons.more_vert,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- Card (Mobile & Tablet)

/// Card layout used in mobile (1-col) and tablet (2-col grid).
class VitalsTriageCard extends StatelessWidget {
  const VitalsTriageCard({
    super.key,
    required this.entry,
  });

  final VitalsTriageEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDefault,
          width: Dimensions.strokeDivider,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Patient Name, Demographics, and 3-dots Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.patientName,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1C1E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.demographics,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        color: Color(0xFF535F69),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              VitalsTriageActionMenu(entry: entry, inCard: true),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderDefault,
          ),
          const SizedBox(height: 12),
          // Middle Row 1: Queue number & Waiting time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.queueNumber,
                style: const TextStyle(
                  fontFamily: AppTextStyles.headingFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Waiting ',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      color: Color(0xFF535F69),
                    ),
                  ),
                  Text(
                    entry.waitingTime,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Middle Row 2: Reason label & Reason value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reason',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 13,
                  color: Color(0xFF535F69),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.reason,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1C1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Bottom Row: Status Badge & Priority Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VitalsTriageStatusBadge(status: entry.status),
              VitalsTriagePriorityTag(priority: entry.priority),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- Table (Desktop)

/// Desktop Table matching Figma design `media_1794393753227_932b9fa1.jpg`.
class VitalsTriageTable extends StatelessWidget {
  const VitalsTriageTable({super.key, required this.entries});

  final List<VitalsTriageEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header matching Figma proportions & subtle background
        Container(
          constraints: const BoxConstraints(minHeight: Dimensions.tableHeaderHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            color: AppColors.backgroundApp,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderDefault,
                width: 1,
              ),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 70,
                child: Text(
                  'Queue',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF535F69),
                  ),
                ),
              ),
              Expanded(
                flex: 170,
                child: Text(
                  'Patient',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF535F69),
                  ),
                ),
              ),
              Expanded(
                flex: 85,
                child: Text(
                  'Waiting',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF535F69),
                  ),
                ),
              ),
              Expanded(
                flex: 145,
                child: Text(
                  'Reason',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF535F69),
                  ),
                ),
              ),
              Expanded(
                flex: 145,
                child: Text(
                  'Status',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF535F69),
                  ),
                ),
              ),
              Expanded(
                flex: 125,
                child: Text(
                  'Priority',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF535F69),
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  'Actions',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF535F69),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Rows
        for (final entry in entries) _VitalsTriageTableRow(entry: entry),
      ],
    );
  }
}

class _VitalsTriageTableRow extends StatelessWidget {
  const _VitalsTriageTableRow({required this.entry});

  final VitalsTriageEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
      ),
      child: Row(
          children: [
            // Queue Number
            Expanded(
              flex: 70,
              child: Text(
                entry.queueNumber,
                style: const TextStyle(
                  fontFamily: AppTextStyles.headingFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C1E),
                ),
              ),
            ),
            // Patient Name & Demographics
            Expanded(
              flex: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entry.patientName,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.headingFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.demographics,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 12,
                      color: Color(0xFF535F69),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Waiting Time
            Expanded(
              flex: 85,
              child: Text(
                entry.waitingTime,
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  color: Color(0xFF1A1C1E),
                ),
              ),
            ),
            // Reason
            Expanded(
              flex: 145,
              child: Text(
                entry.reason,
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  fontSize: 14,
                  color: Color(0xFF1A1C1E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Status
            Expanded(
              flex: 145,
              child: Align(
                alignment: Alignment.centerLeft,
                child: VitalsTriageStatusBadge(status: entry.status),
              ),
            ),
            // Priority
            Expanded(
              flex: 125,
              child: Align(
                alignment: Alignment.centerLeft,
                child: VitalsTriagePriorityTag(priority: entry.priority),
              ),
            ),
            // Actions (3-dots)
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.centerRight,
                child: VitalsTriageActionMenu(entry: entry),
              ),
            ),
          ],
        ),
      );
  }
}

// ------------------------------------------------------------- Search & Filter Toolbar

/// Search and filter toolbar matching Figma input with trailing filter icon button.
class VitalsTriageSearchToolbar extends StatelessWidget {
  const VitalsTriageSearchToolbar({
    super.key,
    required this.onChanged,
    this.hint = 'Search patients by name or ID',
  });

  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: AppSearchField(
            hint: hint,
            onChanged: onChanged,
            hintStyle: AppTextStyles.label.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            border: Border.all(
              color: scheme.outline,
              width: Dimensions.strokeDivider,
            ),
          ),
          child: Center(
            child: Icon(AppIcons.filter, size: 22, color: scheme.primary),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- Pagination Controls

/// Pagination bar for Tablet and Desktop.
class VitalsTriagePagination extends StatelessWidget {
  const VitalsTriagePagination({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VitalsTriageController>();

    return Obx(() {
      final active = controller.activePage.value;
      final totalPages = controller.totalPages.value;

      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          _PageBlock(
            label: 'Previous',
            width: 88,
            enabled: active > 1,
            onTap: controller.previousPage,
          ),
          _PageBlock(
            label: '1',
            width: 40,
            selected: active == 1,
            onTap: () => controller.selectPage(1),
          ),
          _PageBlock(
            label: '2',
            width: 40,
            selected: active == 2,
            onTap: () => controller.selectPage(2),
          ),
          _PageBlock(
            label: '3',
            width: 40,
            selected: active == 3,
            onTap: () => controller.selectPage(3),
          ),
          const _PageBlock(
            label: '...',
            width: 40,
            enabled: false,
          ),
          _PageBlock(
            label: '10',
            width: 44,
            selected: active == 10,
            onTap: () => controller.selectPage(10),
          ),
          _PageBlock(
            label: 'Next',
            width: 66,
            enabled: active < totalPages,
            onTap: controller.nextPage,
          ),
        ],
      );
    });
  }
}

class _PageBlock extends StatefulWidget {
  const _PageBlock({
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
  State<_PageBlock> createState() => _PageBlockState();
}

class _PageBlockState extends State<_PageBlock> {
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
        width: 1,
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
        if (enabled) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (enabled) setState(() => _hovered = false);
      },
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Material(
        color: bgColor,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: enabled ? widget.onTap : null,
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

/// Mobile pagination with full-width Previous and Next buttons matching Queue.
class VitalsTriageMobilePagination extends StatelessWidget {
  const VitalsTriageMobilePagination({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VitalsTriageController>();

    return Obx(() {
      final active = controller.activePage.value;
      final totalPages = controller.totalPages.value;

      return Row(
        spacing: Dimensions.spaceSm,
        children: [
          Expanded(
            child: _MobileNavButton(
              label: 'Previous',
              onTap: () {
                if (active > 1) {
                  controller.previousPage();
                }
              },
            ),
          ),
          Expanded(
            child: _MobileNavButton(
              label: 'Next',
              onTap: () {
                if (active < totalPages) {
                  controller.nextPage();
                }
              },
            ),
          ),
        ],
      );
    });
  }
}

class _MobileNavButton extends StatefulWidget {
  const _MobileNavButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<_MobileNavButton> createState() => _MobileNavButtonState();
}

class _MobileNavButtonState extends State<_MobileNavButton> {
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
