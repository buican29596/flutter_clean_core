import 'package:dartz/dartz.dart';
import 'package:flutter_clean_core/src/error/failures.dart';

/// Base class for all use cases in the application.
///
/// [Type] is the return type of the use case.
/// [Params] is the input parameter type.
///
/// Example:
/// ```dart
/// class GetUser extends UseCase<UserEntity, GetUserParams> {
///   @override
///   Future<Either<Failure, UserEntity>> call(GetUserParams params) async {
///     return repository.getUser(params.id);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this when the use case doesn't require any parameters.
///
/// Example:
/// ```dart
/// class GetCurrentUser extends UseCase<UserEntity, NoParams> {
///   @override
///   Future<Either<Failure, UserEntity>> call(NoParams params) async {
///     return repository.getCurrentUser();
///   }
/// }
/// ```
class NoParams {
  const NoParams();
}
