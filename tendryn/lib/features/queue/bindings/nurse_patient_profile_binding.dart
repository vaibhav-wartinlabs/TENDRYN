import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/queue/controllers/nurse_patient_profile_controller.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';

class NursePatientProfileBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final entry = args?['entry'] as QueueEntry?;
    final from = args?['from'] as String?;
    final fromPatients = from == 'patients';
    // Opened without a patient (e.g. a reload on the route): show the first
    // sample patient rather than an empty page.
    final nurse = Get.isRegistered<AuthController>() ? Get.find<AuthController>().user?.name : null;
    final profile = NursePatientProfile.fromQueueEntry(
      entry ?? _fallback,
      recordedBy: nurse ?? ClinicRole.nurse.demoUserName,
    );
    Get.delete<NursePatientProfileController>(force: true);
    Get.put(NursePatientProfileController(
      profile: profile,
      fromPatients: fromPatients,
      fromSource: from,
    ));
  }

  static const _fallback = QueueEntry(
    number: 'Q014',
    patient: 'John Smith',
    arrival: '08:42',
    waitingMinutes: 24,
    reason: 'Headache',
    priority: QueuePriority.routine,
    status: QueueStatus.waiting,
    practitioner: 'Dr Thandi Nkosi',
    demographics: '42/M',
  );
}
