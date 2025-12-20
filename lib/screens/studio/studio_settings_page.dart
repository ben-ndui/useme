import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/calendar/calendar_exports.dart';
import 'package:useme/core/data/tips_data.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/services/notification_service.dart';
import 'package:useme/main.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/screens/common/tips_screen.dart';
import 'package:useme/widgets/studio/calendar_connection_section.dart';

/// Studio settings page
class StudioSettingsPage extends StatefulWidget {
  const StudioSettingsPage({super.key});

  @override
  State<StudioSettingsPage> createState() => _StudioSettingsPageState();
}

class _StudioSettingsPageState extends State<StudioSettingsPage> {
  late final CalendarBloc _calendarBloc;
  String? _userId;
  AppUser? _currentUser;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _calendarBloc = CalendarBloc();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadUserId();
    }
  }

  void _loadUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      setState(() {
        _userId = authState.user.uid;
        _currentUser = authState.user is AppUser ? authState.user as AppUser : null;
      });
      _calendarBloc.add(LoadCalendarStatusEvent(userId: _userId!));
    }
  }

  @override
  void dispose() {
    _calendarBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _calendarBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Réglages'),
        ),
        body: ListView(
          children: [
            // Studio section
            _buildSectionHeader(context, 'Studio'),
            _buildSettingsTile(
              context,
              icon: FontAwesomeIcons.buildingUser,
              title: 'Profil studio',
              subtitle: 'Nom, adresse, contact',
              onTap: () => context.push(AppRoutes.profile),
            ),
            _buildSettingsTile(
              context,
              icon: FontAwesomeIcons.tags,
              title: 'Services',
              subtitle: 'Catalogue des prestations',
              onTap: () => context.push(AppRoutes.services),
            ),
            _buildSettingsTile(
              context,
              icon: FontAwesomeIcons.userTie,
              title: 'Équipe',
              subtitle: 'Gérer les ingénieurs',
              onTap: () => context.push(AppRoutes.teamManagement),
            ),

            const Divider(height: 32),

            // Visibility section
            _buildSectionHeader(context, 'Visibilité'),
            _buildVisibilitySection(context),

            const Divider(height: 32),

            // Calendar section
            _buildSectionHeader(context, 'Calendrier'),
            if (_userId != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CalendarConnectionSection(userId: _userId!),
              ),

            const Divider(height: 32),

            // App section
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
                    title: 'Guide studio',
                    sections: TipsData.studioTips,
                  ),
                ),
              ),
            ),

            const Divider(height: 32),

            // Account section
            _buildSectionHeader(context, 'Compte'),
            _buildSettingsTile(
              context,
              icon: FontAwesomeIcons.userGear,
              title: 'Compte',
              subtitle: 'Email, mot de passe',
              onTap: () {},
            ),
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

            // App version
            Center(
              child: Text(
                'Use Me v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: theme.textTheme.bodySmall)
          : null,
      trailing: isDestructive
          ? null
          : FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 14,
              color: theme.colorScheme.outline,
            ),
      onTap: onTap,
    );
  }

  Widget _buildVisibilitySection(BuildContext context) {
    final theme = Theme.of(context);
    final isPartner = _currentUser?.isPartner ?? false;
    final studioProfile = _currentUser?.studioProfile;

    if (isPartner && studioProfile != null) {
      // Already a partner - show studio info
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.circleCheck,
                          size: 20,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Studio visible',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            studioProfile.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Les artistes peuvent voir votre studio et vous envoyer des demandes de session.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.studioClaim),
                  icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 14),
                  label: const Text('Modifier'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Not a partner - show claim option
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: InkWell(
          onTap: () async {
            final result = await context.push<bool>(AppRoutes.studioClaim);
            if (result == true) {
              // Reload user data
              _loadUserId();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.eye,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rendez-vous visible',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Les artistes ne peuvent pas encore vous trouver',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 14,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Revendiquez votre studio pour apparaître sur la carte et recevoir des demandes de session.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
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
    if (enable) {
      final granted = await UseMeNotificationService.instance.requestPermissions();
      if (granted) {
        await preferencesService.setNotificationsEnabled(true, userId: _userId);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez autoriser les notifications dans les réglages'),
            ),
          );
        }
      }
    } else {
      await preferencesService.setNotificationsEnabled(false, userId: _userId);
    }
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
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Apparence', style: theme.textTheme.titleLarge),
            ),
            _buildThemeOption(
              ctx,
              icon: FontAwesomeIcons.circleHalfStroke,
              title: 'Système',
              subtitle: 'Suit les réglages de l\'appareil',
              mode: ThemeMode.system,
              isSelected: currentMode == ThemeMode.system,
            ),
            _buildThemeOption(
              ctx,
              icon: FontAwesomeIcons.sun,
              title: 'Clair',
              subtitle: 'Thème lumineux',
              mode: ThemeMode.light,
              isSelected: currentMode == ThemeMode.light,
            ),
            _buildThemeOption(
              ctx,
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
    final theme = Theme.of(this.context);

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
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: isSelected
          ? FaIcon(
              FontAwesomeIcons.circleCheck,
              size: 20,
              color: theme.colorScheme.primary,
            )
          : null,
      onTap: () {
        this.context.read<ThemeBloc>().add(ChangeThemeEvent(themeMode: mode));
        Navigator.pop(context);
      },
    );
  }
}
