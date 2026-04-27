import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/recent_account.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/main.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/auth/biometric_opt_in_sheet.dart';
import 'package:useme/widgets/auth/glass_text_field.dart';
import 'package:useme/widgets/auth/password_bottom_sheet.dart';
import 'package:useme/widgets/auth/quick_login_card.dart';
import 'package:useme/widgets/auth/recent_accounts_list.dart';
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
  bool _showQuickLogin = false;
  bool _showRecentAccounts = false;
  bool _rememberMe = false;
  String _lastLoginProvider = 'email';
  String? _pendingEmailPassword;

  @override
  void initState() {
    super.initState();
    _showQuickLogin = preferencesService.quickLoginEnabled &&
        preferencesService.quickLoginDisplayName != null;
    // Show recent accounts list if no single quick login but accounts exist
    if (!_showQuickLogin && recentAccountsService.accounts.isNotEmpty) {
      _showRecentAccounts = true;
    }
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

    if (_showQuickLogin) {
      final provider = preferencesService.quickLoginProvider ?? 'email';
      final email = preferencesService.quickLoginEmail ?? '';
      return BlocListener<AuthBloc, AuthState>(
        listener: _onAuthState,
        child: QuickLoginCard(
          displayName: preferencesService.quickLoginDisplayName ?? '',
          email: email,
          role: preferencesService.quickLoginRole ?? 'client',
          provider: provider,
          photoUrl: preferencesService.quickLoginPhotoUrl,
          biometricEnabled: _isBiometricEnabled(email),
          onConnect: (password) => _quickConnect(context, password),
          onSwitchAccount: () => setState(() {
            _showQuickLogin = false;
            if (recentAccountsService.accounts.isNotEmpty) {
              _showRecentAccounts = true;
            }
          }),
        ),
      );
    }

    if (_showRecentAccounts) {
      return BlocListener<AuthBloc, AuthState>(
        listener: _onAuthState,
        child: RecentAccountsList(
          accounts: recentAccountsService.accounts,
          onAccountSelected: (account) => _connectRecentAccount(account),
          onAccountRemoved: (account) => _removeRecentAccount(account),
          onUseAnotherAccount: () => setState(() {
            _showRecentAccounts = false;
          }),
        ),
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: _onAuthState,
      child: BlocBuilder<AuthBloc, AuthState>(
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
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _quickConnect(BuildContext context, String? password) async {
    // Capture bloc reference up-front so we can dispatch after awaits.
    final authBloc = context.read<AuthBloc>();

    // If Firebase session is still active, navigate directly
    final state = authBloc.state;
    if (state is AuthAuthenticatedState) {
      final appUser = state.user as AppUser;
      if (appUser.isSuperAdmin || appUser.isStudio) {
        context.go(AppRoutes.home);
      } else if (appUser.isEngineer) {
        context.go(AppRoutes.engineerDashboard);
      } else {
        context.go(AppRoutes.artistPortal);
      }
      return;
    }

    // Session expired — re-authenticate based on provider
    final provider = preferencesService.quickLoginProvider ?? 'email';
    final email = preferencesService.quickLoginEmail ?? '';
    _rememberMe = true; // Keep quick login enabled after re-auth
    _lastLoginProvider = provider;

    // Biometric path: prompt then either reuse stored password or social gate.
    if (_isBiometricEnabled(email)) {
      final ok = await _promptBiometric();
      if (!ok || !mounted) return;
      if (provider == 'email') {
        final stored = await biometricService.retrievePassword(email);
        if (stored == null || stored.isEmpty || !mounted) return;
        _pendingEmailPassword = stored;
        authBloc.add(SignInWithEmailEvent(email: email, password: stored));
        return;
      }
    }

    if (provider == 'google') {
      authBloc.add(const SignInWithGoogleEvent());
    } else if (provider == 'apple') {
      authBloc.add(const SignInWithAppleEvent());
    } else {
      if (password == null || password.isEmpty) return;
      _pendingEmailPassword = password;
      authBloc.add(SignInWithEmailEvent(email: email, password: password));
    }
  }

  Future<void> _removeRecentAccount(RecentAccount account) async {
    await recentAccountsService.removeAccount(account.email);
    await biometricService.clearForEmail(account.email);
    // If quick login was for this account, clear it too
    if (preferencesService.quickLoginEmail == account.email) {
      preferencesService.clearQuickLoginData();
    }
    if (!mounted) return;
    setState(() {
      if (recentAccountsService.accounts.isEmpty) {
        _showRecentAccounts = false;
      }
    });
  }

  Future<void> _connectRecentAccount(RecentAccount account) async {
    final authBloc = context.read<AuthBloc>();
    _lastLoginProvider = account.provider;
    _rememberMe = true;

    if (account.biometricEnabled) {
      final ok = await _promptBiometric();
      if (!ok || !mounted) return;
      if (account.provider == 'email') {
        final stored = await biometricService.retrievePassword(account.email);
        if (stored == null || stored.isEmpty || !mounted) return;
        _pendingEmailPassword = stored;
        authBloc.add(
          SignInWithEmailEvent(email: account.email, password: stored),
        );
        return;
      }
    }

    if (account.provider == 'google') {
      authBloc.add(const SignInWithGoogleEvent());
    } else if (account.provider == 'apple') {
      authBloc.add(const SignInWithAppleEvent());
    } else {
      PasswordBottomSheet.show(
        context,
        displayName: account.displayName,
        email: account.email,
        onSubmit: (password) {
          _pendingEmailPassword = password;
          authBloc.add(
            SignInWithEmailEvent(email: account.email, password: password),
          );
        },
      );
    }
  }

  bool _isBiometricEnabled(String email) =>
      recentAccountsService.findByEmail(email)?.biometricEnabled ?? false;

  Future<bool> _promptBiometric() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await biometricService.authenticate(reason: l10n.biometricReason);
    if (!ok && mounted) {
      AppSnackBar.error(context, l10n.biometricFailed);
    }
    return ok;
  }

  Future<void> _onAuthState(BuildContext context, AuthState state) async {
    if (state is! AuthAuthenticatedState) return;
    final appUser = state.user as AppUser;
    final password = _pendingEmailPassword;
    _saveRecentAccount(appUser);
    if (!context.mounted) return;
    await _maybeOfferBiometricOptIn(
      context,
      email: appUser.email,
      provider: _lastLoginProvider,
      emailPassword: password,
    );
    _pendingEmailPassword = null;
    if (!context.mounted) return;
    _navigateBasedOnRole(context, appUser);
  }

  void _navigateBasedOnRole(BuildContext context, AppUser appUser) {
    if (appUser.isSuperAdmin || appUser.isStudio) {
      context.go(AppRoutes.home);
    } else if (appUser.isEngineer) {
      context.go(AppRoutes.engineerDashboard);
    } else {
      context.go(AppRoutes.artistPortal);
    }
  }

  Future<void> _maybeOfferBiometricOptIn(
    BuildContext context, {
    required String email,
    required String provider,
    String? emailPassword,
  }) async {
    final account = recentAccountsService.findByEmail(email);
    if (account == null || account.biometricEnabled) return;
    if (provider == 'email' &&
        (emailPassword == null || emailPassword.isEmpty)) {
      return;
    }
    final available = await biometricService.isAvailable();
    if (!available || !context.mounted) return;

    final accepted = await BiometricOptInSheet.show(context);
    if (!accepted) return;

    if (provider == 'email') {
      await biometricService.storePassword(
        email: email,
        password: emailPassword!,
      );
    } else {
      await biometricService.setSocialGate(email: email, enabled: true);
    }
    await recentAccountsService.setBiometricEnabled(email, true);

    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      AppSnackBar.success(context, l10n.biometricEnabledToast);
    }
  }

  void _saveRecentAccount(AppUser appUser) {
    final account = RecentAccount(
      email: appUser.email,
      displayName: appUser.displayName ?? appUser.name ?? '',
      provider: _lastLoginProvider,
      role: appUser.role.name,
      photoUrl: appUser.photoURL,
      lastLoginAt: DateTime.now(),
    );
    recentAccountsService.addAccount(account);

    // Also update legacy quick login if remember me was checked
    if (_rememberMe) {
      preferencesService.setQuickLoginData(
        displayName: account.displayName,
        email: account.email,
        role: account.role,
        provider: account.provider,
        photoUrl: account.photoUrl,
      );
    }
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          'UZME',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : cs.onSurface,
            letterSpacing: 25,
          ),
        ),
        Text(
          l10n.bookNextSessionSubtitle,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white.withValues(alpha: 0.75) : cs.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isLoading, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
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
          Row(
            children: [
              _buildRememberMeCheckbox(l10n),
              const Spacer(),
              TextButton(
                onPressed: () => _forgotPassword(l10n),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white.withValues(alpha: 0.8) : cs.onSurface.withValues(alpha: 0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: Text(
                  l10n.forgotPassword,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
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

  Widget _buildRememberMeCheckbox(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _rememberMe = !_rememberMe),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v ?? false),
              side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.6) : cs.onSurface.withValues(alpha: 0.5)),
              checkColor: isDark ? Colors.black87 : cs.onPrimary,
              activeColor: isDark ? Colors.white.withValues(alpha: 0.3) : cs.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.rememberMe,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.8) : cs.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final lineColor = isDark ? Colors.white.withValues(alpha: 0.3) : cs.outlineVariant;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, lineColor]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.or,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.6) : cs.onSurface.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [lineColor, Colors.transparent]),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.noAccountYet,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.75) : cs.onSurface.withValues(alpha: 0.6),
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () => context.push(AppRoutes.signup),
          style: TextButton.styleFrom(
            foregroundColor: isDark ? Colors.white : cs.primary,
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
    final password = _passwordController.text;
    preferencesService.setSavedEmail(email);
    _lastLoginProvider = 'email';
    _pendingEmailPassword = password;

    context.read<AuthBloc>().add(SignInWithEmailEvent(
          email: email,
          password: password,
        ));
  }

  void _socialLogin(String provider) {
    _lastLoginProvider = provider;
    _pendingEmailPassword = null;
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
