import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/map/map_bloc.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/invitation_service.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/auth/auth_map_background.dart';
import 'package:useme/widgets/auth/register_form_content.dart';
import 'package:useme/widgets/common/smooth_draggable_widget.dart';

/// Register screen with map background and draggable form overlay
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapBloc(),
      child: const _RegisterScreenContent(),
    );
  }
}

class _RegisterScreenContent extends StatefulWidget {
  const _RegisterScreenContent();

  @override
  State<_RegisterScreenContent> createState() => _RegisterScreenContentState();
}

class _RegisterScreenContentState extends State<_RegisterScreenContent> {
  final _invitationService = InvitationService();
  BaseUserRole _selectedRole = BaseUserRole.client;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthNeedsRoleSelectionState) {
          // Auto-complete with pre-selected role (no need to show selector again)
          context.read<AuthBloc>().add(CompleteSocialSignUpEvent(role: _selectedRole));
        } else if (state is AuthAuthenticatedState) {
          // Auto-link invitations for artists
          if (_selectedRole == BaseUserRole.client) {
            await _autoLinkInvitations(state.user);
          }
          _navigateBasedOnRole(state.user);
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
            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: _buildBackButton(context),
            ),
            // Draggable form overlay
            SlideInUp(
              duration: const Duration(milliseconds: 600),
              child: SmoothDraggableWidget(
                initial: 0.70,
                minSize: 0.45,
                maxSize: 0.92,
                bottomPadding: 20,
                bodyContent: RegisterFormContent(
                  initialRole: _selectedRole,
                  onRoleChanged: (role) => _selectedRole = role,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }

  void _navigateBasedOnRole(BaseUser user) {
    final appUser = user as AppUser;

    if (appUser.isSuperAdmin || appUser.isStudio) {
      context.go(AppRoutes.home);
    } else if (appUser.isEngineer) {
      context.go(AppRoutes.engineerDashboard);
    } else {
      context.go(AppRoutes.artistPortal);
    }
  }

  Future<void> _autoLinkInvitations(BaseUser user) async {
    try {
      final acceptedCount = await _invitationService.autoAcceptInvitationsForNewUser(
        user.uid,
        user.email.toLowerCase(),
      );

      if (acceptedCount > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$acceptedCount studio${acceptedCount > 1 ? 's' : ''} vous attendai${acceptedCount > 1 ? 'ent' : 't'} !',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur auto-link invitations: $e');
    }
  }
}
