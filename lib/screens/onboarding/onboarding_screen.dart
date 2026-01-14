import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import '../../core/blocs/blocs_exports.dart';
import '../../routing/app_routes.dart';
import '../../routing/router.dart';
import 'onboarding_content_page.dart';
import 'location_permission_page.dart';
import 'notification_permission_page.dart';
import 'terms_acceptance_page.dart';

/// Main onboarding screen that orchestrates the onboarding flow
class OnboardingScreen extends StatelessWidget {
  final String role;

  const OnboardingScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc()
        ..add(StartOnboardingEvent(role: role)),
      child: const _OnboardingContent(),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompletedState) {
          _navigateToHome(context);
        } else if (state is OnboardingErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OnboardingState state) {
    if (state is OnboardingContentState) {
      return OnboardingContentPage(state: state);
    } else if (state is OnboardingLocationState) {
      return LocationPermissionPage(state: state);
    } else if (state is OnboardingNotificationState) {
      return NotificationPermissionPage(state: state);
    } else if (state is OnboardingTermsState) {
      return TermsAcceptancePage(state: state);
    } else if (state is OnboardingCompletingState) {
      return const Center(child: CircularProgressIndicator());
    }
    return const Center(child: CircularProgressIndicator());
  }

  void _navigateToHome(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      context.go(AppRouter.getHomeRouteForUser(authState.user));
    } else {
      context.go(AppRoutes.login);
    }
  }
}
