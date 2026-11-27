/// Urgency of a queued patient. Routine < urgent < emergency.
enum QueuePriority {
  routine('Routine'),
  urgent('Urgent'),
  emergency('Emergency');

  const QueuePriority(this.label);

  final String label;
}

/// Where a queued patient currently is.
enum QueueStatus {
  waiting('Waiting'),
  waitingForDoctor('Waiting for Doctor'),
  withNurse('With Nurse');

  const QueueStatus(this.label);

  final String label;
}

class QueueEntry {
  const QueueEntry({
    required this.number,
    required this.patient,
    required this.arrival,
    required this.waitingMinutes,
    required this.reason,
    required this.priority,
    required this.status,
    this.practitioner,
    this.demographics = '45/M',
  });

  final String number;
  final String patient;

  /// Arrival time as `HH:mm`.
  final String arrival;
  final int waitingMinutes;
  final String reason;
  final QueuePriority priority;
  final QueueStatus status;

  /// Null when nobody is assigned yet.
  final String? practitioner;

  /// Demographic information (e.g. '45/M').
  final String demographics;

  factory QueueEntry.fromJson(Map<String, dynamic> json) => QueueEntry(
    number: json['number'] as String,
    patient: json['patient'] as String,
    arrival: json['arrival'] as String,
    waitingMinutes: json['waiting_minutes'] as int,
    reason: json['reason'] as String,
    priority:
        QueuePriority.values.asNameMap()[json['priority']] ??
        QueuePriority.routine,
    status:
        QueueStatus.values.asNameMap()[json['status']] ?? QueueStatus.waiting,
    practitioner: json['practitioner'] as String?,
    demographics: json['demographics'] as String? ?? '45/M',
  );

  Map<String, dynamic> toJson() => {
    'number': number,
    'patient': patient,
    'arrival': arrival,
    'waiting_minutes': waitingMinutes,
    'reason': reason,
    'priority': priority.name,
    'status': status.name,
    'practitioner': practitioner,
    'demographics': demographics,
  };

  QueueEntry copyWith({
    String? number,
    String? patient,
    String? arrival,
    int? waitingMinutes,
    String? reason,
    QueuePriority? priority,
    QueueStatus? status,
    String? practitioner,
    String? demographics,
  }) => QueueEntry(
    number: number ?? this.number,
    patient: patient ?? this.patient,
    arrival: arrival ?? this.arrival,
    waitingMinutes: waitingMinutes ?? this.waitingMinutes,
    reason: reason ?? this.reason,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    practitioner: practitioner ?? this.practitioner,
    demographics: demographics ?? this.demographics,
  );
}

enum AppointmentStatus {
  checkedIn('Checked In'),
  upcoming('Upcoming');

  const AppointmentStatus(this.label);

  final String label;
}

class AppointmentEntry {
  const AppointmentEntry({
    required this.time,
    required this.patient,
    required this.practitioner,
    required this.visitType,
    required this.status,
  });

  /// Start time as `HH:mm`.
  final String time;
  final String patient;
  final String practitioner;
  final String visitType;
  final AppointmentStatus status;

  factory AppointmentEntry.fromJson(Map<String, dynamic> json) =>
      AppointmentEntry(
        time: json['time'] as String,
        patient: json['patient'] as String,
        practitioner: json['practitioner'] as String,
        visitType: json['visit_type'] as String,
        status:
            AppointmentStatus.values.asNameMap()[json['status']] ??
            AppointmentStatus.upcoming,
      );

  Map<String, dynamic> toJson() => {
    'time': time,
    'patient': patient,
    'practitioner': practitioner,
    'visit_type': visitType,
    'status': status.name,
  };
}

class AppointmentsSummary {
  const AppointmentsSummary({
    required this.booked,
    required this.remaining,
    required this.noShows,
    required this.items,
  });

  final int booked;
  final int remaining;
  final int noShows;
  final List<AppointmentEntry> items;

  factory AppointmentsSummary.fromJson(Map<String, dynamic> json) =>
      AppointmentsSummary(
        booked: json['booked'] as int,
        remaining: json['remaining'] as int,
        noShows: json['no_shows'] as int,
        items: (json['items'] as List<dynamic>)
            .map((e) => AppointmentEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'booked': booked,
    'remaining': remaining,
    'no_shows': noShows,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

enum AttentionKind { appointmentConflicts, outstandingPayments }

class AttentionItem {
  const AttentionItem({
    required this.kind,
    required this.title,
    required this.description,
  });

  final AttentionKind kind;
  final String title;
  final String description;

  factory AttentionItem.fromJson(Map<String, dynamic> json) => AttentionItem(
    kind:
        AttentionKind.values.asNameMap()[json['kind']] ??
        AttentionKind.appointmentConflicts,
    title: json['title'] as String,
    description: json['description'] as String,
  );

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'title': title,
    'description': description,
  };
}

class DashboardModel {
  const DashboardModel({
    required this.patientsWaiting,
    required this.seenToday,
    required this.averageWaitMinutes,
    required this.takingsToday,
    required this.queue,
    required this.appointments,
    required this.attention,
  });

  final int patientsWaiting;
  final int seenToday;
  final int averageWaitMinutes;
  final double takingsToday;
  final List<QueueEntry> queue;
  final AppointmentsSummary appointments;
  final List<AttentionItem> attention;

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    patientsWaiting: json['patients_waiting'] as int,
    seenToday: json['seen_today'] as int,
    averageWaitMinutes: json['average_wait_minutes'] as int,
    takingsToday: (json['takings_today'] as num).toDouble(),
    queue: (json['queue'] as List<dynamic>)
        .map((e) => QueueEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
    appointments: AppointmentsSummary.fromJson(
      json['appointments'] as Map<String, dynamic>,
    ),
    attention: (json['attention'] as List<dynamic>)
        .map((e) => AttentionItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'patients_waiting': patientsWaiting,
    'seen_today': seenToday,
    'average_wait_minutes': averageWaitMinutes,
    'takings_today': takingsToday,
    'queue': queue.map((e) => e.toJson()).toList(),
    'appointments': appointments.toJson(),
    'attention': attention.map((e) => e.toJson()).toList(),
  };
}
