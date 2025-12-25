import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/services/notification_service.dart';
import 'package:useme/l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  void _loadUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.account)),
      body: ListView(
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
            onTap: () => _sendPasswordResetEmail(l10n),
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
            onTap: () => _showDeleteAccountDialog(l10n),
          ),

          const SizedBox(height: 32),
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
              _showPasswordConfirmDialog(l10n);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
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
              _deleteAccount(passwordController.text, l10n);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(String password, AppLocalizations l10n) async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _userEmail == null) return;

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: _userEmail!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Remove FCM token
      await UseMeNotificationService.instance.removeToken();

      // Clear blocs
      if (mounted) {
        context.read<SessionBloc>().add(const ClearSessionsEvent());
        context.read<MessagingBloc>().add(const ClearMessagingEvent());
        context.read<FavoriteBloc>().add(const ClearFavoritesEvent());
      }

      // Delete user
      await user.delete();

      // Sign out and redirect
      if (mounted) {
        context.read<AuthBloc>().add(const SignOutEvent());
        context.go(AppRoutes.login);
      }
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
}
