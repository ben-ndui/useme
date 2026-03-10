import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useme/core/models/subscription_tier_config.dart';
import 'package:useme/config/responsive_config.dart';
import 'package:useme/core/services/iap_service.dart';
import 'package:useme/core/services/stripe_service.dart';
import 'package:useme/core/services/subscription_config_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/screens/shared/upgrade_screen_actions.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';
import 'package:useme/widgets/studio/upgrade/period_button.dart';
import 'package:useme/widgets/studio/upgrade/tier_pricing_card.dart';
import 'package:useme/core/utils/app_logger.dart';

/// Subscription plans screen for studios.
/// Uses IAP on iOS and Stripe on Android.
class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen>
    with UpgradeScreenActions {
  final SubscriptionConfigService _configService = SubscriptionConfigService();

  @override
  final StripeSubscriptionService stripeService = StripeSubscriptionService();
  @override
  final UseMeIAPService iapService = UseMeIAPService();

  bool _showYearly = false;
  bool _isLoading = false;

  @override
  bool get showYearly => _showYearly;

  @override
  Map<String, ProductDetails> iapProducts = {};

  @override
  void setLoading(bool value) => setState(() => _isLoading = value);

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    setLoading(true);

    try {
      final userId = getCurrentUserId();
      if (userId != null) {
        iapService.setCurrentUser(userId);
      }

      // Set callbacks BEFORE initialize so pending purchases are caught
      iapService.onPurchaseCompleted = _onIAPPurchaseCompleted;
      iapService.onPurchaseError = _onIAPPurchaseError;

      await iapService.initialize();

      final products = await iapService.getSubscriptions();

      final productMap = <String, ProductDetails>{};
      for (final product in products) {
        productMap[product.id] = product;
      }

      if (mounted) {
        setState(() {
          iapProducts = productMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      appLog('IAP init error: $e');
      if (mounted) setLoading(false);
    }
  }

  void _onIAPPurchaseCompleted(IAPPurchaseResult result) {
    if (!mounted) return;
    setLoading(false);

    if (result.success) {
      final l10n = AppLocalizations.of(context)!;
      final message = result.isRestored
          ? l10n.subscriptionRestored
          : l10n.subscriptionActivated;
      AppSnackBar.success(context, message);
    }
  }

  void _onIAPPurchaseError(String error) {
    if (!mounted) return;
    setLoading(false);
    AppSnackBar.error(context, error);
  }

  @override
  void dispose() {
    // Don't dispose the singleton IAP service — it must keep listening
    // to the purchase stream across the app lifecycle.
    // Only clear the callbacks to avoid calling setState on a dead widget.
    iapService.onPurchaseCompleted = null;
    iapService.onPurchaseError = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseSubscription),
        centerTitle: true,
        actions: [
          if (Platform.isIOS)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowRotateLeft, size: 18),
              tooltip: l10n.restorePurchases,
              onPressed: _isLoading ? null : restorePurchases,
            ),
          if (hasActiveSubscription())
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.gear, size: 18),
              tooltip: l10n.manageSubscription,
              onPressed: _isLoading ? null : openSubscriptionSettings,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: _buildBody(theme, l10n),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    return Stack(
      children: [
        StreamBuilder<List<SubscriptionTierConfig>>(
          stream: _configService.streamTiers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoader();
            }

            final tiers =
                (snapshot.data ?? []).where((t) => t.isActive).toList();

            if (tiers.isEmpty) {
              return Center(child: Text(l10n.noSubscriptionAvailable));
            }

            return Column(
              children: [
                _buildPeriodToggle(l10n),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tiers.length,
                    itemBuilder: (ctx, i) => TierPricingCard(
                      tier: tiers[i],
                      isYearly: _showYearly,
                      isCurrentTier: isCurrentTier(tiers[i].id),
                      isRecommended: tiers[i].id == 'pro',
                      iapPrice: getIAPPrice(tiers[i].id),
                      onSelect:
                          _isLoading ? null : () => selectTier(tiers[i]),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const AppLoader(),
          ),
      ],
    );
  }

  Widget _buildPeriodToggle(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: PeriodButton(
                label: l10n.monthly,
                isSelected: !_showYearly,
                onTap: _isLoading
                    ? null
                    : () => setState(() => _showYearly = false),
              ),
            ),
            Expanded(
              child: PeriodButton(
                label: l10n.yearly,
                subtitle: l10n.twoMonthsFree,
                isSelected: _showYearly,
                onTap: _isLoading
                    ? null
                    : () => setState(() => _showYearly = true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
