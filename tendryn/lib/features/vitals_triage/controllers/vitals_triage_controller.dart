import 'package:get/get.dart';
import 'package:tendryn/features/queue/controllers/nurse_patient_profile_controller.dart';
import 'package:tendryn/features/vitals_triage/models/vitals_triage_model.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Controller for the Vitals & Triage nurse screen.
class VitalsTriageController extends GetxController {
  VitalsTriageController({List<VitalsTriageEntry>? seed}) {
    if (seed != null) {
      entries.assignAll(seed);
    }
  }

  /// Reactive list of triage queue entries.
  final entries = RxList<VitalsTriageEntry>(vitalsTriageSeed);

  /// Search query for filtering patients.
  final searchQuery = ''.obs;

  /// Current active page for pagination.
  final activePage = 1.obs;

  /// Total pages available (for Figma demonstration, 5-10 pages).
  final totalPages = 5.obs;

  /// Total count of patients across all pages (Figma shows 24).
  final totalCount = 24.obs;

  /// Number of patients awaiting triage in the current queue.
  int get awaitingTriageCount =>
      entries.where((e) => e.status == VitalsTriageStatus.waiting).length;

  /// Filtered entries based on [searchQuery].
  List<VitalsTriageEntry> get filteredEntries {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return entries;
    return entries.where((entry) {
      return entry.patientName.toLowerCase().contains(query) ||
          entry.patientId.toLowerCase().contains(query) ||
          entry.queueNumber.toLowerCase().contains(query) ||
          entry.reason.toLowerCase().contains(query);
    }).toList();
  }

  /// Updates the search filter.
  void search(String query) {
    searchQuery.value = query;
  }

  /// Changes the current pagination page.
  void selectPage(int page) {
    activePage.value = page;
  }

  /// Advances to the next page.
  void nextPage() {
    if (activePage.value < totalPages.value) {
      activePage.value++;
    }
  }

  /// Moves back to the previous page.
  void previousPage() {
    if (activePage.value > 1) {
      activePage.value--;
    }
  }

  /// Opens the full patient profile for [entry].
  void openPatient(VitalsTriageEntry entry) {
    NursePatientProfileController.open(entry.toQueueEntry(), from: 'vitals-triage');
  }

  /// Triggers "Begin Triage" action for [entry].
  void beginTriage(VitalsTriageEntry entry) {
    Get.toNamed(AppRoutes.recordVitalsTriage, arguments: {'entry': entry});
  }
}
