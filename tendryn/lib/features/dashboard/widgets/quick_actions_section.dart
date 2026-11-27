import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_breakpoints.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/app_search_field.dart';

/// One quick action's content; the tap behaviour lives in the controller.
class QuickActionSpec {
  const QuickActionSpec(this.kind, this.icon, this.title, this.description);

  final QuickActionKind kind;
  final IconData icon;
  final String title;
  final String description;
}

const _actions = [
  QuickActionSpec(
    QuickActionKind.addWalkIn,
    AppIcons.addWalkIn,
    'Add Walk-in',
    'Find or register, then add to today’s queue',
  ),
  QuickActionSpec(
    QuickActionKind.registerPatient,
    AppIcons.registerPatient,
    'Register Patient',
    'Create a new patient record',
  ),
  QuickActionSpec(
    QuickActionKind.bookAppointment,
    AppIcons.bookAppointment,
    'Book Appointment',
    'Schedule a future visit',
  ),
  QuickActionSpec(
    QuickActionKind.takePayment,
    AppIcons.takePayment,
    'Take Payment',
    'Record a patient payment',
  ),
];

/// Find Patient search plus the four quick actions.
/// When search bar is tapped/active, search results overlay appears in a Stack on top of the content.
/// Otherwise, all 4 quick action options are displayed.
class QuickActionsSection extends GetView<DashboardController> {
  const QuickActionsSection({
    super.key,
    this.columns = 1,
    this.titleStyle,
    this.hintStyle,
    this.searchHint,
  });

  final int columns;

  /// Section title style; mobile uses the 20px H3, as in Figma.
  final TextStyle? titleStyle;

  /// Search hint style; the tablet frame uses 14/20 Medium, the others the 12px caption.
  final TextStyle? hintStyle;

  /// Search hint override (e.g. mobile frame displays 'Thabo').
  final String? searchHint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMobile = columns == 1 && MediaQuery.sizeOf(context).width < ResponsiveBreakpoints.tablet;

    final tiles = [
      for (final a in _actions)
        QuickActionTile(
          spec: a,
          onTap: () => controller.openQuickAction(a.kind),
        ),
    ];

    Widget buildTiles() {
      if (columns == 1) {
        return Column(
          spacing: Dimensions.spaceMd,
          children: tiles,
        );
      }
      return Column(
        spacing: Dimensions.spaceMd,
        children: [
          for (var i = 0; i < tiles.length; i += columns)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Dimensions.spaceMd,
                children: [
                  for (final t in tiles.skip(i).take(columns))
                    Expanded(child: t),
                ],
              ),
            ),
        ],
      );
    }

    Widget buildContent() {
      return Obx(() {
        final isActive = controller.isPatientSearchActive.value;
        final results = controller.filteredQuickPatients.take(3).toList();
        final query = controller.patientSearchQuery.value.trim();
        final showResults = isActive && results.isNotEmpty;
        final showEmpty = isActive && results.isEmpty && query.isNotEmpty;

        if (!showResults && !showEmpty) {
          return buildTiles();
        }

        final Widget overlay;
        if (showResults) {
          overlay = _SearchResultsCard(
            patients: results,
            compact: isMobile,
            onView: controller.openQuickPatient,
          );
        } else {
          overlay = _NoSearchResultsCard(
            query: query,
            compact: isMobile,
            onRegister: controller.registerPatient,
          );
        }

        // Search results card sits on top of all 4 options in a floating Stack overlay
        return Stack(
          clipBehavior: Clip.none,
          children: [
            buildTiles(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: overlay,
            ),
          ],
        );
      });
    }

    return AppCard(
      padding: const EdgeInsets.all(Dimensions.sectionPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Dimensions.spaceMd,
        children: [
          Text(
            'Quick Actions',
            style: (titleStyle ?? AppTextStyles.h3).copyWith(
              color: scheme.onSurface,
            ),
          ),
          TapRegion(
            groupId: 'dashboard_quick_actions_search',
            onTapOutside: (_) {
              if (controller.isPatientSearchActive.value) {
                controller.deactivatePatientSearch();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Dimensions.spaceMd,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      'Find Patient',
                      style: AppTextStyles.label.copyWith(color: scheme.onSurface),
                    ),
                    Obx(() {
                      final isActive = controller.isPatientSearchActive.value;
                      return AppSearchField(
                        controller: controller.patientSearchText,
                        focusNode: controller.patientSearchFocus,
                        onTap: controller.activatePatientSearch,
                        isActive: isActive,
                        hint: searchHint ?? 'Name, ID, phone or file number',
                        hintStyle: (hintStyle ?? AppTextStyles.caption).copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        onChanged: controller.onPatientSearchChanged,
                        onSubmitted: (query) {
                          final matches = controller.filteredQuickPatients;
                          if (matches.isNotEmpty) {
                            controller.openPatientSearchPreview(matches.first);
                          }
                        },
                        suffixIcon: isActive
                            ? _CloseSearchButton(
                                onPressed: controller.deactivatePatientSearch,
                              )
                            : null,
                      );
                    }),
                  ],
                ),
                buildContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsCard extends StatelessWidget {
  const _SearchResultsCard({
    required this.patients,
    required this.compact,
    required this.onView,
  });

  final List<PatientQuickViewModel> patients;
  final bool compact;
  final ValueChanged<PatientQuickViewModel> onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(
          color: AppColors.borderDefault,
          width: Dimensions.strokeDivider,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < patients.length; i++) ...[
            if (i > 0) const SizedBox(height: 2),
            _SearchResultRow(
              patient: patients[i],
              compact: compact,
              onView: () => onView(patients[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoSearchResultsCard extends StatelessWidget {
  const _NoSearchResultsCard({
    required this.query,
    required this.compact,
    required this.onRegister,
  });

  final String query;
  final bool compact;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(
          color: AppColors.borderDefault,
          width: Dimensions.strokeDivider,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 24,
        vertical: compact ? 20 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No patient found',
            style: (compact ? AppTextStyles.h3Mobile : AppTextStyles.h3).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Check the search details or register a new patient.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppButton.primary(
            label: 'Register New Patient',
            onPressed: onRegister,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _SearchResultRow extends StatefulWidget {
  const _SearchResultRow({
    required this.patient,
    required this.compact,
    required this.onView,
  });

  final PatientQuickViewModel patient;
  final bool compact;
  final VoidCallback onView;

  @override
  State<_SearchResultRow> createState() => _SearchResultRowState();
}

class _SearchResultRowState extends State<_SearchResultRow> {

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String _getSubtitle(PatientQuickViewModel p) {
    final lastVisit = p.name.contains('Nkosi') ? '14 Aug 2026' : '03 Sep 2026';
    final dob = p.dobAndAge.contains('·') ? p.dobAndAge.split('·').first.trim() : p.dobAndAge;
    return 'File ${p.fileNumber} · DOB $dob · ${p.phone} · Last visit $lastVisit';
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(widget.patient.name);
    final subtitle = _getSubtitle(widget.patient);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onView,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        hoverColor: AppColors.brandTint,
        splashColor: Colors.transparent,
        highlightColor: AppColors.brandTint,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
            return AppColors.brandTint;
          }
          return Colors.transparent;
        }),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 10 : 12,
            vertical: widget.compact ? 6 : 8,
          ),
          child: Row(
            children: [
              Container(
                width: widget.compact ? 28 : 34,
                height: widget.compact ? 28 : 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandTint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  initials,
                  style: (widget.compact ? AppTextStyles.caption : AppTextStyles.label).copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.patient.name,
                      style: (widget.compact ? AppTextStyles.bodyMedium : AppTextStyles.label).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!widget.compact) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'View',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseSearchButton extends StatefulWidget {
  const _CloseSearchButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_CloseSearchButton> createState() => _CloseSearchButtonState();
}

class _CloseSearchButtonState extends State<_CloseSearchButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: Tooltip(
          message: 'Clear search',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            width: Dimensions.touchTarget,
            height: Dimensions.touchTarget,
            decoration: BoxDecoration(
              color: _hovered ? AppColors.brandTint : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
            ),
            child: Icon(
              AppIcons.close,
              size: Dimensions.iconSize,
              color: _hovered ? AppColors.brandPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({super.key, required this.spec, required this.onTap});

  final QuickActionSpec spec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(Dimensions.radiusControl);
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: scheme.outline,
          width: Dimensions.strokeDivider,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: AppColors.brandTint.withValues(alpha: 0.6),
        splashColor: Colors.transparent,
        highlightColor: AppColors.brandTint.withValues(alpha: 0.6),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
            return AppColors.brandTint.withValues(alpha: 0.6);
          }
          return Colors.transparent;
        }),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.statusX),
          child: Row(
            spacing: Dimensions.spaceMd,
            children: [
              Container(
                width: Dimensions.actionIconBox,
                height: Dimensions.actionIconBox,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: radius,
                ),
                child: Icon(
                  spec.icon,
                  size: Dimensions.iconSize,
                  color: scheme.primary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      spec.title,
                      style: AppTextStyles.label.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      spec.description,
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                AppIcons.chevronRight,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
