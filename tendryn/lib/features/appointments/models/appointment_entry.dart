/// What a calendar slot holds.
enum AppointmentKind { booked, available, conflict }

/// One slot on the practitioner schedule.
class AppointmentEntry {
  const AppointmentEntry({
    required this.date,
    required this.time,
    required this.practitioner,
    required this.kind,
    this.patient,
    this.type,
    this.minutes = 30,
    this.visits = const [],
    this.fileNumber,
    this.notes,
    this.noShow = false,
  });

  /// Date only.
  final DateTime date;

  /// `HH:mm`
  final String time;
  final String practitioner;
  final AppointmentKind kind;

  /// Patient name; for a conflict, both names (`Peter Jacobs / Nomsa Dube`).
  final String? patient;

  /// `Follow-up`, `Consultation`, `Double booking`
  final String? type;
  final int minutes;

  /// For a conflict: each patient's visit type, in the order of [patient]'s names.
  final List<String> visits;

  /// The patient's file number, when known.
  final String? fileNumber;
  final String? notes;

  /// The patient did not attend this booked visit.
  final bool noShow;

  /// The same booking at another date, time or practitioner.
  AppointmentEntry copyWith({DateTime? date, String? time, String? practitioner, bool? noShow}) => AppointmentEntry(
    date: date ?? this.date,
    time: time ?? this.time,
    practitioner: practitioner ?? this.practitioner,
    kind: kind,
    patient: patient,
    type: type,
    minutes: minutes,
    visits: visits,
    fileNumber: fileNumber,
    notes: notes,
    noShow: noShow ?? this.noShow,
  );

  /// `09:00` for 09:30 — the grid row the slot falls in.
  String get hourSlot => '${time.substring(0, 2)}:00';

  /// `Dr Thandi` from `Dr Thandi Maseko`.
  String get practitionerShort => practitioner.split(' ').take(2).join(' ');

  /// `DR. Thandi` — the patient card style.
  String get practitionerCard => practitionerShort.replaceFirst('Dr ', 'DR. ');
}
