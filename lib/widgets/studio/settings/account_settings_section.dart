import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/settings/settings_exports.dart';

/// Section compte utilisateur
class AccountSettingsSection extends StatelessWidget {
  const AccountSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
