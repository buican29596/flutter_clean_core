# flutter_clean_core

A reusable, enterprise-grade Core library for Flutter applications built on **Clean Architecture** and the **BLoC** state management pattern.

This package provides a standardized core infrastructure including configurable networking, automated dependency injection, secure/local storage helpers, generic BLoC states, responsive layout utilities, and a suite of highly-customized, animated, premium UI components.

---

## Key Features

- **Standardized Clean Architecture**:
  - `BaseBloc` & `BaseState<T>`: Reduce BLoC boilerplate (Loading, Success, and Error state flows).
  - `BaseRepository`: Automated `DioException` parser (translating timeouts, status codes, and server payloads) with offline-first local fallbacks.
  - `UseCase`: Clean contract for all domain use cases.
- **Configurable Network Layer**: Dio client with connectivity checks (`NetworkInfo`) and queued token refresh out of the box.
- **Dependency Injection**: Preconfigured automated manual GetIt DI avoiding build_runner conflicts with host applications.
- **Storage Helpers**:
  - `SecureStorageHelper`: Encrypted key-value storage wrapping `FlutterSecureStorage`.
  - `LocalStorageHelper`: SharedPreferences helper for general key-value configs.
- **Responsive Layout Extensions**: Breakpoint detectors (`isMobile`, `isTablet`, `isDesktop`) and fluid adaptivity hooks on `BuildContext`.
- **Advanced Diagnostics & Formats**:
  - `AppLogger`: Secure logging suppressed automatically in Release builds.
  - `AppInputFormatters`: Reusable formatters (Currency, Phone spacing, Credit Card groups).

---

## Installation

You can integrate the package into the `pubspec.yaml` of your project using either of the following methods:

### Option A: From GitHub Repository (Recommended for Team Distribution)
```yaml
dependencies:
  flutter_clean_core:
    git:
      url: https://github.com/buican29596/flutter_clean_core.git
      ref: main # Or use a specific tag/commit hash
```

### Option B: Local Path Reference (Recommended for Local Dev)
```yaml
dependencies:
  flutter_clean_core:
    path: path/to/flutter_clean_core
```

---

## 1. Initialization & DI Setup

In the host application's `main.dart`, initialize the Core package:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_clean_core/flutter_clean_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Core config
  final config = CoreConfig(
    baseUrl: 'https://api.example.com',
    appName: 'Enterprise App',
    enableLogging: true,
  );

  // Initialize all core dependencies (Dio, storage, connectivity, etc.)
  await configureCoreDepedencies(config);

  runApp(const MyApp());
}
```

Once initialized, all helpers and Cubits can be retrieved anywhere:
```dart
final secureStorage = getIt<SecureStorageHelper>();
final themeCubit = getIt<ThemeCubit>();
final authStatusCubit = getIt<AuthStatusCubit>();
```

---

## 2. Core Architecture Examples

### BaseRepository Auto-Mapping
Let network errors bubble up. `BaseRepository` automatically intercepts and maps them into failures:
```dart
class UserRepositoryImpl extends BaseRepository implements UserRepository {
  UserRepositoryImpl({required super.networkInfo, required this.remoteSource});

  final UserRemoteDataSource remoteSource;

  @override
  Future<Either<Failure, User>> getUserProfile() {
    // Automatically handles timeouts, 401 Unauthorized, and parses API JSON error messages
    return safeRemoteCall(() => remoteSource.fetchProfile());
  }
}
```

### BaseBloc Execution
```dart
class UserBloc extends BaseBloc<UserEvent, BaseState<User>> {
  UserBloc(this._getUserProfile) : super(const BaseState.initial());

  final GetUserProfile _getUserProfile;

  Future<void> _onFetch(FetchUser event, Emitter<BaseState<User>> emit) async {
    await executeUseCase(
      emit: emit,
      useCase: () => _getUserProfile(NoParams()),
    ); // Automatically emits Loading -> Success(User) or Error(Failure)
  }
}
```

---

## 3. Global Cubits

### Persisted Theme Management (`ThemeCubit`)
Wrap `MaterialApp` with `BlocBuilder` to handle Light/Dark mode changes saved automatically to local storage:
```dart
BlocBuilder<ThemeCubit, ThemeMode>(
  bloc: getIt<ThemeCubit>(),
  builder: (context, mode) {
    return MaterialApp(
      themeMode: mode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  },
);

// Toggle theme easily
getIt<ThemeCubit>().toggleTheme();
```

### User Authentication Sessions (`AuthStatusCubit`)
Observe credentials for router redirects:
```dart
BlocListener<AuthStatusCubit, AuthStatusState>(
  bloc: getIt<AuthStatusCubit>(),
  listener: (context, state) {
    if (state.status == AuthStatus.unauthenticated) {
      // Redirect to Login Screen
    } else if (state.status == AuthStatus.authenticated) {
      // Redirect to Home Screen
    }
  },
  child: const RootScreen(),
);
```

---

## 4. Premium UI Elements

### Connectivity Banner
Wrap any page's layout or the root layout to automatically monitor connection changes:
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ConnectivityBanner(
      child: MyPageBody(), // Displays beautiful red banner when offline and green when restored
    ),
  );
}
```

### Custom AppBar (`AppAppBar`)
Premium modern design with circular iOS-style back indicator button:
```dart
Scaffold(
  appBar: const AppAppBar(
    title: 'Product Details',
    showBackButton: true, // Auto-hidden if no navigation stack exists
  ),
  body: Container(),
);
```

### Custom Interactive Button (`AppButton`)
Tactile scale-down animation on tap (0.96 scale) with beautiful drop-shadows:
```dart
AppButton(
  text: 'Proceed to Payment',
  onPressed: () => print('Tapped'),
  isLoading: false, // Set true to render AppLoading spinner dynamically
)
```

### Custom Animated Glow Input (`AppTextField`)
Soft glowing outer borders (primary color on focus, error color on validator failures):
```dart
AppTextField(
  labelText: 'Email Address',
  hintText: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
  validator: (val) => val == null || !val.contains('@') ? 'Invalid email' : null,
)
```

### Dialog Helpers (`AppDialogs`)
Bounce scale-up dialog overlays (`Curves.easeOutBack` transition):
```dart
// Success status popup
AppDialogs.showSuccess(
  context: context,
  title: 'Success',
  message: 'Payment completed successfully!',
);

// Double-action confirmation dialog
AppDialogs.showConfirm(
  context: context,
  title: 'Delete Account?',
  message: 'This action is irreversible.',
  confirmText: 'Delete',
  onConfirm: () => print('Deleted'),
);
```

### Bottom Sheet Helper (`AppBottomSheet`)
Drag handles, close buttons, and automated keyboard viewport adjustments:
```dart
AppBottomSheet.show(
  context: context,
  title: 'Choose Language',
  child: LanguageSelectorWidget(), // TextFields inside will automatically shift above keyboard
);
```

### Shimmer Skeleton (`AppShimmer`)
Acts either as a standalone rectangle block or as a shader mask covering a complex widget skeleton:
```dart
// Block placeholder
const AppShimmer(width: 100, height: 20);

// Shimmer mask over complex widget
AppShimmer(
  child: MyCustomListTileSkeleton(), // Colors will animate synchronously
);
```

---

## 5. Helpers & Extensions

### Responsive Adaptivity
```dart
@override
Widget build(BuildContext context) {
  final padding = context.responsive<double>(
    mobile: 16.0,
    tablet: 24.0,
    desktop: 32.0,
  );
  
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Text(context.isMobile ? 'Mobile Layout' : 'Large Screen Layout'),
  );
}
```

### Input Formatters
Format user input dynamically in text fields:
```dart
AppTextField(
  labelText: 'Amount',
  inputFormatters: [AppInputFormatters.currency()], // e.g. Formats to 1.500.000 as you type
);
```

### Debug Logger
Unified logger silenced completely in Release mode to avoid speed degradation:
```dart
AppLogger.info('App started successfully');
AppLogger.error('API call failed', error, stackTrace);
```

---

## 6. Decoupled Analytics & Crashlytics (Metrics)

To keep the Core package free of native Firebase configuration dependencies, we define decoupled `AppAnalytics` and `AppCrashlytics` interfaces in Core.

By default, Core registers `DebugAnalyticsService` and `DebugCrashlyticsService` which print logs with emojis (📊, 🚨) to console in development.

### How to configure Firebase in the Host App

1. Add your Firebase dependencies to the host app's `pubspec.yaml`.
2. Create implementations of the Core interfaces in the host app:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_clean_core/flutter_clean_core.dart';

class FirebaseAnalyticsService implements AppAnalytics {
  FirebaseAnalyticsService(this._analytics);
  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> logScreenView({required String screenName, String? screenClass}) async {
    await _analytics.logScreenView(screenName: screenName, screenClass: screenClass);
  }

  @override
  Future<void> setUserProperty({required String name, required String value}) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> resetAnalyticsData() async {
    await _analytics.resetAnalyticsData();
  }
}
```

3. Register your Firebase implementation in the host app's injection configuration, overwriting the default core service:

```dart
void configureAppDependencies() {
  // Overwrite the core lazy singleton with your Firebase implementation
  getIt.registerLazySingleton<AppAnalytics>(
    () => FirebaseAnalyticsService(FirebaseAnalytics.instance),
  );
}
```

