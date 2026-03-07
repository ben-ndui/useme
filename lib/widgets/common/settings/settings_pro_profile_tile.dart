import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';

/// Tile dans les settings pour accéder au profil pro.
class SettingsProProfileTile extends StatelessWidget {
  const SettingsProProfileTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticatedState) return const SizedBox.shrink();

        final user = state.user as AppUser;
        final hasPro = user.hasProProfile;

        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasPro
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                hasPro
                    ? FontAwesomeIcons.briefcase
                    : FontAwesomeIcons.briefcase,
                size: 18,
                color: hasPro
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          title: Text(l10n.proProfileTitle),
          subtitle: Text(
            hasPro ? l10n.proProfileManage : l10n.proProfileActivateDesc,
            style: theme.textTheme.bodySmall,
          ),
          trailing: hasPro
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: user.isPro
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.isPro ? l10n.proProfileActive : l10n.proProfileInactive,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: user.isPro ? Colors.green : Colors.orange,
                    ),
                  ),
                )
              : const Icon(Icons.chevron_right),
          onTap: () => context.push(AppRoutes.proProfileSetup),
        );
      },
    );
  }
}
