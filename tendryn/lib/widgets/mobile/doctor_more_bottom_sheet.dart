import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/nav_destination.dart';

/// Clean, modern bottom sheet shown when the user taps "More" in mobile/tablet bottom navigation.
/// Displays clinical destinations not shown in the primary 4 tabs (Consultations, Lab Results).
class DoctorMoreBottomSheet extends StatelessWidget {
  const DoctorMoreBottomSheet({super.key, required this.currentRoute});

  final String currentRoute;

  static Future<void> show(BuildContext context, {required String currentRoute}) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DoctorMoreBottomSheet(currentRoute: currentRoute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.pageMarginMobile,
            Dimensions.spaceSm,
            Dimensions.pageMarginMobile,
            Dimensions.spaceMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: Dimensions.spaceSm),
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                    ),
                    child: Icon(
                      AppIcons.more,
                      size: Dimensions.iconSize,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: Dimensions.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'More Options',
                          style: AppTextStyles.h3.copyWith(color: scheme.onSurface),
                        ),
                        Text(
                          'Additional clinical tasks & tools',
                          style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close, size: Dimensions.iconSize),
                    tooltip: 'Close',
                    color: scheme.onSurfaceVariant,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.spaceMd),

              // Destination items
              for (final dest in NavDestinations.doctorMoreItems) ...[
                _MoreDestinationTile(
                  destination: dest,
                  isSelected: currentRoute == dest.route,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop();
                    AppNavigation.goTo(dest.route);
                  },
                ),
                const SizedBox(height: Dimensions.spaceSm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreDestinationTile extends StatelessWidget {
  const _MoreDestinationTile({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  String _subtitleFor(String route) => switch (route) {
        AppRoutes.labResults => 'Review diagnostic orders & reports',
        AppRoutes.consultations => 'Consultation notes & records',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: destination.label,
      child: Material(
        color: isSelected ? scheme.primaryContainer.withValues(alpha: 0.6) : AppColors.backgroundApp,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius),
          side: BorderSide(
            color: isSelected ? scheme.primary : scheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.spaceMd,
              vertical: Dimensions.spaceSm + 2,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? scheme.surface : scheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  ),
                  child: Icon(
                    destination.icon,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: Dimensions.spaceSm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.label,
                        style: AppTextStyles.label.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitleFor(destination.route),
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? AppIcons.check : AppIcons.chevronRight,
                  size: 18,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
