import 'package:tendryn/features/dashboard/models/dashboard_model.dart';

/// The Queue page data: the headline figures and every entry in today's queue.
/// Entries reuse the Dashboard's [QueueEntry].
class QueueModel {
  const QueueModel({
    required this.patientsWaiting,
    required this.seenToday,
    required this.averageWaitMinutes,
    required this.entries,
  });

  final int patientsWaiting;
  final int seenToday;
  final int averageWaitMinutes;
  final List<QueueEntry> entries;

  factory QueueModel.fromJson(Map<String, dynamic> json) => QueueModel(
    patientsWaiting: json['patients_waiting'] as int,
    seenToday: json['seen_today'] as int,
    averageWaitMinutes: json['average_wait_minutes'] as int,
    entries: (json['entries'] as List<dynamic>)
        .map((e) => QueueEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'patients_waiting': patientsWaiting,
    'seen_today': seenToday,
    'average_wait_minutes': averageWaitMinutes,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  QueueModel copyWith({
    int? patientsWaiting,
    int? seenToday,
    int? averageWaitMinutes,
    List<QueueEntry>? entries,
  }) => QueueModel(
    patientsWaiting: patientsWaiting ?? this.patientsWaiting,
    seenToday: seenToday ?? this.seenToday,
    averageWaitMinutes: averageWaitMinutes ?? this.averageWaitMinutes,
    entries: entries ?? this.entries,
  );
}
