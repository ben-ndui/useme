import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/useme_theme.dart';
import 'package:useme/core/services/notification_service.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/routing/router.dart';

/// Splash screen shown on app launch
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _hasNavigated = false;
  bool _isCheckingAuth = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset navigation state on hot reload and check auth
    _hasNavigated = false;
    _isCheckingAuth = false;
    _scheduleAuthCheck();
  }

  void _scheduleAuthCheck() {
    if (_isCheckingAuth) return;
    _isCheckingAuth = true;

    // Wait for animation to complete, then check auth
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _navigateBasedOnAuth();
    });
  }

  void _navigateBasedOnAuth() {
    if (_hasNavigated || !mounted) return;

    final state = context.read<AuthBloc>().state;

    // If still loading, wait and retry
    if (state is AuthInitialState || state is AuthLoadingState) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _navigateBasedOnAuth();
      });
      return;
    }

    _hasNavigated = true;

    if (state is AuthAuthenticatedState) {
      // Initialize notifications for authenticated user
      _initializeNotifications(state.user.uid);

      final route = AppRouter.getHomeRouteForUser(state.user);
      context.go(route);
    } else {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _initializeNotifications(String userId) async {
    try {
      await UseMeNotificationService.instance.initializeForUser(
        userId: userId,
        onMessage: _handleForegroundMessage,
      );

      // Handle notification that launched the app
      final initialMessage = await UseMeNotificationService.instance.getInitialMessage();
      if (initialMessage != null && mounted) {
        _handleNotificationNavigation(initialMessage.data);
      }

      // Handle notification taps when app is in background
      UseMeNotificationService.instance.onMessageOpenedApp((message) {
        if (mounted) {
          _handleNotificationNavigation(message.data);
        }
      });

      debugPrint('✅ Notifications initialisées pour $userId');
    } catch (e) {
      debugPrint('❌ Erreur init notifications: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification when app is in foreground
    UseMeNotificationService.instance.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification?.title ?? 'Use Me',
      body: message.notification?.body ?? '',
      payload: message.data['type'],
    );
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'new_message':
        final conversationId = data['conversationId'] as String?;
        if (conversationId != null) {
          context.push('/conversations/$conversationId');
        }
        break;
      case 'session_request':
      case 'session_confirmed':
      case 'session_cancelled':
        final sessionId = data['sessionId'] as String?;
        if (sessionId != null) {
          context.push('/artist/sessions/$sessionId');
        }
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // When auth state changes, try to navigate
        _navigateBasedOnAuth();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                UseMeTheme.primaryColor,
                UseMeTheme.primaryColor.withValues(alpha: 0.8),
                UseMeTheme.secondaryColor.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: FaIcon(
                              FontAwesomeIcons.music,
                              size: 50,
                              color: UseMeTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        const Text(
                          'Use Me',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Studio Sessions',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
