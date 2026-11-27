import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/features/patients/models/patient_record.dart';
import 'package:tendryn/features/queue/models/walk_in_patient.dart';
import 'package:tendryn/routes/app_routes.dart';

/// The Add Walk-in flow: step 1 finds a patient, step 2 captures the queue
/// details. One controller for the desktop drawer and the tablet/mobile pages.
class AddWalkInController extends GetxController {
  AddWalkInController({String? returnRoute})
      : returnRoute = returnRoute ?? AppRoutes.queue;

  final String returnRoute;

  /// Local stand-in until patient search is connected.
  static const patients = [
    WalkInPatient(name: 'Thabo Nkosi', fileNumber: 'PT-002184', dateOfBirth: '12 Mar 1982'),
    WalkInPatient(name: 'Thabo Mokoena', fileNumber: 'PT-003011', dateOfBirth: '04 Nov 1976'),
  ];
  static const priorities = ['Routine', 'Urgent', 'Emergency'];
  static const practitioners = ['Unassigned', 'Dr Thandi Maseko', 'Dr Sipho Khumalo', 'Nurse Z. Mthembu'];

  static const _initialQuery = 'Thabo';

  /// 1 = find patient, 2 = queue details.
  final step = 1.obs;

  final searchText = TextEditingController(text: _initialQuery);
  final query = _initialQuery.obs;
  final selected = Rxn<WalkInPatient>();

  final reason = TextEditingController(text: 'General consultation');
  final priority = priorities.first.obs;
  final practitioner = practitioners.first.obs;
  final whatsApp = true.obs;
  final consent = true.obs;

  /// The dropdown currently expanded: [priorities] or [practitioners]; null when closed.
  final openMenu = Rxn<List<String>>();

  /// Patients matching the search text (name or file number).
  List<WalkInPatient> get results {
    final text = query.value.trim().toLowerCase();
    final all = <WalkInPatient>[...patients];
    if (Get.isRegistered<PatientsController>()) {
      final dir = Get.find<PatientsController>();
      for (final p in dir.patients) {
        if (!all.any((existing) => existing.fileNumber == p.fileNumber)) {
          all.add(WalkInPatient(
            name: p.name,
            fileNumber: p.fileNumber,
            dateOfBirth: p.dateOfBirth,
          ));
        }
      }
    }
    return all.where((p) => p.name.toLowerCase().contains(text) || p.fileNumber.toLowerCase().contains(text)).toList();
  }

  void search(String text) => query.value = text;

  void clearSearch() {
    searchText.clear();
    query.value = '';
  }

  /// Picking a patient moves straight on to the queue details.
  void select(WalkInPatient patient) {
    selected.value = patient;
    step.value = 2;
  }

  void toggleMenu(List<String> menu) => openMenu.value = identical(openMenu.value, menu) ? null : menu;

  void choosePriority(String value) {
    priority.value = value;
    openMenu.value = null;
  }

  void choosePractitioner(String value) {
    practitioner.value = value;
    openMenu.value = null;
  }

  Future<void> onRegisterNewPatient() async {
    final context = Get.context;
    if (context == null || Get.key.currentState == null) return;
    try {
      final result = await Get.toNamed(
        AppRoutes.registerPatient,
        arguments: {'returnRoute': returnRoute, 'backLabel': 'Back to Add Walk-in'},
      );
      if (result is PatientRecord) {
        final walkIn = WalkInPatient(
          name: result.name,
          fileNumber: result.fileNumber,
          dateOfBirth: result.dateOfBirth,
        );
        searchText.text = result.name;
        query.value = result.name;
        select(walkIn);
      }
    } catch (_) {
      // In isolated tests where route table is omitted
    }
  }

  /// Step 1: continue with the picked patient. Step 2: add to the queue.
  void onContinue() {
    if (step.value == 2) {
      AppNotice.unavailable('Add to queue');
    } else if (selected.value == null) {
      Get.snackbar('Add Walk-in', 'Select a patient to continue.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    } else {
      step.value = 2;
    }
  }

  /// Header back: step 2 returns to the patient lookup, step 1 leaves the flow.
  void onBack() => step.value == 2 ? step.value = 1 : cancel();

  /// Leave the flow and return to the origin route.
  void cancel() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(returnRoute);
    }
  }

  @override
  void onClose() {
    searchText.dispose();
    reason.dispose();
    super.onClose();
  }
}
