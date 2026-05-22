import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:flutter_clean_core/src/config/core_config.dart';

/// Interceptor that handles:
/// - Adding auth token to requests
/// - Token refresh on 401
class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor({
    required FlutterSecureStorage secureStorage,
    required Dio dio,
    required CoreConfig config,
  })  : _secureStorage = secureStorage,
        _dio = dio,
        _config = config;

  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  final CoreConfig _config;
  final _logger = Logger();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(
      key: _config.accessTokenKey,
    );

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        _config.refreshTokenEndpoint != null) {
      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          // Retry the failed request with the new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

          final response = await _dio.fetch<dynamic>(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        _logger.e('Token refresh failed', error: e);
      }
    }

    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(
        key: _config.refreshTokenKey,
      );

      if (refreshToken == null) return null;

      final response = await Dio().post<Map<String, dynamic>>(
        '${_config.baseUrl}${_config.refreshTokenEndpoint}',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data?['access_token'] as String?;
      final newRefreshToken = response.data?['refresh_token'] as String?;

      if (newAccessToken != null) {
        await _secureStorage.write(
          key: _config.accessTokenKey,
          value: newAccessToken,
        );
      }

      if (newRefreshToken != null) {
        await _secureStorage.write(
          key: _config.refreshTokenKey,
          value: newRefreshToken,
        );
      }

      return newAccessToken;
    } catch (e) {
      _logger.e('Refresh token request failed', error: e);
      // Clear tokens on refresh failure
      await _secureStorage.delete(key: _config.accessTokenKey);
      await _secureStorage.delete(key: _config.refreshTokenKey);
      return null;
    }
  }
}
