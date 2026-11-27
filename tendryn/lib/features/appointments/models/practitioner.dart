/// Availability shown on a practitioner's row.
enum PractitionerStatus {
  available('Available'),
  onLeave('On leave'),
  fullyBooked('Fully booked');

  const PractitionerStatus(this.label);

  final String label;
}

/// A practitioner whose availability can be managed.
class Practitioner {
  const Practitioner({required this.name, required this.id, required this.specialization, required this.status, this.slotMinutes = 30});

  final String name;

  /// `DOC-1024`
  final String id;
  final String specialization;
  final PractitionerStatus status;
  final int slotMinutes;

  /// `TN` for Dr. Thandiwe Nkosi (titles skipped).
  String get initials {
    final parts = name.split(' ').where((p) => p != 'Dr.' && p != 'Dr' && p != 'Nurse').toList();
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  /// `#DOC-1024 · General Practitioner`
  String get summary => '#$id · $specialization';
}
