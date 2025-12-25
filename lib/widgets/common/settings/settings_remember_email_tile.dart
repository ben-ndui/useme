import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/main.dart';

/// A remember email toggle tile for settings pages
class SettingsRememberEmailTile extends StatelessWidget {
  const SettingsRememberEmailTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: preferencesService,
      builder: (context, _) {
        final isEnabled = preferencesService.rememberEmailEnabled;

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
                FontAwesomeIcons.envelope,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          title: Text(l10n.rememberEmail),
          subtitle: Text(
            isEnabled ? l10n.rememberEmailEnabled : l10n.rememberEmailDisabled,
            style: theme.textTheme.bodySmall,
          ),
          trailing: Switch.adaptive(
            value: isEnabled,
            onChanged: (value) => preferencesService.setRememberEmailEnabled(value),
          ),
        );
      },
    );
  }
}
