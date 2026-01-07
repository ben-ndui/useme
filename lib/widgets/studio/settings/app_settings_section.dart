import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/data/ai_guide_data.dart';
import 'package:useme/core/data/tips_data.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/screens/common/ai_guide_screen.dart';
import 'package:useme/screens/common/tips_screen.dart';
import 'package:useme/widgets/common/settings/settings_exports.dart';

/// Section des paramètres de l'application
class AppSettingsSection extends StatelessWidget {
  final String? userId;

  const AppSettingsSection({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: l10n.application),
        SettingsNotificationTile(userId: userId),
        const SettingsRememberEmailTile(),
        const SettingsThemeTile(),
        const SettingsLanguageTile(),
        SettingsTile(
          icon: FontAwesomeIcons.lightbulb,
          title: l10n.userGuide,
          subtitle: l10n.tipsAndAdvice,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TipsScreen(
                title: l10n.studioGuide,
                sections: TipsData.studioTips(l10n),
              ),
            ),
          ),
        ),
        SettingsTile(
          icon: FontAwesomeIcons.robot,
          title: l10n.aiGuideSettingsLink,
          subtitle: l10n.aiGuideHeaderSubtitle,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AIGuideScreen(
                sections: AIGuideData.studioGuide(l10n),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
