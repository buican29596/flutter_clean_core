/// Custom exception classes for the application.
///
/// These exceptions are thrown in the data layer and caught by
/// repository implementations to be converted into [Failure] objects.
library;

/// Exception thrown when a server request fails.
class ServerException implements Exception {
  const ServerException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

/// Exception thrown when a cache operation fails.
class CacheException implements Exception {
  const CacheException({required this.message});

  final String message;

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Exception thrown when there is no network connection.
class NetworkException implements Exception {
  const NetworkException({
    this.message = 'No internet connection',
  });

  final String message;

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// Exception thrown when authentication fails or token is invalid.
class UnauthorizedException implements Exception {
  const UnauthorizedException({
    this.message = 'Unauthorized access',
  });

  final String message;

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}
