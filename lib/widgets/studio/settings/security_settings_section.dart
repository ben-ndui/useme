import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/settings/settings_exports.dart';

/// Section sécurité dans les réglages.
class SecuritySettingsSection extends StatelessWidget {
  const SecuritySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(title: l10n.securitySection),
        SettingsTile(
          icon: FontAwesomeIcons.mobileScreen,
          title: l10n.connectedDevices,
          subtitle: l10n.manageDevices,
          onTap: () => context.push(AppRoutes.connectedDevices),
        ),
      ],
    );
  }
}
