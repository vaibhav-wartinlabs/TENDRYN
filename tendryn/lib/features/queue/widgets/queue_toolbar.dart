import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/widgets/common/app_search_field.dart';

/// Search box plus the status filter (desktop and tablet). On mobile the
/// design shows the search box alone ([showFilter] false).
class QueueToolbar extends GetView<QueueController> {
  const QueueToolbar({
    super.key,
    this.showFilter = true,
    this.hint = 'Search name, ID or queue number',
    this.hintStyle,
  });

  final bool showFilter;
  final String hint;

  /// Overrides the default 14px medium hint (the Nurse tablet and phone designs use 16px regular).
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      spacing: Dimensions.statusX,
      children: [
        Expanded(
          child: AppSearchField(
            controller: controller.searchTextController,
            hint: hint,
            onChanged: controller.search,
            hintStyle: hintStyle ??
                AppTextStyles.label.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
        if (showFilter) const _StatusFilterButton(),
      ],
    );
  }
}

class _StatusFilterButton extends GetView<QueueController> {
  const _StatusFilterButton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(Dimensions.radiusControl);
    return Obx(() {
      final isDoc = controller.isDoctor;
      final active = isDoc
          ? controller.priorityFilter.value != null
          : controller.statusFilter.value != null;

      if (isDoc) {
        return Material(
          color: Colors.white,
          borderRadius: radius,
          child: InkWell(
            onTap: () {},
            borderRadius: radius,
            child: Container(
              width: 51,
              height: Dimensions.touchTarget,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: radius,
                border: Border.all(
                  color: AppColors.borderDefault,
                  width: Dimensions.strokeDivider,
                ),
              ),
              child: const Icon(AppIcons.filter, size: 22, color: AppColors.textPrimary),
            ),
          ),
        );
      }

      return PopupMenuButton<QueueStatus?>(
        tooltip: 'Filter by status',
        position: PopupMenuPosition.under,
        color: scheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius),
          side: BorderSide(
            color: scheme.outline,
            width: Dimensions.strokeDivider,
          ),
        ),
        initialValue: controller.statusFilter.value,
        onSelected: controller.filterByStatus,
        itemBuilder: (_) => [
          _item(null, 'All statuses'),
          for (final s in QueueStatus.values) _item(s, s.label),
        ],
        child: Container(
          width: 51,
          height: Dimensions.touchTarget,
          decoration: BoxDecoration(
            color: active ? scheme.primaryContainer : scheme.surface,
            borderRadius: radius,
            border: Border.all(
              color: scheme.outline,
              width: Dimensions.strokeDivider,
            ),
          ),
          child: Icon(AppIcons.filter, size: 24, color: scheme.primary),
        ),
      );
    });
  }

  PopupMenuItem<QueueStatus?> _item(QueueStatus? value, String label) =>
      PopupMenuItem(
        value: value,
        height: Dimensions.touchTarget,
        child: Text(label, style: AppTextStyles.label),
      );
}
