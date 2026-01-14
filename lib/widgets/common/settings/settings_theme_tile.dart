import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:smoothandesign_package/core/widgets/settings/settings_tile.dart';

/// A theme selector tile for settings pages
class SettingsThemeTile extends StatelessWidget {
  const SettingsThemeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return SettingsTile(
          icon: FontAwesomeIcons.palette,
          title: l10n.appearance,
          subtitle: _getThemeLabel(l10n, state.themeMode),
          onTap: () => _showThemeSelector(context, l10n),
        );
      },
    );
  }

  String _getThemeLabel(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }

  void _showThemeSelector(BuildContext context, AppLocalizations l10n) {
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
              child: Text(l10n.appearance, style: theme.textTheme.titleLarge),
            ),
            _ThemeOption(
              icon: FontAwesomeIcons.circleHalfStroke,
              title: l10n.themeSystem,
              subtitle: l10n.themeSystemSubtitle,
              mode: ThemeMode.system,
              isSelected: currentMode == ThemeMode.system,
            ),
            _ThemeOption(
              icon: FontAwesomeIcons.sun,
              title: l10n.themeLight,
              subtitle: l10n.themeLightSubtitle,
              mode: ThemeMode.light,
              isSelected: currentMode == ThemeMode.light,
            ),
            _ThemeOption(
              icon: FontAwesomeIcons.moon,
              title: l10n.themeDark,
              subtitle: l10n.themeDarkSubtitle,
              mode: ThemeMode.dark,
              isSelected: currentMode == ThemeMode.dark,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeMode mode;
  final bool isSelected;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
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
        context.read<ThemeBloc>().add(ChangeThemeEvent(themeMode: mode));
        Navigator.pop(context);
      },
    );
  }
}
