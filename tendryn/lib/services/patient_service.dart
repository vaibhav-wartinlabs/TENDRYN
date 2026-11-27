import 'package:get/get.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/services/api_service.dart';

/// Patient API calls. DTOs below mirror the backend JSON (PatientOut / PatientCreateResult /
/// PatientStats). Controllers map these to their display models (PatientRecord, etc.).
class PatientService extends GetxService {
  PatientService({required ApiService api}) : _api = api;

  final ApiService _api;

  /// Empty [query] returns the whole directory.
  Future<List<PatientDto>> search({String? query}) async {
    final response = await _api.client.get(
      ApiEndpoints.patientsSearch,
      query: query == null || query.isEmpty ? null : {'q': query},
      parse: (json) => (json as List<dynamic>)
          .map((e) => PatientDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }

  Future<PatientDto> getById(String id) async {
    final response = await _api.client.get(
      ApiEndpoints.patient(id),
      parse: (json) => PatientDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<PatientRegisterResult> register(Map<String, dynamic> body) async {
    final response = await _api.client.post(
      ApiEndpoints.patients,
      body: body,
      parse: (json) => PatientRegisterResult.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<PatientDto> update(String id, Map<String, dynamic> body) async {
    final response = await _api.client.put(
      ApiEndpoints.patient(id),
      body: body,
      parse: (json) => PatientDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<PatientStatsDto> stats() async {
    final response = await _api.client.get(
      ApiEndpoints.patientsStats,
      parse: (json) => PatientStatsDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}

class PatientDto {
  const PatientDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.fileNumber,
    this.saIdNumber,
    this.dateOfBirth,
    this.gender,
    this.mobileNumber,
    this.residentialAddress,
    this.nextOfKinName,
    this.nextOfKinRelationship,
    this.nextOfKinContact,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? fileNumber;
  final String? saIdNumber;
  final String? dateOfBirth; // ISO yyyy-MM-dd
  final String? gender;
  final String? mobileNumber;
  final String? residentialAddress;
  final String? nextOfKinName;
  final String? nextOfKinRelationship;
  final String? nextOfKinContact;

  String get fullName => '$firstName $lastName';

  factory PatientDto.fromJson(Map<String, dynamic> json) => PatientDto(
        id: json['id'] as String,
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        fileNumber: json['file_number'] as String?,
        saIdNumber: json['sa_id_number'] as String?,
        dateOfBirth: json['date_of_birth'] as String?,
        gender: json['gender'] as String?,
        mobileNumber: json['mobile_number'] as String?,
        residentialAddress: json['residential_address'] as String?,
        nextOfKinName: json['next_of_kin_name'] as String?,
        nextOfKinRelationship: json['next_of_kin_relationship'] as String?,
        nextOfKinContact: json['next_of_kin_contact'] as String?,
      );
}

class PatientMatchDto {
  const PatientMatchDto({required this.id, required this.fullName, required this.match, this.fileNumber});
  final String id;
  final String fullName;
  final String match; // 'high' | 'possible'
  final String? fileNumber;

  factory PatientMatchDto.fromJson(Map<String, dynamic> json) => PatientMatchDto(
        id: json['id'] as String,
        fullName: json['full_name'] as String? ?? '',
        match: json['match'] as String? ?? 'possible',
        fileNumber: json['file_number'] as String?,
      );
}

class PatientRegisterResult {
  const PatientRegisterResult({required this.patient, required this.possibleDuplicates});
  final PatientDto patient;
  final List<PatientMatchDto> possibleDuplicates;

  factory PatientRegisterResult.fromJson(Map<String, dynamic> json) => PatientRegisterResult(
        patient: PatientDto.fromJson(json['patient'] as Map<String, dynamic>),
        possibleDuplicates: ((json['possible_duplicates'] as List<dynamic>?) ?? [])
            .map((e) => PatientMatchDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PatientStatsDto {
  const PatientStatsDto({
    required this.total,
    required this.recentlySeen,
    required this.inQueue,
    required this.recentlyAdded,
  });
  final int total;
  final int recentlySeen;
  final int inQueue;
  final int recentlyAdded;

  factory PatientStatsDto.fromJson(Map<String, dynamic> json) => PatientStatsDto(
        total: json['total'] as int? ?? 0,
        recentlySeen: json['recently_seen'] as int? ?? 0,
        inQueue: json['in_queue'] as int? ?? 0,
        recentlyAdded: json['recently_added'] as int? ?? 0,
      );
}
