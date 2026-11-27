/// An existing patient offered by the Add Walk-in lookup.
class WalkInPatient {
  const WalkInPatient({
    required this.name,
    required this.fileNumber,
    required this.dateOfBirth,
    this.phone,
  });

  final String name;

  /// `PT-002184`
  final String fileNumber;

  /// `12 Mar 1982`
  final String dateOfBirth;

  /// `082 ••• ••42`
  final String? phone;

  /// `TN`
  String get initials => name.split(' ').take(2).map((part) => part[0]).join().toUpperCase();

  /// `File #PT-002184 · DOB 12 Mar 1982`
  String get details => 'File #$fileNumber · DOB $dateOfBirth';

  /// `File #PT-002184 · 082 ••• ••42`
  String get phoneDetails => 'File #$fileNumber · ${phone ?? '082 ••• ••42'}';
}

