import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/config/useme_theme.dart';
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
      // Notifications are handled in main.dart via BlocListener
      final route = AppRouter.getHomeRouteForUser(state.user);
      context.go(route);
    } else {
      context.go(AppRoutes.login);
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
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
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
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: UseMeTheme.primaryColor.withValues(alpha: 0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/logo/playstore.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Use Me',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: UseMeTheme.primaryColor,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Studio Sessions',
                          style: TextStyle(
                            fontSize: 16,
                            color: UseMeTheme.primaryColor.withValues(alpha: 0.7),
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
