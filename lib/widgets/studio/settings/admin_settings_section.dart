import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';
import 'package:useme/widgets/common/settings/settings_exports.dart';

/// Section admin (SuperAdmin + DevMaster)
class AdminSettingsSection extends StatelessWidget {
  final AppUser? currentUser;

  const AdminSettingsSection({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSuperAdmin = currentUser?.isSuperAdmin == true;
    final isDevMaster = currentUser?.hasDevMasterAccess == true;

    if (!isSuperAdmin && !isDevMaster) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Super Admin section
        if (isSuperAdmin) ...[
          const Divider(height: 32),
          const SettingsSectionHeader(title: 'Administration'),
          SettingsTile(
            icon: FontAwesomeIcons.buildingCircleCheck,
            title: l10n.studioClaims,
            subtitle: l10n.studioClaimsSubtitle,
            onTap: () => context.push(AppRoutes.studioClaims),
          ),
          SettingsTile(
            icon: FontAwesomeIcons.tags,
            title: 'Abonnements',
            subtitle: 'Configurer les tiers et limites',
            onTap: () => context.push('/admin/subscription-tiers'),
          ),
          SettingsTile(
            icon: FontAwesomeIcons.mobile,
            title: 'Screenshots Store',
            subtitle: 'Générer les captures App Store',
            onTap: () => context.push(AppRoutes.storeScreenshots),
          ),
        ],

        // DevMaster section
        if (isDevMaster) ...[
          const Divider(height: 32),
          const SettingsSectionHeader(title: 'DevMaster'),
          SettingsTile(
            icon: FontAwesomeIcons.stripe,
            title: 'Configuration Stripe',
            subtitle: 'Clés API et Price IDs',
            onTap: () => context.push('/admin/stripe-config'),
          ),
        ],
      ],
    );
  }
}
