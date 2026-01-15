import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/services/notification_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/main.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Account management screen for email, password, and account deletion.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isLoading = false;
  String? _userEmail;
  String? _authProvider;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email;
      _authProvider = useMeAuthService.getAuthProvider();
    });
  }

  bool get _isOAuthUser => _authProvider == 'google.com' || _authProvider == 'apple.com';
  bool get _isAppleUser => _authProvider == 'apple.com';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.account)),
      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 16),

              // Email section
              _buildSectionHeader(context, l10n.credentials),
              _buildTile(
                context,
                icon: FontAwesomeIcons.envelope,
                title: l10n.email,
                subtitle: _userEmail ?? l10n.notAvailable,
                showChevron: false,
              ),
              _buildTile(
                context,
                icon: FontAwesomeIcons.key,
                title: l10n.changePassword,
                subtitle: l10n.sendResetEmail,
                onTap: _isLoading ? null : () => _sendPasswordResetEmail(l10n),
              ),

              const Divider(height: 32),

              // Danger zone
              _buildSectionHeader(context, l10n.dangerZone),
              _buildTile(
                context,
                icon: FontAwesomeIcons.trash,
                title: l10n.deleteAccount,
                subtitle: l10n.deleteAccountWarning,
                isDestructive: true,
                onTap: _isLoading ? null : () => _showDeleteAccountDialog(l10n),
              ),

              const SizedBox(height: 32),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool showChevron = true,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : theme.colorScheme.onSurface;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red : theme.colorScheme.primary,
          ),
        ),
      ),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null
          ? Text(subtitle, style: theme.textTheme.bodySmall)
          : null,
      trailing: onTap != null && showChevron
          ? FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 14,
              color: theme.colorScheme.outline,
            )
          : null,
      onTap: onTap,
    );
  }

  Future<void> _sendPasswordResetEmail(AppLocalizations l10n) async {
    if (_userEmail == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _userEmail!);
      if (mounted) {
        AppSnackBar.success(context, l10n.emailSentTo(_userEmail!));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        AppSnackBar.error(context, e.message ?? l10n.sendError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteAccountDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (_isOAuthUser) {
                _showOAuthConfirmDialog(l10n);
              } else {
                _showPasswordConfirmDialog(l10n);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  /// Dialog for OAuth users (Apple/Google) - no password needed
  void _showOAuthConfirmDialog(AppLocalizations l10n) {
    final providerName = _isAppleUser ? 'Apple' : 'Google';
    final icon = _isAppleUser ? FontAwesomeIcons.apple : FontAwesomeIcons.google;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDeletion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.oauthReauthRequired(providerName),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteAccountOAuth(l10n);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.continueWithProvider(providerName)),
          ),
        ],
      ),
    );
  }

  void _showPasswordConfirmDialog(AppLocalizations l10n) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDeletion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterPassword),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.password,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteAccountWithPassword(passwordController.text, l10n);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  /// Delete account for OAuth users (Apple/Google)
  Future<void> _deleteAccountOAuth(AppLocalizations l10n) async {
    setState(() => _isLoading = true);

    try {
      // Reauthenticate with OAuth provider
      SmoothResponse<bool> reauthResult;

      if (_isAppleUser) {
        reauthResult = await useMeAuthService.reauthenticateWithApple();
      } else {
        reauthResult = await useMeAuthService.reauthenticateWithGoogle();
      }

      if (!reauthResult.isSuccess) {
        if (mounted) {
          AppSnackBar.error(context, reauthResult.message);
        }
        return;
      }

      // Now delete the account
      await _performAccountDeletion(l10n);
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, l10n.deletionError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Delete account with email/password
  Future<void> _deleteAccountWithPassword(String password, AppLocalizations l10n) async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _userEmail == null) return;

      // Re-authenticate with password
      final credential = EmailAuthProvider.credential(
        email: _userEmail!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Now delete the account
      await _performAccountDeletion(l10n);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        AppSnackBar.error(context, e.message ?? l10n.deletionError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Common account deletion logic
  Future<void> _performAccountDeletion(AppLocalizations l10n) async {
    // Remove FCM token
    await UseMeNotificationService.instance.removeToken();

    // Clear blocs
    if (mounted) {
      context.read<SessionBloc>().add(const ClearSessionsEvent());
      context.read<MessagingBloc>().add(const ClearMessagingEvent());
      context.read<FavoriteBloc>().add(const ClearFavoritesEvent());
    }

    // Delete account (handles Apple token revocation internally)
    final result = await useMeAuthService.deleteAccount();

    if (!mounted) return;

    if (result.isSuccess) {
      // Sign out and redirect
      context.read<AuthBloc>().add(const SignOutEvent());
      context.go(AppRoutes.login);
    } else {
      AppSnackBar.error(context, result.message);
    }
  }
}
