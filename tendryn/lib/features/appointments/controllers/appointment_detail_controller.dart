import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/features/appointments/models/appointment_entry.dart';
import 'package:tendryn/features/appointments/views/appointment_confirm_dialog.dart';
import 'package:tendryn/features/appointments/views/reschedule_view.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Appointment Details for the appointment picked in Appointments (passed as
/// the route argument). One controller for desktop, tablet and phone.
class AppointmentDetailController extends GetxController {
  AppointmentDetailController() : _entry = (Get.arguments is AppointmentEntry ? Get.arguments as AppointmentEntry : AppointmentsController.schedule.firstWhere((e) => e.kind == AppointmentKind.booked)).obs;

  final Rx<AppointmentEntry> _entry;

  /// Observable so the page shows a rescheduled time straight away.
  AppointmentEntry get entry => _entry.value;

  String get patient => entry.patient ?? '';

  /// True once the visit has been cancelled from this page.
  final isCancelled = false.obs;
  /// A confirmation (cancel or no-show) is being applied.
  final isSubmitting = false.obs;

  bool get isConflict => entry.kind == AppointmentKind.conflict;

  /// `Booked` or `Conflict`, as on the schedule.
  String get status => isCancelled.value ? 'Cancelled' : (entry.noShow ? 'No-show' : (isConflict ? 'Conflict' : 'Booked'));

  /// Cancelled or no-show: no further front desk actions.
  bool get isFinished => isCancelled.value || entry.noShow;

  String get fileNumber => entry.fileNumber ?? '—';

  /// Date of birth, when the patient is in the directory.
  String? get dateOfBirth => PatientsController.seed.where((p) => p.name == patient).firstOrNull?.dateOfBirth;

  /// `Consultation · 30 minutes`
  String get visitType => '${entry.type ?? 'Visit'} · ${entry.minutes} minutes';

  /// `Tuesday 29 September 2026`
  String get dateLabel => Formatters.longDate(entry.date).replaceFirst(',', '');

  String get notes => entry.notes ?? '—';

  /// Rows of the details card, label then value.
  List<(String, String)> get rows => [
    ('File number', fileNumber),
    ('Practitioner', entry.practitioner),
    ('Visit type', visitType),
    ('Date', dateLabel),
    ('Time', entry.time),
    ('Notes', notes),
  ];

  /// Reschedule opens the slot picker; the rest need appointment services that don't exist yet.
  void perform(RecordAction action, BuildContext context) {
    if (action == RecordAction.reschedule) {
      reschedule(context);
    } else if (action == RecordAction.cancel) {
      cancel(context);
    } else if (action == RecordAction.markNoShow) {
      markNoShow(context);
    } else {
      AppNotice.unavailable(action.label);
    }
  }

  /// Opens the confirmation; the visit stays booked until it is confirmed.
  void cancel(BuildContext context) {
    if (isConflict) return AppNotice.unavailable('Cancel a double booking');
    showCancelAppointment(context, this);
  }

  /// Opens the confirmation; the visit stays booked until it is confirmed.
  void markNoShow(BuildContext context) {
    if (isConflict) return AppNotice.unavailable('Mark a double booking as no-show');
    showNoShowAppointment(context, this);
  }

  /// Confirmed: flags this visit as a no-show on the local schedule (the slot
  /// stays taken). There is no appointments service yet, so this is not sent
  /// to a server.
  void confirmNoShow() {
    if (isSubmitting.value || isFinished) return;
    isSubmitting.value = true;
    final marked = entry.copyWith(noShow: true);
    final schedule = AppointmentsController.schedule;
    final at = schedule.indexOf(entry);
    if (at >= 0) schedule[at] = marked;
    _entry.value = marked;
    if (Get.isRegistered<AppointmentsController>()) Get.find<AppointmentsController>().selectedDate.refresh();
    Get.back();
    Get.closeAllSnackbars();
    Get.snackbar('Marked as no-show', 'Saved on this device only.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    isSubmitting.value = false;
  }

  /// Confirmed: frees the slot on the local schedule. There is no appointments
  /// service yet, so this is not sent to a server.
  void confirmCancel() {
    if (isSubmitting.value || isFinished) return;
    isSubmitting.value = true;
    final schedule = AppointmentsController.schedule;
    final at = schedule.indexOf(entry);
    if (at >= 0) schedule[at] = AppointmentEntry(date: entry.date, time: entry.time, practitioner: entry.practitioner, kind: AppointmentKind.available);
    isCancelled.value = true;
    if (Get.isRegistered<AppointmentsController>()) Get.find<AppointmentsController>().selectedDate.refresh();
    Get.back();
    Get.closeAllSnackbars();
    Get.snackbar('Appointment cancelled', 'Saved on this device only.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    isSubmitting.value = false;
  }

  /// Desktop: drawer over this page. Tablet / phone: full page.
  Future<void> reschedule(BuildContext context) async {
    if (isConflict) return AppNotice.unavailable('Reschedule a double booking');
    final Object? moved = ResponsiveHelper.usesDrawer(context)
        ? await showRescheduleDrawer(context, entry)
        : await Get.toNamed(AppRoutes.rescheduleAppointment, arguments: entry);
    if (moved is! AppointmentEntry) return;
    _entry.value = moved;
    // The schedule is plain data: nudge the Appointments page to re-read it.
    if (Get.isRegistered<AppointmentsController>()) Get.find<AppointmentsController>().selectedDate.refresh();
  }

  /// Back to the previous screen (Appointments).
  void onBack() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.appointments);
    }
  }
}
