import 'package:get/get.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/features/patients/widgets/patients_nurse.dart';
import 'package:tendryn/features/queue/controllers/nurse_patient_profile_controller.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Patients directory state for the mobile, tablet and desktop layouts.
class PatientsController extends GetxController {
  /// Rows per page in the desktop table.
  static const pageSize = 5;

  /// Headline figures from the design.
  static const totalPatients = '1,248';
  static const recentlySeen = '38';
  static const inQueue = '12';
  static const recentlyAdded = '2';

  /// Local stand-in matching the design prototype.
  static const seed = [
    PatientRecord(
      name: 'John Smith',
      fileNumber: 'SWC-10427',
      dateOfBirth: '14 May 1980',
      mobile: '082 ••• ••11',
      lastVisit: 'Today',
      careFlags: 'Penicillin allergy',
    ),
    PatientRecord(
      name: 'Nomsa Dlamini',
      fileNumber: 'SWC-41782',
      dateOfBirth: '22 Aug 1975',
      mobile: '083 ••• ••22',
      lastVisit: 'Today',
      careFlags: 'Diabetes',
    ),
    PatientRecord(
      name: 'Sipho Khumalo',
      fileNumber: 'SWC-62091',
      dateOfBirth: '09 Oct 1988',
      mobile: '072 ••• ••33',
      lastVisit: '09 Oct 2026',
      careFlags: 'Hypertension',
    ),
    PatientRecord(
      name: 'Lerato Maseko',
      fileNumber: 'SWC-33158',
      dateOfBirth: '15 Jan 1992',
      mobile: '084 ••• ••44',
      lastVisit: '08 Oct 2026',
      careFlags: '—',
    ),
    PatientRecord(
      name: 'Michael van der Merwe',
      fileNumber: 'SWC-20865',
      dateOfBirth: '03 Mar 1968',
      mobile: '079 ••• ••55',
      lastVisit: '07 Oct 2026',
      careFlags: '—',
    ),
  ];

  /// Nurse patients matching Figma prototype.
  static const nurseSeed = [
    NursePatientRecord(
      name: 'John Smith',
      patientId: 'TND-000124',
      sex: 'Male',
      age: 42,
      lastVisit: 'Today · Headache',
      queueNumber: 'Q014',
      reason: 'Headache',
      priority: QueuePriority.routine,
      status: QueueStatus.waiting,
    ),
    NursePatientRecord(
      name: 'Kabelo Mokoena',
      patientId: 'TND-000131',
      sex: 'Male',
      age: 36,
      lastVisit: 'Today · Back pain',
      queueNumber: 'Q018',
      reason: 'Back pain',
      priority: QueuePriority.emergency,
      status: QueueStatus.waiting,
    ),
    NursePatientRecord(
      name: 'Thabo Mokoena',
      patientId: 'TND-000118',
      sex: 'Male',
      age: 45,
      lastVisit: 'Today · Chest pain',
      queueNumber: 'Q019',
      reason: 'Chest pain',
      priority: QueuePriority.routine,
      status: QueueStatus.waiting,
    ),
    NursePatientRecord(
      name: 'Naledi Molefe',
      patientId: 'TND-000097',
      sex: 'Female',
      age: 29,
      lastVisit: 'Today · Fever and cough',
      queueNumber: 'Q015',
      reason: 'Fever and cough',
      priority: QueuePriority.urgent,
      status: QueueStatus.waiting,
    ),
    NursePatientRecord(
      name: 'Sipho Dlamini',
      patientId: 'TND-000085',
      sex: 'Male',
      age: 61,
      lastVisit: 'Today · Follow-up visit',
      queueNumber: 'Q016',
      reason: 'Follow-up visit',
      priority: QueuePriority.routine,
      status: QueueStatus.withNurse,
    ),
  ];

  /// The directory; a saved edit replaces its record here.
  final patients = <PatientRecord>[...seed].obs;

  final nursePatients = <NursePatientRecord>[...nurseSeed].obs;

  final searchQuery = ''.obs;

  static PatientRecord? _pendingDoctorProfile;

  /// Asks the Patients screen to open the Doctor profile of [patient] when it
  /// next appears (used by Appointment details, which lives on another route).
  static void requestDoctorProfile(PatientRecord patient) => _pendingDoctorProfile = patient;

  /// The profile requested by [requestDoctorProfile], once.
  static PatientRecord? takePendingDoctorProfile() {
    final patient = _pendingDoctorProfile;
    _pendingDoctorProfile = null;
    return patient;
  }

  /// Folder number of the patient whose action menu is open (defaults to Sipho Khumalo to match prototype).
  final activeMenuFolderNumber = 'SWC-62091'.obs;

  /// True while doctor views a patient profile inline on mobile or tablet.
  final isDoctorProfileOpen = false.obs;

  /// 1-based.
  final page = 1.obs;

  /// Patients matching the search text (name, file number, care flags or mobile).
  List<PatientRecord> get filtered {
    final text = searchQuery.value.trim().toLowerCase();
    if (text.isEmpty) return patients;
    return patients.where((p) =>
      p.name.toLowerCase().contains(text) ||
      p.fileNumber.toLowerCase().contains(text) ||
      p.mobile.contains(text) ||
      (p.careFlags != null && p.careFlags!.toLowerCase().contains(text)) ||
      (p.queueNumber != null && p.queueNumber!.toLowerCase().contains(text))
    ).toList();
  }

  /// Nurse patients matching search query.
  List<NursePatientRecord> get filteredNursePatients {
    final text = searchQuery.value.trim().toLowerCase();
    if (text.isEmpty) return nursePatients;
    return nursePatients.where((p) =>
      p.name.toLowerCase().contains(text) ||
      p.patientId.toLowerCase().contains(text) ||
      p.queueNumber.toLowerCase().contains(text) ||
      p.reason.toLowerCase().contains(text) ||
      p.lastVisit.toLowerCase().contains(text)
    ).toList();
  }

  int get pageCount => (filtered.length / pageSize).ceil().clamp(1, 1 << 30);

  /// The rows of the current page.
  List<PatientRecord> get pageEntries {
    final all = filtered;
    final start = ((page.value - 1) * pageSize).clamp(0, all.length);
    return all.sublist(start, (start + pageSize).clamp(0, all.length));
  }

  /// `Showing 1–4 of 4 patients`
  String get rangeLabel {
    final total = filtered.length;
    if (total == 0) return 'Showing 0 of 0 patients';
    final start = (page.value - 1) * pageSize + 1;
    final end = (start + pageSize - 1).clamp(start, total);
    return 'Showing $start–$end of $total patients';
  }

  void search(String text) {
    searchQuery.value = text;
    page.value = 1;
  }

  void goToPage(int target) => page.value = target.clamp(1, pageCount);

  void setDoctorProfileOpen(bool open) => isDoctorProfileOpen.value = open;

  @override
  void onClose() {
    isDoctorProfileOpen.value = false;
    super.onClose();
  }

  /// Adds a newly registered patient at the top of the directory.
  void addPatient(PatientRecord patient) => patients.insert(0, patient);

  /// Replaces the record with the same file number.
  void updatePatient(PatientRecord updated) {
    final i = patients.indexWhere((p) => p.fileNumber == updated.fileNumber);
    if (i >= 0) patients[i] = updated;
  }

  /// Opens Patient Details for [patient].
  void viewPatient(PatientRecord patient) => Get.toNamed(AppRoutes.patientDetails, arguments: patient);

  /// Opens Nurse Patient profile for [record].
  void openNursePatient(NursePatientRecord record) {
    NursePatientProfileController.open(record.toQueueEntry(), from: 'patients');
  }

  /// Opens the Register Patient flow.
  void registerPatient() => Get.toNamed(AppRoutes.registerPatient);

  void openQueue() => AppNavigation.goTo(AppRoutes.queue);
}
