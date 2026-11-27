enum LabReviewStatus {
  awaitingReview('Awaiting review'),
  reviewed('Reviewed');

  const LabReviewStatus(this.label);
  final String label;
}

enum LabParameterFlag {
  normal('Normal'),
  high('High'),
  low('Low'),
  abnormal('Abnormal');

  const LabParameterFlag(this.label);
  final String label;
}

class LabParameter {
  const LabParameter({
    required this.name,
    required this.value,
    required this.unit,
    required this.referenceRange,
    this.flag = LabParameterFlag.normal,
  });

  final String name;
  final String value;
  final String unit;
  final String referenceRange;
  final LabParameterFlag flag;
}

class LabResultModel {
  LabResultModel({
    required this.id,
    required this.patientName,
    required this.folderNumber,
    required this.testName,
    required this.category,
    required this.resultReceivedDate,
    required this.sampleCollectedDate,
    required this.orderingDoctor,
    required this.laboratory,
    required this.status,
    required this.parameters,
    this.clinicalNotes,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewAction,
    this.reviewImpression,
    this.idNumber = '740312 5021 087',
    this.age = '52',
    this.gender = 'Male',
    this.dob = '12 Mar 1974',
    this.allergies = 'Penicillin (anaphylaxis)',
    this.relatedReferral = 'Lab referral · 08 Oct 2026',
    this.attachmentsCount = 2,
  });

  final String id;
  final String patientName;
  final String folderNumber;
  final String testName;
  final String category;
  final String resultReceivedDate;
  final String sampleCollectedDate;
  final String orderingDoctor;
  final String laboratory;
  LabReviewStatus status;
  final List<LabParameter> parameters;
  final String? clinicalNotes;
  String? reviewedBy;
  String? reviewedAt;
  String? reviewAction;
  String? reviewImpression;
  final String idNumber;
  final String age;
  final String gender;
  final String dob;
  final String allergies;
  final String relatedReferral;
  final int attachmentsCount;

  LabResultModel copyWith({
    String? id,
    String? patientName,
    String? folderNumber,
    String? testName,
    String? category,
    String? resultReceivedDate,
    String? sampleCollectedDate,
    String? orderingDoctor,
    String? laboratory,
    LabReviewStatus? status,
    List<LabParameter>? parameters,
    String? clinicalNotes,
    String? reviewedBy,
    String? reviewedAt,
    String? reviewAction,
    String? reviewImpression,
    String? idNumber,
    String? age,
    String? gender,
    String? dob,
    String? allergies,
    String? relatedReferral,
    int? attachmentsCount,
  }) {
    return LabResultModel(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      folderNumber: folderNumber ?? this.folderNumber,
      testName: testName ?? this.testName,
      category: category ?? this.category,
      resultReceivedDate: resultReceivedDate ?? this.resultReceivedDate,
      sampleCollectedDate: sampleCollectedDate ?? this.sampleCollectedDate,
      orderingDoctor: orderingDoctor ?? this.orderingDoctor,
      laboratory: laboratory ?? this.laboratory,
      status: status ?? this.status,
      parameters: parameters ?? this.parameters,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewAction: reviewAction ?? this.reviewAction,
      reviewImpression: reviewImpression ?? this.reviewImpression,
      idNumber: idNumber ?? this.idNumber,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      allergies: allergies ?? this.allergies,
      relatedReferral: relatedReferral ?? this.relatedReferral,
      attachmentsCount: attachmentsCount ?? this.attachmentsCount,
    );
  }
}
