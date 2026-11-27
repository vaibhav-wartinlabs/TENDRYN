import 'package:get/get.dart';
import 'package:tendryn/core/api/api_client.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/appointments/models/doctor_appointment.dart';

/// Submits the doctor's leave requests. Errors arrive as `ApiException`.
class LeaveService extends GetxService {
  LeaveService({required this._client});

  final ApiClient _client;

  /// Sends a leave request for [start]..[end] (inclusive) and returns what the server stored.
  Future<DoctorLeaveRequest> submit({required DateTime start, required DateTime end, String? reason}) async {
    final response = await _client.post(
      ApiEndpoints.leaveRequests,
      body: {
        'start_date': Formatters.isoDate(start),
        'end_date': Formatters.isoDate(end),
        'reason': ?reason,
      },
      parse: (json) => DoctorLeaveRequest.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
