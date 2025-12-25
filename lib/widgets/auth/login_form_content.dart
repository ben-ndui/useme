import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/main.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/auth/glass_text_field.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Login form content with glassmorphism design
class LoginFormContent extends StatefulWidget {
  const LoginFormContent({super.key});

  @override
  State<LoginFormContent> createState() => _LoginFormContentState();
}

class _LoginFormContentState extends State<LoginFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  void _loadSavedEmail() {
    if (preferencesService.rememberEmailEnabled && preferencesService.savedEmail != null) {
      _emailController.text = preferencesService.savedEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;
        final isGoogleLoading = state is AuthGoogleLoadingState;
        final isAppleLoading = state is AuthAppleLoadingState;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildHeader(l10n),
              const SizedBox(height: 32),
              _buildForm(isLoading, l10n),
              const SizedBox(height: 24),
              _buildDivider(l10n),
              const SizedBox(height: 24),
              _buildSocialButtons(isGoogleLoading, isAppleLoading),
              const SizedBox(height: 28),
              _buildSignUpLink(l10n),
              const SizedBox(height: 16),
              _buildDemoButton(l10n),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        // Logo with glassmorphism
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.music, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Use Me',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.bookNextSessionSubtitle,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isLoading, AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          GlassTextField(
            controller: _emailController,
            hint: l10n.emailHint,
            prefixIcon: FontAwesomeIcons.envelope,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v?.isEmpty ?? true) return l10n.emailRequired;
              if (!v!.contains('@')) return l10n.emailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 16),
          GlassPasswordField(
            controller: _passwordController,
            hint: l10n.passwordHint,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            validator: (v) {
              if (v?.isEmpty ?? true) return l10n.passwordRequired;
              if (v!.length < 6) return l10n.minCharacters(6);
              return null;
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _forgotPassword(l10n),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                l10n.forgotPassword,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GlassButton(
            label: l10n.signIn,
            isLoading: isLoading,
            onPressed: _login,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.or,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons(bool isGoogleLoading, bool isAppleLoading) {
    return Row(
      children: [
        Expanded(
          child: GlassSocialButton(
            icon: FontAwesomeIcons.google,
            label: 'Google',
            isLoading: isGoogleLoading,
            onPressed: () => _socialLogin('google'),
          ),
        ),
        if (Platform.isIOS) ...[
          const SizedBox(width: 16),
          Expanded(
            child: GlassSocialButton(
              icon: FontAwesomeIcons.apple,
              label: 'Apple',
              isLoading: isAppleLoading,
              onPressed: () => _socialLogin('apple'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSignUpLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.noAccountYet,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () => context.push(AppRoutes.signup),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            l10n.signUp,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoButton(AppLocalizations l10n) {
    return TextButton.icon(
      onPressed: () => _showDemoSelector(l10n),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      icon: const FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 14),
      label: Text(
        l10n.demoAccess,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    preferencesService.setSavedEmail(email);

    context.read<AuthBloc>().add(SignInWithEmailEvent(
          email: email,
          password: _passwordController.text,
        ));
  }

  void _socialLogin(String provider) {
    if (provider == 'google') {
      context.read<AuthBloc>().add(const SignInWithGoogleEvent());
    } else if (provider == 'apple') {
      context.read<AuthBloc>().add(const SignInWithAppleEvent());
    }
  }

  void _forgotPassword(AppLocalizations l10n) {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppSnackBar.warning(context, l10n.enterEmailFirst);
      return;
    }
    context.read<AuthBloc>().add(ResetPasswordEvent(email: email));
  }

  void _showDemoSelector(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DemoSelectorSheet(l10n: l10n),
    );
  }
}

class _DemoSelectorSheet extends StatelessWidget {
  final AppLocalizations l10n;

  const _DemoSelectorSheet({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.demoMode,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.browseWithoutLogin,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.buildingUser),
              title: Text(l10n.studioAdmin),
              subtitle: Text(l10n.manageSessionsArtistsServices),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.home);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.headphones),
              title: Text(l10n.soundEngineer),
              subtitle: Text(l10n.viewAndTrackSessions),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.engineerDashboard);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.music),
              title: Text(l10n.artist),
              subtitle: Text(l10n.bookSessions),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.artistPortal);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
