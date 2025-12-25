import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/routing/app_routes.dart';

/// Studio visibility section for settings page
class StudioVisibilitySection extends StatelessWidget {
  final AppUser? currentUser;
  final VoidCallback onUnclaimRequested;
  final VoidCallback onClaimSuccess;

  const StudioVisibilitySection({
    super.key,
    required this.currentUser,
    required this.onUnclaimRequested,
    required this.onClaimSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final isPartner = currentUser?.isPartner ?? false;
    final studioProfile = currentUser?.studioProfile;

    if (isPartner && studioProfile != null) {
      return _buildPartnerCard(context, studioProfile.name);
    }
    return _buildClaimCard(context);
  }

  Widget _buildPartnerCard(BuildContext context, String studioName) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.circleCheck, size: 20, color: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.studioVisible,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          studioName,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.artistsCanSee,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.studioClaim),
                    icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 14),
                    label: Text(l10n.edit),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onUnclaimRequested,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    icon: const FaIcon(FontAwesomeIcons.xmark, size: 14),
                    label: Text(l10n.unclaim),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClaimCard(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: InkWell(
          onTap: () async {
            final result = await context.push<bool>(AppRoutes.studioClaim);
            if (result == true) {
              onClaimSuccess();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: FaIcon(FontAwesomeIcons.eye, size: 20, color: theme.colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.becomeVisible,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            l10n.artistsCantFind,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                    FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: theme.colorScheme.outline),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.claimStudio,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
