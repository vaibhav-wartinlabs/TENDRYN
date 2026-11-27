import 'package:get/get.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/services/api_service.dart';

/// Lab API calls: referrals (raise/sample/upload) and results (list/review).
class LabService extends GetxService {
  LabService({required ApiService api}) : _api = api;

  final ApiService _api;

  Future<List<LabReferralDto>> fetchReferrals({String? status}) async {
    final response = await _api.client.get(
      ApiEndpoints.labReferrals,
      query: status == null ? null : {'status': status},
      parse: (json) => (((json as Map<String, dynamic>)['referrals'] as List<dynamic>?) ?? [])
          .map((e) => LabReferralDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }

  Future<LabReferralDto> createReferral(Map<String, dynamic> body) async {
    final response = await _api.client.post(
      ApiEndpoints.labReferrals,
      body: body,
      parse: (json) => LabReferralDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<LabReferralDto> recordSample(String id, {DateTime? collectedAt, String? notes}) async {
    final response = await _api.client.post(
      ApiEndpoints.labReferralSample(id),
      body: {
        if (collectedAt != null) 'collected_at': collectedAt.toUtc().toIso8601String(),
        if (notes != null) 'sample_notes': notes,
      },
      parse: (json) => LabReferralDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<LabResultDto> uploadResult(String referralId, Map<String, dynamic> body) async {
    final response = await _api.client.post(
      ApiEndpoints.labReferralResult(referralId),
      body: body,
      parse: (json) => LabResultDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<List<LabResultDto>> fetchResults({String? status}) async {
    final response = await _api.client.get(
      ApiEndpoints.labResults,
      query: status == null ? null : {'status': status},
      parse: (json) => (((json as Map<String, dynamic>)['results'] as List<dynamic>?) ?? [])
          .map((e) => LabResultDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }

  Future<LabResultDto> getResult(String id) async {
    final response = await _api.client.get(
      ApiEndpoints.labResult(id),
      parse: (json) => LabResultDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<LabResultDto> recordReview(String id, {String? action, String? impression, bool notifyPatient = false}) async {
    final response = await _api.client.post(
      ApiEndpoints.labResultReview(id),
      body: {
        if (action != null) 'action': action,
        if (impression != null) 'impression': impression,
        'notify_patient': notifyPatient,
      },
      parse: (json) => LabResultDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}

class LabReferralDto {
  const LabReferralDto({
    required this.id,
    required this.patientName,
    this.folderNumber,
    this.reference,
    required this.testsRequested,
    this.laboratory,
    required this.status,
    this.referralDate,
    this.uploadedDocumentName,
  });

  final String id;
  final String patientName;
  final String? folderNumber;
  final String? reference;
  final String testsRequested;
  final String? laboratory;
  final String status; // requested | sample_taken | result_received
  final String? referralDate;
  final String? uploadedDocumentName;

  factory LabReferralDto.fromJson(Map<String, dynamic> json) => LabReferralDto(
        id: json['id'] as String,
        patientName: json['patient_name'] as String? ?? '',
        folderNumber: json['folder_number'] as String?,
        reference: json['reference'] as String?,
        testsRequested: json['tests_requested'] as String? ?? '',
        laboratory: json['laboratory'] as String?,
        status: json['status'] as String? ?? 'requested',
        referralDate: json['referral_date'] as String?,
        uploadedDocumentName: json['uploaded_document_name'] as String?,
      );
}

class LabParameterDto {
  const LabParameterDto({required this.name, required this.value, this.unit, this.referenceRange, this.flag = 'normal'});
  final String name;
  final String value;
  final String? unit;
  final String? referenceRange;
  final String flag; // normal | high | low | abnormal

  factory LabParameterDto.fromJson(Map<String, dynamic> json) => LabParameterDto(
        name: json['name'] as String? ?? '',
        value: '${json['value'] ?? ''}',
        unit: json['unit'] as String?,
        referenceRange: json['reference_range'] as String?,
        flag: json['flag'] as String? ?? 'normal',
      );
}

class LabResultDto {
  const LabResultDto({
    required this.id,
    required this.patientName,
    this.folderNumber,
    required this.testName,
    this.category,
    this.laboratory,
    required this.status,
    this.parameters = const [],
    this.reviewImpression,
    this.reviewAction,
  });

  final String id;
  final String patientName;
  final String? folderNumber;
  final String testName;
  final String? category;
  final String? laboratory;
  final String status; // awaiting_review | reviewed
  final List<LabParameterDto> parameters;
  final String? reviewImpression;
  final String? reviewAction;

  factory LabResultDto.fromJson(Map<String, dynamic> json) => LabResultDto(
        id: json['id'] as String,
        patientName: json['patient_name'] as String? ?? '',
        folderNumber: json['folder_number'] as String?,
        testName: json['test_name'] as String? ?? '',
        category: json['category'] as String?,
        laboratory: json['laboratory'] as String?,
        status: json['status'] as String? ?? 'awaiting_review',
        parameters: ((json['parameters'] as List<dynamic>?) ?? [])
            .map((e) => LabParameterDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        reviewImpression: json['review_impression'] as String?,
        reviewAction: json['review_action'] as String?,
      );
}
