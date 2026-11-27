import 'package:get/get.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/queue/controllers/queue_controller.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';
import 'package:tendryn/features/queue/views/nurse_triage_view.dart';
import 'package:tendryn/routes/app_routes.dart';

/// The Profile tabs of the Nurse Patient profile.
enum NurseProfileTab {
  overview('Overview'),
  clinicalHistory('Clinical History'),
  labReferrals('Lab referrals');

  const NurseProfileTab(this.label);

  final String label;
}

/// State of the Nurse Patient profile. The queue row's [QueueEntry] arrives as
/// the route argument `entry`; [profile] is built from it.
class NursePatientProfileController extends GetxController {
  NursePatientProfileController({
    required this.profile,
    this.fromPatients = false,
    this.fromSource,
  });

  final NursePatientProfile profile;
  final bool fromPatients;
  final String? fromSource;

  String get backLabel {
    if (fromSource == 'vitals-triage') return 'Back to Vitals / Triage';
    if (fromPatients || fromSource == 'patients') return 'Back to Patients';
    return 'Back to Queue';
  }

  final tab = NurseProfileTab.overview.obs;
  late final referrals = RxList<LabReferral>(profile.labReferrals);

  void updateReferral(LabReferral updated) {
    final index = referrals.indexWhere((r) => r.test == updated.test);
    if (index != -1) {
      referrals[index] = updated;
    } else {
      referrals.add(updated);
    }
  }

  LabReferralDetail referralDetailFor(LabReferral referral) {
    final current = referrals.firstWhereOrNull((r) => r.test == referral.test) ?? referral;
    return LabReferralDetail(
      patientName: profile.name,
      patientId: profile.patientId,
      referral: current,
    );
  }

  /// Opens the profile of [entry]. The Queue stays underneath so [back] returns
  /// to it with its search, filter, page and scroll position intact.
  static void open(QueueEntry entry, {String? from}) {
    Get.toNamed(AppRoutes.nursePatientProfile, arguments: {
      'entry': entry,
      'from': ?from,
    });
  }

  void selectTab(NurseProfileTab value) {
    tab.value = value;
  }

  /// "View triage" on a past visit: opens its read-only triage (drawer on
  /// desktop, full page on tablet, sheet on phone). Back or Close returns here.
  void viewTriage(VisitHistoryEntry visit) {
    final context = Get.context;
    if (context == null) return;
    showNurseTriage(context, profile.triageFor(visit), onCallPatient: callPatient);
  }

  /// Opens the read-only triage from the "Read only" badge in Clinical records.
  void viewClinicalRecordTriage() {
    final context = Get.context;
    if (context == null) return;
    final pastVisit = profile.visits.firstWhereOrNull((v) => !v.current);
    final visit = pastVisit ?? profile.visits.firstOrNull;
    if (visit != null) {
      showNurseTriage(context, profile.triageFor(visit), onCallPatient: callPatient);
    }
  }

  /// The phone triage sheet's "Call patient": the same confirmation as Call next,
  /// for this patient, if they are still waiting in the queue.
  void callPatient() {
    if (!Get.isRegistered<QueueController>()) return;
    final queue = Get.find<QueueController>();
    final entry = queue.queue.value?.entries.where((e) => e.number == profile.queueNumber).firstOrNull;
    if (entry == null) {
      AppNotice.info('Call patient', '${profile.name} is not in the queue.');
      return;
    }
    queue.callPatient(entry);
  }

  /// "View Details" on a lab referral: its read-only details (drawer on desktop,
  /// full page on tablet, sheet on phone). Close or back returns to Lab referrals.
  void viewReferralDetails(LabReferral referral) {
    final context = Get.context;
    if (context == null) return;
    showNurseLabReferral(context, referralDetailFor(referral));
  }

  /// "View consultations": the read-only Consultations view (drawer on desktop,
  /// full page on tablet, sheet on phone). Close or back returns to the history.
  void viewConsultations() {
    final context = Get.context;
    if (context == null) return;
    showNurseConsultations(context, profile.recordRef);
  }

  /// "View Prescription": the read-only Prescriptions view, presented like Consultations.
  void viewPrescriptions() {
    final context = Get.context;
    if (context == null) return;
    showNursePrescriptions(context, profile.recordRef);
  }

  /// Opens the Record Vitals & Triage page.
  void startTriage() =>
      Get.toNamed(AppRoutes.recordVitalsTriage, arguments: {'profile': profile});

  /// Back to the Queue, Patients directory or Vitals / Triage. Falls back to replacing the page when the profile was
  /// opened directly (nothing underneath to pop).
  void back() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      if (fromSource == 'vitals-triage') {
        Get.offNamed(AppRoutes.vitalsTriage);
      } else {
        Get.offNamed(fromPatients ? AppRoutes.patients : AppRoutes.queue);
      }
    }
  }
}
