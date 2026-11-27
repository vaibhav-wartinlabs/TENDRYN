import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/queue/controllers/nurse_patient_profile_controller.dart';
import 'package:tendryn/features/queue/models/nurse_patient_profile.dart';
import 'package:tendryn/features/vitals_triage/controllers/vitals_triage_controller.dart';
import 'package:tendryn/features/vitals_triage/models/vitals_triage_model.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Controller for the "Vitals & Triage" record observations screen.
class RecordVitalsTriageController extends GetxController {
  // Patient details
  late final String patientName;
  late final String patientId;
  late final String queueNumber;
  late final String visitDate;
  late final String sex;
  late final int age;
  late final String queueStatus;
  late final String allergy;
  late final String initials;

  // Selected priority in Card C
  final selectedPriority = QueuePriority.routine.obs;

  // Form input controllers
  late final TextEditingController presentingComplaintController;
  late final TextEditingController bloodPressureController;
  late final TextEditingController pulseController;
  late final TextEditingController temperatureController;
  late final TextEditingController weightController;
  late final TextEditingController heightController;
  late final TextEditingController bloodGlucoseController;
  late final TextEditingController oxygenSaturationController;
  late final TextEditingController triageNotesController;

  // Reactive BMI string
  final bmiString = '25.2 kg/m²'.obs;

  // Reactive flag indicating whether review mode / drawer is open
  final isReviewing = false.obs;

  // Track original entry if opened from vitals queue
  VitalsTriageEntry? originalEntry;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;
    final entry = args?['entry'] as VitalsTriageEntry?;
    final queueEntry = args?['queueEntry'] as QueueEntry?;
    final profile = args?['profile'] as NursePatientProfile?;

    originalEntry = entry;

    if (entry != null) {
      patientName = entry.patientName;
      patientId = entry.patientId;
      queueNumber = entry.queueNumber;
      visitDate = '26 Oct 2026';
      sex = entry.sex == 'M' ? 'Male' : (entry.sex == 'F' ? 'Female' : entry.sex);
      age = entry.age;
      queueStatus = 'With Nurse';
      allergy = 'Penicillin';
      selectedPriority.value = entry.priority;
    } else if (queueEntry != null) {
      patientName = queueEntry.patient;
      patientId = 'TND-000124';
      queueNumber = queueEntry.number;
      visitDate = '26 Oct 2026';
      sex = 'Male';
      age = 42;
      queueStatus = 'With Nurse';
      allergy = 'Penicillin';
      selectedPriority.value = queueEntry.priority;
    } else if (profile != null) {
      patientName = profile.name;
      patientId = profile.patientId;
      queueNumber = profile.queueNumber;
      visitDate = '26 Oct 2026';
      sex = profile.sex;
      age = profile.ageYears ?? 42;
      queueStatus = 'With Nurse';
      allergy = profile.allergies.isNotEmpty ? profile.allergies.first : 'Penicillin';
      selectedPriority.value = profile.priority;
    } else {
      // Default to Figma reference patient
      patientName = 'John Smith';
      patientId = 'TND-000124';
      queueNumber = 'Q-012';
      visitDate = '26 Oct 2026';
      sex = 'Male';
      age = 42;
      queueStatus = 'With Nurse';
      allergy = 'Penicillin';
      selectedPriority.value = QueuePriority.routine;
    }

    initials = _computeInitials(patientName);

    // Initial form field values
    final reason = entry?.reason ?? queueEntry?.reason ?? 'Headache';
    presentingComplaintController = TextEditingController(text: reason);
    bloodPressureController = TextEditingController(text: '128/84');
    pulseController = TextEditingController(text: '76');
    temperatureController = TextEditingController(text: '36.8');
    weightController = TextEditingController(text: '78');
    heightController = TextEditingController(text: '176');
    bloodGlucoseController = TextEditingController(text: '5.4');
    oxygenSaturationController = TextEditingController(text: '98');
    triageNotesController = TextEditingController(
      text: 'Patient alert and orientated. Penicillin allergy confirmed with patient.',
    );

    weightController.addListener(_updateBmi);
    heightController.addListener(_updateBmi);
    _updateBmi();
  }

  void _updateBmi() {
    final w = double.tryParse(weightController.text.trim());
    final h = double.tryParse(heightController.text.trim());
    if (w != null && h != null && h > 0) {
      final hM = h / 100.0;
      final bmi = w / (hM * hM);
      bmiString.value = '${bmi.toStringAsFixed(1)} kg/m²';
    } else {
      bmiString.value = '—';
    }
  }

  static String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void setPriority(QueuePriority priority) {
    selectedPriority.value = priority;
  }

  void cancel() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      AppNavigation.goTo(AppRoutes.vitalsTriage);
    }
  }

  void saveTriage() {
    AppNotice.info('Triage saved', 'Progress has been saved as draft for $patientName.');
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      AppNavigation.goTo(AppRoutes.vitalsTriage);
    }
  }

  void reviewTriage() {
    if (presentingComplaintController.text.trim().isEmpty) {
      AppNotice.info('Required field', 'Please provide a presenting complaint.');
      return;
    }
    isReviewing.value = true;
  }

  void completeTriage() {
    // Update entry in VitalsTriageController if registered
    if (Get.isRegistered<VitalsTriageController>() && originalEntry != null) {
      final vtController = Get.find<VitalsTriageController>();
      final updated = VitalsTriageEntry(
        queueNumber: originalEntry!.queueNumber,
        patientName: originalEntry!.patientName,
        patientId: originalEntry!.patientId,
        sex: originalEntry!.sex,
        age: originalEntry!.age,
        waitingTime: originalEntry!.waitingTime,
        waitingMinutes: originalEntry!.waitingMinutes,
        reason: presentingComplaintController.text.trim().isEmpty
            ? 'Headache'
            : presentingComplaintController.text.trim(),
        status: VitalsTriageStatus.waitingForDoctor,
        priority: selectedPriority.value,
      );
      final idx = vtController.entries.indexWhere((e) => e.queueNumber == updated.queueNumber);
      if (idx >= 0) {
        vtController.entries[idx] = updated;
      }
    }
    isReviewing.value = false;
  }

  void viewPatient() {
    final entry = originalEntry?.toQueueEntry() ??
        QueueEntry(
          number: queueNumber,
          patient: patientName,
          arrival: '08:42',
          waitingMinutes: 24,
          priority: selectedPriority.value,
          status: QueueStatus.waitingForDoctor,
          reason: presentingComplaintController.text.trim().isEmpty
              ? 'Headache'
              : presentingComplaintController.text.trim(),
          practitioner: 'Dr Thandi Nkosi',
          demographics: '$age/${sex.startsWith('M') ? 'M' : 'F'}',
        );
    NursePatientProfileController.open(entry, from: 'vitals-triage');
  }

  @override
  void onClose() {
    weightController.removeListener(_updateBmi);
    heightController.removeListener(_updateBmi);
    presentingComplaintController.dispose();
    bloodPressureController.dispose();
    pulseController.dispose();
    temperatureController.dispose();
    weightController.dispose();
    heightController.dispose();
    bloodGlucoseController.dispose();
    oxygenSaturationController.dispose();
    triageNotesController.dispose();
    super.onClose();
  }
}
