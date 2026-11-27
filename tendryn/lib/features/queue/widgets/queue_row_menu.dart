import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_colors.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/core/theme/app_icons.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/queue/controllers/nurse_patient_profile_controller.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/features/queue/widgets/queue_table.dart';
import 'package:tendryn/widgets/common/app_action_menu.dart';

/// The overflow action button of a queue row/card. Opens the actions popup:
/// - In Doctor mode: "View Profile", "Update Status", "Mark Unavailable"
/// - In Receptionist mode: "View Patient", "Assign Practitioner"
/// - In Nurse mode: "View Profile", "Begin Triage"
class QueueRowMenu extends GetView<QueueController> {
  const QueueRowMenu({
    super.key,
    required this.entry,
    this.isDoctor,
    this.onViewPatient,
    this.onAssignPractitioner,
  });

  final QueueEntry entry;
  final bool? isDoctor;
  final ValueChanged<QueueEntry>? onViewPatient;
  final ValueChanged<QueueEntry>? onAssignPractitioner;

  @override
  Widget build(BuildContext context) {
    final doctorMode = isDoctor ??
        (Get.isRegistered<RoleController>() &&
            RoleController.to.currentRole.value == ClinicRole.doctor);

    final nurseMode = !doctorMode &&
        Get.isRegistered<RoleController>() &&
        RoleController.to.currentRole.value == ClinicRole.nurse;

    final actions = doctorMode
        ? const [
            QueueAction.viewProfile,
            QueueAction.updateStatus,
            QueueAction.markUnavailable,
          ]
        : nurseMode
        ? const [
            QueueAction.viewPatient,
            QueueAction.beginTriage,
          ]
        : const [
            QueueAction.viewPatient,
            QueueAction.assignPractitioner,
          ];

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        popupMenuTheme: const PopupMenuThemeData(
          elevation: 6,
          shadowColor: Color(0x1F000000),
          surfaceTintColor: Colors.transparent,
          color: Colors.white,
        ),
      ),
      child: PopupMenuButton<QueueAction>(
        tooltip: 'Queue actions',
        position: PopupMenuPosition.under,
        offset: const Offset(0, 4),
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 6,
        shadowColor: const Color(0x1F000000),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        constraints: BoxConstraints.tightFor(width: nurseMode ? 212 : 196),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusControl),
          side: const BorderSide(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
        onSelected: (action) {
          if (action == QueueAction.updateStatus) {
            showDoctorUpdateStatusView(context, entry: entry);
          } else if (action == QueueAction.markUnavailable) {
            showDoctorMarkUnavailableView(context, entry: entry);
          } else if (action == QueueAction.viewPatient) {
            if (nurseMode) {
              NursePatientProfileController.open(entry);
            } else if (onViewPatient != null) {
              onViewPatient!(entry);
            } else {
              controller.onAction(action, entry);
            }
          } else if (action == QueueAction.assignPractitioner &&
              onAssignPractitioner != null) {
            onAssignPractitioner!(entry);
          } else {
            controller.onAction(action, entry);
          }
        },
        itemBuilder: (_) => [
          for (final action in actions)
            _QueueRowMenuItem(
              action: action,
              isNurse: nurseMode,
            ),
        ],
        child: const AppActionsBoxButton(icon: AppIcons.rowMenu),
      ),
    );
  }
}

class _QueueRowMenuItem extends PopupMenuEntry<QueueAction> {
  const _QueueRowMenuItem({
    required this.action,
    required this.isNurse,
  });

  final QueueAction action;
  final bool isNurse;

  @override
  double get height => Dimensions.touchTarget;

  @override
  bool represents(QueueAction? value) => value == action;

  @override
  State<_QueueRowMenuItem> createState() => _QueueRowMenuItemState();
}

class _QueueRowMenuItemState extends State<_QueueRowMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(widget.action),
        child: Container(
          width: double.infinity,
          height: Dimensions.touchTarget,
          alignment: Alignment.center,
          color: _hovered ? AppColors.brandTint : Colors.transparent,
          child: Text(
            widget.action.label,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.isNurse
                  ? (_hovered ? AppColors.brandHover : AppColors.brandPrimary)
                  : (_hovered ? AppColors.brandHover : AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}


