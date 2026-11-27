import 'package:tendryn/features/dashboard/models/dashboard_model.dart';

/// Status of a patient in the Vitals & Triage queue.
enum VitalsTriageStatus {
  waiting('Waiting'),
  waitingForDoctor('Waiting for Doctor'),
  withDoctor('With Doctor'),
  payment('Payment'),
  done('Done');

  const VitalsTriageStatus(this.label);

  final String label;
}

/// Represents one patient row/card in the Vitals & Triage screen.
class VitalsTriageEntry {
  const VitalsTriageEntry({
    required this.queueNumber,
    required this.patientName,
    required this.patientId,
    required this.sex,
    required this.age,
    required this.waitingTime,
    required this.waitingMinutes,
    required this.reason,
    required this.status,
    required this.priority,
  });

  final String queueNumber;
  final String patientName;
  final String patientId;
  final String sex;
  final int age;
  final String waitingTime;
  final int waitingMinutes;
  final String reason;
  final VitalsTriageStatus status;
  final QueuePriority priority;

  String get demographics => '$patientId · $sex · $age yrs';

  QueueStatus get queueStatus => switch (status) {
    VitalsTriageStatus.waiting => QueueStatus.waiting,
    VitalsTriageStatus.waitingForDoctor => QueueStatus.waitingForDoctor,
    VitalsTriageStatus.withDoctor => QueueStatus.waitingForDoctor,
    _ => QueueStatus.waiting,
  };

  QueueEntry toQueueEntry() => QueueEntry(
    number: queueNumber,
    patient: patientName,
    arrival: '08:42',
    waitingMinutes: waitingMinutes,
    reason: reason,
    priority: priority,
    status: queueStatus,
    practitioner: 'Dr Thandi Nkosi',
    demographics: '$age/$sex',
  );
}

/// Initial seed entries matching Figma Vitals & Triage designs.
const List<VitalsTriageEntry> vitalsTriageSeed = [
  VitalsTriageEntry(
    queueNumber: 'Q-012',
    patientName: 'John Smith',
    patientId: 'TND-000124',
    sex: 'M',
    age: 42,
    waitingTime: '24 min',
    waitingMinutes: 24,
    reason: 'Headache',
    status: VitalsTriageStatus.waiting,
    priority: QueuePriority.routine,
  ),
  VitalsTriageEntry(
    queueNumber: 'Q-013',
    patientName: 'Kabelo Mokoena',
    patientId: 'TND-000131',
    sex: 'M',
    age: 36,
    waitingTime: '6 min',
    waitingMinutes: 6,
    reason: 'Back pain',
    status: VitalsTriageStatus.waiting,
    priority: QueuePriority.routine,
  ),
  VitalsTriageEntry(
    queueNumber: 'Q-004',
    patientName: 'Thabo Mokoena',
    patientId: 'TND-000118',
    sex: 'M',
    age: 45,
    waitingTime: '52 min',
    waitingMinutes: 52,
    reason: 'Chest pain',
    status: VitalsTriageStatus.waitingForDoctor,
    priority: QueuePriority.emergency,
  ),
  VitalsTriageEntry(
    queueNumber: 'Q-008',
    patientName: 'Naledi Molefe',
    patientId: 'TND-000097',
    sex: 'F',
    age: 29,
    waitingTime: '41 min',
    waitingMinutes: 41,
    reason: 'Fever and cough',
    status: VitalsTriageStatus.withDoctor,
    priority: QueuePriority.urgent,
  ),
  VitalsTriageEntry(
    queueNumber: 'Q-002',
    patientName: 'Sipho Dlamini',
    patientId: 'TND-000085',
    sex: 'M',
    age: 61,
    waitingTime: '1 h 10 min',
    waitingMinutes: 70,
    reason: 'Follow-up visit',
    status: VitalsTriageStatus.payment,
    priority: QueuePriority.routine,
  ),
  VitalsTriageEntry(
    queueNumber: 'Q-001',
    patientName: 'Amahle Khumalo',
    patientId: 'TND-000071',
    sex: 'F',
    age: 54,
    waitingTime: '1 h 25 min',
    waitingMinutes: 85,
    reason: 'Prescription refill',
    status: VitalsTriageStatus.done,
    priority: QueuePriority.routine,
  ),
];
