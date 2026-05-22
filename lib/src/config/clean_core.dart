import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_core/src/base/bloc_observer.dart';
import 'package:flutter_clean_core/src/config/core_config.dart';
import 'package:flutter_clean_core/src/di/injection.dart';

/// Main entry point for initializing the App Core package.
///
/// Call this in your app's `main()` before `runApp()`:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await CleanCore.init(
///     config: CoreConfig(
///       baseUrl: 'https://api.my-project.com',
///     ),
///   );
///
///   runApp(MyApp());
/// }
/// ```
class CleanCore {
  CleanCore._();

  static CoreConfig? _config;

  /// Current configuration. Throws if not initialized.
  static CoreConfig get config {
    assert(_config != null, 'CleanCore.init() has not been called.');
    return _config!;
  }

  /// Whether the core has been initialized.
  static bool get isInitialized => _config != null;

  /// Initialize the App Core package.
  ///
  /// Must be called before using any core functionality.
  /// - [config] — Application-specific configuration.
  /// - [useBlocObserver] — Whether to set the global BLoC observer.
  static Future<void> init({
    required CoreConfig config,
    bool useBlocObserver = true,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    _config = config;

    // Initialize core dependencies (GetIt)
    await configureCoreDepedencies(config);

    // Set global BLoC observer
    if (useBlocObserver) {
      Bloc.observer = AppBlocObserver();
    }
  }

  /// Reset the core (useful for testing).
  @visibleForTesting
  static void reset() {
    _config = null;
    resetCoreDependencies();
  }
}
