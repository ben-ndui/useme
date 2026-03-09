import 'package:flutter/material.dart';

import 'package:useme/core/models/subscription_tier_config.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/studio/upgrade/tier_features_list.dart';

/// Card displaying a subscription tier with its pricing, features, and CTA.
class TierPricingCard extends StatelessWidget {
  final SubscriptionTierConfig tier;
  final bool isYearly;
  final bool isCurrentTier;
  final bool isRecommended;
  final String? iapPrice;
  final VoidCallback? onSelect;

  const TierPricingCard({
    super.key,
    required this.tier,
    required this.isYearly,
    required this.isCurrentTier,
    required this.isRecommended,
    this.iapPrice,
    this.onSelect,
  });

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

    // Use IAP price if available (iOS), otherwise Firestore price
    final firestorePrice = isYearly ? tier.priceYearly : tier.priceMonthly;
    final displayPrice = iapPrice ?? '${firestorePrice.toStringAsFixed(0)}\u20AC';
    final monthlyEquivalent = isYearly ? (tier.priceYearly / 12) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended
              ? color
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Recommended badge
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Text(
                l10n.recommended,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(theme, l10n),
                const SizedBox(height: 4),
                Text(
                  tier.description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 16),

                // Price
                _buildPrice(theme, l10n, displayPrice, monthlyEquivalent),
                const SizedBox(height: 20),

                // Features
                TierFeaturesList(tier: tier),
                const SizedBox(height: 20),

                // CTA Button
                _buildCTA(l10n, color),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Text(
          tier.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (isCurrentTier)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.currentPlan,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: Colors.green),
            ),
          ),
      ],
    );
  }

  Widget _buildPrice(
    ThemeData theme,
    AppLocalizations l10n,
    String displayPrice,
    double? monthlyEquivalent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          tier.isFree ? l10n.free : displayPrice,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (!tier.isFree && iapPrice == null) ...[
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              isYearly ? l10n.perYear : l10n.perMonth,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        ],
        if (monthlyEquivalent != null && iapPrice == null) ...[
          const Spacer(),
          Text(
            l10n.pricePerMonth(monthlyEquivalent.toStringAsFixed(0)),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ],
    );
  }

  Widget _buildCTA(AppLocalizations l10n, Color color) {
    return SizedBox(
      width: double.infinity,
      child: isCurrentTier
          ? OutlinedButton(
              onPressed: null,
              child: Text(l10n.currentPlanButton),
            )
          : FilledButton(
              onPressed: onSelect,
              style: FilledButton.styleFrom(
                backgroundColor: color,
              ),
              child: Text(tier.isFree
                  ? l10n.switchToFree
                  : l10n.choosePlan(tier.name)),
            ),
    );
  }
}
