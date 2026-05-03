import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:uzme/core/models/subscription_tier_config.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Displays the list of features for a subscription tier.
///
/// Each feature shows an icon (green check or grey X) and a label,
/// with disabled features shown with a line-through style.
class TierFeaturesList extends StatelessWidget {
  final SubscriptionTierConfig tier;

  const TierFeaturesList({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final features = _getFeatures(l10n);

    return Column(
      children: features.map((f) {
        final (icon, label, enabled) = f;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              FaIcon(
                enabled ? icon : FontAwesomeIcons.xmark,
                size: 14,
                color: enabled ? Colors.green : theme.colorScheme.outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: enabled ? null : theme.colorScheme.outline,
                    decoration: enabled ? null : TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<(IconData, String, bool)> _getFeatures(AppLocalizations l10n) {
    return [
      (
        FontAwesomeIcons.calendar,
        tier.isUnlimited(tier.maxSessions)
            ? l10n.unlimitedSessions
            : l10n.sessionsPerMonth(tier.maxSessions),
        true
      ),
      (
        FontAwesomeIcons.doorOpen,
        tier.isUnlimited(tier.maxRooms)
            ? l10n.unlimitedRooms
            : l10n.roomsCount(tier.maxRooms),
        true
      ),
      (
        FontAwesomeIcons.microphone,
        tier.isUnlimited(tier.maxServices)
            ? l10n.unlimitedServices
            : l10n.servicesCount(tier.maxServices),
        true
      ),
      (
        FontAwesomeIcons.robot,
        tier.isUnlimited(tier.aiMessagesPerMonth)
            ? l10n.unlimitedAI
            : l10n.aiMessagesPerMonth(tier.aiMessagesPerMonth),
        tier.hasAIAssistant
      ),
      (FontAwesomeIcons.wandMagicSparkles, l10n.advancedAI, tier.hasAdvancedAI),
      (FontAwesomeIcons.eye, l10n.discoveryVisibility, tier.hasDiscoveryVisibility),
      (FontAwesomeIcons.chartLine, 'Analytics', tier.hasAnalytics),
      (FontAwesomeIcons.circleCheck, l10n.verifiedBadge, tier.hasVerifiedBadge),
      (FontAwesomeIcons.building, 'Multi-studios', tier.hasMultiStudios),
      (FontAwesomeIcons.code, l10n.apiAccess, tier.hasApiAccess),
      (FontAwesomeIcons.headset, l10n.prioritySupport, tier.hasPrioritySupport),
    ];
  }
}
