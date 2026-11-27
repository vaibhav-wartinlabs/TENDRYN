import 'package:get/get.dart';
import 'package:tendryn/core/storage/preferences_service.dart';
import 'package:tendryn/core/storage/secure_storage_service.dart';
import 'package:tendryn/core/storage/storage_service.dart';

/// The registered owner of both stores. Inject fakes via the constructor in tests.
class StorageManager extends GetxService {
  StorageManager({StorageService? secure, StorageService? preferences})
      : secure = secure ?? const SecureStorageService(),
        preferences = preferences ?? PreferencesService();

  final StorageService secure;
  final StorageService preferences;
}
