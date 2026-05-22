import 'package:flutter_clean_core/src/utils/logger.dart';

/// Abstract interface contract for logging analytics events,
/// user properties, and screen views.
abstract class AppAnalytics {
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  });

  Future<void> setUserProperty({
    required String name,
    required String value,
  });

  Future<void> resetAnalyticsData();
}

/// Default analytics implementation.
///
/// Formats and logs events to [AppLogger] during local development runs.
class DebugAnalyticsService implements AppAnalytics {
  const DebugAnalyticsService();

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    AppLogger.info('📊 [Analytics Event] Name: $name | Params: $parameters');
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    AppLogger.info(
      '📊 [Analytics Screen] Screen: $screenName | Class: $screenClass',
    );
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    AppLogger.info('📊 [Analytics UserProperty] $name: $value');
  }

  @override
  Future<void> resetAnalyticsData() async {
    AppLogger.info('📊 [Analytics Reset] Cleared analytics data');
  }
}
