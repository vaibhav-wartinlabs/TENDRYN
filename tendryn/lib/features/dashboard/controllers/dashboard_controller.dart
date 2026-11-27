import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/authentication/auth_controller.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/core/utils/loadable_mixin.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/features/appointments/views/appointment_details_view.dart';
import 'package:tendryn/features/appointments/views/book_appointment_view.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/features/patients/views/patient_quick_view.dart';
import 'package:tendryn/features/patients/views/patient_front_desk_preview_view.dart';
import 'package:tendryn/features/queue/views/add_walk_in_view.dart';
import 'package:tendryn/routes/app_navigation.dart';
import 'package:tendryn/routes/app_routes.dart';
import 'package:tendryn/services/dashboard_service.dart';

/// The four quick actions on the Dashboard.
enum QuickActionKind {
  addWalkIn,
  registerPatient,
  bookAppointment,
  takePayment,
}

/// One controller for mobile, tablet and desktop layouts alike.
class DashboardController extends GetxController with LoadableMixin {
  DashboardController({required this._service, required this._auth});

  final DashboardService _service;
  final AuthController _auth;

  final summary = Rxn<DashboardModel>();

  String get clinicName => _auth.user?.clinicName ?? '';

  /// `Tuesday, 6 October 2026`
  String get todayLabel => Formatters.longDate(DateTime.now());

  /// `Good morning, Lerato`
  String get greeting {
    final name = _auth.user?.firstName;
    final hello = Formatters.greeting(DateTime.now());
    return name == null ? hello : '$hello, $name';
  }

  String get greetingSubtitle =>
      "Here’s what’s happening${clinicName.isEmpty ? '' : ' at $clinicName'} today.";

  @override
  void onInit() {
    super.onInit();
    patientSearchFocus.addListener(() {
      if (patientSearchFocus.hasFocus) {
        isPatientSearchActive.value = true;
      }
    });
    load();
  }

  Future<void> load() =>
      runLoad(() async => summary.value = await _service.fetchSummary());

  /// Actions whose destination screens don't exist yet. They are wired here so
  /// the UI is final; replace the body with navigation when the feature lands.
  void openQuickAction(QuickActionKind kind) {
    if (kind == QuickActionKind.addWalkIn) {
      addWalkIn();
      return;
    }
    if (kind == QuickActionKind.registerPatient) {
      registerPatient();
      return;
    }
    if (kind == QuickActionKind.bookAppointment) {
      bookAppointment();
      return;
    }
    AppNotice.unavailable(switch (kind) {
      QuickActionKind.addWalkIn => 'Add Walk-in',
      QuickActionKind.registerPatient => 'Register Patient',
      QuickActionKind.bookAppointment => 'Book Appointment',
      QuickActionKind.takePayment => 'Take Payment',
    });
  }

  void registerPatient() {
    Get.toNamed(
      AppRoutes.registerPatient,
      arguments: {'returnRoute': AppRoutes.dashboard, 'backLabel': 'Back to Dashboard'},
    );
  }

  /// Desktop: side drawer over the Dashboard. Tablet / phone: full page.
  void bookAppointment([PatientQuickViewModel? patient]) {
    final context = Get.context;

    if (context != null && ResponsiveHelper.usesDrawer(context)) {
      showBookAppointmentDrawer(
        context,
        returnRoute: AppRoutes.dashboard,
        initialQuickPatient: patient,
      );
    } else {
      Get.toNamed(
        AppRoutes.bookAppointment,
        arguments: {
          'returnRoute': AppRoutes.dashboard,
          'patient': ?patient,
        },
      );
    }
  }

  /// Desktop: side drawer over the Dashboard. Tablet / phone: full page.
  void addWalkIn() {
    final context = Get.context;

    if (context != null && ResponsiveHelper.usesDrawer(context)) {
      showAddWalkInDrawer(context, returnRoute: AppRoutes.dashboard);
    } else {
      Get.toNamed(
        AppRoutes.addWalkIn,
        arguments: {'returnRoute': AppRoutes.dashboard},
      );
    }
  }

  void openQueue() => AppNotice.unavailable('Live queue');
  void openAppointments() => AppNotice.unavailable('Appointments');
  void openBilling() => AppNavigation.goTo(AppRoutes.billing);
  void openPatientSearchPreview([PatientQuickViewModel? patient]) {
    final target = patient ?? PatientQuickViewModel.thaboNkosi;
    final context = Get.context;

    patientSearchFocus.unfocus();

    if (context != null && ResponsiveHelper.usesDrawer(context)) {
      showPatientSearchPreviewDrawer(
        context,
        patient: target,
        returnRoute: AppRoutes.dashboard,
      );
    } else {
      Get.toNamed(
        AppRoutes.patientSearchPreview,
        arguments: {
          'patient': target,
          'returnRoute': AppRoutes.dashboard,
        },
      );
    }
  }

  void openQuickPatient([PatientQuickViewModel? patient]) {
    openPatientSearchPreview(patient);
  }
  
  void viewPatient(QueueEntry entry) {
    final patient = PatientQuickViewModel.fromQueueEntry(entry);
    openPatientQuickView(patient);
  }

  void openPatientQuickView(PatientQuickViewModel patient) {
    final context = Get.context;

    if (context != null && ResponsiveHelper.usesDrawer(context)) {
      // Desktop: overlay drawer — dashboard stays untouched underneath.
      showPatientQuickViewDrawer(
        context,
        patient: patient,
        returnRoute: AppRoutes.dashboard,
      );
    } else {
      // Mobile / tablet: full-page route as before.
      Get.toNamed(
        AppRoutes.patientQuickView,
        arguments: {
          'patient': patient,
          'returnRoute': AppRoutes.dashboard,
        },
      );
    }
  }

  final patientSearchText = TextEditingController();
  final patientSearchQuery = ''.obs;
  final isPatientSearchActive = false.obs;
  final patientSearchFocus = FocusNode();

  void activatePatientSearch() {
    isPatientSearchActive.value = true;
  }

  void deactivatePatientSearch() {
    isPatientSearchActive.value = false;
    patientSearchText.clear();
    patientSearchQuery.value = '';
    patientSearchFocus.unfocus();
  }

  List<PatientQuickViewModel> get filteredQuickPatients {
    const list = [
      PatientQuickViewModel.thaboNkosi,
      PatientQuickViewModel.thaboMokoena,
      PatientQuickViewModel.nalediMolefe,
      PatientQuickViewModel.siphoDlamini,
      PatientQuickViewModel.amahleKhumalo,
      PatientQuickViewModel.kabeloMokoena,
    ];
    final q = patientSearchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((p) =>
      p.name.toLowerCase().contains(q) ||
      p.fileNumber.toLowerCase().contains(q) ||
      p.phone.contains(q),
    ).toList();
  }

  void onPatientSearchChanged(String query) {
    patientSearchQuery.value = query;
    if (query.trim().isNotEmpty) {
      isPatientSearchActive.value = true;
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
        returnRoute: AppRoutes.dashboard,
      );
    } else {
      Get.toNamed(
        AppRoutes.patientQuickView,
        arguments: {
          'assignMode': true,
          'patient': patient,
          'returnRoute': AppRoutes.dashboard,
        },
      );
    }
  }

  void openQueueEntry(QueueEntry entry) =>
      AppNotice.unavailable('Queue actions');

  void openAppointment(AppointmentEntry entry, {BuildContext? context}) {
    final ctx = context ?? Get.context;

    if (ctx != null && ResponsiveHelper.usesDrawer(ctx)) {
      showAppointmentDetailsDrawer(ctx, appointment: entry);
    } else {
      Get.toNamed(
        AppRoutes.appointmentDetails,
        arguments: {'appointment': entry},
      );
    }
  }

  void checkInAppointment(AppointmentEntry entry, {BuildContext? context}) {
    final ctx = context ?? Get.context;
    if (ctx == null) return;
    showCheckInPatientModal(ctx, appointment: entry);
  }

  void completeCheckIn({
    required AppointmentEntry appointment,
    required QueuePriority priority,
    required bool sendWhatsApp,
  }) {
    final current = summary.value;
    if (current == null) return;

    final updatedAppointments = current.appointments.items.map((a) {
      if (a.patient == appointment.patient && a.time == appointment.time) {
        return AppointmentEntry(
          time: a.time,
          patient: a.patient,
          practitioner: a.practitioner,
          visitType: a.visitType,
          status: AppointmentStatus.checkedIn,
        );
      }
      return a;
    }).toList();

    final nextNumber =
        'Q0${(current.queue.length + 14).toString().padLeft(2, '0')}';
    final newQueueEntry = QueueEntry(
      number: nextNumber,
      patient: appointment.patient,
      arrival: appointment.time,
      waitingMinutes: 0,
      reason: appointment.visitType,
      priority: priority,
      status: QueueStatus.waiting,
      practitioner: appointment.practitioner,
    );

    final updatedQueue = [...current.queue, newQueueEntry];

    final updatedAppointmentsSummary = AppointmentsSummary(
      booked: current.appointments.booked,
      remaining: (current.appointments.remaining - 1).clamp(0, 999),
      noShows: current.appointments.noShows,
      items: updatedAppointments,
    );

    summary.value = DashboardModel(
      patientsWaiting: current.patientsWaiting + 1,
      seenToday: current.seenToday,
      averageWaitMinutes: current.averageWaitMinutes,
      takingsToday: current.takingsToday,
      queue: updatedQueue,
      appointments: updatedAppointmentsSummary,
      attention: current.attention,
    );
  }

  void openAttention(AttentionKind kind) =>
      kind == AttentionKind.appointmentConflicts
      ? Get.toNamed(AppRoutes.appointmentConflicts)
      : openBilling();
}
