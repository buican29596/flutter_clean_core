import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_clean_core/src/analytics/app_analytics.dart';
import 'package:flutter_clean_core/src/analytics/app_crashlytics.dart';
import 'package:flutter_clean_core/src/base/auth_status_cubit.dart';
import 'package:flutter_clean_core/src/config/core_config.dart';
import 'package:flutter_clean_core/src/network/api_interceptor.dart';
import 'package:flutter_clean_core/src/network/network_info.dart';
import 'package:flutter_clean_core/src/storage/local_storage_helper.dart';
import 'package:flutter_clean_core/src/storage/secure_storage_helper.dart';
import 'package:flutter_clean_core/src/theme/theme_cubit.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global GetIt instance.
final getIt = GetIt.instance;

/// Initialize core package dependencies manually.
///
/// Avoids using build_runner code generation for DI in the library to prevent
/// conflicts with the host application's generated code.
Future<void> configureCoreDepedencies(CoreConfig config) async {
  // Register configuration
  getIt.registerSingleton<CoreConfig>(config);

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // FlutterSecureStorage
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Storage Helpers
  getIt.registerLazySingleton<SecureStorageHelper>(
    () => SecureStorageHelper(secureStorage: getIt()),
  );
  getIt.registerLazySingleton<LocalStorageHelper>(
    () => LocalStorageHelper(sharedPreferences: getIt()),
  );

  // Connectivity & Network Info
  getIt.registerSingleton<Connectivity>(Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt()),
  );

  // Dio client configuration
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: config.defaultHeaders,
    ),
  );

  // Interceptors
  dio.interceptors.add(
    AuthInterceptor(
      secureStorage: getIt(),
      dio: dio,
      config: config,
    ),
  );

  if (config.enableLogging) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ),
    );
  }

  getIt.registerSingleton<Dio>(dio);

  // Register Core Cubits
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(localStorageHelper: getIt()),
  );
  getIt.registerLazySingleton<AuthStatusCubit>(
    () => AuthStatusCubit(
      secureStorageHelper: getIt(),
      config: getIt(),
    ),
  );

  // Register Metrics / Analytics Abstractions
  getIt.registerLazySingleton<AppAnalytics>(
    () => const DebugAnalyticsService(),
  );
  getIt.registerLazySingleton<AppCrashlytics>(
    () => const DebugCrashlyticsService(),
  );
}

/// Reset dependencies (useful for testing/hot-reload).
void resetCoreDependencies() {
  getIt.reset();
}
