import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/services/auth_service.dart';
import 'package:useme/routing/router.dart';

/// Service d'authentification global.
final useMeAuthService = UseMeAuthService();

/// Service de préférences global.
final preferencesService = BasePreferencesService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SmoothFirebase with default app
  SmoothFirebase.initializeWithDefault();

  // Initialize French locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const UseMeApp());
}

class UseMeApp extends StatelessWidget {
  const UseMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme BLoC from package
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(preferencesService: preferencesService)
            ..add(const LoadThemeEvent()),
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
        BlocProvider<BookingBloc>(create: (_) => BookingBloc()),
        BlocProvider<MessagingBloc>(create: (_) => MessagingBloc()),
        BlocProvider<FavoriteBloc>(create: (_) => FavoriteBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Use Me',
            debugShowCheckedModeBanner: false,
            theme: UseMeTheme.lightTheme,
            darkTheme: UseMeTheme.darkTheme,
            themeMode: themeState.themeMode,
            routerConfig: AppRouter.getRouter(),
          );
        },
      ),
    );
  }
}
