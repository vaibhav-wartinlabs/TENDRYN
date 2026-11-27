/// One working day's hours, `HH:mm`.
class DayHours {
  const DayHours(this.day, this.start, this.end);

  final String day;
  final String start;
  final String end;

  DayHours copyWith({String? start, String? end}) => DayHours(day, start ?? this.start, end ?? this.end);

  /// `08:00 – 17:00`
  String get label => '$start – $end';
}

/// A practitioner's editable availability: Monday–Friday hours (weekends are
/// closed) and one leave entry. Public holidays follow the clinic calendar.
class AvailabilitySchedule {
  const AvailabilitySchedule({required this.days, required this.leaveDate, required this.leaveDuration});

  static const leaveDurations = ['Full day', 'Morning', 'Afternoon'];

  final List<DayHours> days;
  final DateTime leaveDate;
  final String leaveDuration;

  static final defaults = AvailabilitySchedule(
    days: const [
      DayHours('Monday', '08:00', '17:00'),
      DayHours('Tuesday', '08:00', '17:00'),
      DayHours('Wednesday', '08:00', '17:00'),
      DayHours('Thursday', '08:00', '17:00'),
      DayHours('Friday', '08:00', '16:00'),
    ],
    leaveDate: DateTime(2026, 10, 2),
    leaveDuration: 'Full day',
  );
}
