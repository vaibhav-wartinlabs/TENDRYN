abstract class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';

  // Dashboard / queue / leave
  static const String dashboardSummary = '/dashboard/summary';
  static const String queue = '/queue';
  static const String leaveRequests = '/leave-requests';

  // Patients
  static const String patients = '/patients';
  static const String patientsSearch = '/patients/search';
  static const String patientsStats = '/patients/stats';
  static String patient(String id) => '/patients/$id';

  // Appointments
  static const String appointments = '/appointments';
  static String appointmentCheckIn(String id) => '/appointments/$id/check-in';
  static String appointmentReschedule(String id) => '/appointments/$id/reschedule';
  static String appointmentCancel(String id) => '/appointments/$id/cancel';
  static String appointmentNoShow(String id) => '/appointments/$id/no-show';

  // Consultations / clinical
  static const String consultations = '/consultations';
  static const String encounters = '/encounters';
  static String encounter(String id) => '/encounters/$id';
  static String encounterSignOff(String id) => '/encounters/$id/sign-off';
  static String encounterDiagnoses(String id) => '/encounters/$id/diagnoses';
  static String encounterPrescriptions(String id) => '/encounters/$id/prescriptions';
  static String encounterAddenda(String id) => '/encounters/$id/addenda';
  static const String vitals = '/vitals';

  // Billing
  static const String invoices = '/invoices';
  static String invoice(String id) => '/invoices/$id';
  static const String payments = '/payments';
  static const String cashUps = '/cash-ups';
  static const String billingSummary = '/billing/summary';

  // Lab
  static const String labReferrals = '/lab/referrals';
  static String labReferral(String id) => '/lab/referrals/$id';
  static String labReferralSample(String id) => '/lab/referrals/$id/sample';
  static String labReferralResult(String id) => '/lab/referrals/$id/result';
  static const String labResults = '/lab/results';
  static String labResult(String id) => '/lab/results/$id';
  static String labResultReview(String id) => '/lab/results/$id/review';

  /// Paths that must not carry a bearer token or trigger a refresh.
  static const List<String> public = [login, refresh];
}
