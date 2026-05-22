import 'package:equatable/equatable.dart';
import 'package:flutter_clean_core/src/error/failures.dart';

/// Generic BLoC states that can be reused across features.
///
/// Usage:
/// ```dart
/// class MyBloc extends Bloc<MyEvent, BaseState<MyData>> {
///   MyBloc() : super(const BaseState.initial()) {
///     on<FetchData>((event, emit) async {
///       emit(const BaseState.loading());
///       final result = await useCase(NoParams());
///       result.fold(
///         (failure) => emit(BaseState.error(failure)),
///         (data) => emit(BaseState.success(data)),
///       );
///     });
///   }
/// }
/// ```
sealed class BaseState<T> extends Equatable {
  const BaseState();

  /// Initial state before any action.
  const factory BaseState.initial() = BaseInitialState<T>;

  /// Loading state during async operations.
  const factory BaseState.loading({String? message}) = BaseLoadingState<T>;

  /// Success state with data.
  const factory BaseState.success(T data) = BaseSuccessState<T>;

  /// Error state with failure.
  const factory BaseState.error(Failure failure) = BaseErrorState<T>;

  @override
  List<Object?> get props => [];
}

/// Initial state.
class BaseInitialState<T> extends BaseState<T> {
  const BaseInitialState();
}

/// Loading state with optional message.
class BaseLoadingState<T> extends BaseState<T> {
  const BaseLoadingState({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Success state containing data of type [T].
class BaseSuccessState<T> extends BaseState<T> {
  const BaseSuccessState(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

/// Error state containing a [Failure].
class BaseErrorState<T> extends BaseState<T> {
  const BaseErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
