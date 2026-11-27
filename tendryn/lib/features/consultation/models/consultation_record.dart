enum ConsultationRecordStatus {
  inProgress('In progress'),
  draft('Draft'),
  signed('Signed');

  final String label;
  const ConsultationRecordStatus(this.label);
}

class ConsultationRecord {
  const ConsultationRecord({
    required this.id,
    required this.patientName,
    required this.visit,
    required this.status,
    required this.lastUpdated,
    this.consultationNumber = '',
  });

  final String id;
  final String patientName;
  final String visit;
  final ConsultationRecordStatus status;
  final String lastUpdated;
  final String consultationNumber;
}
