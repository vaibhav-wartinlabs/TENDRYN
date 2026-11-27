import 'package:shared_preferences/shared_preferences.dart';
import 'package:tendryn/core/storage/storage_service.dart';

/// Non-sensitive settings. shared_preferences supports Android and Windows.
class PreferencesService implements StorageService {
  PreferencesService();

  Future<SharedPreferences>? _instance;

  Future<SharedPreferences> get _prefs => _instance ??= SharedPreferences.getInstance();

  @override
  Future<String?> read(String key) async => (await _prefs).getString(key);

  @override
  Future<void> write(String key, String value) async => (await _prefs).setString(key, value);

  @override
  Future<void> delete(String key) async => (await _prefs).remove(key);
}
