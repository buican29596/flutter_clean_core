import 'package:equatable/equatable.dart';

/// Base failure class using sealed class for exhaustive pattern matching.
///
/// Failures are returned via `Either<Failure, T>` from repositories
/// to represent expected error states in a type-safe way.
sealed class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Failure resulting from server/API errors.
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Failure resulting from local cache errors.
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Failure resulting from no network connection.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Failure resulting from authentication issues.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Session expired. Please login again.',
  });
}

/// Failure for unexpected/unknown errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}
