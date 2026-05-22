import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for non-sensitive local storage.
///
/// Wraps [SharedPreferences] to provide safe read/write methods.
class LocalStorageHelper {
  const LocalStorageHelper({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  /// Get string value.
  String? getString(String key) => _sharedPreferences.getString(key);

  /// Save string value.
  Future<bool> setString(String key, String value) =>
      _sharedPreferences.setString(key, value);

  /// Get boolean value.
  bool? getBool(String key) => _sharedPreferences.getBool(key);

  /// Save boolean value.
  Future<bool> setBool(String key, bool value) =>
      _sharedPreferences.setBool(key, value);

  /// Get integer value.
  int? getInt(String key) => _sharedPreferences.getInt(key);

  /// Save integer value.
  Future<bool> setInt(String key, int value) =>
      _sharedPreferences.setInt(key, value);

  /// Get double value.
  double? getDouble(String key) => _sharedPreferences.getDouble(key);

  /// Save double value.
  Future<bool> setDouble(String key, double value) =>
      _sharedPreferences.setDouble(key, value);

  /// Remove item.
  Future<bool> remove(String key) => _sharedPreferences.remove(key);

  /// Clear all items.
  Future<bool> clear() => _sharedPreferences.clear();

  /// Check if key exists.
  bool containsKey(String key) => _sharedPreferences.containsKey(key);
}
