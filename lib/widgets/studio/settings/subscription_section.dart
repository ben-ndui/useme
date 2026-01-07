import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/subscription_tier_config.dart';
import 'package:useme/core/services/subscription_config_service.dart';
import 'package:useme/l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tierId = widget.user?.subscriptionTierId ?? 'free';
    final tierStyle = _getTierStyle(tierId);

    // Utiliser la config Firestore ou les valeurs par défaut
    final config = _tierConfig ?? _getDefaultConfig(tierId);

    final content = Container(
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
          // Header with badge
          Row(
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
          ),

          // Usage stats (for limited tiers)
          if (!config.isUnlimited(config.maxSessions)) ...[
            const SizedBox(height: 16),
            _buildUsageBar(
              context,
              label: 'Sessions ce mois',
              current: widget.user?.sessionsThisMonth ?? 0,
              max: config.maxSessions,
              color: tierStyle.color,
            ),
          ],

          // Upgrade button for non-enterprise
          if (tierId != 'enterprise') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/upgrade'),
                icon: const FaIcon(FontAwesomeIcons.arrowUp, size: 14),
                label: Text(_getUpgradeLabel(tierId)),
                style: FilledButton.styleFrom(
                  backgroundColor: tierStyle.color,
                ),
              ),
            ),
          ],

          // Manage button for paid tiers
          if (tierId != 'free') ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/upgrade'),
                icon: const FaIcon(FontAwesomeIcons.gear, size: 14),
                label: const Text('Gérer mon abonnement'),
              ),
            ),
          ],
        ],
      ),
    );

    if (!widget.showComingSoonOverlay) return content;

    return Stack(
      children: [
        content,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.clockRotateLeft,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.comingSoon,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageBar(
    BuildContext context, {
    required String label,
    required int current,
    required int max,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final percentage = (current / max).clamp(0.0, 1.0);
    final isNearLimit = percentage >= 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(
              '$current / $max',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isNearLimit ? Colors.orange : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              isNearLimit ? Colors.orange : color,
            ),
          ),
        ),
      ],
    );
  }

  String _getUpgradeLabel(String tierId) {
    return tierId == 'free' ? 'Passer à Pro' : 'Passer à Enterprise';
  }

  SubscriptionTierConfig _getDefaultConfig(String tierId) {
    return switch (tierId) {
      'pro' => SubscriptionTierConfig.defaultPro,
      'enterprise' => SubscriptionTierConfig.defaultEnterprise,
      _ => SubscriptionTierConfig.defaultFree,
    };
  }

  _TierStyle _getTierStyle(String tierId) {
    return switch (tierId) {
      'pro' => _TierStyle(icon: FontAwesomeIcons.gem, color: Colors.blue),
      'enterprise' => _TierStyle(icon: FontAwesomeIcons.crown, color: Colors.purple),
      _ => _TierStyle(icon: FontAwesomeIcons.star, color: Colors.grey),
    };
  }
}

class _TierStyle {
  final IconData icon;
  final Color color;

  _TierStyle({required this.icon, required this.color});
}
