import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/blocs/blocs_exports.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/settings/settings_tile.dart';

/// A language selector tile for settings pages
class SettingsLanguageTile extends StatelessWidget {
  const SettingsLanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        return SettingsTile(
          icon: FontAwesomeIcons.language,
          title: l10n.language,
          subtitle: _getLanguageLabel(l10n, state.locale),
          onTap: () => _showLanguageSelector(context, l10n),
        );
      },
    );
  }

  String _getLanguageLabel(AppLocalizations l10n, Locale? locale) {
    if (locale == null) return l10n.languageSystem;
    switch (locale.languageCode) {
      case 'fr':
        return l10n.languageFrench;
      case 'en':
        return l10n.languageEnglish;
      default:
        return l10n.languageSystem;
    }
  }

  void _showLanguageSelector(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final currentLocale = context.read<LocaleBloc>().state.locale;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.language, style: theme.textTheme.titleLarge),
            ),
            _LanguageOption(
              icon: FontAwesomeIcons.globe,
              title: l10n.languageSystem,
              subtitle: l10n.languageSystemSubtitle,
              locale: null,
              isSelected: currentLocale == null,
            ),
            _LanguageOption(
              icon: FontAwesomeIcons.language,
              title: l10n.languageFrench,
              subtitle: 'French',
              locale: const Locale('fr'),
              isSelected: currentLocale?.languageCode == 'fr',
            ),
            _LanguageOption(
              icon: FontAwesomeIcons.language,
              title: l10n.languageEnglish,
              subtitle: 'Anglais',
              locale: const Locale('en'),
              isSelected: currentLocale?.languageCode == 'en',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Locale? locale;
  final bool isSelected;

  const _LanguageOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.locale,
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
        context.read<LocaleBloc>().add(ChangeLocaleEvent(locale: locale));
        Navigator.pop(context);
      },
    );
  }
}
