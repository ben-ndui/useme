import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/data/tips_data.dart';
import 'package:useme/core/services/notification_service.dart';
import 'package:useme/main.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/screens/common/tips_screen.dart';

/// Artist settings page
class ArtistSettingsPage extends StatelessWidget {
  const ArtistSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Profil'),
          _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.user,
            title: 'Mon profil',
            subtitle: 'Informations personnelles',
            onTap: () => context.push(AppRoutes.profile),
          ),

          const Divider(height: 32),

          _buildSectionHeader(context, 'Application'),
          _buildNotificationTile(context),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return _buildSettingsTile(
                context,
                icon: FontAwesomeIcons.palette,
                title: 'Apparence',
                subtitle: _getThemeLabel(state.themeMode),
                onTap: () => _showThemeSelector(context),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.lightbulb,
            title: 'Guide d\'utilisation',
            subtitle: 'Astuces et conseils',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TipsScreen(
                  title: 'Guide artiste',
                  sections: TipsData.artistTips,
                ),
              ),
            ),
          ),

          const Divider(height: 32),

          _buildSectionHeader(context, 'Compte'),
          _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.circleInfo,
            title: 'À propos',
            subtitle: 'Version, mentions légales',
            onTap: () => context.push(AppRoutes.about),
          ),
          _buildSettingsTile(
            context,
            icon: FontAwesomeIcons.rightFromBracket,
            title: 'Déconnexion',
            subtitle: '',
            isDestructive: true,
            onTap: () => _showLogoutDialog(context),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Use Me v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          const SizedBox(height: 16),
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

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : theme.colorScheme.onSurface;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: FaIcon(icon, size: 18, color: isDestructive ? Colors.red : theme.colorScheme.primary),
        ),
      ),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: theme.textTheme.bodySmall) : null,
      trailing: isDestructive ? null : FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: theme.colorScheme.outline),
      onTap: onTap,
    );
  }

  Widget _buildNotificationTile(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: preferencesService,
      builder: (context, _) {
        final isEnabled = preferencesService.notificationsEnabled;

        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                isEnabled ? FontAwesomeIcons.solidBell : FontAwesomeIcons.bellSlash,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          title: const Text('Notifications'),
          subtitle: Text(
            isEnabled ? 'Activées' : 'Désactivées',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Switch.adaptive(
            value: isEnabled,
            onChanged: (value) => _toggleNotifications(context, value),
          ),
        );
      },
    );
  }

  Future<void> _toggleNotifications(BuildContext context, bool enable) async {
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticatedState) {
      userId = authState.user.uid;
    }

    if (enable) {
      // Demander les permissions
      final granted = await UseMeNotificationService.instance.requestPermissions();
      if (granted) {
        await preferencesService.setNotificationsEnabled(true, userId: userId);
      } else {
        // Afficher un message si refusé
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez autoriser les notifications dans les réglages'),
            ),
          );
        }
      }
    } else {
      await preferencesService.setNotificationsEnabled(false, userId: userId);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    // Capture parent context before showing dialog
    final authBloc = context.read<AuthBloc>();
    final router = GoRouter.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Remove FCM token before logout
              await UseMeNotificationService.instance.removeToken();
              // Logout via AuthBloc using captured references
              authBloc.add(const SignOutEvent());
              router.go(AppRoutes.login);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }

  void _showThemeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final currentMode = context.read<ThemeBloc>().state.themeMode;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Apparence', style: theme.textTheme.titleLarge),
            ),
            _buildThemeOption(
              context,
              icon: FontAwesomeIcons.circleHalfStroke,
              title: 'Système',
              subtitle: 'Suit les réglages de l\'appareil',
              mode: ThemeMode.system,
              isSelected: currentMode == ThemeMode.system,
            ),
            _buildThemeOption(
              context,
              icon: FontAwesomeIcons.sun,
              title: 'Clair',
              subtitle: 'Thème lumineux',
              mode: ThemeMode.light,
              isSelected: currentMode == ThemeMode.light,
            ),
            _buildThemeOption(
              context,
              icon: FontAwesomeIcons.moon,
              title: 'Sombre',
              subtitle: 'Thème sombre',
              mode: ThemeMode.dark,
              isSelected: currentMode == ThemeMode.dark,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 18,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: isSelected
          ? FaIcon(FontAwesomeIcons.circleCheck, size: 20, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        context.read<ThemeBloc>().add(ChangeThemeEvent(themeMode: mode));
        Navigator.pop(context);
      },
    );
  }
}
