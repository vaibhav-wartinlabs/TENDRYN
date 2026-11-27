import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tendryn/core/api/api_endpoints.dart';
import 'package:tendryn/core/constants/storage_keys.dart';
import 'package:tendryn/core/storage/storage_service.dart';
import 'package:tendryn/models/auth_tokens.dart';

/// Token lifecycle: persistence in secure storage and refresh.
/// (Login/logout API calls live in services/auth_service.dart.)
class SessionService extends GetxService {
  SessionService({required this._secureStorage, required this._refreshDio});

  final StorageService _secureStorage;
  final Dio _refreshDio;
  Future<AuthTokens?>? _inflightRefresh;

  Future<String?> accessToken() => _secureStorage.read(StorageKeys.accessToken);

  Future<AuthTokens?> readTokens() async {
    final access = await _secureStorage.read(StorageKeys.accessToken);
    final refresh = await _secureStorage.read(StorageKeys.refreshToken);
    return (access == null || refresh == null) ? null : AuthTokens(accessToken: access, refreshToken: refresh);
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    await _secureStorage.write(StorageKeys.accessToken, tokens.accessToken);
    await _secureStorage.write(StorageKeys.refreshToken, tokens.refreshToken);
  }

  Future<void> clear() async {
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
  }

  /// New tokens, or null if refresh failed (tokens are then cleared).
  /// Concurrent callers share a single request.
  Future<AuthTokens?> refresh() =>
      _inflightRefresh ??= _doRefresh().whenComplete(() => _inflightRefresh = null);

  Future<AuthTokens?> _doRefresh() async {
    try {
      final current = await readTokens();
      if (current == null) return null;
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refresh_token': current.refreshToken},
      );
      final tokens = AuthTokens.fromJson(response.data!);
      await saveTokens(tokens);
      return tokens;
    } catch (_) {
      await clear();
      return null;
    }
  }
}
