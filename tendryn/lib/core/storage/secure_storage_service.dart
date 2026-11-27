import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tendryn/core/storage/storage_service.dart';

/// Sensitive data (tokens). Android Keystore / Windows Credential Manager (DPAPI)
/// via flutter_secure_storage, which supports both targets.
class SecureStorageService implements StorageService {
  const SecureStorageService([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
