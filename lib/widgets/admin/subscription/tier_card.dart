import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/subscription_tier_config.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/admin/subscription/tier_chips.dart';

/// Card pour afficher un tier d'abonnement
class TierCard extends StatelessWidget {
  final SubscriptionTierConfig tier;
  final VoidCallback onEdit;

  const TierCard({super.key, required this.tier, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final color = switch (tier.id) {
      'free' => Colors.grey,
      'pro' => Colors.blue,
      'enterprise' => Colors.purple,
      _ => theme.colorScheme.primary,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, l10n, color),
              const SizedBox(height: 12),
              if (tier.description.isNotEmpty)
                Text(
                  tier.description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              const SizedBox(height: 16),
              _buildLimits(l10n),
              const SizedBox(height: 12),
              _buildFeatures(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tier.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (!tier.isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              l10n.adminDisabled,
              style:
                  theme.textTheme.labelSmall?.copyWith(color: Colors.red),
            ),
          ),
        const Spacer(),
        Text(
          tier.isFree
              ? l10n.free
              : l10n.adminPricePerMonth(
                  tier.priceMonthly.toStringAsFixed(0)),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLimits(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        LimitChip(
          icon: FontAwesomeIcons.calendar,
          label: tier.isUnlimited(tier.maxSessions)
              ? l10n.adminSessionsUnlimited
              : l10n.adminSessionsCount(tier.maxSessions),
        ),
        LimitChip(
          icon: FontAwesomeIcons.doorOpen,
          label: tier.isUnlimited(tier.maxRooms)
              ? l10n.adminRoomsUnlimited
              : l10n.adminRoomsCount(tier.maxRooms),
        ),
        LimitChip(
          icon: FontAwesomeIcons.microphone,
          label: tier.isUnlimited(tier.maxServices)
              ? l10n.adminServicesUnlimited
              : l10n.adminServicesCount(tier.maxServices),
        ),
        LimitChip(
          icon: FontAwesomeIcons.userGroup,
          label: tier.isUnlimited(tier.maxEngineers)
              ? l10n.adminEngineersUnlimited
              : l10n.adminEngineersCount(tier.maxEngineers),
        ),
        LimitChip(
          icon: FontAwesomeIcons.robot,
          label: tier.isUnlimited(tier.aiMessagesPerMonth)
              ? l10n.adminAiUnlimited
              : l10n.adminAiCount(tier.aiMessagesPerMonth),
        ),
      ],
    );
  }

  Widget _buildFeatures(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (tier.hasAIAssistant)
          FeatureChip(
              icon: FontAwesomeIcons.robot,
              label: l10n.adminFeatureAiAssistant),
        if (tier.hasAdvancedAI)
          FeatureChip(
              icon: FontAwesomeIcons.wandMagicSparkles,
              label: l10n.adminFeatureAdvancedAi),
        if (tier.hasDiscoveryVisibility)
          FeatureChip(
              icon: FontAwesomeIcons.eye,
              label: l10n.adminFeatureDiscovery),
        if (tier.hasAnalytics)
          FeatureChip(
              icon: FontAwesomeIcons.chartLine,
              label: l10n.adminFeatureAnalytics),
        if (tier.hasVerifiedBadge)
          FeatureChip(
              icon: FontAwesomeIcons.circleCheck,
              label: l10n.adminFeatureBadge),
        if (tier.hasMultiStudios)
          FeatureChip(
              icon: FontAwesomeIcons.building,
              label: l10n.adminFeatureMultiStudios),
        if (tier.hasApiAccess)
          FeatureChip(
              icon: FontAwesomeIcons.code, label: l10n.adminFeatureApi),
        if (tier.hasPrioritySupport)
          FeatureChip(
              icon: FontAwesomeIcons.headset,
              label: l10n.adminFeaturePrioritySupport),
      ],
    );
  }
}
