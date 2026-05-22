import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_core/src/storage/local_storage_helper.dart';

/// Cubit to manage system and user selected ThemeModes.
///
/// Keeps user preference stored persistently using [LocalStorageHelper].
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required LocalStorageHelper localStorageHelper})
      : _storage = localStorageHelper,
        super(ThemeMode.system) {
    _loadTheme();
  }

  final LocalStorageHelper _storage;
  static const _themeKey = 'app_theme_mode';

  void _loadTheme() {
    final themeStr = _storage.getString(_themeKey);
    if (themeStr != null) {
      final mode = ThemeMode.values.firstWhere(
        (e) => e.name == themeStr,
        orElse: () => ThemeMode.system,
      );
      emit(mode);
    }
  }

  /// Update the current theme mode to a specific value.
  Future<void> setTheme(ThemeMode mode) async {
    await _storage.setString(_themeKey, mode.name);
    emit(mode);
  }

  /// Toggle between Light and Dark mode.
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newMode);
  }
}
