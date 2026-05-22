import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_clean_core/src/error/exceptions.dart';
import 'package:flutter_clean_core/src/error/failures.dart';
import 'package:flutter_clean_core/src/network/network_info.dart';

/// Base repository class providing common patterns.
///
/// Provides helper methods for:
/// - Network check before remote calls
/// - Exception → Failure mapping
/// - Remote-first with local fallback pattern
///
/// Usage:
/// ```dart
/// class UserRepositoryImpl extends BaseRepository implements UserRepository {
///   UserRepositoryImpl({
///     required this.remoteDataSource,
///     required this.localDataSource,
///     required super.networkInfo,
///   });
///
///   @override
///   Future<Either<Failure, UserEntity>> getUser(String id) {
///     return safeRemoteCall(
///       () => remoteDataSource.getUser(id),
///     );
///   }
/// }
/// ```
abstract class BaseRepository {
  const BaseRepository({required this.networkInfo});

  final NetworkInfo networkInfo;

  /// Execute a remote call with automatic error handling.
  ///
  /// Checks network connectivity first, then executes the call
  /// and maps exceptions to failures.
  Future<Either<Failure, T>> safeRemoteCall<T>(
    Future<T> Function() call,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await call();
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioExceptionToFailure(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  /// Execute a remote call with local cache fallback.
  ///
  /// 1. If online → fetch remote, cache result, return
  /// 2. If offline → return cached data
  /// 3. If remote fails → try cache
  Future<Either<Failure, T>> remoteWithLocalFallback<T>({
    required Future<T> Function() remoteCall,
    required Future<T> Function() localCall,
    required Future<void> Function(T data) cacheCall,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteCall();
        await cacheCall(remoteData);
        return Right(remoteData);
      } on DioException catch (e) {
        // Try cache on network error
        try {
          final cachedData = await localCall();
          return Right(cachedData);
        } catch (_) {
          return Left(_mapDioExceptionToFailure(e));
        }
      } on ServerException catch (e) {
        // Try cache on server error
        try {
          final cachedData = await localCall();
          return Right(cachedData);
        } catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        return Left(UnexpectedFailure(message: e.toString()));
      }
    } else {
      try {
        final cachedData = await localCall();
        return Right(cachedData);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return const Left(NetworkFailure());
      }
    }
  }

  Failure _mapDioExceptionToFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerFailure(
          message: 'Connection timeout. Please try again later.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String? serverMessage;
        if (data is Map<String, dynamic>) {
          serverMessage = data['message'] as String? ?? data['error'] as String?;
        }

        if (statusCode == 401 || statusCode == 403) {
          return UnauthorizedFailure(
            message: serverMessage ?? 'Session expired. Please login again.',
          );
        }
        return ServerFailure(
          message: serverMessage ??
              'Server error occurred (${statusCode ?? 'unknown'}).',
        );
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.cancel:
        return const UnexpectedFailure(message: 'Request was cancelled.');
      default:
        return UnexpectedFailure(message: e.message ?? 'Unknown network error.');
    }
  }

  /// Execute a local-only call with error handling.
  Future<Either<Failure, T>> safeLocalCall<T>(
    Future<T> Function() call,
  ) async {
    try {
      final result = await call();
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
