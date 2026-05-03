import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/card/digital_card_sheet.dart';

/// Settings tile to access the holographic digital business card.
class SettingsDigitalCardTile extends StatelessWidget {
  const SettingsDigitalCardTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.idCard, size: 18, color: Colors.white),
        ),
      ),
      title: Text(l10n.myCard),
      subtitle: Text(
        l10n.tiltToExplore,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: FaIcon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () => DigitalCardSheet.show(context),
    );
  }
}
