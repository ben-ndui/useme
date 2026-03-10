import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/subscription_tier_config.dart';
import 'package:useme/core/services/subscription_config_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/studio/settings/subscription_widgets.dart';

/// Section affichant les informations d'abonnement dans les settings
/// Récupère les configs depuis Firestore
class SubscriptionSection extends StatefulWidget {
  final AppUser? user;
  final bool showComingSoonOverlay;

  const SubscriptionSection({
    super.key,
    this.user,
    this.showComingSoonOverlay = true,
  });

  @override
  State<SubscriptionSection> createState() => _SubscriptionSectionState();
}

class _SubscriptionSectionState extends State<SubscriptionSection> {
  final SubscriptionConfigService _service = SubscriptionConfigService();
  SubscriptionTierConfig? _tierConfig;

  @override
  void initState() {
    super.initState();
    _loadTierConfig();
  }

  @override
  void didUpdateWidget(SubscriptionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.subscriptionTierId != widget.user?.subscriptionTierId) {
      _loadTierConfig();
    }
  }

  Future<void> _loadTierConfig() async {
    final tierId = widget.user?.subscriptionTierId ?? 'free';
    final config = await _service.getTier(tierId);
    if (mounted) {
      setState(() => _tierConfig = config);
    }
  }

  bool get _isApplePlatform =>
      !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tierId = widget.user?.subscriptionTierId ?? 'free';
    final tierStyle = TierStyle.forTier(tierId);
    final config = _tierConfig ?? getDefaultTierConfig(tierId);

    final content = _buildContent(theme, l10n, tierStyle, config);

    if (!widget.showComingSoonOverlay) return content;
    return ComingSoonOverlay(child: content);
  }

  Widget _buildContent(
    ThemeData theme,
    AppLocalizations l10n,
    TierStyle tierStyle,
    SubscriptionTierConfig config,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tierStyle.color.withValues(alpha: 0.15),
            tierStyle.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tierStyle.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, tierStyle, config),
          if (!config.isUnlimited(config.maxSessions)) ...[
            const SizedBox(height: 16),
            SubscriptionUsageBar(
              label: 'Sessions ce mois',
              current: widget.user?.sessionsThisMonth ?? 0,
              max: config.maxSessions,
              color: tierStyle.color,
            ),
          ],
          const SizedBox(height: 16),
          _buildActionButton(l10n, tierStyle),
        ],
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    TierStyle tierStyle,
    SubscriptionTierConfig config,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tierStyle.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(tierStyle.icon, size: 20, color: tierStyle.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan ${config.name}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                config.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(AppLocalizations l10n, TierStyle tierStyle) {
    return SizedBox(
      width: double.infinity,
      child: _isApplePlatform
          ? FilledButton.icon(
              onPressed: () => context.push('/upgrade'),
              icon: const FaIcon(FontAwesomeIcons.gem, size: 14),
              label: Text(l10n.viewPlans),
              style: FilledButton.styleFrom(
                backgroundColor: tierStyle.color,
              ),
            )
          : FilledButton.icon(
              onPressed: () => launchUrl(
                Uri.parse('https://uzme.app/admin/subscription'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const FaIcon(
                FontAwesomeIcons.arrowUpRightFromSquare,
                size: 14,
              ),
              label: Text(l10n.manageSubscription),
              style: FilledButton.styleFrom(
                backgroundColor: tierStyle.color,
              ),
            ),
    );
  }

}
