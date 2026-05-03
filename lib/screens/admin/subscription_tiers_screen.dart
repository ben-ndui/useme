import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:uzme/config/responsive_config.dart';
import 'package:uzme/core/models/subscription_tier_config.dart';
import 'package:uzme/core/services/subscription_config_service.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/admin/subscription/tier_card.dart';
import 'package:uzme/widgets/admin/subscription/tier_edit_sheet.dart';
import 'package:uzme/widgets/common/app_loader.dart';
import 'package:uzme/widgets/common/snackbar/app_snackbar.dart';

/// Ecran SuperAdmin pour configurer les tiers d'abonnement
class SubscriptionTiersScreen extends StatefulWidget {
  const SubscriptionTiersScreen({super.key});

  @override
  State<SubscriptionTiersScreen> createState() =>
      _SubscriptionTiersScreenState();
}

class _SubscriptionTiersScreenState extends State<SubscriptionTiersScreen> {
  final SubscriptionConfigService _service = SubscriptionConfigService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminSubscriptionConfig),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.creditCard, size: 18),
            tooltip: l10n.adminStripeConfigTooltip,
            onPressed: () => context.push('/admin/stripe-config'),
          ),
        ],
      ),
      body: StreamBuilder<List<SubscriptionTierConfig>>(
        stream: _service.streamTiers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.triangleExclamation,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(l10n.errorWithMessage(snapshot.error.toString())),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() {}),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final tiers = snapshot.data ?? [];

          if (tiers.isEmpty) {
            return _buildInitializeState(context);
          }

          return Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: Responsive.maxContentWidth),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tiers.length,
                itemBuilder: (ctx, i) => TierCard(
                  tier: tiers[i],
                  onEdit: () => _showEditDialog(tiers[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitializeState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.gears,
              size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(l10n.adminNoTierConfigured,
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            l10n.adminInitializeDefaults,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _initializeDefaults,
            child: Text(l10n.adminInitialize),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeDefaults() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      for (final tier in SubscriptionTierConfig.defaultTiers) {
        await _service.createTier(tier);
      }
      if (mounted) {
        AppSnackBar.success(context, l10n.adminTiersInitialized);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, l10n.errorWithMessage(e.toString()));
      }
    }
  }

  Future<void> _showEditDialog(SubscriptionTierConfig tier) async {
    final result = await showModalBottomSheet<SubscriptionTierConfig>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => TierEditSheet(tier: tier),
    );

    if (result != null && mounted) {
      final l10n = AppLocalizations.of(context)!;
      try {
        await _service.updateTier(result);
        if (mounted) {
          AppSnackBar.success(context, l10n.adminTierUpdated(result.name));
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.error(context, l10n.errorWithMessage(e.toString()));
        }
      }
    }
  }
}
