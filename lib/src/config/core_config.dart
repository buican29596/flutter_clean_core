/// Configuration for the App Core package.
///
/// Each project provides its own config to customize the core behavior.
///
/// ```dart
/// final config = CoreConfig(
///   baseUrl: 'https://api.my-project.com',
///   appName: 'My App',
/// );
/// await CleanCore.init(config: config);
/// ```
class CoreConfig {
  const CoreConfig({
    required this.baseUrl,
    this.appName = 'App',
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableLogging = true,
    this.accessTokenKey = 'access_token',
    this.refreshTokenKey = 'refresh_token',
    this.refreshTokenEndpoint,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  });

  /// Base URL for the API (e.g., 'https://api.example.com').
  final String baseUrl;

  /// Application name.
  final String appName;

  /// Connection timeout.
  final Duration connectTimeout;

  /// Receive timeout.
  final Duration receiveTimeout;

  /// Send timeout.
  final Duration sendTimeout;

  /// Whether to enable Dio request/response logging.
  final bool enableLogging;

  /// Key used to store access token in secure storage.
  final String accessTokenKey;

  /// Key used to store refresh token in secure storage.
  final String refreshTokenKey;

  /// Endpoint for refreshing tokens (e.g., '/auth/refresh').
  /// If null, token refresh is disabled.
  final String? refreshTokenEndpoint;

  /// Default headers for all API requests.
  final Map<String, String> defaultHeaders;
}
