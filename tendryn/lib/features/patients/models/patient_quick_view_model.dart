import 'package:tendryn/features/dashboard/models/dashboard_model.dart';

/// Model representing data displayed in Patient Quick View.
class PatientQuickViewModel {
  const PatientQuickViewModel({
    required this.name,
    required this.fileNumber,
    required this.phone,
    required this.dobAndAge,
    required this.queueNumber,
    required this.arrivedTime,
    required this.waitingDuration,
    required this.visitReason,
    required this.priority,
    required this.status,
    required this.practitioner,
    required this.whatsAppStatus,
  });

  final String name;
  final String fileNumber;
  final String phone;
  final String dobAndAge;
  final String queueNumber;
  final String arrivedTime;
  final String waitingDuration;
  final String visitReason;
  final String priority;
  final String status;
  final String practitioner;
  final String whatsAppStatus;

  /// Default mock data for Thabo Nkosi matching prototypes 2, 3, and 4.
  static const PatientQuickViewModel thaboNkosi = PatientQuickViewModel(
    name: 'Thabo Nkosi',
    fileNumber: '#PT-002184',
    phone: '082 ••• ••42',
    dobAndAge: '12 Mar 1982 · 44 years',
    queueNumber: 'Q014',
    arrivedTime: '09:10',
    waitingDuration: '24 min',
    visitReason: 'General consultation',
    priority: 'Routine',
    status: 'Waiting',
    practitioner: 'Not assigned',
    whatsAppStatus: 'Active',
  );

  /// Mock data for Thabo Mokoena matching prototype search results.
  static const PatientQuickViewModel thaboMokoena = PatientQuickViewModel(
    name: 'Thabo Mokoena',
    fileNumber: '#PT-003011',
    phone: '071 ••• ••91',
    dobAndAge: '04 Nov 1976 · 50 years',
    queueNumber: 'Q019',
    arrivedTime: '08:31',
    waitingDuration: '3 min',
    visitReason: 'General consultation',
    priority: 'Routine',
    status: 'Waiting',
    practitioner: 'Not assigned',
    whatsAppStatus: 'Active',
  );

  static const PatientQuickViewModel nalediMolefe = PatientQuickViewModel(
    name: 'Naledi Molefe',
    fileNumber: '#PT-001803',
    phone: '083 ••• ••17',
    dobAndAge: '22 May 1989 · 37 years',
    queueNumber: 'Q015',
    arrivedTime: '09:18',
    waitingDuration: '16 min',
    visitReason: 'Follow-up',
    priority: 'Routine',
    status: 'Waiting',
    practitioner: 'Dr Thandi Maseko',
    whatsAppStatus: 'Active',
  );

  static const PatientQuickViewModel siphoDlamini = PatientQuickViewModel(
    name: 'Sipho Dlamini',
    fileNumber: '#PT-002360',
    phone: '072 ••• ••88',
    dobAndAge: '07 Jul 1978 · 48 years',
    queueNumber: 'Q016',
    arrivedTime: '09:22',
    waitingDuration: '12 min',
    visitReason: 'General consultation',
    priority: 'Routine',
    status: 'Waiting',
    practitioner: 'Not assigned',
    whatsAppStatus: 'Active',
  );

  static const PatientQuickViewModel amahleKhumalo = PatientQuickViewModel(
    name: 'Amahle Khumalo',
    fileNumber: '#PT-001925',
    phone: '082 ••• ••33',
    dobAndAge: '19 Jan 1995 · 31 years',
    queueNumber: 'Q017',
    arrivedTime: '09:27',
    waitingDuration: '7 min',
    visitReason: 'Prescription follow-up',
    priority: 'Routine',
    status: 'Waiting',
    practitioner: 'Not assigned',
    whatsAppStatus: 'Active',
  );

  static const PatientQuickViewModel kabeloMokoena = PatientQuickViewModel(
    name: 'Kabelo Mokoena',
    fileNumber: '#PT-002488',
    phone: '084 ••• ••55',
    dobAndAge: '30 Sep 1985 · 41 years',
    queueNumber: 'Q018',
    arrivedTime: '09:31',
    waitingDuration: '3 min',
    visitReason: 'General consultation',
    priority: 'Routine',
    status: 'Waiting',
    practitioner: 'Not assigned',
    whatsAppStatus: 'Active',
  );

  /// Create a view model dynamically from a QueueEntry.
  factory PatientQuickViewModel.fromQueueEntry(QueueEntry entry) {
    return PatientQuickViewModel(
      name: entry.patient,
      fileNumber: '#PT-${entry.number.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}',
      phone: '082 ••• ••42',
      dobAndAge: '12 Mar 1982 · 44 years',
      queueNumber: entry.number,
      arrivedTime: entry.arrival,
      waitingDuration: '${entry.waitingMinutes} min',
      visitReason: entry.reason,
      priority: entry.priority.label,
      status: entry.status.label,
      practitioner: entry.practitioner ?? 'Not assigned',
      whatsAppStatus: 'Active',
    );
  }

  /// Create a view model from appointment details or custom parameters.
  factory PatientQuickViewModel.forPatient({
    required String name,
    String fileNumber = '#PT-001746',
    String phone = '083 ••• ••18',
    String dobAndAge = '14 Jun 1988 · 38 years',
    String queueNumber = '—',
    String arrivedTime = '13:52',
    String waitingDuration = '8 min',
    String visitReason = 'Follow-up',
    String priority = 'Routine',
    String status = 'Checked In',
    String practitioner = 'Dr Thandi Maseko',
    String whatsAppStatus = 'Active',
  }) {
    return PatientQuickViewModel(
      name: name,
      fileNumber: fileNumber,
      phone: phone,
      dobAndAge: dobAndAge,
      queueNumber: queueNumber,
      arrivedTime: arrivedTime,
      waitingDuration: waitingDuration,
      visitReason: visitReason,
      priority: priority,
      status: status,
      practitioner: practitioner,
      whatsAppStatus: whatsAppStatus,
    );
  }

  PatientQuickViewModel copyWith({
    String? name,
    String? fileNumber,
    String? phone,
    String? dobAndAge,
    String? queueNumber,
    String? arrivedTime,
    String? waitingDuration,
    String? visitReason,
    String? priority,
    String? status,
    String? practitioner,
    String? whatsAppStatus,
  }) {
    return PatientQuickViewModel(
      name: name ?? this.name,
      fileNumber: fileNumber ?? this.fileNumber,
      phone: phone ?? this.phone,
      dobAndAge: dobAndAge ?? this.dobAndAge,
      queueNumber: queueNumber ?? this.queueNumber,
      arrivedTime: arrivedTime ?? this.arrivedTime,
      waitingDuration: waitingDuration ?? this.waitingDuration,
      visitReason: visitReason ?? this.visitReason,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      practitioner: practitioner ?? this.practitioner,
      whatsAppStatus: whatsAppStatus ?? this.whatsAppStatus,
    );
  }
}
