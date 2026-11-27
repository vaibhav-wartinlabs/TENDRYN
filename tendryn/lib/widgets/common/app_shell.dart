import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_layout.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/features/consultation/controllers/consultation_controller.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/queue/views/nurse_patient_profile_view.dart';
import 'package:tendryn/features/queue/views/nurse_triage_view.dart';
import 'package:tendryn/features/queue/views/record_sample_view.dart';
import 'package:tendryn/features/vitals_triage/views/record_vitals_triage_view.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/routes/route_names.dart';
import 'package:tendryn/widgets/common/connectivity_banner.dart';
import 'package:tendryn/widgets/common/doctor_coming_soon_view.dart';
import 'package:tendryn/widgets/desktop/desktop_scaffold.dart';
import 'package:tendryn/widgets/mobile/mobile_scaffold.dart';
import 'package:tendryn/widgets/tablet/tablet_scaffold.dart';

/// Navigation chrome around a main destination. Page content is identical
/// across sizes; only how the user moves around changes.
/// When in Doctor mode, renders page heading on top-left and 'Coming Soon' in center.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.route,
    required this.child,
    this.hideBottomNavigation = false,
    this.hideMobileHeader = false,
  });

  final String route;
  final Widget child;
  final bool hideBottomNavigation;

  /// Phone only: leave out the brand header because the page draws its own heading.
  final bool hideMobileHeader;

  Widget _buildBody(Widget pageContent, {bool showBottomNavigation = true}) {
    final isNursePatientProfile =
        pageContent is NursePatientProfileView ||
        child is NursePatientProfileView ||
        route == AppRoutes.nursePatientProfile;
    final isNurseReadOnlySubpage =
        pageContent is NurseTriagePage ||
        child is NurseTriagePage ||
        pageContent is NurseConsultationsPage ||
        child is NurseConsultationsPage ||
        pageContent is NursePrescriptionsPage ||
        child is NursePrescriptionsPage ||
        pageContent is NurseLabReferralPage ||
        child is NurseLabReferralPage ||
        pageContent is NurseRecordSamplePage ||
        child is NurseRecordSamplePage ||
        route == AppRoutes.nurseTriageDetail ||
        route == AppRoutes.nurseConsultations ||
        route == AppRoutes.nursePrescriptions ||
        route == AppRoutes.nurseLabReferral ||
        route == AppRoutes.nurseRecordSample;
    final isNurseRecordVitalsTriage =
        pageContent is RecordVitalsTriageView ||
        child is RecordVitalsTriageView ||
        route == AppRoutes.recordVitalsTriage;
    final effectiveHideHeader =
        hideMobileHeader || isNursePatientProfile || isNurseRecordVitalsTriage;
    final effectiveHideTabletHeader = isNurseReadOnlySubpage;
    final effectiveHideBottom =
        hideBottomNavigation ||
        isNursePatientProfile ||
        isNurseReadOnlySubpage ||
        isNurseRecordVitalsTriage;

    final content = Column(
      children: [
        const ConnectivityBanner(),
        Expanded(child: pageContent),
      ],
    );
    return ResponsiveLayout(
      mobile: MobileScaffold(
        route: route,
        showBottomNavigation: showBottomNavigation && !effectiveHideBottom,
        showHeader: !effectiveHideHeader,
        child: content,
      ),
      tablet: TabletScaffold(
        route: route,
        showHeader: !effectiveHideTabletHeader,
        showBottomNavigation: showBottomNavigation && !effectiveHideBottom,
        child: content,
      ),
      desktop: DesktopScaffold(route: route, child: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (route == AppRoutes.consultations &&
        !hideBottomNavigation &&
        !Get.isRegistered<ConsultationController>()) {
      Get.lazyPut<ConsultationController>(() => ConsultationController());
    }
    if (route == AppRoutes.patients &&
        !Get.isRegistered<PatientsController>()) {
      Get.lazyPut<PatientsController>(() => PatientsController());
    }

    if (Get.isRegistered<RoleController>()) {
      return Obx(() {
        final isDoctor =
            RoleController.to.currentRole.value == ClinicRole.doctor;
        final isNurse =
            RoleController.to.currentRole.value == ClinicRole.nurse;
        final isDoctorProfileOpen =
            isDoctor &&
            route == AppRoutes.patients &&
            Get.isRegistered<PatientsController>() &&
            Get.find<PatientsController>().isDoctorProfileOpen.value;
        final isConsultationProfileOpen =
            !hideBottomNavigation &&
            route == AppRoutes.consultations &&
            Get.isRegistered<ConsultationController>() &&
            Get.find<ConsultationController>().isProfileOpen.value;
        final isNurseProfile =
            isNurse &&
            (child is NursePatientProfileView ||
                route == AppRoutes.nursePatientProfile);
        final isNurseRecordVitals =
            isNurse &&
            (child is RecordVitalsTriageView ||
                route == AppRoutes.recordVitalsTriage);
        final isLabStaff =
            RoleController.to.currentRole.value == ClinicRole.labStaff;
        final isImplementedInDoctor =
            route == AppRoutes.dashboard ||
            route == AppRoutes.queue ||
            route == AppRoutes.patients ||
            route == AppRoutes.consultations ||
            route == AppRoutes.patientDetails ||
            route == AppRoutes.appointments ||
            route == AppRoutes.labResults ||
            route == AppRoutes.labResultDetails;
        final isImplementedInLabStaff =
            route == AppRoutes.labReferral ||
            route == AppRoutes.labReferralDetails ||
            route == AppRoutes.labResults ||
            route == AppRoutes.labResultDetails ||
            route == AppRoutes.patientLabInfo;
        final isComingSoon =
            (isDoctor && !isImplementedInDoctor) ||
            (isLabStaff && !isImplementedInLabStaff);
        final pageContent = isComingSoon
            ? DoctorComingSoonView(title: RouteNames.titleOf(route))
            : child;
        return _buildBody(
          pageContent,
          showBottomNavigation:
              !hideBottomNavigation &&
              !isDoctorProfileOpen &&
              !isConsultationProfileOpen &&
              !isNurseProfile &&
              !isNurseRecordVitals,
        );
      });
    }

    if (route == AppRoutes.consultations &&
        !hideBottomNavigation &&
        Get.isRegistered<ConsultationController>()) {
      return Obx(() {
        final isConsultationProfileOpen =
            Get.find<ConsultationController>().isProfileOpen.value;
        return _buildBody(
          child,
          showBottomNavigation:
              !hideBottomNavigation && !isConsultationProfileOpen,
        );
      });
    }

    return _buildBody(child, showBottomNavigation: !hideBottomNavigation);
  }
}
