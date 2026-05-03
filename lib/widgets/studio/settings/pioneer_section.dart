import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/pioneer_status.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/common/badges/pioneer_badge.dart';

/// Settings section for Pioneer users showing badge and benefits status.
class PioneerSection extends StatelessWidget {
  final AppUser? user;

  const PioneerSection({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final pioneer = user?.pioneer;
    if (pioneer == null || !pioneer.isPioneer) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const gold = Color(0xFFFFD700);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gold.withValues(alpha: 0.15),
            gold.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, pioneer),
          const SizedBox(height: 16),
          _buildBenefits(theme, l10n, pioneer),
          if (pioneer.daysUntilBenefitsExpire > 0) ...[
            const SizedBox(height: 12),
            _buildCountdown(theme, l10n, pioneer),
          ],
          if (pioneer.daysUntilBenefitsExpire == 0) ...[
            const SizedBox(height: 12),
            _buildExpiredNotice(theme, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, PioneerStatus pioneer) {
    return Row(
      children: [
        PioneerBadge(pioneerNumber: pioneer.pioneerNumber),
        const Spacer(),
        if (pioneer.pioneerSince != null)
          Text(
            _formatDate(pioneer.pioneerSince!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildBenefits(
    ThemeData theme,
    AppLocalizations l10n,
    PioneerStatus pioneer,
  ) {
    return Column(
      children: [
        _benefitRow(
          theme,
          icon: FontAwesomeIcons.gem,
          label: l10n.pioneerFreeSubscription,
          active: pioneer.isFreeSubscriptionActive,
        ),
        const SizedBox(height: 8),
        _benefitRow(
          theme,
          icon: FontAwesomeIcons.percent,
          label: l10n.pioneerNoCommission,
          active: pioneer.isCommissionExempt,
        ),
        const SizedBox(height: 8),
        _benefitRow(
          theme,
          icon: FontAwesomeIcons.crown,
          label: l10n.pioneerBadgePermanent,
          active: true,
        ),
      ],
    );
  }

  Widget _benefitRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required bool active,
  }) {
    const gold = Color(0xFFFFD700);
    return Row(
      children: [
        FaIcon(
          active
              ? FontAwesomeIcons.solidCircleCheck
              : FontAwesomeIcons.solidCircleXmark,
          size: 14,
          color: active ? gold : theme.colorScheme.outline,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: active
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdown(
    ThemeData theme,
    AppLocalizations l10n,
    PioneerStatus pioneer,
  ) {
    final days = pioneer.daysUntilBenefitsExpire;
    const gold = Color(0xFFFFD700);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.clock, size: 13, color: gold),
              const SizedBox(width: 8),
              Text(
                l10n.pioneerDaysRemaining(days.toString()),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiredNotice(ThemeData theme, AppLocalizations l10n) {
    return Text(
      l10n.pioneerNormalRates,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
