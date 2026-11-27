import 'package:get/get.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/features/dashboard/models/dashboard_model.dart';
import 'package:tendryn/services/api_service.dart';

class DashboardService extends GetxService {
  DashboardService({required this._api});

  final ApiService _api;

  Future<DashboardModel> fetchSummary() async {
    final response = await _api.client.get(
      ApiEndpoints.dashboardSummary,
      parse: (json) => DashboardModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
