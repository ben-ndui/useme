import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/data/ai_guide_data.dart';
import 'package:useme/core/data/tips_data.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/screens/common/ai_guide_screen.dart';
import 'package:useme/screens/common/tips_screen.dart';
import 'package:useme/widgets/common/settings/settings_exports.dart';
import 'package:useme/widgets/studio/settings/security_settings_section.dart';

/// Artist settings page
class ArtistSettingsPage extends StatelessWidget {
  const ArtistSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          SettingsSectionHeader(title: l10n.profile),
          SettingsTile(
            icon: FontAwesomeIcons.user,
            title: l10n.myProfile,
            subtitle: l10n.personalInfo,
            onTap: () => context.push(AppRoutes.profile),
          ),

          const Divider(height: 32),

          SettingsSectionHeader(title: l10n.application),
          const SettingsNotificationTile(),
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
                  title: l10n.artistGuide,
                  sections: TipsData.artistTips(l10n),
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
                  sections: AIGuideData.artistGuide(l10n),
                ),
              ),
            ),
          ),

          const Divider(height: 32),

          const SecuritySettingsSection(),
          const Divider(height: 32),

          SettingsSectionHeader(title: l10n.account),
          SettingsTile(
            icon: FontAwesomeIcons.userGear,
            title: l10n.account,
            subtitle: l10n.emailPassword,
            onTap: () => context.push(AppRoutes.account),
          ),
          SettingsTile(
            icon: FontAwesomeIcons.circleInfo,
            title: l10n.about,
            subtitle: l10n.versionLegal,
            onTap: () => context.push(AppRoutes.about),
          ),
          const SettingsLogoutTile(),

          const SizedBox(height: 32),
          Center(
            child: Text(
              l10n.version('1.0.0'),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
