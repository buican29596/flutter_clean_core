import 'package:flutter/foundation.dart';

/// Premium structured logging utility.
///
/// Log prints are active ONLY during `kDebugMode` (development builds) and
/// are completely disabled in Release configurations to maintain runtime speed
/// and secure application outputs.
class AppLogger {
  const AppLogger._();

  static void _log(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) return;

    final output = '$tag $message';
    if (error != null) {
      // Print verbose errors and stacks
      debugPrint('$output\nDetail: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace:\n$stackTrace');
      }
    } else {
      debugPrint(output);
    }
  }

  /// Print a green diagnostic debug log.
  static void debug(String message) => _log('🟢 [DEBUG]', message);

  /// Print a blue informational log.
  static void info(String message) => _log('🔵 [INFO] ', message);

  /// Print a yellow warning log.
  static void warning(String message) => _log('🟡 [WARN] ', message);

  /// Print a red error log with optional stack traces.
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) =>
      _log('🔴 [ERROR]', message, error, stackTrace);
}
