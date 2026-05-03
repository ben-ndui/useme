import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/core/models/subscription_tier_config.dart';
import 'package:uzme/l10n/app_localizations.dart';

/// Visual style for a subscription tier
class TierStyle {
  final IconData icon;
  final Color color;

  TierStyle({required this.icon, required this.color});

  static TierStyle forTier(String tierId) {
    return switch (tierId) {
      'pro' => TierStyle(icon: FontAwesomeIcons.gem, color: Colors.blue),
      'enterprise' => TierStyle(icon: FontAwesomeIcons.crown, color: Colors.purple),
      _ => TierStyle(icon: FontAwesomeIcons.star, color: Colors.grey),
    };
  }
}

/// Returns the default tier config for a given tier ID
SubscriptionTierConfig getDefaultTierConfig(String tierId) {
  return switch (tierId) {
    'pro' => SubscriptionTierConfig.defaultPro,
    'enterprise' => SubscriptionTierConfig.defaultEnterprise,
    _ => SubscriptionTierConfig.defaultFree,
  };
}

/// Usage bar showing current/max with progress indicator
class SubscriptionUsageBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;

  const SubscriptionUsageBar({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// Blurred "Coming Soon" overlay for subscription section
class ComingSoonOverlay extends StatelessWidget {
  final Widget child;

  const ComingSoonOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        child,
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
}
