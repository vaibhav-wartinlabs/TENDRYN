import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_guard.dart';
import 'package:tendryn/core/role/role_guard.dart';
import 'package:tendryn/features/appointments/bindings/appointment_conflicts_binding.dart';
import 'package:tendryn/features/appointments/bindings/book_appointment_binding.dart';
import 'package:tendryn/features/appointments/views/appointment_conflicts_view.dart';
import 'package:tendryn/features/appointments/views/appointment_details_view.dart';
import 'package:tendryn/features/appointments/bindings/appointments_binding.dart';
import 'package:tendryn/features/appointments/bindings/appointment_detail_binding.dart';
import 'package:tendryn/features/appointments/bindings/availability_binding.dart';
import 'package:tendryn/features/appointments/bindings/edit_availability_binding.dart';
import 'package:tendryn/features/appointments/bindings/reschedule_binding.dart';
import 'package:tendryn/features/appointments/views/reschedule_view.dart';
import 'package:tendryn/features/appointments/views/edit_availability_view.dart';
import 'package:tendryn/features/appointments/views/appointment_detail_view.dart';
import 'package:tendryn/features/appointments/views/availability_view.dart';
import 'package:tendryn/features/appointments/views/appointments_view.dart';
import 'package:tendryn/features/appointments/views/book_appointment_view.dart';
import 'package:tendryn/features/appointments/widgets/doctor_appointments.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/billing/bindings/billing_binding.dart';
import 'package:tendryn/features/billing/views/billing_view.dart';
import 'package:tendryn/features/billing/views/invoice_details_view.dart';
import 'package:tendryn/features/dashboard/bindings/dashboard_binding.dart';
import 'package:tendryn/features/dashboard/views/dashboard_view.dart';
import 'package:tendryn/features/login/bindings/login_binding.dart';
import 'package:tendryn/features/login/views/login_view.dart';
import 'package:tendryn/features/patients/bindings/patient_details_binding.dart';
import 'package:tendryn/features/patients/bindings/patient_edit_binding.dart';
import 'package:tendryn/features/patients/bindings/patients_binding.dart';
import 'package:tendryn/features/patients/bindings/register_patient_binding.dart';
import 'package:tendryn/features/patients/views/patient_details_view.dart';
import 'package:tendryn/features/patients/views/patient_edit_view.dart';
import 'package:tendryn/features/patients/views/patients_view.dart';
import 'package:tendryn/features/patients/views/register_patient_view.dart';
import 'package:tendryn/features/queue/bindings/add_walk_in_binding.dart';
import 'package:tendryn/features/queue/bindings/nurse_patient_profile_binding.dart';
import 'package:tendryn/features/queue/bindings/queue_binding.dart';
import 'package:tendryn/features/queue/views/add_walk_in_view.dart';
import 'package:tendryn/features/queue/views/nurse_patient_profile_view.dart';
import 'package:tendryn/features/queue/views/nurse_triage_view.dart';
import 'package:tendryn/features/queue/controllers/record_sample_controller.dart';
import 'package:tendryn/features/queue/views/record_sample_view.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';
import 'package:tendryn/features/queue/views/queue_view.dart';
import 'package:tendryn/features/patients/bindings/patient_quick_view_binding.dart';
import 'package:tendryn/features/patients/views/patient_quick_view.dart';
import 'package:tendryn/features/patients/bindings/patient_front_desk_preview_binding.dart';
import 'package:tendryn/features/patients/views/patient_front_desk_preview_view.dart';
import 'package:tendryn/features/splash/bindings/splash_binding.dart';
import 'package:tendryn/features/splash/views/splash_view.dart';
import 'package:tendryn/features/consultation/bindings/consultation_binding.dart';
import 'package:tendryn/features/consultation/views/consultation_view.dart';
import 'package:tendryn/features/consultation/views/consultation_workspace_view.dart';
import 'package:tendryn/features/lab_results/bindings/lab_results_binding.dart';
import 'package:tendryn/features/lab_results/bindings/lab_result_details_binding.dart';
import 'package:tendryn/features/lab_results/views/lab_results_view.dart';
import 'package:tendryn/features/lab_results/views/lab_result_details_view.dart';
import 'package:tendryn/features/lab_results/views/lab_referral_view.dart';
import 'package:tendryn/features/lab_results/views/patient_lab_info_view.dart';
import 'package:tendryn/features/lab_results/views/lab_referral_details_view.dart';
import 'package:tendryn/features/lab_results/models/lab_referral_model.dart';
import 'package:tendryn/features/lab_results/controllers/lab_referral_controller.dart';
import 'package:tendryn/features/vitals_triage/bindings/record_vitals_triage_binding.dart';
import 'package:tendryn/features/vitals_triage/bindings/vitals_triage_binding.dart';
import 'package:tendryn/features/vitals_triage/views/record_vitals_triage_view.dart';
import 'package:tendryn/features/vitals_triage/views/vitals_triage_view.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/widgets/common/app_shell.dart';

/// The single route table. Each page declares its Binding; the main
/// destinations share the AppShell chrome and the auth guard.
abstract class AppPages {
  static const initial = AppRoutes.splash;

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: LoginBinding()),
    _shellPage(AppRoutes.dashboard, const DashboardView(), DashboardBinding()),
    _shellPage(AppRoutes.queue, const QueueView(), QueueBinding()),
    // Page shells (heading only for now); each gets its own binding when it gets real state.
    _shellPage(AppRoutes.patients, const PatientsView(), PatientsBinding()),
    _shellPage(AppRoutes.appointments, const AppointmentsView(), AppointmentsBinding()),
    _shellPage(AppRoutes.billing, const BillingView(), BillingBinding()),
    _shellPage(
      AppRoutes.consultations,
      const ConsultationView(),
      ConsultationBinding(),
    ),
    GetPage(
      name: AppRoutes.consultationWorkspace,
      page: () => const ConsultationWorkspaceView(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    _shellPage(
      AppRoutes.labResults,
      const LabResultsView(),
      LabResultsBinding(),
    ),
    GetPage(
      name: AppRoutes.labResultDetails,
      page: () => const LabResultDetailsView(),
      binding: LabResultDetailsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    _shellPage(
      AppRoutes.labReferral,
      const LabReferralView(),
      BindingsBuilder(() {
        Get.lazyPut<LabReferralController>(() => LabReferralController(), fenix: true);
      }),
    ),
    _shellPage(
      AppRoutes.patientLabInfo,
      const PatientLabInfoView(),
      BindingsBuilder(() {
        Get.lazyPut<LabReferralController>(() => LabReferralController(), fenix: true);
      }),
    ),
    GetPage(
      name: AppRoutes.labReferralDetails,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final referral = args?['referral'] as LabReferralModel? ??
            LabReferralController.to.referrals.first;
        return AppShell(
          route: AppRoutes.labReferralDetails,
          hideBottomNavigation: true,
          hideMobileHeader: true,
          child: LabReferralDetailsView(
            referral: referral,
            onClose: () => Get.back(),
          ),
        );
      },
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    // Nurse destination: Vitals / Triage queue screen.
    _shellPage(
      AppRoutes.vitalsTriage,
      const VitalsTriageView(),
      VitalsTriageBinding(),
    ),
    // Nurse Record observations screen (Begin triage).
    GetPage(
      name: AppRoutes.recordVitalsTriage,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final from = args?['from'] as String?;
        final shellRoute = switch (from) {
          'patients' => AppRoutes.patients,
          'queue' => AppRoutes.queue,
          _ => AppRoutes.vitalsTriage,
        };
        return AppShell(
          route: shellRoute,
          hideMobileHeader: true,
          hideBottomNavigation: true,
          child: const RecordVitalsTriageView(),
        );
      },
      binding: RecordVitalsTriageBinding(),
      middlewares: [AuthGuard(), RoleGuard()],
      transition: Transition.noTransition,
    ),
    // Nurse Patient profile, opened from a Queue row or Patients directory. Inside the shell with
    // appropriate active route; the phone shows its own heading instead of the brand header.
    GetPage(
      name: AppRoutes.nursePatientProfile,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final from = args?['from'] as String?;
        final shellRoute = switch (from) {
          'patients' => AppRoutes.patients,
          'vitals-triage' => AppRoutes.vitalsTriage,
          _ => AppRoutes.queue,
        };
        return AppShell(
          route: shellRoute,
          hideMobileHeader: true,
          hideBottomNavigation: true,
          child: const NursePatientProfileView(),
        );
      },
      binding: NursePatientProfileBinding(),
      middlewares: [AuthGuard(), RoleGuard()],
      transition: Transition.noTransition,
    ),
    // Nurse past-visit Triage, full page on tablets (desktop uses a drawer, phones a sheet).
    GetPage(
      name: AppRoutes.nurseTriageDetail,
      page: () => AppShell(
        route: AppRoutes.queue,
        hideMobileHeader: true,
        hideBottomNavigation: true,
        child: NurseTriagePage(record: (Get.arguments as Map<String, dynamic>)['record'] as TriageRecord),
      ),
      middlewares: [AuthGuard(), RoleGuard()],
      transition: Transition.noTransition,
    ),
    // Nurse read-only Consultations, full page on tablets (desktop uses a drawer, phones a sheet).
    GetPage(
      name: AppRoutes.nurseConsultations,
      page: () => AppShell(
        route: AppRoutes.queue,
        hideMobileHeader: true,
        hideBottomNavigation: true,
        child: NurseConsultationsPage(
          record: (Get.arguments as Map<String, dynamic>)['record'] as PatientRecordRef,
        ),
      ),
      middlewares: [AuthGuard(), RoleGuard()],
      transition: Transition.noTransition,
    ),
    // Nurse read-only Prescriptions, same presentation as Consultations.
    GetPage(
      name: AppRoutes.nursePrescriptions,
      page: () => AppShell(
        route: AppRoutes.queue,
        hideMobileHeader: true,
        hideBottomNavigation: true,
        child: NursePrescriptionsPage(
          record: (Get.arguments as Map<String, dynamic>)['record'] as PatientRecordRef,
        ),
      ),
      middlewares: [AuthGuard(), RoleGuard()],
      transition: Transition.noTransition,
    ),
    // Nurse Lab Referral Details, full page on tablets (desktop uses a drawer, phones a sheet).
    GetPage(
      name: AppRoutes.nurseLabReferral,
      page: () => AppShell(
        route: AppRoutes.queue,
        hideBottomNavigation: true,
        child: NurseLabReferralPage(
          detail: (Get.arguments as Map<String, dynamic>)['detail'] as LabReferralDetail,
        ),
      ),
      middlewares: [AuthGuard(), RoleGuard()],
      transition: Transition.noTransition,
    ),
    // Nurse Record Sample form, full page on tablets (desktop uses a drawer, phones a sheet).
    GetPage(
      name: AppRoutes.nurseRecordSample,
      page: () => const AppShell(
        route: AppRoutes.queue,
        hideMobileHeader: true,
        hideBottomNavigation: true,
        child: NurseRecordSamplePage(),
      ),
      binding: BindingsBuilder(() {
        final detail = (Get.arguments as Map<String, dynamic>)['detail'] as LabReferralDetail;
        // A fresh form on every opening, never a leftover one.
        Get.delete<RecordSampleController>(force: true);
        Get.put(RecordSampleController(detail: detail));
      }),
      middlewares: [AuthGuard(), RoleGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.invoiceDetails,
      page: () => const InvoiceDetailsView(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.appointmentDetail,
      page: () => const AppointmentDetailView(),
      binding: AppointmentDetailBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.rescheduleAppointment,
      page: () => const RescheduleView(),
      binding: RescheduleBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.editAvailability,
      page: () => const EditAvailabilityView(),
      binding: EditAvailabilityBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.manageAvailability,
      page: () => const AvailabilityView(),
      binding: AvailabilityBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.registerPatient,
      page: () => const RegisterPatientView(),
      binding: RegisterPatientBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.patientEdit,
      page: () => const PatientEditView(),
      binding: PatientEditBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.patientDetails,
      page: () => const PatientDetailsView(),
      binding: PatientDetailsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.addWalkIn,
      page: () => const AddWalkInView(),
      binding: AddWalkInBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.patientQuickView,
      page: () => const PatientQuickView(),
      binding: PatientQuickViewBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.patientSearchPreview,
      page: () => const PatientFrontDeskPreviewView(),
      binding: PatientFrontDeskPreviewBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.appointmentDetails,
      page: () => const AppointmentDetailsView(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>?;
        final entry = args?['appointment'] as AppointmentEntry?;
        final details = args?['details'] as AppointmentDetailsModel?;
        Get.lazyPut<AppointmentDetailsController>(() => AppointmentDetailsController(
          initialAppointment: entry,
          initialDetails: details,
        ));
      }),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    // Doctor appointment details on tablets, inside the shell with Appointments selected.
    GetPage(
      name: AppRoutes.doctorAppointmentDetails,
      page: () => const AppShell(route: AppRoutes.appointments, child: DoctorAppointmentDetailsPage()),
      binding: AppointmentsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    // Doctor Request Leave on tablets, inside the shell with Appointments selected.
    GetPage(
      name: AppRoutes.doctorLeaveRequest,
      page: () => const AppShell(route: AppRoutes.appointments, child: DoctorLeaveRequestPage()),
      binding: AppointmentsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.bookAppointment,
      page: () => const BookAppointmentView(),
      binding: BookAppointmentBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.appointmentConflicts,
      page: () => const AppointmentConflictsView(),
      binding: AppointmentConflictsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.noTransition,
    ),
  ];

  static GetPage<dynamic> _shellPage(String route, Widget view, [Bindings? binding]) => GetPage(
        name: route,
        page: () => AppShell(route: route, child: view),
        binding: binding,
        middlewares: [AuthGuard(), RoleGuard()],
        transition: Transition.noTransition,
      );
}
