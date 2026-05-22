import 'dart:async';
import 'package:dartz/dartz.dart' hide State;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_core/flutter_clean_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core package
  await CleanCore.init(
    config: const CoreConfig(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      appName: 'Clean Core Demo App',
      enableLogging: true,
    ),
  );

  runApp(const DemoApp());
}

// ═════════════════════════════════════════════════════════════════
// 0. GOROUTER CONFIGURATION & REFRESH STREAM ADAPTER
// ═════════════════════════════════════════════════════════════════

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(getIt<AuthStatusCubit>().stream),
  redirect: (context, state) {
    final authState = getIt<AuthStatusCubit>().state;
    final isLoggedIn = authState.status == AuthStatus.authenticated;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn) {
      return '/login';
    }

    if (isLoggedIn && isLoggingIn) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginSandboxScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainSandboxScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) {
        final item = state.extra as DemoItem;
        return DetailSandboxScreen(item: item);
      },
    ),
    GoRoute(
      path: '/webview',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>;
        return AppWebView(
          url: extra['url']!,
          title: extra['title']!,
        );
      },
    ),
  ],
);

// ═════════════════════════════════════════════════════════════════
// 1. DATA LAYER (MOCK MODEL, DATASOURCE, REPOSITORY)
// ═════════════════════════════════════════════════════════════════

class DemoItem extends Equatable {
  const DemoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  @override
  List<Object?> get props => [id, title, description, price, imageUrl];
}

class DemoRemoteDataSource {
  const DemoRemoteDataSource();

  /// Mock remote paginated endpoint
  Future<List<DemoItem>> fetchItems({
    required int page,
    required int limit,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    // Simulate network error on page 4 to demo mapping
    if (page == 4) {
      throw Exception('Simulated API Server failure.');
    }

    return List.generate(
      limit,
      (index) {
        final itemIndex = ((page - 1) * limit) + index + 1;
        return DemoItem(
          id: '$itemIndex',
          title: 'Premium Product #$itemIndex',
          description:
              'This is a description for product #$itemIndex loaded dynamically.',
          price: (itemIndex * 150000).toDouble(),
          imageUrl: 'https://picsum.photos/200/300?random=$itemIndex',
        );
      },
    );
  }
}

class DemoRepository extends BaseRepository {
  DemoRepository({
    required super.networkInfo,
    required DemoRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final DemoRemoteDataSource _remoteDataSource;

  Future<Either<Failure, List<DemoItem>>> getItems({
    required int page,
    required int limit,
  }) {
    return safeRemoteCall(() => _remoteDataSource.fetchItems(
          page: page,
          limit: limit,
        ));
  }
}

// ═════════════════════════════════════════════════════════════════
// 2. PRESENTATION LAYER (BLOC)
// ═════════════════════════════════════════════════════════════════

class FetchItemsEvent extends Equatable {
  const FetchItemsEvent({this.isRefresh = false});
  final bool isRefresh;

  @override
  List<Object?> get props => [isRefresh];
}

class DemoItemsBloc extends BaseBloc<FetchItemsEvent, BaseState<List<DemoItem>>> {
  DemoItemsBloc({required DemoRepository repository})
      : _repository = repository,
        super(const BaseState.initial()) {
    on<FetchItemsEvent>(_onFetchItems);
  }

  final DemoRepository _repository;
  final List<DemoItem> _cachedItems = [];
  int _currentPage = 1;
  static const _limit = 10;
  bool _hasReachedMax = false;

  bool get hasReachedMax => _hasReachedMax;

  Future<void> _onFetchItems(
    FetchItemsEvent event,
    Emitter<BaseState<List<DemoItem>>> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 1;
      _cachedItems.clear();
      _hasReachedMax = false;
    }

    if (_hasReachedMax) return;

    // Show initial loading only if empty cache
    final isInitialLoad = _cachedItems.isEmpty;

    if (isInitialLoad) {
      emit(const BaseState.loading());
    }

    final result = await _repository.getItems(
      page: _currentPage,
      limit: _limit,
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to load items', failure);
        getIt<AppCrashlytics>().recordError(
          failure,
          StackTrace.current,
          reason: 'Failed API fetch in DemoItemsBloc',
        );
        emit(BaseState.error(failure));
      },
      (newItems) {
        _currentPage++;
        if (newItems.length < _limit) {
          _hasReachedMax = true;
        }
        _cachedItems.addAll(newItems);
        
        getIt<AppAnalytics>().logEvent(
          name: 'items_loaded',
          parameters: {'count': _cachedItems.length, 'page': _currentPage - 1},
        );
        
        emit(BaseState.success(List.from(_cachedItems)));
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// 3. APPLICATION CONTAINER & BOOTSTRAP
// ═════════════════════════════════════════════════════════════════

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          bloc: getIt<ThemeCubit>(),
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'Clean Core Demo',
              themeMode: themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              debugShowCheckedModeBanner: false,
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// 4. PRESENTATION LAYER (SCREENS)
// ═════════════════════════════════════════════════════════════════

/// Secure Login Screen demoing AppTextField, InputFormatters, and AppButton
class LoginSandboxScreen extends StatefulWidget {
  const LoginSandboxScreen({super.key});

  @override
  State<LoginSandboxScreen> createState() => _LoginSandboxScreenState();
}

class _LoginSandboxScreenState extends State<LoginSandboxScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // Perform session login
      await getIt<AuthStatusCubit>().login(
        'mock_jwt_access_token_12345',
        refreshToken: 'mock_jwt_refresh_token_67890',
      );
      
      if (mounted) {
        context.showSuccessSnackBar('Mock Session Authenticated!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Portal Authentication', showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(
                  Icons.lock_person_rounded,
                  size: 80.r,
                  color: context.theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Clean Core Sandbox',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to explore the integrated sandbox environment.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.hintColor,
                  ),
                ),
                const SizedBox(height: 40),
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '090 123 4567',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_iphone_rounded,
                  inputFormatters: [AppInputFormatters.phoneNumber()],
                  validator: (value) {
                    if (value == null || value.replaceAll(' ', '').length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Authenticate Session',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Main Application Sandbox displaying premium widgets and dynamic interactions
class MainSandboxScreen extends StatefulWidget {
  const MainSandboxScreen({super.key});

  @override
  State<MainSandboxScreen> createState() => _MainSandboxScreenState();
}

class _MainSandboxScreenState extends State<MainSandboxScreen> {
  late final DemoItemsBloc _itemsBloc;

  @override
  void initState() {
    super.initState();
    // Instantiate repository and bloc
    final repository = DemoRepository(
      networkInfo: getIt<NetworkInfo>(),
      remoteDataSource: const DemoRemoteDataSource(),
    );
    _itemsBloc = DemoItemsBloc(repository: repository)
      ..add(const FetchItemsEvent());
  }

  @override
  void dispose() {
    _itemsBloc.close();
    super.dispose();
  }

  void _triggerBottomSheet() {
    AppBottomSheet.show(
      context: context,
      title: 'Dynamic Input Form',
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: _BottomSheetForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityBanner(
      child: Scaffold(
        appBar: AppAppBar(
          title: 'Clean Core Sandbox',
          showBackButton: false,
          actions: [
            IconButton(
              icon: Icon(
                context.isDarkMode
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
              ),
              onPressed: () => getIt<ThemeCubit>().toggleTheme(),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => AppDialogs.showConfirm(
                context: context,
                title: 'Logout?',
                message: 'Do you want to terminate your current session?',
                onConfirm: () => getIt<AuthStatusCubit>().logout(),
              ),
            ),
          ],
        ),
        body: BlocBuilder<DemoItemsBloc, BaseState<List<DemoItem>>>(
          bloc: _itemsBloc,
          builder: (context, state) {
            return switch (state) {
              BaseInitialState() => const SizedBox.shrink(),
              BaseLoadingState() => const Center(child: AppLoading(size: 50)),
              BaseErrorState(failure: final failure) => Center(
                  child: AppErrorWidget(
                    message: failure.message,
                    onRetry: () => _itemsBloc.add(
                      const FetchItemsEvent(isRefresh: true),
                    ),
                  ),
                ),
              BaseSuccessState(data: final items) => () {
                  if (items.isEmpty) {
                    return const Center(
                      child: AppEmptyWidget(
                        message: 'No items currently exist.',
                      ),
                    );
                  }
                  return AppRefreshListView<DemoItem>(
                    items: items,
                    onRefresh: () async {
                      _itemsBloc.add(const FetchItemsEvent(isRefresh: true));
                    },
                    onLoadMore: _itemsBloc.hasReachedMax
                        ? null
                        : () async {
                            _itemsBloc.add(const FetchItemsEvent());
                          },
                    itemBuilder: (context, index, item) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          onTap: () => context.go('/details', extra: item),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: AppImage(
                              imageUrl: item.imageUrl,
                              width: 60.r,
                              height: 60.r,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            Helpers.formatCurrency(item.price),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        ),
                      );
                    },
                  );
                }(),
            };
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _triggerBottomSheet,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}

class _BottomSheetForm extends StatefulWidget {
  const _BottomSheetForm();

  @override
  State<_BottomSheetForm> createState() => _BottomSheetFormState();
}

class _BottomSheetFormState extends State<_BottomSheetForm> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _amountController,
          label: 'Deposit Amount (VND)',
          hint: '1.000.000',
          keyboardType: TextInputType.number,
          inputFormatters: [AppInputFormatters.currency()],
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Confirm Deposit',
          onPressed: () {
            final val = _amountController.text;
            Navigator.of(context).pop();
            AppDialogs.showSuccess(
              context: context,
              title: 'Transaction Logged',
              message: 'Logged transaction amount: $val VND.',
            );
          },
        ),
      ],
    );
  }
}

/// Detail Screen illustrating Responsive Grid Breakpoints & AppWebView integrations
class DetailSandboxScreen extends StatelessWidget {
  const DetailSandboxScreen({required this.item, super.key});

  final DemoItem item;

  void _openProductWebView(BuildContext context) {
    context.push(
      '/webview',
      extra: {
        'url': 'https://flutter.dev',
        'title': item.title,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic columns count computed via responsive extensions
    final gridColumns = context.responsive<int>(
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    return Scaffold(
      appBar: const AppAppBar(
        title: 'Detail Sandbox',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: AppImage(
                imageUrl: item.imageUrl,
                width: double.infinity,
                height: 240.h,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              item.title,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Helpers.formatCurrency(item.price),
              style: context.textTheme.titleLarge?.copyWith(
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.description,
              style: context.textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Display Responsive Layout Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: context.theme.dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Responsive Breakpoint Info',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Grid columns for device size: $gridColumns'),
                  Text(
                    'Device Profile: '
                    '${context.isMobile ? "Mobile" : context.isTablet ? "Tablet" : "Desktop"}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'View Official Documentation (WebView)',
              onPressed: () => _openProductWebView(context),
            ),
          ],
        ),
      ),
    );
  }
}
