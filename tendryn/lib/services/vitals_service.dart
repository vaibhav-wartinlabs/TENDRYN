import 'package:get/get.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/services/api_service.dart';

/// Vitals API calls. Each reading is one row. Clinical write -> requires POPIA consent (403).
/// Canonical kinds (match the app's VitalReading labels):
/// blood_pressure, pulse, temperature, weight, height, bmi, blood_glucose, oxygen_saturation.
class VitalsService extends GetxService {
  VitalsService({required ApiService api}) : _api = api;

  final ApiService _api;

  Future<void> recordVital({
    required String patientId,
    required String kind,
    required String value,
    String? unit,
    String? encounterId,
  }) async {
    await _api.client.post(
      ApiEndpoints.vitals,
      body: {
        'patient_id': patientId,
        'kind': kind,
        'value': value,
        if (unit != null) 'unit': unit,
        if (encounterId != null) 'encounter_id': encounterId,
      },
      parse: (_) {},
    );
  }

  Future<List<VitalDto>> fetchVitals({String? patientId, String? encounterId}) async {
    final query = <String, dynamic>{};
    if (patientId != null) query['patient_id'] = patientId;
    if (encounterId != null) query['encounter_id'] = encounterId;
    final response = await _api.client.get(
      ApiEndpoints.vitals,
      query: query.isEmpty ? null : query,
      parse: (json) => (json as List<dynamic>)
          .map((e) => VitalDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }
}

class VitalDto {
  const VitalDto({required this.id, required this.kind, required this.value, this.unit});
  final String id;
  final String kind;
  final String value;
  final String? unit;

  factory VitalDto.fromJson(Map<String, dynamic> json) => VitalDto(
        id: json['id'] as String,
        kind: json['kind'] as String? ?? '',
        value: '${json['value'] ?? ''}',
        unit: json['unit'] as String?,
      );
}
