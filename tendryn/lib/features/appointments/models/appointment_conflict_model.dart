class AppointmentConflictItem {
  final String id;
  final String time;
  final String practitioner;
  final String date;
  final String badgeText;
  final String patient1Name;
  final String patient1Type;
  final String patient2Name;
  final String patient2Type;

  const AppointmentConflictItem({
    required this.id,
    required this.time,
    required this.practitioner,
    required this.date,
    this.badgeText = 'Double booking',
    required this.patient1Name,
    required this.patient1Type,
    required this.patient2Name,
    required this.patient2Type,
  });
}
