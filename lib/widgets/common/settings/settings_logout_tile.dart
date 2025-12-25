import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/services/notification_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';

/// A logout tile for settings pages with confirmation dialog
class SettingsLogoutTile extends StatelessWidget {
  const SettingsLogoutTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.rightFromBracket, size: 18, color: Colors.red),
        ),
      ),
      title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
      onTap: () => _showLogoutDialog(context, l10n),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    final authBloc = context.read<AuthBloc>();
    final sessionBloc = context.read<SessionBloc>();
    final artistBloc = context.read<ArtistBloc>();
    final serviceBloc = context.read<ServiceBloc>();
    final messagingBloc = context.read<MessagingBloc>();
    final favoriteBloc = context.read<FavoriteBloc>();
    final router = GoRouter.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await UseMeNotificationService.instance.removeToken();

              sessionBloc.add(const ClearSessionsEvent());
              artistBloc.add(const ClearArtistsEvent());
              serviceBloc.add(const ClearServicesEvent());
              messagingBloc.add(const ClearMessagingEvent());
              favoriteBloc.add(const ClearFavoritesEvent());

              authBloc.add(const SignOutEvent());
              router.go(AppRoutes.login);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
