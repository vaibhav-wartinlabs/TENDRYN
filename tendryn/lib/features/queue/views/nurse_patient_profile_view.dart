import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/dashboard/widgets/queue_widgets.dart';
import 'package:tendryn/features/queue/controllers/nurse_patient_profile_controller.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';
import 'package:tendryn/widgets/common/app_button.dart';
import 'package:tendryn/widgets/common/app_card.dart';
import 'package:tendryn/widgets/common/status_pill.dart';

/// Nurse "Patient profile", opened from a Queue row (Figma: desktop 1280,
/// tablet 744, mobile 393). It sits inside the shell with Queue selected.
///
/// - Desktop: back chip, heading with Start triage, identity row, two columns
///   (Demographics + conditions | previous vitals as a list), timeline.
/// - Tablet: back button + heading, identity card, two columns with a vitals
///   grid, timeline; Start triage in a bar above the navigation.
/// - Mobile: back + title header, one column, Start triage bar.
class NursePatientProfileView extends GetView<NursePatientProfileController> {
  const NursePatientProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: _MobileProfile(),
      tablet: _TabletProfile(),
      desktop: _DesktopProfile(),
    );
  }
}

/// Below this content width the tablet layout stacks its two columns, so the
/// vitals tiles keep room for "Oxygen saturation".
const double _tabletTwoColumnMinWidth = 640;

// ---------------------------------------------------------------- desktop

class _DesktopProfile extends GetView<NursePatientProfileController> {
  const _DesktopProfile();

  @override
  Widget build(BuildContext context) {
    final p = controller.profile;
    return ListView(
      padding: const EdgeInsets.all(Dimensions.pageMarginDesktop),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _BackToQueueChip(label: controller.backLabel, onTap: controller.back),
        ),
        const SizedBox(height: 12),
        Row(
          spacing: Dimensions.pageSectionGap,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text('Patient profile', style: AppTextStyles.h2Bold.copyWith(color: AppColors.textPrimary)),
                  Text(
                    _subtitle,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 173,
              height: Dimensions.buttonMinHeight,
              child: AppButton.primary(label: 'Start triage', expand: true, onPressed: controller.startTriage),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.pageSectionGap),
        _DesktopIdentity(profile: p),
        if (p.allergies.isNotEmpty) ...[
          const SizedBox(height: Dimensions.pageSectionGap),
          _AllergyBanner(message: p.allergyMessage, textStyle: AppTextStyles.bodyMedium, iconSize: 18),
        ],
        const SizedBox(height: Dimensions.pageSectionGap),
        _ProfileTabs(),
        const SizedBox(height: Dimensions.pageSectionGap),
        Obx(() {
          if (controller.tab.value == NurseProfileTab.clinicalHistory) {
            return _HistoryContent(profile: p, layout: _HistoryLayout.table, gap: Dimensions.pageSectionGap);
          }
          if (controller.tab.value == NurseProfileTab.labReferrals) {
            return _LabReferralsCard(profile: p, layout: _HistoryLayout.table);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimensions.pageSectionGap,
              children: [
                Expanded(
                  child: Column(
                    spacing: Dimensions.pageSectionGap,
                    children: [
                      _DemographicsCard(profile: p, dense: true),
                      _ConditionsCard(profile: p, title: _desktopCardTitle, body: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Expanded(child: _PreviousVitalsCard(profile: p, asList: true)),
              ],
            ),
            const SizedBox(height: Dimensions.pageSectionGap),
            _TimelineCard(profile: p, asRows: true),
            ],
          );
        }),
      ],
    );
  }
}

final TextStyle _desktopCardTitle =
    AppTextStyles.h3Mobile.copyWith(fontSize: 16, height: 24 / 16, color: AppColors.textPrimary);

const _subtitle = 'Review patient details, allergies and history before triage.';

class _BackToQueueChip extends StatelessWidget {
  const _BackToQueueChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                const Icon(AppIcons.chevronLeft, size: 16, color: AppColors.brandPrimary),
                Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                    fontVariations: [const FontVariation.weight(600)],
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

class _DesktopIdentity extends StatelessWidget {
  const _DesktopIdentity({required this.profile});

  final NursePatientProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: Row(
        spacing: Dimensions.spaceMd,
        children: [
          _Avatar(
            name: profile.name,
            size: 56,
            shape: BoxShape.circle,
            style: AppTextStyles.h3Mobile.copyWith(fontSize: 16, height: 24 / 16, color: AppColors.brandPrimary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(profile.name, style: AppTextStyles.h3Mobile.copyWith(color: AppColors.textPrimary)),
                Text(profile.desktopMeta, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          _StatusRow(profile: profile),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- tablet

class _TabletProfile extends GetView<NursePatientProfileController> {
  const _TabletProfile();

  @override
  Widget build(BuildContext context) {
    final p = controller.profile;
    return Column(
      children: [
        _TabletHeading(backLabel: controller.backLabel, onBack: controller.back),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final twoColumns = box.maxWidth >= _tabletTwoColumnMinWidth;
              final details = Column(
                spacing: Dimensions.spaceMd,
                children: [
                  _DemographicsCard(profile: p),
                  _ConditionsCard(profile: p, title: AppTextStyles.h3Mobile.copyWith(color: AppColors.textPrimary)),
                ],
              );
              final vitals = _PreviousVitalsCard(profile: p);
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pageMarginTablet,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 20,
                  children: [
                    _TabletIdentity(profile: p),
                    if (p.allergies.isNotEmpty)
                      _AllergyBanner(message: p.allergyMessage, textStyle: AppTextStyles.bodyMedium, iconSize: 18),
                    _ProfileTabs(compact: true),
                    Obx(() {
                      if (controller.tab.value == NurseProfileTab.clinicalHistory) {
                        return _HistoryContent(
                          profile: p,
                          layout: twoColumns ? _HistoryLayout.tabletTable : _HistoryLayout.cards,
                          gap: 20,
                        );
                      }
                      if (controller.tab.value == NurseProfileTab.labReferrals) {
                        return _LabReferralsCard(
                          profile: p,
                          layout: twoColumns ? _HistoryLayout.tabletTable : _HistoryLayout.cards,
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 20,
                        children: [
                          if (twoColumns)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: Dimensions.spaceMd,
                              children: [Expanded(child: details), Expanded(child: vitals)],
                            )
                          else ...[
                            details,
                            vitals,
                          ],
                          _TimelineCard(profile: p),
                        ],
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
        StartTriageBar(horizontal: Dimensions.pageMarginTablet, onPressed: controller.startTriage),
      ],
    );
  }
}

class _TabletHeading extends StatelessWidget {
  const _TabletHeading({required this.backLabel, required this.onBack});

  final String backLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginTablet),
      child: Row(
        spacing: 12,
        children: [
          Semantics(
            button: true,
            label: backLabel,
            child: Tooltip(
              message: backLabel,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  onTap: onBack,
                  child: SizedBox.square(
                    dimension: Dimensions.touchTarget,
                    child: Center(
                      child: Container(
                        width: Dimensions.touchTarget,
                        height: Dimensions.touchTarget,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSurface,
                          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                          border: Border.all(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
                        ),
                        child: const Icon(AppIcons.chevronLeft, size: Dimensions.iconSize, color: AppColors.brandPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient profile', style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary)),
                Text(_subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletIdentity extends StatelessWidget {
  const _TabletIdentity({required this.profile});

  final NursePatientProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Dimensions.spaceMd,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Dimensions.spaceMd,
            runSpacing: Dimensions.spaceSm,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Dimensions.spaceSm,
                children: [
                  _Avatar(
                    name: profile.name,
                    size: 34,
                    shape: BoxShape.rectangle,
                    style: AppTextStyles.label.copyWith(color: AppColors.brandPrimary),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(profile.name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                        Text(
                          profile.ageSexAndId,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _StatusRow(profile: profile),
            ],
          ),
          _ReasonStrip(reason: profile.reason, padding: const EdgeInsets.all(12), valueStyle: AppTextStyles.label),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- mobile

class _MobileProfile extends GetView<NursePatientProfileController> {
  const _MobileProfile();

  @override
  Widget build(BuildContext context) {
    final p = controller.profile;
    return Column(
      children: [
        _MobileHeading(backLabel: controller.backLabel, onBack: controller.back),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.pageMarginMobile,
              Dimensions.spaceSm,
              Dimensions.pageMarginMobile,
              Dimensions.spaceLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Dimensions.spaceMd,
              children: [
                _MobileIdentity(profile: p),
                if (p.allergies.isNotEmpty)
                  _AllergyBanner(
                    message: p.allergyMessage,
                    textStyle: AppTextStyles.label,
                    iconSize: 16,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.controlX, vertical: 10),
                  ),
                _ProfileTabs(compact: true),
                Obx(() {
                  if (controller.tab.value == NurseProfileTab.clinicalHistory) {
                    return _HistoryContent(profile: p, layout: _HistoryLayout.cards, gap: Dimensions.spaceMd);
                  }
                  if (controller.tab.value == NurseProfileTab.labReferrals) {
                    return _LabReferralsCard(profile: p, layout: _HistoryLayout.cards);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Dimensions.spaceMd,
                    children: [
                      _DemographicsCard(profile: p),
                      _ConditionsCard(profile: p, title: AppTextStyles.h3Mobile.copyWith(color: AppColors.textPrimary)),
                      _PreviousVitalsCard(profile: p),
                      _TimelineCard(profile: p),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        StartTriageBar(horizontal: Dimensions.pageMarginMobile, onPressed: controller.startTriage),
      ],
    );
  }
}

/// Back arrow inside box and fixed top bar matching tablet/project layout.
class _MobileHeading extends StatelessWidget {
  const _MobileHeading({required this.backLabel, required this.onBack});

  final String backLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDefault,
            width: Dimensions.strokeDivider,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.pageMarginMobile),
      child: Row(
        spacing: 12,
        children: [
          Semantics(
            button: true,
            label: backLabel,
            child: Tooltip(
              message: backLabel,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Dimensions.radiusControl),
                  onTap: onBack,
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
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                'Patient profile',
                style: const TextStyle(
                  fontFamily: AppTextStyles.headingFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C1E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileIdentity extends StatelessWidget {
  const _MobileIdentity({required this.profile});

  final NursePatientProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.cardInner),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 9,
        children: [
          Row(
            spacing: Dimensions.spaceSm,
            children: [
              _Avatar(
                name: profile.name,
                size: 48,
                shape: BoxShape.circle,
                style: AppTextStyles.h3Mobile.copyWith(
                  color: AppColors.brandPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      profile.name,
                      style: AppTextStyles.h3Mobile.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      profile.ageSexAndId,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _ReasonStrip(
            reason: profile.reason,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.cardInner, vertical: 8),
            valueStyle: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            bordered: true,
          ),
          Align(alignment: Alignment.centerLeft, child: _StatusRow(profile: profile)),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- shared

/// Fixed bottom "Start triage" bar (tablet and phone) with safe area insets and top border.
class StartTriageBar extends StatelessWidget {
  const StartTriageBar({super.key, required this.horizontal, required this.onPressed});

  final double horizontal;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: Dimensions.spaceMd),
          child: AppButton.primary(label: 'Start triage', expand: true, onPressed: onPressed),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.size, required this.shape, required this.style});

  final String name;
  final double size;
  final BoxShape shape;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(5) : null,
      ),
      child: Text(Formatters.initials(name), style: style),
    );
  }
}

/// Where the patient is (tinted pill) and their triage priority (dot + label).
class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.profile});

  final NursePatientProfile profile;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (profile.status) {
      QueueStatus.waiting => (AppColors.feedbackWarningTint, AppColors.feedbackWarning),
      QueueStatus.waitingForDoctor => (AppColors.brandTint, AppColors.brandPrimary),
      QueueStatus.withNurse => (AppColors.feedbackInfoTint, AppColors.feedbackInfo),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: Dimensions.chipHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
          child: Text(
            profile.status.label,
            style: AppTextStyles.label.copyWith(color: foreground, fontSize: 12, height: 16 / 12),
          ),
        ),
        const SizedBox(width: Dimensions.spaceSm),
        StatusPill(color: QueueStyles.priorityDot(profile.priority), label: profile.priority.label),
      ],
    );
  }
}

class _ReasonStrip extends StatelessWidget {
  const _ReasonStrip({required this.reason, required this.padding, required this.valueStyle, this.bordered = false});

  final String reason;
  final EdgeInsets padding;
  final TextStyle valueStyle;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.backgroundApp,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        border: bordered ? Border.all(color: AppColors.borderDefault, width: Dimensions.strokeDivider) : null,
      ),
      child: Row(
        spacing: 12,
        children: [
          Text('Reason for visit', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              reason,
              style: valueStyle.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllergyBanner extends StatelessWidget {
  const _AllergyBanner({
    required this.message,
    required this.textStyle,
    required this.iconSize,
    this.padding = const EdgeInsets.all(Dimensions.controlX),
  });

  final String message;
  final TextStyle textStyle;
  final double iconSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // Critical colours are fixed (system-controlled), never clinic branding.
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.safetyCriticalBackground,
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        ),
        child: Row(
          spacing: Dimensions.componentGap,
          children: [
            Icon(AppIcons.alert, size: iconSize, color: AppColors.safetyCriticalText),
            Expanded(child: Text(message, style: textStyle.copyWith(color: AppColors.safetyCriticalText))),
          ],
        ),
      ),
    );
  }
}

/// Overview / Clinical History / Lab referrals. Only Overview has a design;
/// the others tell the nurse they are not available yet.
class _ProfileTabs extends GetView<NursePatientProfileController> {
  const _ProfileTabs({this.compact = false});

  /// Tablet and phone: white 8px-radius tray with 4px padding and 48px tabs.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.tab.value;
      final tabs = [
        for (final t in NurseProfileTab.values)
          Expanded(
            child: _TabButton(
              label: t.label,
              selected: t == selected,
              height: compact ? Dimensions.touchTarget : 38,
              onTap: () => controller.selectTab(t),
            ),
          ),
      ];
      return Container(
        padding: compact ? const EdgeInsets.all(4) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: compact ? BorderRadius.circular(Dimensions.radiusControl) : null,
        ),
        child: Row(spacing: compact ? 2 : Dimensions.spaceLg, children: tabs),
      );
    });
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.height, required this.onTap});

  final String label;
  final bool selected;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.brandTint : AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Container(
            height: height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(color: selected ? AppColors.brandPrimary : AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _DemographicsCard extends StatelessWidget {
  const _DemographicsCard({required this.profile, this.dense = false});

  final NursePatientProfile profile;

  /// Desktop: 8px row padding, regular labels. Tablet / phone: 10px, medium labels.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Patient ID', profile.patientId),
      ('Sex', profile.sex),
      ('Age', profile.ageLabel),
      ('Reason for visit', profile.reason),
      ('Assigned practitioner', profile.practitioner),
    ];
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Dimensions.spaceMd,
        children: [
          Text('Demographics', style: dense ? _desktopCardTitle : _cardTitle),
          Column(
            children: [
              for (final (i, row) in rows.indexed)
                ProfileKeyValueRow(
                  label: row.$1,
                  value: row.$2,
                  divider: i < rows.length - 1,
                  verticalPadding: dense ? 8 : 10,
                  labelRegular: dense,
                  valueFlexible: !dense,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

final TextStyle _cardTitle = AppTextStyles.h3Mobile.copyWith(color: AppColors.textPrimary);

class ProfileKeyValueRow extends StatelessWidget {
  const ProfileKeyValueRow({
    super.key,
    required this.label,
    required this.value,
    required this.divider,
    required this.verticalPadding,
    this.labelRegular = false,
    this.valueFlexible = false,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final bool divider;
  final double verticalPadding;

  /// Desktop labels are Inter Regular; tablet / phone labels are Medium.
  final bool labelRegular;

  /// Tablet / phone: label and value each take half the row and wrap.
  final bool valueFlexible;

  /// The Triage view shows its readings in the secondary colour.
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = (labelRegular ? AppTextStyles.bodySmall : AppTextStyles.label)
        .copyWith(color: AppColors.textSecondary);
    final valueStyle = AppTextStyles.label.copyWith(color: valueColor);
    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider))
            : null,
      ),
      child: Row(
        spacing: valueFlexible ? 12 : Dimensions.spaceMd,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          if (valueFlexible)
            Expanded(child: Text(value, style: valueStyle, textAlign: TextAlign.end))
          else
            Flexible(child: Text(value, style: valueStyle, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard({required this.profile, required this.title, this.body});

  final NursePatientProfile profile;
  final TextStyle title;

  /// Defaults to Inter Regular 16/24 (tablet / phone).
  final TextStyle? body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: body == null ? Dimensions.componentGap : Dimensions.spaceMd,
        children: [
          Text('Existing conditions', style: title),
          Text(
            profile.conditions.isEmpty ? 'None recorded' : profile.conditions.join(', '),
            style: (body ?? AppTextStyles.body).copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Read-only vitals from the previous visit. Desktop lists them as rows;
/// tablet and phone show a two-column grid of tiles.
class _PreviousVitalsCard extends StatelessWidget {
  const _PreviousVitalsCard({required this.profile, this.asList = false});

  final NursePatientProfile profile;
  final bool asList;

  @override
  Widget build(BuildContext context) {
    const readOnly = ProfileReadOnlyBadge();
    final vitals = profile.previousVitals;
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Dimensions.spaceMd,
        children: [
          if (asList)
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text('Previous vitals', style: _desktopCardTitle),
                      Text(
                        profile.previousVisitLabel,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                readOnly,
              ],
            )
          else ...[
            Text('Previous vitals', style: _cardTitle),
            Row(
              spacing: Dimensions.spaceSm,
              children: [
                Expanded(
                  child: Text(
                    profile.previousVisitLabel,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                readOnly,
              ],
            ),
          ],
          if (asList)
            Column(
              children: [
                for (final (i, v) in vitals.indexed)
                  ProfileKeyValueRow(
                    label: v.label,
                    value: v.display,
                    divider: i < vitals.length - 1,
                    verticalPadding: 8,
                    labelRegular: true,
                  ),
              ],
            )
          else
            Column(
              spacing: Dimensions.spaceSm,
              children: [
                for (var i = 0; i < vitals.length; i += 2)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Dimensions.spaceSm,
                      children: [
                        Expanded(child: _VitalTile(reading: vitals[i])),
                        Expanded(
                          child: i + 1 < vitals.length ? _VitalTile(reading: vitals[i + 1]) : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class ProfileReadOnlyBadge extends StatelessWidget {
  const ProfileReadOnlyBadge({super.key, this.locked = false, this.onTap});

  /// The Triage view's badge has a lock icon before the label.
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundApp,
        borderRadius: BorderRadius.circular(Dimensions.radiusPill),
        border: Border.all(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (locked) const Icon(AppIcons.lock, size: 12, color: AppColors.textSecondary),
          Text(
            'Read only',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            softWrap: false,
          ),
        ],
      ),
    );

    if (onTap == null) return badge;

    return Semantics(
      button: true,
      label: 'Read only clinical records',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusPill),
          onTap: onTap,
          child: badge,
        ),
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  const _VitalTile({required this.reading});

  final VitalReading reading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundApp,
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Dimensions.spaceSm,
        children: [
          Text(reading.label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          Text.rich(
            TextSpan(
              text: reading.value,
              style: AppTextStyles.tabular(AppTextStyles.h3Mobile).copyWith(color: AppColors.textPrimary),
              children: [
                TextSpan(
                  text: ' ${reading.unit}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Visit timeline. Desktop: one row per event (dot, time, description).
/// Tablet and phone: a vertical line connecting stacked events.
class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.profile, this.asRows = false});

  final NursePatientProfile profile;
  final bool asRows;

  @override
  Widget build(BuildContext context) {
    final events = profile.timeline;
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Dimensions.spaceMd,
        children: [
          Text('Visit timeline', style: asRows ? _desktopCardTitle : _cardTitle),
          if (asRows)
            Column(
              children: [
                for (final (i, e) in events.indexed) _TimelineRow(event: e, divider: i < events.length - 1),
              ],
            )
          else
            Column(
              spacing: Dimensions.spaceMd,
              children: [
                for (final (i, e) in events.indexed) _TimelineEntry(event: e, last: i == events.length - 1),
              ],
            ),
        ],
      ),
    );
  }
}

Color _dotColor(VisitEvent e) => e.current ? AppColors.brandPrimary : AppColors.textDisabled;

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.divider});

  final VisitEvent event;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider))
            : null,
      ),
      child: Row(
        spacing: Dimensions.spaceMd,
        children: [
          Container(
            width: Dimensions.stateDot,
            height: Dimensions.stateDot,
            decoration: BoxDecoration(color: _dotColor(event), borderRadius: BorderRadius.circular(4)),
          ),
          SizedBox(
            width: 180,
            child: Text(event.time, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(event.description, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.event, required this.last});

  final VisitEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          SizedBox(
            width: 10,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: Dimensions.stateDot,
                    height: Dimensions.stateDot,
                    decoration: BoxDecoration(color: _dotColor(event), shape: BoxShape.circle),
                  ),
                ),
                if (!last) ...[
                  const SizedBox(height: 6),
                  Expanded(child: Container(width: 1, color: AppColors.borderDefault)),
                ],
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : Dimensions.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(event.time, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  Text(event.description, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------- clinical history

/// How the visit history is drawn: desktop table, tablet table (date and
/// reason stacked), or one card per visit (phone and narrow tablets).
enum _HistoryLayout { table, tabletTable, cards }

/// The Clinical History tab: Visit history, then the read-only Clinical records.
class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.profile, required this.layout, required this.gap});

  final NursePatientProfile profile;
  final _HistoryLayout layout;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: [
        _VisitHistoryCard(profile: profile, layout: layout),
        _ClinicalRecordsCard(layout: layout),
      ],
    );
  }
}

class _VisitHistoryCard extends GetView<NursePatientProfileController> {
  const _VisitHistoryCard({required this.profile, required this.layout});

  final NursePatientProfile profile;
  final _HistoryLayout layout;

  @override
  Widget build(BuildContext context) {
    final visits = profile.visits;
    final desktop = layout == _HistoryLayout.table;
    final cards = layout == _HistoryLayout.cards;
    final title = desktop || layout == _HistoryLayout.tabletTable
        ? AppTextStyles.h3.copyWith(color: AppColors.textPrimary)
        : _cardTitle;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: BoxConstraints(minHeight: desktop ? 68 : 60),
            padding: EdgeInsets.symmetric(horizontal: desktop ? 20 : Dimensions.spaceMd, vertical: Dimensions.spaceMd),
            child: Row(
              children: [
                Expanded(child: Text('Visit history', style: title)),
                Text(
                  visits.length == 1 ? '1 visit' : '${visits.length} visits',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (!cards) _HistoryColumnLabels(layout: layout),
          for (final (i, v) in visits.indexed)
            if (cards)
              _VisitCard(visit: v, onViewTriage: () => controller.viewTriage(v))
            else
              _VisitRow(
                visit: v,
                layout: layout,
                divider: i < visits.length - 1,
                onViewTriage: () => controller.viewTriage(v),
              ),
        ],
      ),
    );
  }
}

/// Flex weights of the desktop columns: date, reason, recorded by, status, actions.
const _desktopColumnFlex = [140, 200, 220, 180, 120];

class _HistoryColumnLabels extends StatelessWidget {
  const _HistoryColumnLabels({required this.layout});

  final _HistoryLayout layout;

  @override
  Widget build(BuildContext context) {
    final desktop = layout == _HistoryLayout.table;
    final labels = desktop
        ? const ['Date', 'Reason', 'Recorded by', 'Status', 'Actions']
        : const ['Date / Reason', 'Recorded by', 'Status', 'Actions'];
    final style = (desktop ? AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500) : AppTextStyles.caption)
        .copyWith(color: AppColors.textSecondary);
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceMd, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.backgroundApp,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
        ),
      ),
      child: Row(
        spacing: desktop ? 20 : 16,
        children: [
          for (final (i, l) in labels.indexed)
            if (desktop)
              Expanded(flex: _desktopColumnFlex[i], child: Text(l, style: style))
            else
              _tabletCell(i, Text(l, style: style, textAlign: i == 3 ? TextAlign.end : TextAlign.start)),
        ],
      ),
    );
  }
}

/// Tablet columns: details 142, recorded by flex, status flex, actions 120.
Widget _tabletCell(int index, Widget child) => switch (index) {
      0 => SizedBox(width: 142, child: child),
      1 => Expanded(flex: 3, child: child),
      2 => Expanded(flex: 3, child: child),
      _ => SizedBox(width: 120, child: Align(alignment: Alignment.centerRight, child: child)),
    };

class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit, required this.layout, required this.divider, required this.onViewTriage});

  final VisitHistoryEntry visit;
  final _HistoryLayout layout;
  final bool divider;
  final VoidCallback onViewTriage;

  @override
  Widget build(BuildContext context) {
    final desktop = layout == _HistoryLayout.table;
    final value = AppTextStyles.label.copyWith(color: AppColors.textPrimary);
    final action = _VisitAction(visit: visit, onViewTriage: onViewTriage, desktop: desktop);
    return Container(
      constraints: BoxConstraints(minHeight: desktop ? 60 : 76),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceMd, vertical: Dimensions.spaceSm),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider))
            : null,
      ),
      child: desktop
          ? Row(
              spacing: 20,
              children: [
                Expanded(flex: _desktopColumnFlex[0], child: Text(visit.date, style: value)),
                Expanded(flex: _desktopColumnFlex[1], child: Text(visit.reason, style: value)),
                Expanded(flex: _desktopColumnFlex[2], child: Text(visit.recordedBy, style: value)),
                Expanded(
                  flex: _desktopColumnFlex[3],
                  child: Align(alignment: Alignment.centerLeft, child: _VisitStatusPill(status: visit.status)),
                ),
                Expanded(flex: _desktopColumnFlex[4], child: Align(alignment: Alignment.centerLeft, child: action)),
              ],
            )
          : Row(
              spacing: 16,
              children: [
                _tabletCell(
                  0,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [Text(visit.date, style: value), Text(visit.reason, style: value)],
                  ),
                ),
                _tabletCell(1, Text(visit.recordedBy, style: value)),
                _tabletCell(
                  2,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _VisitStatusPill(status: visit.status, large: true),
                  ),
                ),
                _tabletCell(3, action),
              ],
            ),
    );
  }
}

/// "Current visit" for today's visit, otherwise the brand "View triage" link.
class _VisitAction extends StatelessWidget {
  const _VisitAction({required this.visit, required this.onViewTriage, required this.desktop});

  final VisitHistoryEntry visit;
  final VoidCallback onViewTriage;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    if (visit.current) {
      return Text(
        'Current visit',
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        textAlign: desktop ? TextAlign.start : TextAlign.end,
      );
    }
    return _OpenRecordLink(label: 'View triage', onTap: onViewTriage);
  }
}

/// Brand text link with the up-right arrow ("View triage ↗"). The arrow sits in
/// a 22.6px box like the Figma link ([gap] is the space before that box).
class _OpenRecordLink extends StatelessWidget {
  const _OpenRecordLink({
    required this.label,
    required this.onTap,
    this.style,
    this.gap = 0,
  });

  final String label;
  final VoidCallback onTap;
  final TextStyle? style;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        onTap: onTap,
        child: Container(
          // Sizes to its content (no alignment, which would fill the slot and centre the text).
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: gap,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: (style ?? AppTextStyles.label).copyWith(color: AppColors.brandPrimary),
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                ),
              ),
              const SizedBox(
                width: 22.627,
                height: 22.627,
                child: Center(child: Icon(AppIcons.arrowUpRight, size: 16, color: AppColors.brandPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisitStatusPill extends StatelessWidget {
  const _VisitStatusPill({required this.status, this.large = false});

  final VisitStatus status;

  /// Tablet and phone pills read 14px; the desktop table's are 12px.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      VisitStatus.triageInProgress => (AppColors.feedbackInfoTint, AppColors.feedbackInfo),
      VisitStatus.triageCompleted => (AppColors.feedbackSuccessTint, AppColors.feedbackSuccess),
    };
    final base = large ? AppTextStyles.label : AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
      child: Text(status.label, style: base.copyWith(color: foreground)),
    );
  }
}

/// Phone visit: date and action, a brand-tint box with recorder and reason, status.
class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit, required this.onViewTriage});

  final VisitHistoryEntry visit;
  final VoidCallback onViewTriage;

  @override
  Widget build(BuildContext context) {
    final label = AppTextStyles.caption.copyWith(color: AppColors.textSecondary);
    final value = AppTextStyles.label.copyWith(color: AppColors.textPrimary);
    return Container(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(visit.date, style: value),
              if (visit.current)
                Text('Current visit', style: label)
              else
                _OpenRecordLink(label: 'View triage', onTap: onViewTriage),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(color: AppColors.brandTint, borderRadius: BorderRadius.circular(4)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Dimensions.spaceMd,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [Text('Recorded by', style: label), Text(visit.recordedBy, style: value)],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [Text('Reason', style: label), Text(visit.reason, style: value)],
                  ),
                ),
              ],
            ),
          ),
          Align(alignment: Alignment.centerLeft, child: _VisitStatusPill(status: visit.status)),
        ],
      ),
    );
  }
}

/// Read-only Consultations and Prescriptions. Neither has records or a screen
/// yet, so each says none are recorded and its link says so when tapped.
class _ClinicalRecordsCard extends GetView<NursePatientProfileController> {
  const _ClinicalRecordsCard({required this.layout});

  final _HistoryLayout layout;

  @override
  Widget build(BuildContext context) {
    final desktop = layout == _HistoryLayout.table;
    final linkStyle = desktop ? AppTextStyles.label : AppTextStyles.caption;
    final records = [
      ('Consultations', 'No consultations recorded', 'View consultations'),
      ('Prescriptions', 'No prescriptions recorded', 'View Prescription'),
    ];
    return AppCard(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Dimensions.spaceMd,
        children: [
          Row(
            spacing: desktop ? 12 : Dimensions.spaceSm,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text('Clinical records', style: desktop ? _desktopCardTitle : _cardTitle),
                    Text(
                      'Read only for your role',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              ProfileReadOnlyBadge(
                onTap: controller.viewClinicalRecordTriage,
              ),
            ],
          ),
          Column(
            children: [
              for (final (i, r) in records.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: i < records.length - 1
                        ? const Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider))
                        : null,
                  ),
                  child: Row(
                    spacing: Dimensions.spaceMd,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.$1, style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                            Text(r.$2, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      // Not Flexible: next to the Expanded text it would take half the free
                      // space and start mid-row instead of ending at the right edge.
                      _OpenRecordLink(
                        label: r.$3,
                        style: linkStyle,
                        // Tablet and phone sit 4px from their arrow.
                        gap: desktop ? 0 : 4,
                        onTap: i == 0 ? controller.viewConsultations : controller.viewPrescriptions,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ lab referrals

/// Flex weights of the desktop columns: test, date, requested by, status, action.
const _labColumnFlex = [210, 150, 205, 180, 124];

/// The Lab referrals tab: heading, then a table (desktop, tablet) or one card
/// per referral (phone and narrow tablets). Read only.
class _LabReferralsCard extends GetView<NursePatientProfileController> {
  const _LabReferralsCard({required this.profile, required this.layout});

  final NursePatientProfile profile;
  final _HistoryLayout layout;

  @override
  Widget build(BuildContext context) {
    final desktop = layout == _HistoryLayout.table;
    final cards = layout == _HistoryLayout.cards;
    final title = cards ? _cardTitle : AppTextStyles.h3.copyWith(color: AppColors.textPrimary);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(desktop ? 20 : Dimensions.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text('Lab Referrals', style: title),
                Text(
                  'View laboratory referrals and sample collection information for this patient.',
                  style: (cards ? AppTextStyles.caption : AppTextStyles.bodySmall).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Obx(() {
            final currentReferrals = controller.referrals;
            if (currentReferrals.isEmpty) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  desktop ? 20 : Dimensions.spaceMd,
                  0,
                  desktop ? 20 : Dimensions.spaceMd,
                  desktop ? 20 : Dimensions.spaceMd,
                ),
                child: const _LabReferralsEmptyState(),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!cards) _LabColumnLabels(layout: layout),
                for (final (i, r) in currentReferrals.indexed)
                  if (cards)
                    _LabReferralCard(referral: r, onViewDetails: () => controller.viewReferralDetails(r))
                  else
                    _LabReferralRow(
                      referral: r,
                      layout: layout,
                      divider: i < currentReferrals.length - 1,
                      onViewDetails: () => controller.viewReferralDetails(r),
                    ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// The empty state panel shown when no lab referrals exist for this patient.
class _LabReferralsEmptyState extends StatelessWidget {
  const _LabReferralsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceLg, vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            AppIcons.file,
            size: 64,
            color: AppColors.brandPrimary,
          ),
          const SizedBox(height: 16),
          Text(
            'No lab referrals found',
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No laboratory referrals have been recorded for this patient.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabColumnLabels extends StatelessWidget {
  const _LabColumnLabels({required this.layout});

  final _HistoryLayout layout;

  @override
  Widget build(BuildContext context) {
    final desktop = layout == _HistoryLayout.table;
    final style = AppTextStyles.caption.copyWith(color: AppColors.textSecondary);
    return Container(
      constraints: BoxConstraints(minHeight: desktop ? 44 : 56),
      padding: EdgeInsets.symmetric(horizontal: Dimensions.spaceMd, vertical: desktop ? 0 : 12),
      decoration: const BoxDecoration(
        color: AppColors.backgroundApp,
        border: Border(
          top: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
          bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider),
        ),
      ),
      child: desktop
          ? Row(
              spacing: 20,
              children: [
                for (final (i, l) in const ['Test Requested', 'Referral Date', 'Requested By', 'Status', 'Action'].indexed)
                  Expanded(flex: _labColumnFlex[i], child: Text(l, style: style)),
              ],
            )
          : Row(
              spacing: 12,
              children: [
                SizedBox(width: 172, child: Text('Test Requested\nReferral Date', style: style)),
                Expanded(child: Text('Requested By', style: style)),
                SizedBox(width: 120, child: Text('Status', style: style)),
                SizedBox(width: 100, child: Text('Action', style: style, textAlign: TextAlign.center)),
              ],
            ),
    );
  }
}

class _LabReferralRow extends StatelessWidget {
  const _LabReferralRow({
    required this.referral,
    required this.layout,
    required this.divider,
    required this.onViewDetails,
  });

  final LabReferral referral;
  final _HistoryLayout layout;
  final bool divider;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final desktop = layout == _HistoryLayout.table;
    final value = AppTextStyles.label.copyWith(color: AppColors.textPrimary);
    final border = divider
        ? const Border(bottom: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider))
        : null;
    if (desktop) {
      return Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.spaceMd, vertical: Dimensions.spaceSm),
        decoration: BoxDecoration(border: border),
        child: Row(
          spacing: 20,
          children: [
            Expanded(flex: _labColumnFlex[0], child: Text(referral.test, style: value)),
            Expanded(flex: _labColumnFlex[1], child: Text(referral.date, style: value)),
            Expanded(flex: _labColumnFlex[2], child: Text(referral.requestedBy, style: value)),
            Expanded(
              flex: _labColumnFlex[3],
              child: Align(alignment: Alignment.centerLeft, child: ProfileReferralStatusPill(status: referral.status)),
            ),
            Expanded(
              flex: _labColumnFlex[4],
              child: Align(
                alignment: Alignment.centerLeft,
                child: _ViewDetailsButton(
                  referral: referral,
                  onTap: onViewDetails,
                  style: AppTextStyles.caption,
                  boxed: false,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      decoration: BoxDecoration(border: border),
      child: Row(
        spacing: 12,
        children: [
          SizedBox(
            width: 172,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(referral.test, style: value),
                Text(referral.date, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
          Expanded(child: Text(referral.requestedBy, style: value)),
          SizedBox(
            width: 120,
            child: Align(alignment: Alignment.centerLeft, child: ProfileReferralStatusPill(status: referral.status)),
          ),
          _ViewDetailsButton(referral: referral, onTap: onViewDetails),
        ],
      ),
    );
  }
}

/// Phone referral: test name, a tinted box with date and requester, then the
/// status pill with the View Details button at the right.
class _LabReferralCard extends StatelessWidget {
  const _LabReferralCard({required this.referral, required this.onViewDetails});

  final LabReferral referral;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final label = AppTextStyles.caption.copyWith(color: AppColors.textSecondary);
    final value = AppTextStyles.label.copyWith(color: AppColors.textPrimary);
    return Container(
      padding: const EdgeInsets.all(Dimensions.spaceMd),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderDefault, width: Dimensions.strokeDivider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(referral.test, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.backgroundApp, borderRadius: BorderRadius.circular(4)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [Text('Referral Date', style: label), Text(referral.date, style: value)],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [Text('Requested By', style: label), Text(referral.requestedBy, style: value)],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProfileReferralStatusPill(status: referral.status),
              _ViewDetailsButton(referral: referral, onTap: onViewDetails),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileReferralStatusPill extends StatelessWidget {
  const ProfileReferralStatusPill({super.key, required this.status, this.fontSize = 11});

  final LabReferralStatus status;

  /// 11px in the referral lists, 12px in the referral details.
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      LabReferralStatus.requested => (AppColors.feedbackWarningTint, AppColors.feedbackWarning),
      LabReferralStatus.resultReceived => (AppColors.feedbackSuccessTint, AppColors.feedbackSuccess),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(Dimensions.radiusPill)),
      child: Text(
        status.label,
        softWrap: false,
        // Figma: Inter Medium 11/16 in the lists, 12/16 in the details.
        style: AppTextStyles.caption.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          fontVariations: const [FontVariation.weight(500)],
          color: foreground,
        ),
      ),
    );
  }
}

/// "View Details": a 100x44 centred button on tablet and phone, a plain 12px
/// brand link in the desktop table.
class _ViewDetailsButton extends StatelessWidget {
  const _ViewDetailsButton({required this.referral, required this.onTap, this.style, this.boxed = true});

  final LabReferral referral;
  final VoidCallback onTap;
  final TextStyle? style;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      'View Details',
      softWrap: false,
      style: (style ?? AppTextStyles.label).copyWith(color: AppColors.brandPrimary),
    );
    return Semantics(
      button: true,
      label: 'View Details, ${referral.test}',
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusControl),
        onTap: onTap,
        child: boxed
            ? SizedBox(width: 100, height: 44, child: Center(child: text))
            // widthFactor: hug the text so it stays at the column's left edge (a plain Center would fill the cell).
            : ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Align(alignment: Alignment.centerLeft, widthFactor: 1, child: text),
              ),
      ),
    );
  }
}
