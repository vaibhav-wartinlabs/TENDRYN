/// A row in the Patients directory.
class PatientRecord {
  const PatientRecord({
    required this.name,
    required this.fileNumber,
    required this.dateOfBirth,
    required this.mobile,
    required this.lastVisit,
    this.queueNumber,
    this.address = '12 Market Road, Johannesburg',
    this.nextOfKin = 'Not recorded',
    this.whatsApp,
    this.careFlags,
  });

  final String name;

  /// `PT-003011`
  final String fileNumber;

  /// `04 Nov 1976`
  final String dateOfBirth;

  /// Masked, as shown to the front desk: `082 ••• ••42`
  final String mobile;

  /// `14 Aug 2026`
  final String lastVisit;

  /// `Q019`; null when the patient isn't in the queue (e.g. just registered).
  final String? queueNumber;

  /// Residential address and next of kin (name · relationship · mobile).
  final String address;
  final String nextOfKin;

  /// Null until recorded; the form then offers [mobile].
  final String? whatsApp;

  /// Longitudinal care flag (e.g. 'Penicillin allergy', 'Diabetes', 'Hypertension').
  final String? careFlags;

  PatientRecord copyWith({String? mobile, String? address, String? nextOfKin, String? whatsApp, String? careFlags}) => PatientRecord(
    name: name,
    fileNumber: fileNumber,
    dateOfBirth: dateOfBirth,
    mobile: mobile ?? this.mobile,
    lastVisit: lastVisit,
    queueNumber: queueNumber,
    address: address ?? this.address,
    nextOfKin: nextOfKin ?? this.nextOfKin,
    whatsApp: whatsApp ?? this.whatsApp,
    careFlags: careFlags ?? this.careFlags,
  );

  /// `In queue · Q019`, or `Registered`
  String get status => queueNumber == null ? 'Registered' : 'In queue · $queueNumber';

  /// `PT-003011 · 04 Nov 1976`
  String get fileAndDob => '$fileNumber · $dateOfBirth';
}
