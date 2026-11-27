import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/widgets/common/app_data_table.dart';
import 'package:tendryn/widgets/common/app_search_field.dart';

/// Patient item model for the Nurse Patients directory.
class NursePatientRecord {
  const NursePatientRecord({
    required this.name,
    required this.patientId,
    required this.sex,
    required this.age,
    required this.lastVisit,
    required this.queueNumber,
    required this.reason,
    this.priority = QueuePriority.routine,
    this.status = QueueStatus.waiting,
  });

  final String name;
  final String patientId;
  final String sex;
  final int age;
  final String lastVisit;
  final String queueNumber;
  final String reason;
  final QueuePriority priority;
  final QueueStatus status;

  QueueEntry toQueueEntry() => QueueEntry(
        number: queueNumber,
        patient: name,
        arrival: '08:42',
        waitingMinutes: 24,
        reason: reason,
        priority: priority,
        status: status,
        practitioner: 'Dr Thandi Nkosi',
        demographics: '$age/${sex.startsWith('M') ? 'M' : 'F'}',
      );
}

// ----------------------------------------------------------------- mobile

/// Mobile layout (Figma: 393px) for Nurse Patients directory.
class PatientsNurseMobile extends GetView<PatientsController> {
  const PatientsNurseMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginMobile),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Patients',
            style: AppTextStyles.h2Bold.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Search patient records and open a profile.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: Dimensions.spaceLg),
        _NurseSearchToolbar(onChanged: controller.search),
        const SizedBox(height: Dimensions.spaceLg),
        Obx(() {
          final rows = controller.filteredNursePatients;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All patients',
                    style: TextStyle(
                      fontFamily: AppTextStyles.headingFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  Text(
                    '${rows.length} patients',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      color: Color(0xFF535F69),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.spaceSm),
              for (final patient in rows) ...[
                NursePatientCard(
                  patient: patient,
                  onViewProfile: () => controller.openNursePatient(patient),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              const _MobilePaginationButtons(),
            ],
          );
        }),
      ],
    );
  }
}

// ----------------------------------------------------------------- tablet

/// Tablet layout (Figma: 744px) for Nurse Patients directory.
class PatientsNurseTablet extends GetView<PatientsController> {
  const PatientsNurseTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginTablet),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Patients',
            style: AppTextStyles.h2Bold.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Search patient records and open a profile.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: Dimensions.spaceLg),
        _NurseSearchToolbar(onChanged: controller.search),
        const SizedBox(height: Dimensions.spaceLg),
        Obx(() {
          final rows = controller.filteredNursePatients;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All patients',
                    style: TextStyle(
                      fontFamily: AppTextStyles.headingFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  Text(
                    '${rows.length} patients',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      color: Color(0xFF535F69),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.spaceSm),
              for (int i = 0; i < rows.length; i += 2) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: NursePatientCard(
                        patient: rows[i],
                        onViewProfile: () => controller.openNursePatient(rows[i]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: i + 1 < rows.length
                          ? NursePatientCard(
                              patient: rows[i + 1],
                              onViewProfile: () =>
                                  controller.openNursePatient(rows[i + 1]),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: Dimensions.spaceSm),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing 1–5 of 24 patients',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13,
                      color: Color(0xFF535F69),
                    ),
                  ),
                  _PaginationControls(),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------- desktop

/// Desktop layout (Figma: 1280px) for Nurse Patients directory.
class PatientsNurseDesktop extends GetView<PatientsController> {
  const PatientsNurseDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
      children: [
        Semantics(
          header: true,
          child: Text(
            'Patients',
            style: AppTextStyles.h2Bold.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Search patient records and open a profile.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: Dimensions.spaceLg),
        _NurseSearchToolbar(onChanged: controller.search),
        const SizedBox(height: Dimensions.spaceLg),
        Container(
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
                  child: Row(
                    children: [
                      Text(
                        'All patients',
                        style: AppTextStyles.h3.copyWith(color: scheme.onSurface),
                      ),
                      const Spacer(),
                      Obx(() {
                        final count = controller.filteredNursePatients.length;
                        return Text(
                          '$count ${count == 1 ? 'patient' : 'patients'}',
                          style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Obx(() {
                final rows = controller.filteredNursePatients;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppDataTable<NursePatientRecord>(
                      horizontalPadding: Dimensions.spaceMd,
                      columnGap: Dimensions.spaceMd,
                      rowMinHeight: Dimensions.queueRowMinHeight,
                      minWidth: 860,
                      distributeColumnWidths: true,
                      onRowTap: (patient) => controller.openNursePatient(patient),
                      rows: rows,
                      columns: _columns(scheme),
                    ),
                    if (rows.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No patients found',
                            style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                  ],
                );
              }),
              Padding(
                padding: const EdgeInsets.all(Dimensions.spaceMd),
                child: SizedBox(
                  height: Dimensions.touchTarget,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Showing 1–5 of 24 patients',
                          style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      const _PaginationControls(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<AppTableColumn<NursePatientRecord>> _columns(ColorScheme scheme) => [
        AppTableColumn(
          label: 'Patient',
          width: 180,
          cell: (_, e) => Text(
            e.name,
            style: AppTextStyles.label.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn(
          label: 'Patient ID',
          width: 150,
          cell: (_, e) => Text(
            e.patientId,
            style: AppTextStyles.body.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn(
          label: 'Sex · Age',
          width: 150,
          cell: (_, e) => Text(
            '${e.sex} · ${e.age} yrs',
            style: AppTextStyles.body.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn(
          label: 'Last visit',
          width: 210,
          cell: (_, e) => Text(
            e.lastVisit,
            style: AppTextStyles.body.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppTableColumn(
          label: 'Actions',
          width: 120,
          cell: (_, e) => InkWell(
            onTap: () => controller.openNursePatient(e),
            child: Text(
              'View profile',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ];
}

// ----------------------------------------------------------- shared widgets

/// Card used in mobile (1-col) and tablet (2-col grid). Matches Figma design.
class NursePatientCard extends StatelessWidget {
  const NursePatientCard({
    super.key,
    required this.patient,
    required this.onViewProfile,
  });

  final NursePatientRecord patient;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'View profile for ${patient.name}',
      child: Material(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppColors.brandTint.withValues(alpha: 0.1),
          onTap: onViewProfile,
          child: Container(
            decoration: BoxDecoration(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        patient.name,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.headingFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1C1E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onViewProfile,
                      borderRadius: BorderRadius.circular(4),
                      child: const Text(
                        'View profile',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${patient.patientId} · ${patient.sex} · ${patient.age} yrs',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13,
                    color: Color(0xFF535F69),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderDefault,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Last visit',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFamily,
                        fontSize: 13,
                        color: Color(0xFF535F69),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        patient.lastVisit,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NurseSearchToolbar extends StatelessWidget {
  const _NurseSearchToolbar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: AppSearchField(
            hint: 'Search name, ID or queue number',
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

class _PaginationControls extends StatefulWidget {
  const _PaginationControls();

  @override
  State<_PaginationControls> createState() => _PaginationControlsState();
}

class _PaginationControlsState extends State<_PaginationControls> {
  int _activePage = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        _NursePageBlock(
          label: 'Previous',
          width: 88,
          enabled: true,
          onTap: () {
            setState(() {
              if (_activePage > 1) {
                _activePage--;
              }
            });
          },
        ),
        _NursePageBlock(
          label: '1',
          width: 40,
          selected: _activePage == 1,
          onTap: () => setState(() => _activePage = 1),
        ),
        _NursePageBlock(
          label: '2',
          width: 40,
          selected: _activePage == 2,
          onTap: () => setState(() => _activePage = 2),
        ),
        _NursePageBlock(
          label: '3',
          width: 40,
          selected: _activePage == 3,
          onTap: () => setState(() => _activePage = 3),
        ),
        _NursePageBlock(
          label: '...',
          width: 40,
          enabled: true,
          onTap: () => setState(() => _activePage =
              _activePage <= 3 ? 4 : (_activePage == 10 ? 9 : _activePage)),
        ),
        _NursePageBlock(
          label: '10',
          width: 44,
          selected: _activePage == 10,
          onTap: () => setState(() => _activePage = 10),
        ),
        _NursePageBlock(
          label: 'Next',
          width: 66,
          enabled: true,
          onTap: () {
            setState(() {
              if (_activePage < 10) {
                _activePage++;
              }
            });
          },
        ),
      ],
    );
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

class _MobilePaginationButtons extends StatefulWidget {
  const _MobilePaginationButtons();

  @override
  State<_MobilePaginationButtons> createState() => _MobilePaginationButtonsState();
}

class _MobilePaginationButtonsState extends State<_MobilePaginationButtons> {
  int _activePage = 1;
  static const int _totalPages = 5;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Dimensions.spaceSm,
      children: [
        Expanded(
          child: _MobileButton(
            label: 'Previous',
            onTap: () {
              if (_activePage > 1) {
                setState(() {
                  _activePage--;
                });
              }
            },
          ),
        ),
        Expanded(
          child: _MobileButton(
            label: 'Next',
            onTap: () {
              if (_activePage < _totalPages) {
                setState(() {
                  _activePage++;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}

class _MobileButton extends StatefulWidget {
  const _MobileButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  State<_MobileButton> createState() => _MobileButtonState();
}

class _MobileButtonState extends State<_MobileButton> {
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
