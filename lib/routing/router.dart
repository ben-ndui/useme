import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/screens/auth/login_screen.dart';
import 'package:useme/screens/auth/register_screen.dart';
import 'package:useme/screens/auth/splash_screen.dart';
import 'package:useme/screens/studio/studio_main_scaffold.dart';
import 'package:useme/screens/studio/session_form_screen.dart';
import 'package:useme/screens/studio/artist_form_screen.dart';
import 'package:useme/screens/studio/add_artist_screen.dart';
import 'package:useme/screens/studio/services_page.dart';
import 'package:useme/screens/studio/service_form_screen.dart';
import 'package:useme/screens/studio/studio_claim_screen.dart';
import 'package:useme/screens/studio/manual_studio_form_screen.dart';
import 'package:useme/screens/studio/team_management_screen.dart';
import 'package:useme/screens/engineer/engineer_main_scaffold.dart';
import 'package:useme/screens/engineer/session_tracking_screen.dart';
import 'package:useme/screens/engineer/engineer_availability_screen.dart';
import 'package:useme/screens/artist/artist_main_scaffold.dart';
import 'package:useme/screens/artist/session_request_screen.dart';
import 'package:useme/screens/shared/notifications_screen.dart';
import 'package:useme/screens/shared/profile_screen.dart';
import 'package:useme/screens/shared/conversations_screen.dart';
import 'package:useme/screens/shared/chat_screen.dart';
import 'package:useme/screens/shared/about_screen.dart';
import 'package:useme/screens/shared/favorites_screen.dart';
import 'app_routes.dart';

/// GoRouter configuration for Use Me
class AppRouter {
  static GoRouter getRouter({GlobalKey<NavigatorState>? navigatorKey}) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,

      routes: [
        // Splash / Root
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),

        // Authentication routes
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.signup,
          builder: (context, state) => const RegisterScreen(),
        ),

        // Studio (Admin) dashboard - Main scaffold with pages
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const StudioMainScaffold(initialPage: 0),
        ),
        GoRoute(
          path: AppRoutes.sessions,
          builder: (context, state) => const StudioMainScaffold(initialPage: 1),
        ),
        GoRoute(
          path: AppRoutes.artists,
          builder: (context, state) => const StudioMainScaffold(initialPage: 2),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const StudioMainScaffold(initialPage: 3),
        ),

        // Session routes
        GoRoute(
          path: AppRoutes.sessionAdd,
          builder: (context, state) => const SessionFormScreen(),
        ),
        GoRoute(
          path: AppRoutes.sessionDetail,
          builder: (context, state) {
            final sessionId = state.pathParameters['id']!;
            return _PlaceholderScreen(title: 'Session $sessionId');
          },
        ),
        GoRoute(
          path: AppRoutes.sessionEdit,
          builder: (context, state) {
            final sessionId = state.pathParameters['id']!;
            return SessionFormScreen(sessionId: sessionId);
          },
        ),

        // Artist routes
        GoRoute(
          path: AppRoutes.artistAdd,
          builder: (context, state) => const AddArtistScreen(),
        ),
        GoRoute(
          path: AppRoutes.artistDetail,
          builder: (context, state) {
            final artistId = state.pathParameters['id']!;
            return ArtistFormScreen(artistId: artistId);
          },
        ),
        GoRoute(
          path: AppRoutes.artistEdit,
          builder: (context, state) {
            final artistId = state.pathParameters['id']!;
            return ArtistFormScreen(artistId: artistId);
          },
        ),

        // Service routes
        GoRoute(
          path: AppRoutes.services,
          builder: (context, state) => const ServicesPage(),
        ),
        GoRoute(
          path: AppRoutes.serviceAdd,
          builder: (context, state) => const ServiceFormScreen(),
        ),
        GoRoute(
          path: '/services/:id/edit',
          builder: (context, state) {
            final serviceId = state.pathParameters['id']!;
            return ServiceFormScreen(serviceId: serviceId);
          },
        ),

        // Engineer routes
        GoRoute(
          path: AppRoutes.engineerDashboard,
          builder: (context, state) => const EngineerMainScaffold(initialPage: 0),
        ),
        GoRoute(
          path: '/engineer/sessions',
          builder: (context, state) => const EngineerMainScaffold(initialPage: 1),
        ),
        GoRoute(
          path: AppRoutes.sessionTracking,
          builder: (context, state) {
            final sessionId = state.pathParameters['id']!;
            return SessionTrackingScreen(sessionId: sessionId);
          },
        ),
        GoRoute(
          path: AppRoutes.engineerAvailability,
          builder: (context, state) => const EngineerAvailabilityScreen(),
        ),

        // Artist portal routes
        GoRoute(
          path: AppRoutes.artistPortal,
          builder: (context, state) => const ArtistMainScaffold(initialPage: 0),
        ),
        GoRoute(
          path: '/artist/sessions',
          builder: (context, state) => const ArtistMainScaffold(initialPage: 1),
        ),
        GoRoute(
          path: '/artist/sessions/:id',
          builder: (context, state) {
            final sessionId = state.pathParameters['id']!;
            return _PlaceholderScreen(title: 'Session $sessionId');
          },
        ),
        GoRoute(
          path: '/artist/request',
          builder: (context, state) {
            final studioId = state.uri.queryParameters['studioId'];
            final studioName = state.uri.queryParameters['studioName'];
            return SessionRequestScreen(
              studioId: studioId,
              studioName: studioName,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.artistSettings,
          builder: (context, state) => const ArtistMainScaffold(initialPage: 4),
        ),
        GoRoute(
          path: '/artist/favorites',
          builder: (context, state) => const ArtistMainScaffold(initialPage: 2),
        ),

        // Profile & Settings
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),

        // Team management
        GoRoute(
          path: AppRoutes.teamManagement,
          builder: (context, state) => const TeamManagementScreen(),
        ),

        // Studio claim
        GoRoute(
          path: AppRoutes.studioClaim,
          builder: (context, state) => const StudioClaimScreen(),
        ),
        GoRoute(
          path: AppRoutes.studioCreate,
          builder: (context, state) => const ManualStudioFormScreen(),
        ),

        // Notifications
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),

        // Messaging
        GoRoute(
          path: AppRoutes.conversations,
          builder: (context, state) => const ConversationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          builder: (context, state) {
            final conversationId = state.pathParameters['id']!;
            return ChatScreen(conversationId: conversationId);
          },
        ),

        // About
        GoRoute(
          path: AppRoutes.about,
          builder: (context, state) => const AboutScreen(),
        ),

        // Favorites
        GoRoute(
          path: AppRoutes.favorites,
          builder: (context, state) => const FavoritesScreen(),
        ),
      ],

      // Error handling
      errorBuilder: (context, state) {
        return _NotFoundScreen(uri: state.uri.toString());
      },
    );
  }

  /// Get the home route based on user role
  static String getHomeRouteForUser(BaseUser user) {
    final appUser = user as AppUser;

    if (appUser.isSuperAdmin || appUser.isStudio) {
      return AppRoutes.home;
    } else if (appUser.isEngineer) {
      return AppRoutes.engineerDashboard;
    } else {
      return AppRoutes.artistPortal;
    }
  }
}

/// Temporary placeholder screen for routes not yet implemented
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.hammer, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('En construction...'),
          ],
        ),
      ),
    );
  }
}

/// Not found screen with role-aware redirect
class _NotFoundScreen extends StatelessWidget {
  final String uri;

  const _NotFoundScreen({required this.uri});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.circleExclamation, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Page non trouvée', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(uri, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (authState is AuthAuthenticatedState) {
                      context.go(AppRouter.getHomeRouteForUser(authState.user));
                    } else {
                      context.go(AppRoutes.login);
                    }
                  },
                  child: const Text('Retour à l\'accueil'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
