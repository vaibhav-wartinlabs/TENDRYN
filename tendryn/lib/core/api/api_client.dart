import 'package:dio/dio.dart';
import 'package:tendryn/core/api/api_exception.dart';
import 'package:tendryn/core/api/api_response.dart';

typedef JsonParser<T> = T Function(dynamic json);

/// Typed wrapper over Dio. Callers never see [DioException]; failures arrive as [ApiException].
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResponse<T>> get<T>(String path, {Map<String, dynamic>? query, required JsonParser<T> parse}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query), parse);

  Future<ApiResponse<T>> post<T>(String path, {Object? body, required JsonParser<T> parse}) =>
      _send(() => _dio.post<dynamic>(path, data: body), parse);

  Future<ApiResponse<T>> put<T>(String path, {Object? body, required JsonParser<T> parse}) =>
      _send(() => _dio.put<dynamic>(path, data: body), parse);

  Future<ApiResponse<T>> _send<T>(Future<Response<dynamic>> Function() call, JsonParser<T> parse) async {
    try {
      final response = await call();
      return ApiResponse(data: parse(response.data), statusCode: response.statusCode ?? 200);
    } on DioException catch (e) {
      throw ApiException.from(e);
    } on TypeError {
      // The body did not match the model.
      throw const ApiException.unexpected();
    }
  }
}
