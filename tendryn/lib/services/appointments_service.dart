import 'package:get/get.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/services/api_service.dart';

/// Appointments API calls. DTOs mirror AppointmentOut / AppointmentBookResult.
class AppointmentsService extends GetxService {
  AppointmentsService({required ApiService api}) : _api = api;

  final ApiService _api;

  Future<List<AppointmentDto>> fetchDay(DateTime date) async {
    final response = await _api.client.get(
      ApiEndpoints.appointments,
      query: {'day': Formatters.isoDate(date)},
      parse: (json) => (json as List<dynamic>)
          .map((e) => AppointmentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }

  Future<AppointmentBookResultDto> book({
    required String patientId,
    required DateTime scheduledStart,
    DateTime? scheduledEnd,
    String? practitionerId,
    String? visitType,
    String? reason,
  }) async {
    final response = await _api.client.post(
      ApiEndpoints.appointments,
      body: {
        'patient_id': patientId,
        'scheduled_start': scheduledStart.toUtc().toIso8601String(),
        if (scheduledEnd != null) 'scheduled_end': scheduledEnd.toUtc().toIso8601String(),
        if (practitionerId != null) 'practitioner_id': practitionerId,
        if (visitType != null) 'visit_type': visitType,
        if (reason != null) 'reason': reason,
      },
      parse: (json) => AppointmentBookResultDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<AppointmentDto> checkIn(String id) => _action(ApiEndpoints.appointmentCheckIn(id));
  Future<AppointmentDto> cancel(String id) => _action(ApiEndpoints.appointmentCancel(id));
  Future<AppointmentDto> noShow(String id) => _action(ApiEndpoints.appointmentNoShow(id));

  Future<AppointmentBookResultDto> reschedule({
    required String id,
    required DateTime scheduledStart,
    DateTime? scheduledEnd,
    String? practitionerId,
  }) async {
    final response = await _api.client.post(
      ApiEndpoints.appointmentReschedule(id),
      body: {
        'scheduled_start': scheduledStart.toUtc().toIso8601String(),
        if (scheduledEnd != null) 'scheduled_end': scheduledEnd.toUtc().toIso8601String(),
        if (practitionerId != null) 'practitioner_id': practitionerId,
      },
      parse: (json) => AppointmentBookResultDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<AppointmentDto> _action(String path) async {
    final response = await _api.client.post(
      path,
      parse: (json) => AppointmentDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}

class AppointmentDto {
  const AppointmentDto({
    required this.id,
    this.patientId,
    this.patientName,
    this.fileNumber,
    this.practitionerId,
    this.practitionerName,
    required this.scheduledStart,
    this.scheduledEnd,
    this.visitType,
    required this.status,
    this.reason,
  });

  final String id;
  final String? patientId;
  final String? patientName;
  final String? fileNumber;
  final String? practitionerId;
  final String? practitionerName;
  final String scheduledStart; // ISO datetime
  final String? scheduledEnd;
  final String? visitType;
  final String status; // upcoming | checked_in | rescheduled | cancelled | no_show
  final String? reason;

  factory AppointmentDto.fromJson(Map<String, dynamic> json) => AppointmentDto(
        id: json['id'] as String,
        patientId: json['patient_id'] as String?,
        patientName: json['patient_name'] as String?,
        fileNumber: json['file_number'] as String?,
        practitionerId: json['practitioner_id'] as String?,
        practitionerName: json['practitioner_name'] as String?,
        scheduledStart: json['scheduled_start'] as String,
        scheduledEnd: json['scheduled_end'] as String?,
        visitType: json['visit_type'] as String?,
        status: json['status'] as String? ?? 'upcoming',
        reason: json['reason'] as String?,
      );
}

class AppointmentBookResultDto {
  const AppointmentBookResultDto({required this.appointment, required this.overlaps});
  final AppointmentDto appointment;
  final List<AppointmentDto> overlaps;

  factory AppointmentBookResultDto.fromJson(Map<String, dynamic> json) => AppointmentBookResultDto(
        appointment: AppointmentDto.fromJson(json['appointment'] as Map<String, dynamic>),
        overlaps: ((json['overlaps'] as List<dynamic>?) ?? [])
            .map((e) => AppointmentDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
