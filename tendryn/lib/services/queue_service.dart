import 'package:get/get.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/core/utils/formatters.dart';
import 'package:tendryn/features/queue/models/queue_model.dart';
import 'package:tendryn/services/api_service.dart';

class QueueService extends GetxService {
  QueueService({required this._api});

  final ApiService _api;

  Future<QueueModel> fetchQueue({required DateTime date}) async {
    final response = await _api.client.get(
      ApiEndpoints.queue,
      query: {'date': Formatters.isoDate(date)},
      parse: (json) => QueueModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
