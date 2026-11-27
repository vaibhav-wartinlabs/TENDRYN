import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/features/queue/widgets/queue_table.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_action_menu.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/app_search_field.dart';

/// The headline figures. Desktop: three cards with a detail line. Tablet: four
/// cards in a row. Mobile: four compact cards, two per row.
class PatientsSummary extends StatelessWidget {
  const PatientsSummary({super.key, required this.screenType});

  final LayoutType screenType;

  @override
  Widget build(BuildContext context) {
    const total = (
      'Total patients',
      PatientsController.totalPatients,
      'Records in this clinic',
    );
    const seen = (
      'Recently seen',
      PatientsController.recentlySeen,
      'Patients seen today',
    );
    const queue = (
      'In queue',
      PatientsController.inQueue,
      'Open queue records',
    );
    const added = ('Recently added', PatientsController.recentlyAdded, null);

    Widget card((String, String, String?) c) => Expanded(
      child: _SummaryCard(
        label: c.$1,
        value: c.$2,
        detail: c.$3,
        compact: screenType == LayoutType.mobile,
      ),
    );

    if (screenType == LayoutType.mobile) {
      return Column(
        spacing: 10,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [card(total), card(seen)],
            ),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [card(queue), card(added)],
            ),
          ),
        ],
      );
    }
    final cards = [
      card(total),
      card(seen),
      card(queue),
      if (screenType == LayoutType.tablet) card(added),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (screenType == LayoutType.tablet && constraints.maxWidth < 900) {
          return Column(
            spacing: Dimensions.spaceMd,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Dimensions.spaceMd,
                  children: cards.take(2).toList(),
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Dimensions.spaceMd,
                  children: cards.skip(2).toList(),
                ),
              ),
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Dimensions.spaceMd,
            children: cards,
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.compact,
  });

  final String label;
  final String value;
  final String? detail;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: compact ? 74 : 112),
      child: AppCard(
        padding: EdgeInsets.all(compact ? 10 : Dimensions.spaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: compact ? 3 : 6,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              value,
              style: AppTextStyles.tabular(
                compact ? AppTextStyles.h3Mobile : AppTextStyles.h3,
              ).copyWith(color: scheme.onSurface),
            ),
            if (detail != null)
              Text(
                detail!,
                style: AppTextStyles.caption.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Search box plus the filter button (desktop and tablet). The design defines
/// no filter options, so the button is display-only.
class PatientsToolbar extends GetView<PatientsController> {
  const PatientsToolbar({
    super.key,
    required this.hint,
    this.showFilter = true,
  });

  final String hint;
  final bool showFilter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      spacing: Dimensions.statusX,
      children: [
        Expanded(
          child: AppSearchField(
            hint: hint,
            onChanged: controller.search,
            hintStyle: AppTextStyles.label.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        if (showFilter)
          Container(
            width: 51,
            height: Dimensions.touchTarget,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              border: Border.all(
                color: scheme.outline,
                width: Dimensions.strokeDivider,
              ),
            ),
            child: Icon(AppIcons.filter, size: 24, color: scheme.primary),
          ),
      ],
    );
  }
}

/// Patient summary card used only by the doctor's responsive directory.
class DoctorPatientDirectoryCard extends StatelessWidget {
  const DoctorPatientDirectoryCard({
    super.key,
    required this.patient,
    required this.onViewProfile,
    this.showActionMenu = false,
  });

  final PatientRecord patient;
  final VoidCallback onViewProfile;
  final bool showActionMenu;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.spaceMd,
        vertical: Dimensions.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  patient.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showActionMenu)
                _DoctorPatientCompactActionMenu(
                  patient: patient,
                  onViewProfile: onViewProfile,
                )
              else
                TextButton(
                  onPressed: onViewProfile,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, Dimensions.buttonMinHeight),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.controlX,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View Profile',
                    style: AppTextStyles.label.copyWith(color: scheme.primary),
                  ),
                ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: Dimensions.spaceSm),
          _DoctorPatientInfoRow(
            label: 'File Number',
            value: patient.fileNumber,
          ),
          const SizedBox(height: Dimensions.spaceXs),
          _DoctorPatientInfoRow(label: 'Last Visit', value: patient.lastVisit),
          const SizedBox(height: Dimensions.spaceXs),
          _DoctorPatientInfoRow(
            label: 'Care Flag',
            value: patient.careFlags ?? '—',
          ),
        ],
      ),
    );
  }
}

class _DoctorPatientCompactActionMenu extends StatelessWidget {
  const _DoctorPatientCompactActionMenu({
    required this.patient,
    required this.onViewProfile,
  });

  final PatientRecord patient;
  final VoidCallback onViewProfile;

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
      child: PopupMenuButton<String>(
        tooltip: 'Actions for ${patient.name}',
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 6,
        shadowColor: const Color(0x1F000000),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        constraints: const BoxConstraints.tightFor(width: 212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        onSelected: (action) {
          if (action == 'profile') {
            onViewProfile();
          } else {
            AppNavigation.goToConsultationWorkspace(
              returnRoute: AppRoutes.patients,
              patient: patient,
            );
          }
        },
        itemBuilder: (_) => [
          const AppActionMenuItem<String>(
            value: 'profile',
            label: 'View Profile',
            alignment: Alignment.center,
          ),
          const AppActionMenuItem<String>(
            value: 'consultation',
            label: 'Start Consultation',
            alignment: Alignment.center,
          ),
        ],
        child: const AppActionsBoxButton(icon: Icons.more_vert),
      ),
    );
  }
}

class _DoctorPatientInfoRow extends StatelessWidget {
  const _DoctorPatientInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown when nothing matches the search.
class PatientsEmptyState extends StatelessWidget {
  const PatientsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.spaceXl),
      child: Center(
        child: Text(
          'No patients match your search.',
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Range and page controls for the doctor's patient directory.
class DoctorPatientPagination extends StatefulWidget {
  const DoctorPatientPagination({
    super.key,
    this.showRange = true,
    this.demoOnly = false,
    this.alignment = Alignment.center,
  });

  final bool showRange;
  final AlignmentGeometry alignment;

  /// Displays reference values; taps move highlight without changing records.
  final bool demoOnly;

  @override
  State<DoctorPatientPagination> createState() =>
      _DoctorPatientPaginationState();
}

class _DoctorPatientPaginationState extends State<DoctorPatientPagination> {
  int _demoPage = 1;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = Get.find<PatientsController>();
    return Obx(() {
      final actualPage = controller.page.value;
      final current = widget.demoOnly ? _demoPage : actualPage;
      final count = widget.demoOnly ? 10 : controller.pageCount;
      final visiblePages = _visiblePages(count, current);

      void selectPage(int page) {
        if (widget.demoOnly) {
          setState(() => _demoPage = page);
        } else {
          controller.goToPage(page);
        }
      }

      final controls = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: current > 1 ? () => selectPage(current - 1) : null,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, Dimensions.buttonMinHeight),
              foregroundColor: widget.demoOnly ? scheme.onSurfaceVariant : null,
            ),
            child: const Text('Previous'),
          ),
          for (final page in visiblePages)
            if (page == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '…',
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TextButton(
                  onPressed: () => selectPage(page),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      Dimensions.touchTarget,
                      Dimensions.buttonMinHeight,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.controlX,
                    ),
                    backgroundColor: current == page
                        ? scheme.primary
                        : Colors.transparent,
                    foregroundColor: current == page
                        ? Colors.white
                        : scheme.onSurface,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('$page'),
                ),
              ),
          TextButton(
            onPressed: current < count ? () => selectPage(current + 1) : null,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, Dimensions.buttonMinHeight),
              foregroundColor: widget.demoOnly ? scheme.onSurfaceVariant : null,
            ),
            child: const Text('Next'),
          ),
        ],
      );

      if (!widget.showRange) {
        return Align(
          alignment: widget.alignment,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: controls,
          ),
        );
      }
      return Row(
        children: [
          Expanded(
            child: Text(
              widget.demoOnly
                  ? 'Showing 1–5 of 24 patients'
                  : controller.rangeLabel,
              style: AppTextStyles.caption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: controls,
              ),
            ),
          ),
        ],
      );
    });
  }

  List<int?> _visiblePages(int count, int current) {
    if (count <= 5) return List<int?>.generate(count, (index) => index + 1);
    if (current <= 3) return <int?>[1, 2, 3, null, count];
    if (current >= count - 2) {
      return <int?>[1, null, count - 2, count - 1, count];
    }
    return <int?>[1, null, current - 1, current, current + 1, null, count];
  }
}

/// "Showing 1–4 of 4 patients" with previous / page / next buttons.
class PatientsPagination extends GetView<PatientsController> {
  const PatientsPagination({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 80,
      color: Theme.of(context).scaffoldBackgroundColor,
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
