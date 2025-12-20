import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/auth/auth_map_background.dart';
import 'package:useme/widgets/auth/login_form_content.dart';
import 'package:useme/widgets/auth/role_selector_sheet.dart';
import 'package:useme/widgets/common/smooth_draggable_widget.dart';

/// Login screen with map background and draggable form overlay
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapBloc(),
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatelessWidget {
  const _LoginScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthAuthenticatedState) {
          _navigateBasedOnRole(context, state.user);
        } else if (state is AuthNeedsRoleSelectionState) {
          RoleSelectorSheet.show(context, isNewUser: true);
        } else if (state is AuthPasswordResetSentState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email envoye a ${state.email}')),
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Map background with studios
            const Positioned.fill(
              child: AuthMapBackground(),
            ),
            // Draggable form overlay
            SlideInUp(
              duration: const Duration(milliseconds: 600),
              child: SmoothDraggableWidget(
                initial: 0.55,
                minSize: 0.35,
                maxSize: 0.85,
                bottomPadding: 20,
                bodyContent: const LoginFormContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateBasedOnRole(BuildContext context, BaseUser user) {
    final appUser = user as AppUser;

    if (appUser.isSuperAdmin || appUser.isStudio) {
      context.go(AppRoutes.home);
    } else if (appUser.isEngineer) {
      context.go(AppRoutes.engineerDashboard);
    } else {
      context.go(AppRoutes.artistPortal);
    }
  }
}
