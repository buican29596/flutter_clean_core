import 'package:flutter_clean_core/src/utils/logger.dart';

/// Abstract interface contract for recording app crashes and non-fatal exceptions.
abstract class AppCrashlytics {
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  });

  Future<void> log(String message);

  Future<void> setCustomKey(String key, Object value);

  Future<void> setUserId(String identifier);
}

/// Default crashlytics implementation.
///
/// Formats and logs non-fatal / fatal exceptions to [AppLogger] during local runs.
class DebugCrashlyticsService implements AppCrashlytics {
  const DebugCrashlyticsService();

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    AppLogger.error(
      '🚨 [Crashlytics Error] Fatal: $fatal | Reason: $reason',
      exception,
      stack,
    );
  }

  @override
  Future<void> log(String message) async {
    AppLogger.info('🚨 [Crashlytics Log] $message');
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    AppLogger.info('🚨 [Crashlytics Key] $key: $value');
  }

  @override
  Future<void> setUserId(String identifier) async {
    AppLogger.info('🚨 [Crashlytics User] ID: $identifier');
  }
}
