import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_breakpoints.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/core/utils/loadable_mixin.dart';
import 'package:tendryn/core/role/role_controller.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/features/patients/views/patient_quick_view.dart';
import 'package:tendryn/features/queue/controllers/nurse_patient_profile_controller.dart';
import 'package:tendryn/features/queue/models/queue_model.dart';
import 'package:tendryn/features/queue/widgets/nurse_call_patient_dialog.dart';
import 'package:tendryn/features/queue/views/add_walk_in_view.dart';
import 'package:tendryn/features/queue/widgets/queue_table.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/queue_service.dart';

/// Row actions in the Queue overflow menu.
enum QueueAction {
  viewProfile('View Profile'),
  updateStatus('Update Status'),
  markUnavailable('Mark Unavailable'),
  viewPatient('View Patient'),
  assignPractitioner('Assign Practitioner'),
  beginTriage('Begin Triage');

  const QueueAction(this.label);

  final String label;
}

/// One controller for mobile, tablet and desktop layouts alike.
class QueueController extends GetxController with LoadableMixin {
  QueueController({required this._service});

  /// Rows per page in the desktop table.
  static const pageSize = 10;

  /// Dedicated 5-patient list for the Doctor Patient Queue matching the designs.
  static const List<QueueEntry> doctorQueueEntries = [
    QueueEntry(
      number: 'Q-004',
      patient: 'Thabo Mokoena',
      arrival: '09:05',
      waitingMinutes: 5,
      reason: 'Chest pain',
      priority: QueuePriority.emergency,
      status: QueueStatus.waiting,
      demographics: '45/M',
    ),
    QueueEntry(
      number: 'Q015',
      patient: 'Naledi Molefe',
      arrival: '09:18',
      waitingMinutes: 16,
      reason: 'Follow-up',
      priority: QueuePriority.urgent,
      status: QueueStatus.waitingForDoctor,
      demographics: '45/M',
    ),
    QueueEntry(
      number: 'Q016',
      patient: 'Sipho Dlamini',
      arrival: '09:22',
      waitingMinutes: 12,
      reason: 'General consultation',
      priority: QueuePriority.routine,
      status: QueueStatus.waiting,
      demographics: '45/M',
    ),
    QueueEntry(
      number: 'Q017',
      patient: 'Amahle Khumalo',
      arrival: '09:27',
      waitingMinutes: 7,
      reason: 'Prescription follow-up',
      priority: QueuePriority.routine,
      status: QueueStatus.waiting,
      demographics: '45/M',
    ),
    QueueEntry(
      number: 'Q018',
      patient: 'Kabelo Mokoena',
      arrival: '09:31',
      waitingMinutes: 3,
      reason: 'General consultation',
      priority: QueuePriority.emergency,
      status: QueueStatus.waiting,
      demographics: '45/M',
    ),
  ];

  /// 6 entries for the tablet 2-column view (matching the tablet mockup).
  static const List<QueueEntry> doctorTabletEntries = [
    QueueEntry(
      number: 'Q-004',
      patient: 'Thabo Mokoena',
      arrival: '09:12',
      waitingMinutes: 5,
      reason: 'Chest pain',
      priority: QueuePriority.emergency,
      status: QueueStatus.waitingForDoctor,
      demographics: '45/M',
    ),
    QueueEntry(
      number: 'Q015',
      patient: 'Naledi Molefe',
      arrival: '09:18',
      waitingMinutes: 16,
      reason: 'Follow-up',
      priority: QueuePriority.urgent,
      status: QueueStatus.waitingForDoctor,
      demographics: '45/M',
    ),
    QueueEntry(
      number: 'Q016',
      patient: 'Sipho Dlamini',
      arrival: '09:22',
      waitingMinutes: 12,
      reason: 'General consultation',
      priority: QueuePriority.routine,
      status: QueueStatus.waiting,
      demographics: '45/M',
    ),
    QueueEntry(
      number: '',
      patient: 'Amahle Khumalo',
      arrival: '09:27',
      waitingMinutes: 7,
      reason: 'Prescription follow-up',
      priority: QueuePriority.routine,
      status: QueueStatus.waiting,
      demographics: '45/M',
    ),
    QueueEntry(
      number: 'Q018',
      patient: 'Kabelo Mokoena',
      arrival: '09:31',
      waitingMinutes: 3,
      reason: 'General consultation',
      priority: QueuePriority.emergency,
      status: QueueStatus.waiting,
      demographics: '45/M',
    ),
    QueueEntry(
      number: 'Q018',
      patient: 'Kabelo Mokoena',
      arrival: '09:31',
      waitingMinutes: 3,
      reason: 'General consultation',
      priority: QueuePriority.emergency,
      status: QueueStatus.waiting,
      demographics: '45/M',
    ),
  ];

  final QueueService _service;

  final queue = Rxn<QueueModel>();
  final selectedDate = DateTime.now().obs;
  final searchQuery = ''.obs;
  TextEditingController _searchTextController = TextEditingController();
  TextEditingController get searchTextController {
    try {
      _searchTextController.addListener(_noop);
      _searchTextController.removeListener(_noop);
    } catch (_) {
      _searchTextController = TextEditingController(text: searchQuery.value);
    }
    return _searchTextController;
  }
  static void _noop() {}

  /// Null shows every status.
  final statusFilter = Rxn<QueueStatus>();

  /// Priority filter for doctor queue.
  final priorityFilter = Rxn<QueuePriority>();

  /// 1-based.
  final page = 1.obs;

  /// 1-based active button index for doctor pagination toggle.
  final selectedDoctorPage = 1.obs;

  /// 1-based active button index for nurse demo pagination toggle.
  final selectedNursePage = 1.obs;

  bool get isDoctor =>
      Get.isRegistered<RoleController>() &&
      RoleController.to.currentRole.value == ClinicRole.doctor;

  bool get isNurse =>
      Get.isRegistered<RoleController>() &&
      RoleController.to.currentRole.value == ClinicRole.nurse;

  int get currentPageSize => isDoctor ? 5 : pageSize;

  /// Reactive patient lists for the Doctor Queue to support dynamic status updates.
  late final doctorQueueList = RxList<QueueEntry>(doctorQueueEntries);
  late final doctorTabletList = RxList<QueueEntry>(doctorTabletEntries);

  void updatePatientStatus(String queueNumber, QueueStatus newStatus, [String? note]) {
    final idx = doctorQueueList.indexWhere((e) => e.number == queueNumber);
    if (idx != -1) {
      doctorQueueList[idx] = doctorQueueList[idx].copyWith(status: newStatus);
    }
    final tabletIdx = doctorTabletList.indexWhere((e) => e.number == queueNumber);
    if (tabletIdx != -1) {
      doctorTabletList[tabletIdx] = doctorTabletList[tabletIdx].copyWith(status: newStatus);
    }
    doctorQueueList.refresh();
    doctorTabletList.refresh();
  }

  void returnPatientToQueue(String queueNumber, [String? note]) {
    updatePatientStatus(queueNumber, QueueStatus.waiting, note);
  }

  void markPatientNoShow(String queueNumber, [String? note]) {
    doctorQueueList.removeWhere((e) => e.number == queueNumber);
    doctorTabletList.removeWhere((e) => e.number == queueNumber);
    doctorQueueList.refresh();
    doctorTabletList.refresh();
  }

  /// `Tuesday, 29 September 2026`
  String get dateLabel => Formatters.longDate(selectedDate.value);

  /// `29 Sep 2026`
  String get shortDateLabel => Formatters.shortDate(selectedDate.value);

  /// Entries matching the search text (name, queue number, reason), status and priority.
  List<QueueEntry> get filtered {
    final entries = isDoctor
        ? doctorQueueList
        : (queue.value?.entries ?? const <QueueEntry>[]);
    final text = searchQuery.value.trim().toLowerCase();
    final status = statusFilter.value;
    final priority = priorityFilter.value;

    return entries.where((e) {
      if (status != null && e.status != status) return false;
      if (priority != null && e.priority != priority) return false;
      if (text.isEmpty) return true;
      return e.patient.toLowerCase().contains(text) ||
          e.number.toLowerCase().contains(text) ||
          e.reason.toLowerCase().contains(text);
    }).toList();
  }

  /// Tablet-specific filtered list (6 items).
  List<QueueEntry> get doctorTabletFiltered {
    final text = searchQuery.value.trim().toLowerCase();
    if (text.isEmpty) return doctorTabletList;
    return doctorTabletList.where((e) {
      return e.patient.toLowerCase().contains(text) ||
          e.number.toLowerCase().contains(text) ||
          e.reason.toLowerCase().contains(text);
    }).toList();
  }

  int get pageCount => (isDoctor || isNurse)
      ? (searchQuery.value.trim().isEmpty ? 10 : (filtered.length / currentPageSize).ceil().clamp(1, 1 << 20))
      : (filtered.length / currentPageSize).ceil().clamp(1, 1 << 20);

  /// The rows of the current page.
  List<QueueEntry> get pageEntries {
    if (isDoctor || isNurse) return filtered;
    final all = filtered;
    final start = ((page.value - 1) * currentPageSize).clamp(0, all.length);
    return all.sublist(start, (start + currentPageSize).clamp(0, all.length));
  }

  /// `Showing 1–5 of 24 patients`
  String get rangeLabel {
    if ((isDoctor || isNurse) && searchQuery.value.trim().isEmpty) {
      final p = isDoctor ? selectedDoctorPage.value : selectedNursePage.value;
      final start = (p - 1) * 5 + 1;
      final end = (start + 4).clamp(start, 24);
      return 'Showing $start–$end of 24 patients';
    }
    final total = filtered.length;
    if (total == 0) return 'Showing 0 of 0 patients';
    final start = (page.value - 1) * currentPageSize + 1;
    final end = (start + currentPageSize - 1).clamp(start, total);
    return 'Showing $start–$end of $total patients';
  }

  void switchDoctorPage(int target) {
    selectedDoctorPage.value = target.clamp(1, 10);
  }

  void previousDoctorPage() {
    if (selectedDoctorPage.value > 1) {
      selectedDoctorPage.value--;
    }
  }

  void nextDoctorPage() {
    if (selectedDoctorPage.value < 10) {
      selectedDoctorPage.value++;
    }
  }

  void switchNursePage(int target) {
    selectedNursePage.value = target.clamp(1, 10);
  }

  void previousNursePage() {
    if (selectedNursePage.value > 1) {
      selectedNursePage.value--;
    }
  }

  void nextNursePage() {
    if (selectedNursePage.value < 10) {
      selectedNursePage.value++;
    }
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => runLoad(() async {
    queue.value = await _service.fetchQueue(date: selectedDate.value);
    page.value = 1;
  });

  void selectDate(DateTime date) {
    selectedDate.value = date;
    load();
  }

  void search(String text) {
    if (searchTextController.text != text) {
      searchTextController.text = text;
    }
    searchQuery.value = text;
    page.value = 1;
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    statusFilter.value = null;
    priorityFilter.value = null;
    page.value = 1;
  }

  void filterByStatus(QueueStatus? status) {
    statusFilter.value = status;
    priorityFilter.value = null;
    page.value = 1;
  }

  void filterByPriority(QueuePriority? priority) {
    priorityFilter.value = priority;
    statusFilter.value = null;
    page.value = 1;
  }

  void goToPage(int target) => page.value = target.clamp(1, pageCount);

  /// Doctor calls the next patient in queue (opens confirmation modal / bottom sheet).
  void callNextPatient() {
    final list = filtered;
    final next = isDoctor
        ? const QueueEntry(
            number: 'Q015',
            patient: 'Naledi Molefe',
            arrival: '09:18',
            waitingMinutes: 16,
            reason: 'Follow-up',
            priority: QueuePriority.urgent,
            status: QueueStatus.waitingForDoctor,
            demographics: '45/M',
          )
        : (list.isNotEmpty ? list.first : null);
    final context = Get.context ?? Get.overlayContext;
    if (context != null) {
      showCallNextPatientDialog(context, patient: next);
    } else {
      final isMobile =
          (Get.width < Get.height ? Get.width : Get.height) < ResponsiveBreakpoints.mobile;
      if (isMobile) {
        Get.bottomSheet(
          CallNextPatientSheet(patient: next),
          backgroundColor: Colors.white,
          barrierColor: const Color(0x850F1F1D),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        );
      } else {
        Get.dialog(
          CallNextPatientDialog(patient: next),
          barrierColor: const Color(0x850F1F1D),
        );
      }
    }
  }

  /// The patient "Call next" calls: the first one still waiting, in queue order.
  QueueEntry? get nextToCall {
    for (final e in queue.value?.entries ?? const <QueueEntry>[]) {
      if (e.status == QueueStatus.waiting) return e;
    }
    return null;
  }

  /// Nurse "Call next": asks to confirm calling the next waiting patient.
  void callNextForTriage() {
    final next = nextToCall;
    if (next == null) {
      AppNotice.info('Call next', 'No patients are waiting.');
      return;
    }
    callPatient(next);
  }

  /// Asks the nurse to confirm calling [entry] to the triage room.
  void callPatient(QueueEntry entry) {
    final context = Get.context ?? Get.overlayContext;
    if (context == null) return;
    if (entry.status != QueueStatus.waiting) {
      AppNotice.info('Call patient', '${entry.patient} is no longer waiting.');
      return;
    }
    showNurseCallPatientDialog(context, entry: entry, onConfirm: () => callPatientToTriage(entry));
  }

  /// Marks [entry] With Nurse in the queue shown on this device. There is no
  /// calling or queue-update service yet, so nothing is sent to the patient or
  /// the server, and the notice says so.
  void callPatientToTriage(QueueEntry entry) {
    final current = queue.value;
    if (current == null) return;
    final index = current.entries.indexWhere((e) => e.number == entry.number);
    if (index == -1 || current.entries[index].status != QueueStatus.waiting) {
      AppNotice.info('Call next', '${entry.patient} is no longer waiting.');
      return;
    }
    final entries = [...current.entries];
    entries[index] = entries[index].copyWith(status: QueueStatus.withNurse);
    queue.value = current.copyWith(
      entries: entries,
      patientsWaiting: (current.patientsWaiting - 1).clamp(0, 1 << 20),
    );
    AppNotice.info(
      '${entry.patient} marked With Nurse',
      'Updated on this device only. Notifying the patient and syncing are not available yet.',
    );
  }

  /// Doctor starts consultation for the chosen patient.
  void startConsultation(QueueEntry entry) {
    AppNavigation.goToConsultationWorkspace(returnRoute: AppRoutes.queue);
  }

  /// Desktop: side drawer over the Queue. Tablet / phone: full page.
  void addWalkIn() {
    final context = Get.context;
    if (context != null && ResponsiveHelper.usesDrawer(context)) {
      showAddWalkInDrawer(context);
    } else {
      Get.toNamed(AppRoutes.addWalkIn);
    }
  }

  void updatePractitioner(String queueNumber, String practitioner) {
    final currentQueue = queue.value;
    if (currentQueue == null) return;
    final updatedEntries = currentQueue.entries.map((e) {
      if (e.number == queueNumber) {
        return QueueEntry(
          number: e.number,
          patient: e.patient,
          arrival: e.arrival,
          waitingMinutes: e.waitingMinutes,
          reason: e.reason,
          priority: e.priority,
          status: e.status,
          practitioner: practitioner == 'Not assigned' ? null : practitioner,
        );
      }
      return e;
    }).toList();
    queue.value = currentQueue.copyWith(entries: updatedEntries);
  }

  void viewPatient(QueueEntry entry) {
    final context = Get.context;
    final patient = PatientQuickViewModel.fromQueueEntry(entry);

    if (context != null && ResponsiveHelper.usesDrawer(context)) {
      showPatientQuickViewDrawer(
        context,
        patient: patient,
        returnRoute: AppRoutes.queue,
      );
    } else {
      Get.toNamed(
        AppRoutes.patientQuickView,
        arguments: {
          'patient': patient,
          'returnRoute': AppRoutes.queue,
        },
      );
    }
  }

  void assignPractitioner(QueueEntry entry) {
    final context = Get.context;
    final patient = PatientQuickViewModel.fromQueueEntry(entry);

    if (context != null && ResponsiveHelper.usesDrawer(context)) {
      showPatientQuickViewDrawer(
        context,
        startInAssignMode: true,
        patient: patient,
        returnRoute: AppRoutes.queue,
      );
    } else {
      Get.toNamed(
        AppRoutes.patientQuickView,
        arguments: {
          'assignMode': true,
          'patient': patient,
          'returnRoute': AppRoutes.queue,
        },
      );
    }
  }

  void onAction(QueueAction action, QueueEntry entry) {
    if (action == QueueAction.viewProfile) {
      viewProfile(entry);
    } else if (action == QueueAction.updateStatus) {
      updateStatus(entry);
    } else if (action == QueueAction.markUnavailable) {
      markUnavailable(entry);
    } else if (action == QueueAction.assignPractitioner) {
      assignPractitioner(entry);
    } else if (action == QueueAction.viewPatient) {
      if (isNurse) {
        NursePatientProfileController.open(entry);
      } else {
        viewPatient(entry);
      }
    } else if (action == QueueAction.beginTriage) {
      Get.toNamed(AppRoutes.recordVitalsTriage, arguments: {'queueEntry': entry});
    } else {
      AppNotice.unavailable(action.label, 'Page is not generated');
    }
  }

  void viewProfile(QueueEntry entry) {
    if (isNurse) {
      NursePatientProfileController.open(entry);
      return;
    }
    final context = Get.context;
    if (context != null) {
      showDoctorQueuePatientView(context, entry: entry);
    } else {
      openDoctorPatientProfile(entry: entry);
    }
  }

  void updateStatus(QueueEntry entry) {
    final context = Get.context ?? Get.overlayContext;
    if (context != null) {
      showDoctorUpdateStatusView(context, entry: entry);
    }
  }

  void markUnavailable(QueueEntry entry) {
    final context = Get.context ?? Get.overlayContext;
    if (context != null) {
      showDoctorMarkUnavailableView(context, entry: entry);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
