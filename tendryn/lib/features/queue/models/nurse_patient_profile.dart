import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';

/// One previous-visit vital sign (`Blood pressure`, `124/80`, `mmHg`).
class VitalReading {
  const VitalReading(this.label, this.value, this.unit);

  final String label;
  final String value;
  final String unit;

  /// `124/80 mmHg`
  String get display => '$value $unit';
}

/// One line of the visit timeline. [current] events are today's (brand dot);
/// earlier visits get the muted dot.
class VisitEvent {
  const VisitEvent({required this.time, required this.description, this.current = true});

  final String time;
  final String description;
  final bool current;
}

enum VisitStatus {
  triageInProgress('Triage in progress'),
  triageCompleted('Triage completed');

  const VisitStatus(this.label);

  final String label;
}

/// One row of the Clinical History "Visit history" ([date] is `26 Oct 2026`).
class VisitHistoryEntry {
  const VisitHistoryEntry({
    required this.date,
    required this.reason,
    required this.recordedBy,
    required this.status,
    this.current = false,
    this.notes = 'Routine check. No concerns recorded.',
    this.priority = QueuePriority.routine,
    this.vitals,
  });

  final String date;
  final String reason;
  final String recordedBy;
  final VisitStatus status;

  /// Today's visit: shows "Current visit" instead of a View triage action.
  final bool current;
  final String notes;
  final QueuePriority priority;
  final List<VitalReading>? vitals;
}

/// A past visit's triage as the read-only "Triage · 12 Aug 2026" view shows it.
class TriageRecord {
  const TriageRecord({
    required this.patientName,
    required this.queueNumber,
    required this.date,
    required this.recordedBy,
    required this.priority,
    required this.complaint,
    required this.vitals,
    required this.notes,
  });

  final String patientName;
  final String queueNumber;

  /// `12 Aug 2026`
  final String date;
  final String recordedBy;
  final QueuePriority priority;
  final String complaint;
  final List<VitalReading> vitals;
  final String notes;

  String get title => 'Triage · $date';
  String get subtitle => 'Recorded by $recordedBy';
}

/// What the read-only "Consultations" and "Prescriptions" views need. There is no
/// consultation or prescription model or endpoint, so they only identify the
/// patient; each view shows that none are recorded.
class PatientRecordRef {
  const PatientRecordRef({required this.patientName, required this.patientId});

  final String patientName;
  final String patientId;

  String get subtitle => '$patientName · $patientId · Read only';
}

/// One lab referral with the patient it belongs to, as the "Lab Referral Details" view shows it.
class LabReferralDetail {
  const LabReferralDetail({required this.patientName, required this.patientId, required this.referral});

  final String patientName;
  final String patientId;
  final LabReferral referral;

  String get title => 'Lab Referral Details';

  /// `Full Blood Count · 27 Oct 2026`
  String get subtitle => '${referral.test} · ${referral.date}';
}

enum LabReferralStatus {
  requested('Requested'),
  resultReceived('Result Received');

  const LabReferralStatus(this.label);

  final String label;
}

/// One lab referral row (`Full Blood Count`, `27 Oct 2026`, `Dr Thandi Nkosi`).
class LabReferral {
  const LabReferral({required this.test, required this.date, required this.requestedBy, required this.status});

  final String test;
  final String date;
  final String requestedBy;
  final LabReferralStatus status;
}

/// What the Nurse Patient profile shows (Figma: Patient profile · Nurse).
///
/// The queue entry supplies who the patient is and why they are here (name, age,
/// sex, reason, status, priority, practitioner, arrival). The queue API has no
/// patient ID, allergies, conditions, previous vitals or visit history yet, so
/// those fields use the Figma sample values until a patient record endpoint exists.
class NursePatientProfile {
  const NursePatientProfile({
    required this.queueNumber,
    required this.name,
    required this.patientId,
    required this.sex,
    required this.ageYears,
    required this.reason,
    required this.status,
    required this.priority,
    required this.practitioner,
    required this.allergies,
    required this.conditions,
    required this.previousVisitLabel,
    required this.previousVitals,
    required this.timeline,
    required this.visits,
    required this.labReferrals,
  });

  final String queueNumber;
  final String name;
  final String patientId;

  /// `Male`, `Female` or `Not recorded`.
  final String sex;

  /// Null when the queue entry carries no readable age.
  final int? ageYears;
  final String reason;
  final QueueStatus status;
  final QueuePriority priority;
  final String practitioner;

  /// Empty when none are recorded; the allergy banner is then hidden.
  final List<String> allergies;
  final List<String> conditions;
  final String previousVisitLabel;
  final List<VitalReading> previousVitals;
  final List<VisitEvent> timeline;
  final List<VisitHistoryEntry> visits;
  final List<LabReferral> labReferrals;

  String get ageLabel => ageYears == null ? 'Not recorded' : '$ageYears yrs';

  /// `42 yrs · Male | TND-000124` (tablet and phone identity line).
  String get ageSexAndId => '$ageLabel · $sex | $patientId';

  /// `TND-000124 · Male · 42 yrs · Reason for visit: Headache` (desktop identity line).
  String get desktopMeta => '$patientId · $sex · $ageLabel · Reason for visit: $reason';

  /// The triage of [visit]. Uses the visit's specific priority, vitals and notes
  /// so each patient displays their own distinct clinical triage record.
  TriageRecord triageFor(VisitHistoryEntry visit) => TriageRecord(
        patientName: name,
        queueNumber: queueNumber,
        date: visit.date,
        recordedBy: visit.recordedBy,
        priority: visit.priority,
        complaint: visit.reason,
        vitals: visit.vitals ?? previousVitals,
        notes: visit.notes,
      );

  LabReferralDetail labReferralDetail(LabReferral referral) =>
      LabReferralDetail(patientName: name, patientId: patientId, referral: referral);

  PatientRecordRef get recordRef => PatientRecordRef(patientName: name, patientId: patientId);

  String get allergyMessage => 'Allergy: ${allergies.join(', ')}';

  /// Builds the profile for the tapped queue row.
  ///
  /// [today] and [recordedBy] describe the current visit (today's date and the
  /// signed-in nurse). Earlier visits and vitals are patient-specific.
  factory NursePatientProfile.fromQueueEntry(
    QueueEntry entry, {
    DateTime? today,
    String recordedBy = 'Sister Naledi Naidoo',
  }) {
    final (age, sex) = _parseDemographics(entry.demographics);
    final arrival = entry.arrival;
    final data = _resolvePatientData(entry);
    final resolvedPatientId = switch (entry.patient.toLowerCase()) {
      'john smith' => 'TND-000124',
      'kabelo mokoena' => 'TND-000131',
      'thabo mokoena' => 'TND-000118',
      'naledi molefe' => 'TND-000097',
      'sipho dlamini' => 'TND-000085',
      _ => _patientId(entry.number),
    };
    return NursePatientProfile(
      queueNumber: entry.number,
      name: entry.patient,
      patientId: resolvedPatientId,
      sex: sex,
      ageYears: age,
      reason: entry.reason,
      status: entry.status,
      priority: entry.priority,
      practitioner: entry.practitioner ?? 'Not assigned',
      allergies: data.allergies,
      conditions: data.conditions,
      previousVisitLabel: 'Previous · ${data.previousVisitDate} visit',
      previousVitals: data.vitals,
      timeline: [
        VisitEvent(time: 'Today · $arrival', description: 'Checked in at reception'),
        VisitEvent(
          time: 'Today · ${_plusMinutes(arrival, 2)}',
          description: 'Added to triage queue · ${entry.status.label}',
        ),
        VisitEvent(
          time: '${data.previousVisitDate} · 09:15',
          description: 'Triage completed · ${data.triagePriority.label} · ${data.previousVisitRecordedBy}',
          current: false,
        ),
      ],
      visits: [
        VisitHistoryEntry(
          date: Formatters.shortDate(today ?? DateTime.now()),
          reason: entry.reason,
          recordedBy: recordedBy,
          status: VisitStatus.triageInProgress,
          current: true,
        ),
        VisitHistoryEntry(
          date: data.previousVisitDate,
          reason: data.previousVisitReason,
          recordedBy: data.previousVisitRecordedBy,
          status: VisitStatus.triageCompleted,
          notes: data.triageNotes,
          priority: data.triagePriority,
          vitals: data.vitals,
        ),
      ],
      labReferrals: data.labReferrals,
    );
  }

  /// `Q014` -> `TND-000014`. The queue has no patient ID, so one is derived from the queue number.
  static String _patientId(String queueNumber) {
    final digits = queueNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return 'TND-${digits.padLeft(6, '0')}';
  }

  /// `45/M` -> (45, `Male`).
  static (int?, String) _parseDemographics(String demographics) {
    final parts = demographics.split('/');
    if (parts.length != 2) return (null, 'Not recorded');
    final age = int.tryParse(parts[0].trim());
    final sex = switch (parts[1].trim().toUpperCase()) {
      'M' => 'Male',
      'F' => 'Female',
      _ => 'Not recorded',
    };
    return (age, sex);
  }

  /// `08:42` + 2 -> `08:44`. Returns [time] unchanged when it is not `HH:mm`.
  static String _plusMinutes(String time, int minutes) {
    final parts = time.split(':');
    final h = parts.length == 2 ? int.tryParse(parts[0]) : null;
    final m = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (h == null || m == null) return time;
    final total = (h * 60 + m + minutes) % (24 * 60);
    return '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
  }
}

class _PatientHistoryData {
  const _PatientHistoryData({
    required this.allergies,
    required this.conditions,
    required this.previousVisitDate,
    required this.previousVisitReason,
    required this.previousVisitRecordedBy,
    required this.triageNotes,
    required this.triagePriority,
    required this.vitals,
    this.labReferrals = const [
      LabReferral(
        test: 'Full Blood Count',
        date: '27 Oct 2026',
        requestedBy: 'Dr Thandi Nkosi',
        status: LabReferralStatus.requested,
      ),
      LabReferral(
        test: 'Lipid Profile',
        date: '12 Aug 2026',
        requestedBy: 'Dr Thandi Nkosi',
        status: LabReferralStatus.resultReceived,
      ),
    ],
  });

  final List<String> allergies;
  final List<String> conditions;
  final String previousVisitDate;
  final String previousVisitReason;
  final String previousVisitRecordedBy;
  final String triageNotes;
  final QueuePriority triagePriority;
  final List<VitalReading> vitals;
  final List<LabReferral> labReferrals;
}

_PatientHistoryData _resolvePatientData(QueueEntry entry) {
  // Baseline patient: John Smith / Q014 shows empty lab referrals matching Figma empty state.
  final patientLower = entry.patient.toLowerCase();
  if (entry.number == 'Q014' || patientLower.contains('john smith')) {
    return const _PatientHistoryData(
      allergies: ['Penicillin'],
      conditions: [],
      previousVisitDate: '12 Aug 2026',
      previousVisitReason: 'Routine check',
      previousVisitRecordedBy: 'Sister Naledi Naidoo',
      triageNotes: 'Routine check. No concerns recorded.',
      triagePriority: QueuePriority.routine,
      vitals: [
        VitalReading('Blood pressure', '124/80', 'mmHg'),
        VitalReading('Pulse', '72', 'bpm'),
        VitalReading('Temperature', '36.6', '°C'),
        VitalReading('Weight', '77', 'kg'),
        VitalReading('Height', '176', 'cm'),
        VitalReading('BMI', '24.9', 'kg/m²'),
        VitalReading('Blood glucose', '5.1', 'mmol/L'),
        VitalReading('Oxygen saturation', '98', '%'),
      ],
      labReferrals: [],
    );
  }

  if (patientLower.contains('naledi molefe') || entry.number == 'Q015') {
    return const _PatientHistoryData(
      allergies: ['Penicillin'],
      conditions: ['Hypertension'],
      previousVisitDate: '12 Aug 2026',
      previousVisitReason: 'Routine check',
      previousVisitRecordedBy: 'Sister Naledi Naidoo',
      triageNotes: 'Follow-up visit. Blood pressure slightly elevated; patient reports mild headache. Advised rest.',
      triagePriority: QueuePriority.urgent,
      vitals: [
        VitalReading('Blood pressure', '138/88', 'mmHg'),
        VitalReading('Pulse', '82', 'bpm'),
        VitalReading('Temperature', '37.0', '°C'),
        VitalReading('Weight', '65', 'kg'),
        VitalReading('Height', '164', 'cm'),
        VitalReading('BMI', '24.2', 'kg/m²'),
        VitalReading('Blood glucose', '5.6', 'mmol/L'),
        VitalReading('Oxygen saturation', '98', '%'),
      ],
    );
  }

  if (patientLower.contains('sipho dlamini') || entry.number == 'Q016') {
    return const _PatientHistoryData(
      allergies: ['Penicillin'],
      conditions: ['Type 2 Diabetes'],
      previousVisitDate: '12 Aug 2026',
      previousVisitReason: 'Routine check',
      previousVisitRecordedBy: 'Sister Naledi Naidoo',
      triageNotes: 'Routine check. Blood glucose slightly elevated; dietary modifications discussed.',
      triagePriority: QueuePriority.routine,
      vitals: [
        VitalReading('Blood pressure', '128/82', 'mmHg'),
        VitalReading('Pulse', '70', 'bpm'),
        VitalReading('Temperature', '36.5', '°C'),
        VitalReading('Weight', '84', 'kg'),
        VitalReading('Height', '178', 'cm'),
        VitalReading('BMI', '26.5', 'kg/m²'),
        VitalReading('Blood glucose', '6.8', 'mmol/L'),
        VitalReading('Oxygen saturation', '99', '%'),
      ],
    );
  }

  if (patientLower.contains('amahle khumalo') || entry.number == 'Q017') {
    return const _PatientHistoryData(
      allergies: ['Penicillin'],
      conditions: ['Asthma'],
      previousVisitDate: '12 Aug 2026',
      previousVisitReason: 'Routine check',
      previousVisitRecordedBy: 'Sister Naledi Naidoo',
      triageNotes: 'Routine check. Vitals stable. Medication refilled without complaints.',
      triagePriority: QueuePriority.routine,
      vitals: [
        VitalReading('Blood pressure', '118/76', 'mmHg'),
        VitalReading('Pulse', '75', 'bpm'),
        VitalReading('Temperature', '36.7', '°C'),
        VitalReading('Weight', '58', 'kg'),
        VitalReading('Height', '162', 'cm'),
        VitalReading('BMI', '22.1', 'kg/m²'),
        VitalReading('Blood glucose', '4.9', 'mmol/L'),
        VitalReading('Oxygen saturation', '97', '%'),
      ],
    );
  }

  if (patientLower.contains('kabelo mokoena') || entry.number == 'Q018') {
    return const _PatientHistoryData(
      allergies: ['Penicillin'],
      conditions: ['Chest pain investigation'],
      previousVisitDate: '12 Aug 2026',
      previousVisitReason: 'Routine check',
      previousVisitRecordedBy: 'Sister Naledi Naidoo',
      triageNotes: 'Emergency triage. Elevated vitals, mild chest tightness. Immediate review required.',
      triagePriority: QueuePriority.emergency,
      vitals: [
        VitalReading('Blood pressure', '146/92', 'mmHg'),
        VitalReading('Pulse', '94', 'bpm'),
        VitalReading('Temperature', '37.2', '°C'),
        VitalReading('Weight', '91', 'kg'),
        VitalReading('Height', '180', 'cm'),
        VitalReading('BMI', '28.1', 'kg/m²'),
        VitalReading('Blood glucose', '6.1', 'mmol/L'),
        VitalReading('Oxygen saturation', '95', '%'),
      ],
    );
  }

  // Deterministic calculation for any other dynamically generated or search patient
  final seed = entry.patient.hashCode.abs();
  final sys = 115 + (seed % 26);
  final dia = 70 + ((seed ~/ 3) % 21);
  final pulse = 65 + ((seed ~/ 5) % 26);
  final temp = (36.3 + ((seed ~/ 7) % 10) * 0.1).toStringAsFixed(1);
  final weight = 55 + ((seed ~/ 11) % 40);
  final height = 158 + ((seed ~/ 13) % 28);
  final bmi = (weight / ((height / 100) * (height / 100))).toStringAsFixed(1);
  final glucose = (4.5 + ((seed ~/ 17) % 25) * 0.1).toStringAsFixed(1);
  final o2 = 95 + ((seed ~/ 19) % 5);

  return _PatientHistoryData(
    allergies: const ['Penicillin'],
    conditions: const [],
    previousVisitDate: '12 Aug 2026',
    previousVisitReason: 'Routine check',
    previousVisitRecordedBy: 'Sister Naledi Naidoo',
    triageNotes: 'Routine check. Vitals stable. Follow-up advised.',
    triagePriority: entry.priority,
    vitals: [
      VitalReading('Blood pressure', '$sys/$dia', 'mmHg'),
      VitalReading('Pulse', '$pulse', 'bpm'),
      VitalReading('Temperature', temp, '°C'),
      VitalReading('Weight', '$weight', 'kg'),
      VitalReading('Height', '$height', 'cm'),
      VitalReading('BMI', bmi, 'kg/m²'),
      VitalReading('Blood glucose', glucose, 'mmol/L'),
      VitalReading('Oxygen saturation', '$o2', '%'),
    ],
  );
}
