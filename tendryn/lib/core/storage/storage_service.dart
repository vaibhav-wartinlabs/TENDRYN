/// Minimal async key/value contract. Implementations decide where the data
/// lives (secure vault, preferences, memory in tests); UI never touches them.
abstract interface class StorageService {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}
