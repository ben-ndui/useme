import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/subscription_tier_config.dart';
import 'package:useme/core/services/iap_service.dart';
import 'package:useme/core/services/stripe_service.dart';
import 'package:useme/core/services/subscription_config_service.dart';
import 'package:useme/l10n/app_localizations.dart';
import 'package:useme/widgets/common/app_loader.dart';
import 'package:useme/widgets/common/snackbar/app_snackbar.dart';

/// Écran de présentation des abonnements pour les studios
/// Utilise IAP sur iOS et Stripe sur Android
class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final SubscriptionConfigService _configService = SubscriptionConfigService();
  final StripeSubscriptionService _stripeService = StripeSubscriptionService();
  final UseMeIAPService _iapService = UseMeIAPService();

  bool _showYearly = false;
  bool _isLoading = false;

  // Produits IAP chargés depuis Apple (iOS uniquement)
  Map<String, ProductDetails> _iapProducts = {};

  @override
  void initState() {
    super.initState();
    _initializePaymentServices();
  }

  Future<void> _initializePaymentServices() async {
    if (Platform.isIOS) {
      await _initializeIAP();
    }
  }

  Future<void> _initializeIAP() async {
    setState(() => _isLoading = true);

    try {
      // Définir l'utilisateur courant
      final userId = _getCurrentUserId();
      if (userId != null) {
        _iapService.setCurrentUser(userId);
      }

      // Initialiser le service
      await _iapService.initialize();

      // Configurer les callbacks
      _iapService.onPurchaseCompleted = _onIAPPurchaseCompleted;
      _iapService.onPurchaseError = _onIAPPurchaseError;

      // Charger les produits depuis Apple
      final products = await _iapService.getSubscriptions();
      final productMap = <String, ProductDetails>{};
      for (final product in products) {
        productMap[product.id] = product;
      }

      if (mounted) {
        setState(() {
          _iapProducts = productMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur init IAP: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onIAPPurchaseCompleted(IAPPurchaseResult result) {
    if (!mounted) return;

    setState(() => _isLoading = false);

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

    setState(() => _isLoading = false);
    AppSnackBar.error(context, error);
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      _iapService.dispose();
    }
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
          // Bouton restaurer achats (iOS uniquement)
          if (Platform.isIOS)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowRotateLeft, size: 18),
              tooltip: l10n.restorePurchases,
              onPressed: _isLoading ? null : _restorePurchases,
            ),
          // Bouton pour gérer l'abonnement existant
          if (_hasActiveSubscription())
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.gear, size: 18),
              tooltip: l10n.manageSubscription,
              onPressed: _isLoading ? null : _openSubscriptionSettings,
            ),
        ],
      ),
      body: Stack(
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
                  // Toggle mensuel/annuel
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _PeriodButton(
                              label: l10n.monthly,
                              isSelected: !_showYearly,
                              onTap: _isLoading
                                  ? null
                                  : () => setState(() => _showYearly = false),
                            ),
                          ),
                          Expanded(
                            child: _PeriodButton(
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
                  ),

                  // Tier cards
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tiers.length,
                      itemBuilder: (ctx, i) => _TierPricingCard(
                        tier: tiers[i],
                        isYearly: _showYearly,
                        isCurrentTier: _isCurrentTier(tiers[i].id),
                        isRecommended: tiers[i].id == 'pro',
                        iapPrice: _getIAPPrice(tiers[i].id),
                        onSelect: _isLoading ? null : () => _selectTier(tiers[i]),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const AppLoader(),
            ),
        ],
      ),
    );
  }

  /// Récupère le prix IAP pour un tier (iOS uniquement)
  String? _getIAPPrice(String tierId) {
    if (!Platform.isIOS || _iapProducts.isEmpty) return null;

    final productId = _showYearly
        ? 'com.smoothandesign.useme.$tierId.yearly'
        : 'com.smoothandesign.useme.$tierId.monthly';

    return _iapProducts[productId]?.price;
  }

  bool _isCurrentTier(String tierId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user;
      if (user is AppUser) {
        return user.subscriptionTierId == tierId;
      }
    }
    return tierId == 'free';
  }

  bool _hasActiveSubscription() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user;
      if (user is AppUser) {
        return user.hasPaidSubscription;
      }
    }
    return false;
  }

  String? _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      return authState.user.uid;
    }
    return null;
  }

  Future<void> _selectTier(SubscriptionTierConfig tier) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      AppSnackBar.error(context, AppLocalizations.of(context)!.userNotConnected);
      return;
    }

    if (tier.isFree) {
      await _handleDowngradeToFree(userId);
      return;
    }

    // Upgrade vers Pro ou Enterprise
    if (Platform.isIOS) {
      await _handleIOSPurchase(tier);
    } else {
      await _handleStripePurchase(userId, tier);
    }
  }

  /// Downgrade vers le plan gratuit
  Future<void> _handleDowngradeToFree(String userId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.downgradeToFreeTitle),
        content: Text(
          Platform.isIOS
              ? l10n.cancelViaAppStore
              : l10n.downgradeWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          if (Platform.isIOS)
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx, false);
                _openSubscriptionSettings();
              },
              child: Text(l10n.openAppStore),
            )
          else
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.confirm),
            ),
        ],
      ),
    );

    if (confirmed == true && !Platform.isIOS) {
      setState(() => _isLoading = true);

      final result = await _stripeService.cancelSubscription(userId: userId);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.success) {
          final expiresAt = result.expiresAt;
          final message = expiresAt != null
              ? l10n.subscriptionCancelledOn('${expiresAt.day}/${expiresAt.month}/${expiresAt.year}')
              : l10n.subscriptionCancelledEndPeriod;
          AppSnackBar.success(context, message);
        } else {
          AppSnackBar.error(
              context, result.error ?? l10n.cancellationError);
        }
      }
    }
  }

  /// Achat via Apple In-App Purchase (iOS)
  Future<void> _handleIOSPurchase(SubscriptionTierConfig tier) async {
    final productId = _showYearly
        ? 'com.smoothandesign.useme.${tier.id}.yearly'
        : 'com.smoothandesign.useme.${tier.id}.monthly';

    final product = _iapProducts[productId];

    if (product == null) {
      AppSnackBar.error(context, AppLocalizations.of(context)!.productNotAvailable);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _iapService.buyProduct(product);
      // Le résultat sera géré par les callbacks _onIAPPurchaseCompleted/Error
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.error(context, AppLocalizations.of(context)!.purchaseError(e.toString()));
      }
    }
  }

  /// Achat via Stripe (Android)
  Future<void> _handleStripePurchase(
      String userId, SubscriptionTierConfig tier) async {
    setState(() => _isLoading = true);

    final result = await _stripeService.createSubscriptionCheckout(
      userId: userId,
      tierId: tier.id,
      isYearly: _showYearly,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      final l10n = AppLocalizations.of(context)!;
      if (result.success) {
        AppSnackBar.info(context, l10n.redirectingToPayment);
      } else {
        AppSnackBar.error(
          context,
          result.error ?? l10n.paymentCreationError,
        );
      }
    }
  }

  /// Restaure les achats (iOS uniquement)
  Future<void> _restorePurchases() async {
    if (!Platform.isIOS) return;

    setState(() => _isLoading = true);

    try {
      await _iapService.restorePurchases();
      // Timeout car la restauration peut ne pas déclencher de callback
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.info(context, AppLocalizations.of(context)!.restoreCompleted);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.error(context, AppLocalizations.of(context)!.restoreError);
      }
    }
  }

  /// Ouvre les paramètres d'abonnement
  Future<void> _openSubscriptionSettings() async {
    final userId = _getCurrentUserId();

    if (Platform.isIOS) {
      // iOS: Ouvrir les abonnements App Store
      final url = Uri.parse(UseMeIAPService.appleSubscriptionUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else {
      // Android: Ouvrir le portail Stripe
      if (userId == null) return;

      setState(() => _isLoading = true);

      final success = await _stripeService.openCustomerPortal(userId: userId);

      if (mounted) {
        setState(() => _isLoading = false);

        if (!success) {
          AppSnackBar.error(context, AppLocalizations.of(context)!.cannotOpenPortal);
        }
      }
    }
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PeriodButton({
    required this.label,
    this.subtitle,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                      : Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TierPricingCard extends StatelessWidget {
  final SubscriptionTierConfig tier;
  final bool isYearly;
  final bool isCurrentTier;
  final bool isRecommended;
  final String? iapPrice;
  final VoidCallback? onSelect;

  const _TierPricingCard({
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

    // Utiliser le prix IAP si disponible (iOS), sinon le prix Firestore
    final firestorePrice = isYearly ? tier.priceYearly : tier.priceMonthly;
    final displayPrice = iapPrice ?? '${firestorePrice.toStringAsFixed(0)}€';
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
                Row(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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
                ),
                const SizedBox(height: 4),
                Text(
                  tier.description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 16),

                // Price
                Row(
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
                ),
                const SizedBox(height: 20),

                // Features
                ..._buildFeaturesList(theme, l10n),
                const SizedBox(height: 20),

                // CTA Button
                SizedBox(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeaturesList(ThemeData theme, AppLocalizations l10n) {
    final features = <(IconData, String, bool)>[
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

    return features.map((f) {
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
    }).toList();
  }
}
