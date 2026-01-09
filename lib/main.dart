import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/services/auth_service.dart';
import 'package:useme/core/services/notification_service.dart';
import 'package:useme/core/services/notification_navigation_service.dart';
import 'package:useme/core/services/deep_link_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/router.dart';

/// Global navigator key for notification navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Service d'authentification global.
final useMeAuthService = UseMeAuthService();

/// Service de préférences global.
final preferencesService = BasePreferencesService();

/// Service de notifications global.
final notificationService = UseMeNotificationService.instance;

/// Service de deep links global.
final deepLinkService = DeepLinkService();

/// CalendarBloc global (needed for deep link callbacks).
late CalendarBloc globalCalendarBloc;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (optional - for dev only)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env file not found in production - this is expected
  }

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SmoothFirebase with default app
  SmoothFirebase.initializeWithDefault();

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Allow all orientations for tablet/desktop support
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize CalendarBloc globally
  globalCalendarBloc = CalendarBloc();

  runApp(const UseMeApp());

  // Initialize notification listeners after app is running (non-blocking)
  _initializeNotificationListeners();

  // Initialize deep link service
  _initializeDeepLinks();
}

/// Initialize deep link handling
Future<void> _initializeDeepLinks() async {
  try {
    // Set callback for calendar OAuth result
    deepLinkService.onCalendarCallback = (success, error) {
      debugPrint('Calendar OAuth callback: success=$success, error=$error');

      if (success) {
        // Get current user ID and reload calendar status
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          try {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticatedState) {
              globalCalendarBloc.add(
                LoadCalendarStatusEvent(userId: authState.user.uid),
              );
            }
          } catch (e) {
            debugPrint('Error reloading calendar status: $e');
          }
        }
      }
    };

    await deepLinkService.initialize();
  } catch (e) {
    debugPrint('Deep link init error: $e');
  }
}

/// Initialize notification listeners - non-blocking
Future<void> _initializeNotificationListeners() async {
  try {
    final navService = NotificationNavigationService();

    await notificationService.initialize(
      onNotificationTap: (message) {
        navService.handleNotificationTap(message);
      },
      onForegroundMessage: (message) {
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          InAppNotificationBanner.show(
            context,
            message,
            onTap: () => navService.handleNotificationTap(message),
          );
        }
      },
    );
  } catch (e) {
    debugPrint('Notification init error: $e');
  }
}

class UseMeApp extends StatefulWidget {
  const UseMeApp({super.key});

  @override
  State<UseMeApp> createState() => _UseMeAppState();
}

class _UseMeAppState extends State<UseMeApp> {
  late final _router = AppRouter.getRouter(navigatorKey: rootNavigatorKey);

  @override
  void initState() {
    super.initState();
    // Set router for notification navigation
    NotificationNavigationService().setRouter(_router);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme BLoC from package
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(preferencesService: preferencesService)
            ..add(const LoadThemeEvent()),
        ),
        // Locale BLoC
        BlocProvider<LocaleBloc>(
          create: (_) => LocaleBloc()..add(const LoadLocaleEvent()),
        ),
        // Auth BLoC from package with Use Me service
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authService: useMeAuthService)
            ..add(const CheckAuthEvent()),
        ),
        // Use Me specific BLoCs
        BlocProvider<SessionBloc>(create: (_) => SessionBloc()),
        BlocProvider<ArtistBloc>(create: (_) => ArtistBloc()),
        BlocProvider<ServiceBloc>(create: (_) => ServiceBloc()),
        BlocProvider<StudioRoomBloc>(create: (_) => StudioRoomBloc()),
        BlocProvider<BookingBloc>(create: (_) => BookingBloc()),
        BlocProvider<MessagingBloc>(create: (_) => MessagingBloc()),
        BlocProvider<FavoriteBloc>(create: (_) => FavoriteBloc()),
        BlocProvider<CalendarBloc>.value(value: globalCalendarBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              return BlocListener<AuthBloc, AuthState>(
                listenWhen: (prev, curr) {
                  // Detect auth state changes for notification token management
                  final wasAuth = prev is AuthAuthenticatedState;
                  final isAuth = curr is AuthAuthenticatedState;
                  return wasAuth != isAuth;
                },
                listener: (context, state) {
                  if (state is AuthAuthenticatedState) {
                    // User logged in: set userId for notification token
                    notificationService.setUserId(state.user.uid);
                  } else {
                    // User logged out: remove token
                    notificationService.removeToken();
                  }
                },
                child: MaterialApp.router(
                  title: 'Use Me',
                  debugShowCheckedModeBanner: false,
                  theme: UseMeTheme.lightTheme,
                  darkTheme: UseMeTheme.darkTheme,
                  themeMode: themeState.themeMode,
                  locale: localeState.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routerConfig: _router,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
