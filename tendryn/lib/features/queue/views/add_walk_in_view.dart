import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_breakpoints.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/queue/controllers/add_walk_in_controller.dart';
import 'package:tendryn/features/queue/models/walk_in_patient.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/tablet/tablet_header.dart';
import 'package:tendryn/routes/app_routes.dart';

const _intro = 'Find an existing patient before adding queue details.';
const _helper = 'Search by name, SA ID, passport/document, phone or file number';

/// Add Walk-in, step 1 of 2. Tablet and phone render this as a full page; on
/// desktop the Queue opens [AddWalkInDrawer] over itself instead.
class AddWalkInView extends GetView<AddWalkInController> {
  const AddWalkInView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= ResponsiveBreakpoints.mobile;
    return isTablet ? _Tablet(controller: controller) : _Mobile(controller: controller);
  }
}

// ---------------------------------------------------------------------------
// Tablet
// ---------------------------------------------------------------------------

class _Tablet extends StatelessWidget {
  const _Tablet({required this.controller});

  final AddWalkInController controller;

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
                vertical: Dimensions.spaceMd,
              ),
              decoration: const BoxDecoration(
                color: AppColors.backgroundSurface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: Row(
                children: [
                  _BackButton(onTap: controller.onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add Walk-in',
                      style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  _StepPill(controller: controller),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.pageMarginDesktop,
                  Dimensions.spaceLg,
                  Dimensions.pageMarginDesktop,
                  Dimensions.spaceLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() => controller.step.value == 1
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(_intro, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: Dimensions.pageSectionGap),
                              _FindPatient(controller: controller, layout: _Layout.tablet),
                            ],
                          )
                        : _QueueDetails(controller: controller, layout: _Layout.tablet)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _PageActions(
        controller: controller,
        horizontal: Dimensions.pageMarginDesktop,
        vertical: Dimensions.spaceMd,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile
// ---------------------------------------------------------------------------

class _Mobile extends StatelessWidget {
  const _Mobile({required this.controller});

  final AddWalkInController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundApp,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: Dimensions.mobileHeaderHeight,
              decoration: const BoxDecoration(
                color: AppColors.backgroundSurface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginMobile),
                child: Row(
                  children: [
                    _BackButton(onTap: controller.onBack),
                    const SizedBox(width: Dimensions.spaceSm),
                    Expanded(child: Text('Add Walk-in', style: AppTextStyles.h2Mobile.copyWith(color: AppColors.textPrimary))),
                    _StepPill(controller: controller),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(Dimensions.pageMarginMobile, 0, Dimensions.pageMarginMobile, Dimensions.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() => controller.step.value == 1
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(_intro, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: Dimensions.spaceLg),
                              _FindPatient(controller: controller, layout: _Layout.mobile),
                            ],
                          )
                        : _QueueDetails(controller: controller, layout: _Layout.mobile)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _PageActions(
        controller: controller,
        horizontal: Dimensions.pageMarginMobile,
        vertical: Dimensions.spaceSm + 2,
      ),
    );
  }
}

/// Cancel + Continue bottom sheet matching Patient Quick View.
class _PageActions extends StatelessWidget {
  const _PageActions({required this.controller, required this.horizontal, required this.vertical});

  final AddWalkInController controller;
  final double horizontal;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(top: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
          child: Row(
            children: [
              Expanded(child: AppButton.secondary(label: 'Cancel', onPressed: controller.cancel, expand: true)),
              SizedBox(width: horizontal == Dimensions.pageMarginMobile ? Dimensions.spaceSm : Dimensions.spaceMd),
              Expanded(child: Obx(() => AppButton.primary(label: controller.step.value == 1 ? 'Continue' : 'Add to queue', onPressed: controller.onContinue, expand: true))),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop drawer
// ---------------------------------------------------------------------------

/// Right-hand panel shown over the Queue on desktop.
class AddWalkInDrawer extends StatelessWidget {
  const AddWalkInDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddWalkInController>();
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: AppColors.backgroundSurface,
        elevation: 0,
        child: Container(
          width: Dimensions.drawerWidth,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.backgroundSurface,
            boxShadow: [BoxShadow(color: Color(0x240F1F1D), blurRadius: 32, offset: Offset(0, 12))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Add Walk-in', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                              const SizedBox(width: Dimensions.spaceSm),
                              _StepPill(controller: controller, compact: true),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Obx(() => Text(
                                controller.step.value == 1 ? _intro : '${controller.selected.value!.name} · File #${controller.selected.value!.fileNumber}',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              )),
                        ],
                      ),
                    ),
                    InkResponse(
                      onTap: controller.cancel,
                      radius: 16,
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(AppIcons.close, size: 20, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.spaceLg),
                  child: Obx(() => controller.step.value == 1
                      ? _FindPatient(controller: controller, layout: _Layout.drawer)
                      : _QueueDetails(controller: controller, layout: _Layout.drawer)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceLg, vertical: Dimensions.spaceMd),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
                ),
                child: Row(
                  children: [
                    Expanded(child: AppButton.secondary(label: 'Cancel', onPressed: controller.cancel, expand: true)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => AppButton.primary(
                            label: controller.step.value == 1 ? 'Continue' : 'Add to queue',
                            onPressed: controller.onContinue,
                            expand: true,
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the Add Walk-in drawer over the current page (desktop).
void showAddWalkInDrawer(BuildContext context, {String returnRoute = AppRoutes.queue}) {
  Get.put(AddWalkInController(returnRoute: returnRoute));
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0xA30F1F1D),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, _, _) => const AddWalkInDrawer(),
    transitionBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ).then((_) {
    if (Get.isRegistered<AddWalkInController>()) Get.delete<AddWalkInController>();
  });
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

enum _Layout { drawer, tablet, mobile }

/// "Find Patient" label, search field and matching patients.
class _FindPatient extends StatelessWidget {
  const _FindPatient({required this.controller, required this.layout});

  final AddWalkInController controller;
  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final isDrawer = layout == _Layout.drawer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Find Patient', style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        SizedBox(height: isDrawer ? 6 : Dimensions.spaceSm),
        _SearchControl(controller: controller, compact: isDrawer),
        if (isDrawer) ...[
          const SizedBox(height: 6),
          Text(_helper, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
        SizedBox(height: isDrawer ? Dimensions.spaceMd : Dimensions.spaceLg),
        Obx(() {
          final results = controller.results;
          final selected = controller.selected.value;
          if (results.isEmpty) {
            return _NoPatientFound(controller: controller, layout: layout);
          }
          return Column(
            children: [
              for (final patient in results)
                Padding(
                  padding: EdgeInsets.only(bottom: isDrawer ? 10 : 12),
                  child: _PatientCard(
                    patient: patient,
                    layout: layout,
                    selected: patient == selected,
                    onTap: () => controller.select(patient),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}

class _NoPatientFound extends StatelessWidget {
  const _NoPatientFound({required this.controller, required this.layout});

  final AddWalkInController controller;
  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final topSpacing = switch (layout) {
      _Layout.drawer => 64.0,
      _Layout.tablet => 80.0,
      _Layout.mobile => 60.0,
    };

    return Padding(
      padding: EdgeInsets.only(top: topSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No patient found',
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check the search details or register a new patient.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          AppButton.primary(
            label: 'Register New Patient',
            onPressed: controller.onRegisterNewPatient,
            expand: true,
          ),
        ],
      ),
    );
  }
}

/// Focused search box with a clear button. [compact] is the 44px drawer
/// variant; otherwise the 52px page variant.
class _SearchControl extends StatelessWidget {
  const _SearchControl({required this.controller, required this.compact});

  final AddWalkInController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textStyle = compact ? AppTextStyles.label : AppTextStyles.body;
    return Container(
      height: compact ? 44 : 52,
      padding: compact ? const EdgeInsets.symmetric(horizontal: 12) : const EdgeInsets.only(left: Dimensions.controlX, right: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: Border.all(color: AppColors.brandPrimary),
      ),
      child: Row(
        children: [
          if (!compact) ...[
            const Icon(AppIcons.search, size: Dimensions.iconSize, color: AppColors.textSecondary),
            const SizedBox(width: Dimensions.componentGap),
          ],
          Expanded(
            child: TextField(
              controller: controller.searchText,
              onChanged: controller.search,
              style: textStyle.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          InkResponse(
            onTap: controller.clearSearch,
            radius: 20,
            child: SizedBox(
              width: compact ? 24 : 48,
              height: compact ? 24 : 48,
              child: Icon(AppIcons.close, size: compact ? 16 : 20, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.layout, required this.selected, required this.onTap});

  final WalkInPatient patient;
  final _Layout layout;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (padding, radius, avatar, name, details) = switch (layout) {
      _Layout.drawer => (12.0, 8.0, 36.0, AppTextStyles.label, AppTextStyles.caption),
      _Layout.tablet => (24.0, Dimensions.radius, 48.0, AppTextStyles.h3, AppTextStyles.label),
      _Layout.mobile => (Dimensions.spaceMd, Dimensions.radius, 48.0, AppTextStyles.h3Mobile, AppTextStyles.caption.copyWith(fontSize: 11)),
    };
    final isDrawer = layout == _Layout.drawer;
    return Material(
      color: AppColors.backgroundSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: selected ? AppColors.brandPrimary : AppColors.borderDefault,
          width: selected ? Dimensions.strokeFocus : Dimensions.strokeDivider,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              Container(
                width: avatar,
                height: avatar,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.brandTint, shape: BoxShape.circle),
                child: Text(patient.initials, style: AppTextStyles.label.copyWith(color: AppColors.brandPrimary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.name, style: name.copyWith(color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (!isDrawer) const SizedBox(height: 2),
                    Text(patient.details, style: details.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (isDrawer) Text(selected ? 'Selected' : 'Select', style: AppTextStyles.label.copyWith(color: AppColors.brandPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.controller, this.compact = false});

  final AddWalkInController controller;

  /// Drawer: 12px caption on a 9px inset; pages: 14px label.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 9 : Dimensions.badgePaddingX, vertical: Dimensions.badgePaddingY),
      decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
      child: Obx(() => Text('Step ${controller.step.value} of 2', style: (compact ? AppTextStyles.caption : AppTextStyles.label).copyWith(color: AppColors.brandPrimary))),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
        onTap: onTap,
        child: SizedBox.square(
          dimension: Dimensions.touchTarget,
          child: Center(
            child: Container(
              width: Dimensions.touchTarget,
              height: Dimensions.touchTarget,
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                border: Border.all(
                  color: AppColors.borderDefault,
                  width: Dimensions.strokeDivider,
                ),
              ),
              child: const Icon(
                AppIcons.chevronLeft,
                size: Dimensions.iconSize,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: queue details
// ---------------------------------------------------------------------------

/// Selected patient, visit details and queue update preferences.
class _QueueDetails extends StatelessWidget {
  const _QueueDetails({required this.controller, required this.layout});

  final AddWalkInController controller;
  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final isTablet = layout == _Layout.tablet;
    final reason = _Field(
      label: 'Reason for visit',
      tablet: isTablet,
      child: Container(
        height: isTablet ? 48 : 44,
        padding: EdgeInsets.symmetric(horizontal: isTablet ? Dimensions.controlX : 12),
        alignment: Alignment.centerLeft,
        decoration: _fieldDecoration(AppColors.borderDefault),
        child: TextField(
          controller: controller.reason,
          style: (isTablet ? AppTextStyles.bodyMedium : AppTextStyles.label).copyWith(color: AppColors.textPrimary),
          decoration: _bare,
        ),
      ),
    );
    final priority = _Select(
      label: 'Priority',
      tablet: isTablet,
      options: AddWalkInController.priorities,
      value: controller.priority,
      controller: controller,
      onChoose: controller.choosePriority,
    );
    final practitioner = _Select(
      label: 'Practitioner',
      tablet: isTablet,
      options: AddWalkInController.practitioners,
      value: controller.practitioner,
      controller: controller,
      onChoose: controller.choosePractitioner,
    );
    final whatsApp = Obx(() => _Preference(
          tablet: isTablet,
          control: _Toggle(on: controller.whatsApp.value),
          title: 'Send queue updates by WhatsApp',
          note: 'Patient has an active WhatsApp number.',
          onTap: () => controller.whatsApp.toggle(),
        ));
    final consent = Obx(() => _Preference(
          tablet: isTablet,
          control: _Checkbox(checked: controller.consent.value, size: isTablet ? 20 : 18),
          title: 'Patient consented to receive queue updates',
          note: 'Queue number, position, estimated wait and you’re-next notifications only.',
          onTap: () => controller.consent.toggle(),
        ));

    if (!isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PatientSummary(patient: controller.selected.value!, layout: layout),
          const SizedBox(height: Dimensions.spaceMd),
          reason,
          const SizedBox(height: Dimensions.spaceMd),
          priority,
          const SizedBox(height: Dimensions.spaceMd),
          practitioner,
          const SizedBox(height: Dimensions.spaceMd),
          whatsApp,
          const SizedBox(height: Dimensions.spaceMd),
          consent,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PatientSummary(patient: controller.selected.value!, layout: layout),
        const SizedBox(height: Dimensions.pageSectionGap),
        _Card(
          gap: 20,
          children: [
            reason,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: priority),
                const SizedBox(width: Dimensions.pageSectionGap),
                Expanded(child: practitioner),
              ],
            ),
          ],
        ),
        const SizedBox(height: Dimensions.pageSectionGap),
        _Card(gap: Dimensions.spaceMd, children: [whatsApp, consent]),
      ],
    );
  }
}

const _bare = InputDecoration(
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  filled: false,
  isCollapsed: true,
  contentPadding: EdgeInsets.zero,
);

BoxDecoration _fieldDecoration(Color border) => BoxDecoration(
      color: AppColors.backgroundSurface,
      borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      border: Border.all(color: border),
    );

class _Card extends StatelessWidget {
  const _Card({required this.gap, required this.children});

  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.cardInner),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: gap), children[i]],
        ],
      ),
    );
  }
}

class _PatientSummary extends StatelessWidget {
  const _PatientSummary({required this.patient, required this.layout});

  final WalkInPatient patient;
  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final (padding, radius, avatar, name, details) = switch (layout) {
      _Layout.drawer => (12.0, Dimensions.radiusControl, 36.0, AppTextStyles.label, AppTextStyles.caption),
      _Layout.tablet => (24.0, Dimensions.radius, 48.0, AppTextStyles.h2, AppTextStyles.label),
      _Layout.mobile => (Dimensions.spaceMd, Dimensions.radius, 48.0, AppTextStyles.h3Mobile, AppTextStyles.label),
    };
    return Container(
      constraints: BoxConstraints(minHeight: layout == _Layout.tablet ? 112 : 0),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: layout == _Layout.drawer ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: avatar,
            height: avatar,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.backgroundSurface, shape: BoxShape.circle),
            child: Text(patient.initials, style: AppTextStyles.label.copyWith(color: AppColors.brandPrimary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name, style: name.copyWith(color: AppColors.textPrimary)),
                if (layout != _Layout.drawer) const SizedBox(height: 2),
                Text('File #${patient.fileNumber} · Selected patient', style: details.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label above a control: 6px apart on drawer / mobile, 8px on tablet.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.tablet, required this.child});

  final String label;
  final bool tablet;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
        SizedBox(height: tablet && label == 'Reason for visit' ? Dimensions.spaceSm : 6),
        child,
      ],
    );
  }
}

/// Dropdown that opens its option list inline under the field.
class _Select extends StatelessWidget {
  const _Select({
    required this.label,
    required this.tablet,
    required this.options,
    required this.value,
    required this.controller,
    required this.onChoose,
  });

  final String label;
  final bool tablet;
  final List<String> options;
  final RxString value;
  final AddWalkInController controller;
  final ValueChanged<String> onChoose;

  Color _optionColor(String option) => switch (option) {
        'Urgent' => AppColors.priorityUrgent,
        'Emergency' => AppColors.priorityEmergency,
        _ => AppColors.textPrimary,
      };

  @override
  Widget build(BuildContext context) {
    final textStyle = (tablet ? AppTextStyles.bodyMedium : AppTextStyles.label).copyWith(color: AppColors.textPrimary);
    return _Field(
      label: label,
      tablet: tablet,
      child: Obx(() {
        final open = identical(controller.openMenu.value, options);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radiusControl),
              onTap: () => controller.toggleMenu(options),
              child: Container(
                height: tablet ? 48 : 44,
                padding: EdgeInsets.symmetric(horizontal: tablet ? Dimensions.controlX : 12),
                decoration: _fieldDecoration(AppColors.brandPrimary),
                child: Row(
                  children: [
                    Expanded(child: Text(value.value, style: textStyle)),
                    Icon(open ? AppIcons.chevronUp : AppIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            if (open)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  border: Border.all(color: AppColors.borderDefault),
                  boxShadow: const [BoxShadow(color: Color(0x1F0F1F1D), blurRadius: 20, offset: Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    for (final option in options)
                      InkWell(
                        onTap: () => onChoose(option),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: Dimensions.spaceSm),
                          color: option == value.value ? AppColors.brandTint : AppColors.backgroundSurface,
                          child: Text(
                            option == value.value ? '$option  ✓' : option,
                            style: AppTextStyles.label.copyWith(color: _optionColor(option)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }
}

/// A toggle or checkbox with its title and note. Tablet gives the control a
/// 48px touch target and centres the row.
class _Preference extends StatelessWidget {
  const _Preference({required this.tablet, required this.control, required this.title, required this.note, required this.onTap});

  final bool tablet;
  final Widget control;
  final String title;
  final String note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: tablet ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (tablet) SizedBox(width: Dimensions.touchTarget, height: Dimensions.touchTarget, child: Center(child: control)) else control,
          SizedBox(width: tablet ? 12 : (control is _Checkbox ? 10 : 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                if (tablet) const SizedBox(height: Dimensions.spaceXs),
                Text(note, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 44,
      height: 24,
      padding: const EdgeInsets.all(2),
      alignment: on ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: on ? AppColors.brandPrimary : AppColors.borderDefault,
        borderRadius: BorderRadius.circular(Dimensions.radiusPill),
      ),
      child: Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(color: AppColors.backgroundSurface, shape: BoxShape.circle),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked, required this.size});

  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: checked ? AppColors.brandPrimary : AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: checked ? AppColors.brandPrimary : AppColors.borderDefault),
      ),
      child: checked ? Icon(AppIcons.check, size: size - 6, color: AppColors.textOnBrand) : null,
    );
  }
}
