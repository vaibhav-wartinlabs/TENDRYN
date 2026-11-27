import 'package:get/get.dart';
import 'package:tendryn/core/responsive/responsive_helper.dart';
import 'package:tendryn/core/utils/app_notice.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/appointments/models/appointment_entry.dart';
import 'package:tendryn/features/appointments/views/book_appointment_view.dart';
import 'package:tendryn/features/patients/models/patient_quick_view_model.dart';
import 'package:tendryn/features/queue/models/walk_in_patient.dart';
import 'package:tendryn/routes/app_routes.dart';

/// Whether the schedule is read by practitioner or by patient.
enum AppointmentsMode { doctor, patients }

/// Actions in a record's ⋮ menu (Patient view).
enum RecordAction {
  viewDetail('View Detail'),
  reschedule('Reschedule'),
  markNoShow('Mark no-show'),
  checkIn('Check In Patient'),
  cancel('Cancel Appointment');

  const RecordAction(this.label);

  final String label;
}

/// Week shows the day strip; Day shows just the selected date (desktop toolbar).
enum AppointmentsScope { week, day }

/// Appointments state for the mobile, tablet and desktop layouts: selected
/// date, view, scope and practitioner filter over a local schedule.
class AppointmentsController extends GetxController {
  static const practitioners = ['Dr Thandi Maseko', 'Dr Sipho Khumalo', 'Nurse Z. Mthembu'];

  /// Grid rows on the desktop week calendar.
  static const hourSlots = ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];

  static final _monday = DateTime(2026, 9, 28);

  /// Local stand-in until the appointments service is connected.
  static final schedule = <AppointmentEntry>[
    _e(0, '09:00', 'Dr Thandi Maseko', 'Naledi Molefe', 'Follow-up'),
    _e(0, '10:00', 'Dr Sipho Khumalo', 'Sipho Dlamini', 'Consultation'),
    _e(0, '14:00', 'Nurse Z. Mthembu', 'Amahle Khumalo', 'Prescription follow-up'),
    _e(1, '09:00', 'Dr Thandi Maseko', 'Lindiwe Ndlovu', 'Follow-up', notes: 'Patient requested a morning reminder.'),
    _e(1, '10:00', 'Dr Sipho Khumalo', 'Thabo Nkosi', 'Consultation'),
    _a(1, '11:00', 'Dr Thandi Maseko'),
    AppointmentEntry(date: _monday.add(const Duration(days: 1)), time: '14:30', practitioner: 'Dr Thandi Maseko', kind: AppointmentKind.conflict, patient: 'Peter Jacobs / Nomsa Dube', type: 'Double booking', visits: ['Consultation', 'Follow-up']),
    _a(1, '15:00', 'Nurse Z. Mthembu'),
    _e(2, '09:00', 'Dr Thandi Maseko', 'Kabelo Mokoena', 'Consultation'),
    _e(2, '11:00', 'Dr Sipho Khumalo', 'Thabo Mokoena', 'Follow-up'),
    _e(2, '15:00', 'Nurse Z. Mthembu', 'Naledi Molefe', 'Blood pressure check'),
    _e(3, '10:00', 'Dr Thandi Maseko', 'Sipho Dlamini', 'Follow-up'),
    _e(3, '14:00', 'Dr Sipho Khumalo', 'Amahle Khumalo', 'Consultation'),
    _e(4, '09:00', 'Dr Sipho Khumalo', 'Kabelo Mokoena', 'Follow-up'),
    _e(4, '11:00', 'Dr Thandi Maseko', 'Lindiwe Ndlovu', 'Consultation'),
  ];

  /// File numbers for the patients on the schedule (directory patients keep theirs).
  static const _files = {
    'Naledi Molefe': 'PT-001803',
    'Sipho Dlamini': 'PT-002360',
    'Amahle Khumalo': 'PT-002711',
    'Lindiwe Ndlovu': 'PT-003005',
    'Thabo Nkosi': 'PT-002184',
    'Kabelo Mokoena': 'PT-002890',
    'Thabo Mokoena': 'PT-003011',
    'Peter Jacobs': 'PT-003040',
    'Nomsa Dube': 'PT-003041',
  };

  static AppointmentEntry _e(int day, String time, String practitioner, String patient, String type, {String? notes}) => AppointmentEntry(
    fileNumber: _files[patient],
    notes: notes,
    date: _monday.add(Duration(days: day)),
    time: time,
    practitioner: practitioner,
    kind: AppointmentKind.booked,
    patient: patient,
    type: type,
  );

  static AppointmentEntry _a(int day, String time, String practitioner) =>
      AppointmentEntry(date: _monday.add(Duration(days: day)), time: time, practitioner: practitioner, kind: AppointmentKind.available);

  final selectedDate = DateTime(2026, 9, 29).obs;
  final mode = AppointmentsMode.doctor.obs;
  final scope = AppointmentsScope.week.obs;

  /// Null shows every practitioner.
  final practitioner = RxnString();

  /// Monday of the selected date's week.
  DateTime get weekStart => selectedDate.value.subtract(Duration(days: selectedDate.value.weekday - 1));

  /// Monday to Saturday, as the day strip shows them.
  List<DateTime> get weekDays => [for (var i = 0; i < 6; i++) weekStart.add(Duration(days: i))];

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  bool isSelected(DateTime day) => _sameDay(day, selectedDate.value);

  /// `28 September 2026`
  static String _longDay(DateTime d) => Formatters.longDate(d).split(', ').last;

  /// `Tuesday 29 September 2026`
  String get selectedDateLabel => Formatters.longDate(selectedDate.value).replaceFirst(',', '');

  /// `28 Sep – 3 Oct 2026` (week) or `29 Sep 2026` (day).
  String get rangeLabel {
    if (scope.value == AppointmentsScope.day) return Formatters.shortDate(selectedDate.value);
    final start = weekStart;
    final end = weekDays.last;
    final startShort = Formatters.shortDate(start).replaceFirst(' ${start.year}', '');
    return '$startShort – ${Formatters.shortDate(end)}';
  }

  /// `Week of 28 September – 3 October 2026 · practitioner schedule`
  String get desktopSubtitle {
    if (scope.value == AppointmentsScope.day) return '$selectedDateLabel · practitioner schedule';
    final start = weekStart;
    final end = weekDays.last;
    final startLong = _longDay(start).replaceFirst(' ${start.year}', '');
    return 'Week of $startLong – ${_longDay(end)} · practitioner schedule';
  }

  List<AppointmentEntry> get _weekEntries => schedule.where((e) => !e.date.isBefore(weekStart) && e.date.isBefore(weekStart.add(const Duration(days: 7)))).toList();

  int get bookedThisWeek => _weekEntries.where((e) => e.kind == AppointmentKind.booked).length;
  int get conflictsThisWeek => _weekEntries.where((e) => e.kind == AppointmentKind.conflict).length;
  int get freeSlotsToday => schedule.where((e) => _sameDay(e.date, selectedDate.value) && e.kind == AppointmentKind.available).length;

  /// Selected day's slots for the chosen practitioner, in time order.
  List<AppointmentEntry> get dayEntries {
    final list = schedule.where((e) => _sameDay(e.date, selectedDate.value) && (practitioner.value == null || e.practitioner == practitioner.value)).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  /// Patient view: the day's booked and conflicting slots by time, one row per
  /// patient (a double booking becomes two rows).
  List<AppointmentEntry> get patientRows {
    final rows = <AppointmentEntry>[];
    for (final e in dayEntries) {
      if (e.kind == AppointmentKind.booked) {
        rows.add(e);
      } else if (e.kind == AppointmentKind.conflict) {
        final names = e.patient!.split(' / ');
        for (final (i, name) in names.indexed) {
          rows.add(AppointmentEntry(date: e.date, time: e.time, practitioner: e.practitioner, kind: e.kind, patient: name, type: i < e.visits.length ? e.visits[i] : e.type, minutes: e.minutes, fileNumber: _files[name]));
        }
      }
    }
    return rows;
  }

  /// `5 appointments · 1 conflict`
  String get patientSummary {
    final conflicts = dayEntries.where((e) => e.kind == AppointmentKind.conflict).length;
    final count = patientRows.length;
    return '$count ${count == 1 ? 'appointment' : 'appointments'} · $conflicts ${conflicts == 1 ? 'conflict' : 'conflicts'}';
  }

  /// Practitioners with a column on the week grid.
  List<String> get visiblePractitioners => practitioner.value == null ? practitioners : [practitioner.value!];

  void selectDay(DateTime day) => selectedDate.value = day;
  void setMode(AppointmentsMode value) => mode.value = value;
  void setScope(AppointmentsScope value) => scope.value = value;
  void setPractitioner(String? value) => practitioner.value = value;

  /// Previous / next week, or day when the scope is Day. The weekday is kept.
  void step(int direction) => selectedDate.value = selectedDate.value.add(Duration(days: (scope.value == AppointmentsScope.week ? 7 : 1) * direction));

  /// View Detail opens the appointment; the other actions need appointment
  /// services that don't exist yet.
  void onRecordAction(RecordAction action, AppointmentEntry entry) {
    if (action == RecordAction.viewDetail) {
      Get.toNamed(AppRoutes.appointmentDetail, arguments: entry);
    } else {
      AppNotice.unavailable(action.label);
    }
  }

  void bookAppointment([
    WalkInPatient? patient,
    PatientQuickViewModel? quickPatient,
  ]) {
    final context = Get.context;

    if (context != null && ResponsiveHelper.usesDrawer(context)) {
      showBookAppointmentDrawer(
        context,
        returnRoute: AppRoutes.appointments,
        initialPatient: patient,
        initialQuickPatient: quickPatient,
        initialDate: selectedDate.value,
        initialPractitioner: practitioner.value,
      );
    } else {
      Get.toNamed(
        AppRoutes.bookAppointment,
        arguments: {
          'returnRoute': AppRoutes.appointments,
          'patient': patient ?? quickPatient,
          'date': selectedDate.value,
          'practitioner': practitioner.value,
        },
      );
    }
  }

  void manageAvailability() => Get.toNamed(AppRoutes.manageAvailability);

  void openEntry(AppointmentEntry entry) {
    switch (entry.kind) {
      case AppointmentKind.available:
        final context = Get.context;

        if (context != null && ResponsiveHelper.usesDrawer(context)) {
          showBookAppointmentDrawer(
            context,
            returnRoute: AppRoutes.appointments,
            initialDate: entry.date,
            initialSlot: entry.time,
            initialPractitioner: entry.practitioner,
          );
        } else {
          Get.toNamed(
            AppRoutes.bookAppointment,
            arguments: {
              'returnRoute': AppRoutes.appointments,
              'date': entry.date,
              'slot': entry.time,
              'practitioner': entry.practitioner,
            },
          );
        }
        break;
      case AppointmentKind.conflict:
        Get.toNamed(AppRoutes.appointmentConflicts, arguments: entry);
        break;
      case AppointmentKind.booked:
        Get.toNamed(AppRoutes.appointmentDetail, arguments: entry);
        break;
    }
  }
}
