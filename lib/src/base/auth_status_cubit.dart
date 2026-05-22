import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_core/src/config/core_config.dart';
import 'package:flutter_clean_core/src/storage/secure_storage_helper.dart';

/// Enum representing session authenticity status.
enum AuthStatus {
  /// Session status is still checking/resolving.
  unknown,

  /// Session has a valid verified token.
  authenticated,

  /// Session does not have a token.
  unauthenticated,
}

/// State object representing current session authentication state.
class AuthStatusState {
  const AuthStatusState({required this.status, this.accessToken});

  final AuthStatus status;
  final String? accessToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStatusState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          accessToken == other.accessToken;

  @override
  int get hashCode => status.hashCode ^ accessToken.hashCode;
}

/// Global cubit tracking session credentials and routing auth status.
class AuthStatusCubit extends Cubit<AuthStatusState> {
  AuthStatusCubit({
    required SecureStorageHelper secureStorageHelper,
    required CoreConfig config,
  })  : _secureStorage = secureStorageHelper,
        _config = config,
        super(const AuthStatusState(status: AuthStatus.unknown)) {
    checkAuth();
  }

  final SecureStorageHelper _secureStorage;
  final CoreConfig _config;

  /// Check storage for existence of access token and emit status.
  Future<void> checkAuth() async {
    try {
      final token = await _secureStorage.read(key: _config.accessTokenKey);
      if (token != null && token.isNotEmpty) {
        emit(AuthStatusState(
          status: AuthStatus.authenticated,
          accessToken: token,
        ));
      } else {
        emit(const AuthStatusState(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(const AuthStatusState(status: AuthStatus.unauthenticated));
    }
  }

  /// Store tokens and transition status to authenticated.
  Future<void> login(String token, {String? refreshToken}) async {
    await _secureStorage.write(key: _config.accessTokenKey, value: token);
    if (refreshToken != null) {
      await _secureStorage.write(
        key: _config.refreshTokenKey,
        value: refreshToken,
      );
    }
    emit(AuthStatusState(status: AuthStatus.authenticated, accessToken: token));
  }

  /// Wipe credentials from storage and transit status to unauthenticated.
  Future<void> logout() async {
    await _secureStorage.delete(key: _config.accessTokenKey);
    await _secureStorage.delete(key: _config.refreshTokenKey);
    emit(const AuthStatusState(status: AuthStatus.unauthenticated));
  }
}
