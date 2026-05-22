import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Helper class for secure key-value storage.
///
/// Wraps [FlutterSecureStorage] to provide generic read/write methods.
class SecureStorageHelper {
  const SecureStorageHelper({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  /// Write string value to secure storage.
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Read string value from secure storage.
  Future<String?> read({required String key}) async {
    return _secureStorage.read(key: key);
  }

  /// Delete value from secure storage.
  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  /// Clear all values in secure storage.
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  /// Check if key exists in secure storage.
  Future<bool> containsKey({required String key}) async {
    return _secureStorage.containsKey(key: key);
  }
}
