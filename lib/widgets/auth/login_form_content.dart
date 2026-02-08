import 'dart:io';

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
              const SizedBox(height: 24),
              // Demo mode disabled for V1 App Store release
              // _buildDemoButton(l10n),
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
         Text(
          'UZME',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 25,
          ),
        ),
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

}
