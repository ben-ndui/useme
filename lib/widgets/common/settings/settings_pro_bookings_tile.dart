import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';

/// Tile in settings to access pro booking requests received.
/// Only visible when the user has an active pro profile.
class SettingsProBookingsTile extends StatelessWidget {
  const SettingsProBookingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticatedState) return const SizedBox.shrink();

        final user = state.user as AppUser;
        if (!user.isPro) return const SizedBox.shrink();

        return BlocBuilder<SessionBloc, SessionState>(
          buildWhen: (prev, curr) => prev.pendingCount != curr.pendingCount,
          builder: (context, sessionState) {
            final pendingCount = sessionState.pendingCount;

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.calendarCheck,
                    size: 18,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
              title: Text(l10n.proBookingsReceived),
              subtitle: Text(
                l10n.proBookingsReceivedDesc,
                style: theme.textTheme.bodySmall,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pendingCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        pendingCount > 99 ? '99+' : '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                // Load pro sessions before navigating
                context.read<SessionBloc>().add(
                      LoadProSessionsEvent(proId: user.uid),
                    );
                context.push(AppRoutes.proBookingsReceived);
              },
            );
          },
        );
      },
    );
  }
}
