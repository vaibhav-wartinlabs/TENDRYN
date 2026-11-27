import 'package:get/get.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/appointments/controllers/appointments_controller.dart';
import 'package:tendryn/features/appointments/models/appointment_entry.dart';
import 'package:tendryn/features/patients/controllers/patients_controller.dart';

/// Reschedule one booked appointment. The choices live in a draft: the original
/// visit stays untouched until Save new time. Saving rewrites the local schedule
/// for this session only, because there is no appointments service yet.
class RescheduleController extends GetxController {
  RescheduleController(this.entry);

  factory RescheduleController.fromArguments(Object? arguments) =>
      RescheduleController(arguments is AppointmentEntry ? arguments : AppointmentsController.schedule.firstWhere((e) => e.kind == AppointmentKind.booked));

  final AppointmentEntry entry;

  /// Start times the clinic offers, before taken slots are removed.
  static const candidateTimes = ['09:00', '09:30', '10:00', '10:30', '11:00', '12:00', '14:00', '14:30'];

  /// Earliest date the picker offers (the first day on the schedule).
  static final firstDate = DateTime(2026, 9, 28);
  static final lastDate = DateTime(2027, 9, 30);

  /// Everyone who appears on the schedule.
  static List<String> get practitioners => {for (final e in AppointmentsController.schedule) e.practitioner}.toList();

  late final practitioner = entry.practitioner.obs;
  late final date = entry.date.obs;
  final selectedTime = RxnString();
  final isSaving = false.obs;

  /// Set when Save new time is pressed before a slot is chosen.
  final missingSlot = false.obs;

  String get patient => entry.patient ?? '';

  /// `PT-002184 · 082 ••• ••42` style line under the patient name.
  String get patientLine {
    final record = PatientsController.seed.where((p) => p.name == patient).firstOrNull;
    final mobile = record?.mobile.replaceAll(RegExp(r'\s'), '');
    final masked = mobile == null || mobile.length < 4 ? null : '${mobile.substring(0, 3)} ••• ••${mobile.substring(mobile.length - 2)}';
    return 'File #${entry.fileNumber ?? '—'}${masked == null ? '' : ' · $masked'}';
  }

  String get initials => Formatters.initials(patient);

  /// `Tuesday, 29 September 2026`
  String get dateLabel => Formatters.longDate(date.value);

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// A time is free when no booking holds it for the chosen practitioner and
  /// date. The original visit still holds its own slot until saved.
  bool isFree(String time) => !AppointmentsController.schedule.any(
    (e) => e.kind != AppointmentKind.available && e.practitioner == practitioner.value && e.time == time && _sameDay(e.date, date.value),
  );

  List<String> get freeTimes => candidateTimes.where(isFree).toList();

  void setPractitioner(String name) {
    practitioner.value = name;
    _dropStaleSelection();
  }

  void setDate(DateTime value) {
    date.value = DateTime(value.year, value.month, value.day);
    _dropStaleSelection();
  }

  void selectTime(String time) {
    if (!isFree(time)) return;
    selectedTime.value = time;
    missingSlot.value = false;
  }

  /// A kept selection must still be free after the practitioner or date changes.
  void _dropStaleSelection() {
    final t = selectedTime.value;
    if (t != null && !isFree(t)) selectedTime.value = null;
    missingSlot.value = false;
  }

  /// Moves the booking and returns the new entry to the caller.
  void save() {
    final time = selectedTime.value;
    if (isSaving.value) return;
    if (time == null) {
      missingSlot.value = true;
      return;
    }
    isSaving.value = true;
    final schedule = AppointmentsController.schedule;
    final moved = entry.copyWith(date: date.value, time: time, practitioner: practitioner.value);
    final at = schedule.indexOf(entry);
    if (at >= 0) {
      // The old slot goes back to being free.
      schedule[at] = AppointmentEntry(date: entry.date, time: entry.time, practitioner: entry.practitioner, kind: AppointmentKind.available);
    }
    schedule.removeWhere((e) => e.kind == AppointmentKind.available && e.practitioner == moved.practitioner && e.time == moved.time && _sameDay(e.date, moved.date));
    schedule.add(moved);
    Get.back(result: moved);
    Get.closeAllSnackbars();
    Get.snackbar('Appointment rescheduled', 'Saved on this device only.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
    isSaving.value = false;
  }

  /// Keep original: closes without changing anything.
  void keepOriginal() => Get.back();
}
