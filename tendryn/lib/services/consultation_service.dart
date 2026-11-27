import 'package:get/get.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/services/api_service.dart';

/// Consultation / encounter API calls. Clinical writes require POPIA consent on the
/// patient; the backend returns 403 (surfaced as ApiException with statusCode 403).
class ConsultationService extends GetxService {
  ConsultationService({required ApiService api}) : _api = api;

  final ApiService _api;

  Future<List<ConsultationDto>> fetchConsultations() async {
    final response = await _api.client.get(
      ApiEndpoints.consultations,
      parse: (json) => (((json as Map<String, dynamic>)['items'] as List<dynamic>?) ?? [])
          .map((e) => ConsultationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }

  Future<EncounterDto> createEncounter({
    required String patientId,
    String? queueEntryId,
    String? reason,
    String? notes,
  }) async {
    final response = await _api.client.post(
      ApiEndpoints.encounters,
      body: {
        'patient_id': patientId,
        if (queueEntryId != null) 'queue_entry_id': queueEntryId,
        if (reason != null) 'reason': reason,
        if (notes != null) 'notes': notes,
      },
      parse: (json) => EncounterDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<EncounterDto> updateEncounter(String id, {String? reason, String? notes}) async {
    final response = await _api.client.patch(
      ApiEndpoints.encounter(id),
      body: {if (reason != null) 'reason': reason, if (notes != null) 'notes': notes},
      parse: (json) => EncounterDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<EncounterDto> signOff(String id) async {
    final response = await _api.client.post(
      ApiEndpoints.encounterSignOff(id),
      parse: (json) => EncounterDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<void> addDiagnosis(String encounterId, {String? code, required String description}) async {
    await _api.client.post(
      ApiEndpoints.encounterDiagnoses(encounterId),
      body: {if (code != null) 'code': code, 'description': description},
      parse: (_) {},
    );
  }

  /// items: each {description, dosage?, quantity?, instructions?, medicine_id?}
  Future<void> addPrescription(String encounterId, {String? notes, required List<Map<String, dynamic>> items}) async {
    await _api.client.post(
      ApiEndpoints.encounterPrescriptions(encounterId),
      body: {if (notes != null) 'notes': notes, 'items': items},
      parse: (_) {},
    );
  }

  Future<void> addAddendum(String encounterId, String text) async {
    await _api.client.post(
      ApiEndpoints.encounterAddenda(encounterId),
      body: {'text': text},
      parse: (_) {},
    );
  }
}

class ConsultationDto {
  const ConsultationDto({
    required this.id,
    required this.patientName,
    required this.visit,
    required this.status,
    this.lastUpdated,
    this.consultationNumber = '',
  });

  final String id;
  final String patientName;
  final String visit;
  final String status; // inProgress | draft | signed
  final String? lastUpdated;
  final String consultationNumber;

  factory ConsultationDto.fromJson(Map<String, dynamic> json) => ConsultationDto(
        id: json['id'] as String,
        patientName: json['patient_name'] as String? ?? '',
        visit: json['visit'] as String? ?? '',
        status: json['status'] as String? ?? 'inProgress',
        lastUpdated: json['last_updated'] as String?,
        consultationNumber: json['consultation_number'] as String? ?? '',
      );
}

class EncounterDto {
  const EncounterDto({required this.id, required this.patientId, required this.signedOff, this.reason, this.notes});
  final String id;
  final String patientId;
  final bool signedOff;
  final String? reason;
  final String? notes;

  factory EncounterDto.fromJson(Map<String, dynamic> json) => EncounterDto(
        id: json['id'] as String,
        patientId: json['patient_id'] as String,
        signedOff: json['signed_off'] as bool? ?? false,
        reason: json['reason'] as String?,
        notes: json['notes'] as String?,
      );
}
