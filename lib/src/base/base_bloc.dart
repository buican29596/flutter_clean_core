import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_core/src/base/base_state.dart';
import 'package:flutter_clean_core/src/error/failures.dart';

/// Base BLoC class providing common patterns for all BLoCs.
///
/// Provides helper methods for:
/// - Executing use cases and emitting states
/// - Common error handling
///
/// Usage:
/// ```dart
/// class UserBloc extends BaseBloc<UserEvent, BaseState<UserEntity>> {
///   UserBloc(this._getUserUseCase) : super(const BaseState.initial());
///
///   final GetUserUseCase _getUserUseCase;
///
///   Future<void> _onFetchUser(
///     FetchUser event,
///     Emitter<BaseState<UserEntity>> emit,
///   ) async {
///     await executeUseCase(
///       emit: emit,
///       useCase: () => _getUserUseCase(NoParams()),
///     );
///   }
/// }
/// ```
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  BaseBloc(super.initialState);

  /// Execute a use case that returns `Either<Failure, T>` and
  /// automatically emits Loading → Success/Error states.
  ///
  /// Only works when [State] is [BaseState<T>].
  Future<void> executeUseCase<T>({
    required Emitter<BaseState<T>> emit,
    required Future<Either<Failure, T>> Function() useCase,
    String? loadingMessage,
    void Function(T data)? onSuccess,
    void Function(Failure failure)? onError,
  }) async {
    emit(BaseState<T>.loading(message: loadingMessage));

    final result = await useCase();

    result.fold(
      (failure) {
        onError?.call(failure);
        emit(BaseState<T>.error(failure));
      },
      (data) {
        onSuccess?.call(data);
        emit(BaseState<T>.success(data));
      },
    );
  }

  /// Execute a void use case (no return data).
  Future<void> executeVoidUseCase<T>({
    required Emitter<BaseState<T>> emit,
    required Future<Either<Failure, void>> Function() useCase,
    required T successData,
    String? loadingMessage,
  }) async {
    emit(BaseState<T>.loading(message: loadingMessage));

    final result = await useCase();

    result.fold(
      (failure) => emit(BaseState<T>.error(failure)),
      (_) => emit(BaseState<T>.success(successData)),
    );
  }
}
