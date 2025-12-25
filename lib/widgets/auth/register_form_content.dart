import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/main.dart';
import 'package:useme/widgets/auth/glass_text_field.dart';

/// Register form content with glassmorphism design
class RegisterFormContent extends StatefulWidget {
  final BaseUserRole? initialRole;
  final ValueChanged<BaseUserRole>? onRoleChanged;

  const RegisterFormContent({
    super.key,
    this.initialRole,
    this.onRoleChanged,
  });

  @override
  State<RegisterFormContent> createState() => _RegisterFormContentState();
}

class _RegisterFormContentState extends State<RegisterFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late BaseUserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? BaseUserRole.client;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _updateRole(BaseUserRole role) {
    setState(() => _selectedRole = role);
    widget.onRoleChanged?.call(role);
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
              const SizedBox(height: 24),
              _buildRoleSelector(l10n),
              const SizedBox(height: 20),
              _buildSocialButtons(isGoogleLoading, isAppleLoading),
              const SizedBox(height: 20),
              _buildDivider(l10n),
              const SizedBox(height: 20),
              _buildForm(isLoading, l10n),
              const SizedBox(height: 24),
              _buildLoginLink(l10n),
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
                child: FaIcon(FontAwesomeIcons.userPlus, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.createAccount,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.joinCommunity,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.iAm,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRoleChip(BaseUserRole.client, l10n.artist, FontAwesomeIcons.music)),
            const SizedBox(width: 12),
            Expanded(child: _buildRoleChip(BaseUserRole.worker, l10n.engineer, FontAwesomeIcons.headphones)),
            const SizedBox(width: 12),
            Expanded(child: _buildRoleChip(BaseUserRole.admin, l10n.studio, FontAwesomeIcons.buildingUser)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleChip(BaseUserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => _updateRole(role),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.2),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.06),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                FaIcon(
                  icon,
                  size: 22,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            onPressed: () => _socialSignIn('google'),
          ),
        ),
        if (Platform.isIOS) ...[
          const SizedBox(width: 16),
          Expanded(
            child: GlassSocialButton(
              icon: FontAwesomeIcons.apple,
              label: 'Apple',
              isLoading: isAppleLoading,
              onPressed: () => _socialSignIn('apple'),
            ),
          ),
        ],
      ],
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
            l10n.orByEmail,
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

  Widget _buildForm(bool isLoading, AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          GlassTextField(
            controller: _nameController,
            hint: _selectedRole == BaseUserRole.client ? l10n.stageNameOrName : l10n.fullName,
            prefixIcon: FontAwesomeIcons.user,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v?.isEmpty ?? true) return l10n.nameRequired;
              if (v!.length < 2) return l10n.minCharacters(2);
              return null;
            },
          ),
          const SizedBox(height: 16),
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
          _buildPasswordField(l10n),
          const SizedBox(height: 16),
          _buildConfirmField(l10n),
          const SizedBox(height: 24),
          GlassButton(
            label: l10n.createMyAccount,
            isLoading: isLoading,
            onPressed: _register,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return GlassTextField(
      controller: _passwordController,
      hint: l10n.passwordHint,
      prefixIcon: FontAwesomeIcons.lock,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        icon: FaIcon(
          _obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
          size: 16,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
      validator: (v) {
        if (v?.isEmpty ?? true) return l10n.passwordRequired;
        if (v!.length < 6) return l10n.minCharacters(6);
        return null;
      },
    );
  }

  Widget _buildConfirmField(AppLocalizations l10n) {
    return GlassTextField(
      controller: _confirmController,
      hint: l10n.confirmPassword,
      prefixIcon: FontAwesomeIcons.lock,
      obscureText: _obscureConfirm,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _register(),
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        icon: FaIcon(
          _obscureConfirm ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
          size: 16,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
      validator: (v) {
        if (v?.isEmpty ?? true) return l10n.confirmationRequired;
        if (v != _passwordController.text) return l10n.passwordsDontMatch;
        return null;
      },
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            l10n.signIn,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    preferencesService.setSavedEmail(email);

    final extraData = <String, dynamic>{};
    if (_selectedRole == BaseUserRole.client) {
      extraData['stageName'] = _nameController.text.trim();
    }

    context.read<AuthBloc>().add(SignUpWithEmailEvent(
          email: email,
          password: _passwordController.text,
          name: _nameController.text.trim(),
          role: _selectedRole,
          extraData: extraData.isNotEmpty ? extraData : null,
        ));
  }

  void _socialSignIn(String provider) {
    if (provider == 'google') {
      context.read<AuthBloc>().add(const SignInWithGoogleEvent());
    } else if (provider == 'apple') {
      context.read<AuthBloc>().add(const SignInWithAppleEvent());
    }
  }
}
