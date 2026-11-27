import 'package:tendryn/routes/app_routes.dart';

/// Human-readable titles for routes (headers, navigation labels, tooltips).
abstract class RouteNames {
  static const dashboard = 'Dashboard';
  static const patientQuickView = 'Patient Quick View';
  static const patientSearchPreview = 'Patient Quick View';
  static const queue = 'Queue';
  static const patients = 'Patients';
  static const appointments = 'Appointments';
  static const bookAppointment = 'Book Appointment';
  static const billing = 'Billing';
  static const consultations = 'Consultations';
  static const labResults = 'Lab Results';
  static const vitalsTriage = 'Vitals / Triage';
  static const recordVitalsTriage = 'Vitals & Triage';
  static const labReferral = 'Lab Referral';
  static const labReferralDetails = 'Lab Referral Details';
  static const patientLabInfo = 'Patient Lab Information';

  static String titleOf(String route) => switch (route) {
        AppRoutes.dashboard => dashboard,
        AppRoutes.patientQuickView => patientQuickView,
        AppRoutes.patientSearchPreview => patientSearchPreview,
        AppRoutes.queue => queue,
        AppRoutes.patients => patients,
        AppRoutes.appointments => appointments,
        AppRoutes.bookAppointment => bookAppointment,
        AppRoutes.billing => billing,
        AppRoutes.consultations => consultations,
        AppRoutes.labResults => labResults,
        AppRoutes.vitalsTriage => vitalsTriage,
        AppRoutes.recordVitalsTriage => recordVitalsTriage,
        AppRoutes.labReferral => labReferral,
        AppRoutes.labReferralDetails => labReferralDetails,
        AppRoutes.patientLabInfo => patientLabInfo,
        _ => '',
      };
}
