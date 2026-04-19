import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:useme/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/localization/sango_material_localizations.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/auth_service.dart';
import 'package:useme/core/services/deep_link_service.dart';
import 'package:useme/core/services/notification_navigation_service.dart';
import 'package:useme/core/services/notification_service.dart';
import 'package:useme/core/services/recent_accounts_service.dart';
import 'package:useme/core/utils/app_logger.dart';
import 'package:useme/core/utils/crashlytics_bloc_observer.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/router.dart';

/// Global navigator key for notification navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Service d'authentification global.
final useMeAuthService = UseMeAuthService();

/// Service de préférences global.
final preferencesService = BasePreferencesService();

/// Service de comptes récents global.
final recentAccountsService = RecentAccountsService();

/// Service de notifications global.
final notificationService = UseMeNotificationService.instance;

/// Service de deep links global.
final deepLinkService = DeepLinkService();

/// Service de sessions d'appareils global.
final deviceSessionService = BaseDeviceSessionService();

/// CalendarBloc global (needed for deep link callbacks).
late CalendarBloc globalCalendarBloc;

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Load environment variables (optional - for dev only)
      try {
        await dotenv.load(fileName: 'assets/.env');
      } catch (_) {
        // .env file not found in production - this is expected
      }

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize SmoothFirebase with default app
      SmoothFirebase.initializeWithDefault();

      // Crashlytics — capture Flutter framework errors
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      // BLoC observer — breadcrumbs + erreurs BLoC vers Crashlytics
      Bloc.observer = CrashlyticsBlocObserver();

      // Crashlytics — capture async errors outside Flutter (Platform, isolates)
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Initialize French locale for date formatting
      await initializeDateFormatting('fr_FR', null);

      // Allow all orientations for tablet/desktop support
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      // Load recent accounts
      await recentAccountsService.load();

      // Initialize CalendarBloc globally
      globalCalendarBloc = CalendarBloc();

      runApp(const UseMeApp());

      // Initialize notification listeners after app is running (non-blocking)
      _initializeNotificationListeners();

      // Initialize deep link service
      _initializeDeepLinks();
    },
    (error, stack) =>
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
  );
}

/// Create device session for the authenticated user.
Future<void> _createDeviceSession(String userId) async {
  try {
    // Get FCM token for push notifications
    final fcmToken = notificationService.fcmToken;

    // Create or update the device session
    final session = await deviceSessionService.createSession(
      userId: userId,
      fcmToken: fcmToken,
      appVersion: '1.0.0',
    );
    appLog('Device session created for user: $userId');

    // Start listening for session revocation
    _startSessionRevocationListener(session.id);
  } catch (e) {
    appLog('Failed to create device session: $e');
  }
}

/// Subscription for session revocation listener.
StreamSubscription<bool>? _sessionRevocationSubscription;

/// Start listening for session revocation (remote logout).
void _startSessionRevocationListener(String sessionId) {
  _sessionRevocationSubscription?.cancel();
  _sessionRevocationSubscription = deviceSessionService.watchSessionRevoked(sessionId).listen(
    (isRevoked) {
      if (isRevoked) {
        appLog('Session revoked remotely, forcing logout...');
        _handleRemoteLogout();
      }
    },
    onError: (e) => appLog('Session revocation listener error: $e'),
  );
}

/// Handle remote logout when session is revoked.
void _handleRemoteLogout() {
  _sessionRevocationSubscription?.cancel();
  _sessionRevocationSubscription = null;

  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    // Show message to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vous avez été déconnecté depuis un autre appareil'),
        duration: Duration(seconds: 4),
      ),
    );

    // Trigger logout
    context.read<AuthBloc>().add(const SignOutEvent());
  }
}

/// Initialize deep link handling
Future<void> _initializeDeepLinks() async {
  try {
    // Set callback for calendar OAuth result
    deepLinkService.onCalendarCallback = (success, error) {
      appLog('Calendar OAuth callback: success=$success, error=$error');

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
            appLog('Error reloading calendar status: $e');
          }
        }
      }
    };

    await deepLinkService.initialize();
  } catch (e) {
    appLog('Deep link init error: $e');
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
    appLog('Notification init error: $e');
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
        BlocProvider<ProProfileBloc>(create: (_) => ProProfileBloc()),
        BlocProvider<NetworkBloc>(create: (_) => NetworkBloc()),
        BlocProvider<CardConfigBloc>(create: (_) => CardConfigBloc()),
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
                listener: (context, state) async {
                  if (state is AuthAuthenticatedState) {
                    final user = state.user;

                    // Crashlytics — identify user for crash reports
                    FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
                    FirebaseCrashlytics.instance.setCustomKey('role', user.role.name);
                    FirebaseCrashlytics.instance.log('User authenticated: ${user.uid} (${user.role.name})');

                    // User logged in: set userId for notification token
                    notificationService.setUserId(user.uid);

                    // Create device session
                    _createDeviceSession(user.uid);

                    // Load calendar status for studios
                    if (user.role.isStudio || user.role.isSuperAdmin) {
                      globalCalendarBloc.add(
                        LoadCalendarStatusEvent(userId: user.uid),
                      );
                    }
                  } else {
                    // Crashlytics — clear user identity on logout
                    FirebaseCrashlytics.instance.setUserIdentifier('');
                    FirebaseCrashlytics.instance.log('User signed out');

                    // User logged out: remove token, reset calendar
                    notificationService.removeToken();
                    globalCalendarBloc.add(const ResetCalendarEvent());

                    // Cancel session revocation listener and clear local session
                    _sessionRevocationSubscription?.cancel();
                    _sessionRevocationSubscription = null;
                    deviceSessionService.clearLocalSession();
                  }
                },
                child: MaterialApp.router(
                  title: 'UZME',
                  debugShowCheckedModeBanner: false,
                  theme: UseMeTheme.lightTheme,
                  darkTheme: UseMeTheme.darkTheme,
                  themeMode: themeState.themeMode,
                  locale: localeState.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    SangoMaterialLocalizationsDelegate(),
                    SangoCupertinoLocalizationsDelegate(),
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
