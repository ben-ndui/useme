import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/subscription_tier_config.dart';
import 'package:uzme/core/services/iap_service.dart';
import 'package:uzme/core/services/stripe_service.dart';
import 'package:uzme/core/utils/app_logger.dart';
import 'package:uzme/l10n/app_localizations.dart';
import 'package:uzme/widgets/common/snackbar/app_snackbar.dart';

/// Mixin providing subscription purchase and management actions.
mixin UpgradeScreenActions<T extends StatefulWidget> on State<T> {
  StripeSubscriptionService get stripeService;
  UseMeIAPService get iapService;
  Map<String, ProductDetails> get iapProducts;
  bool get showYearly;

  void setLoading(bool value);

  String? getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      return authState.user.uid;
    }
    return null;
  }

  bool isCurrentTier(String tierId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user;
      if (user is AppUser) {
        return user.subscriptionTierId == tierId;
      }
    }
    return tierId == 'free';
  }

  bool hasActiveSubscription() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user;
      if (user is AppUser) {
        return user.hasPaidSubscription;
      }
    }
    return false;
  }

  String? getIAPPrice(String tierId) {
    if (!Platform.isIOS || iapProducts.isEmpty) return null;
    final productId = showYearly
        ? 'com.smoothandesign.useme.$tierId.yearly'
        : 'com.smoothandesign.useme.$tierId.monthly';
    return iapProducts[productId]?.price;
  }

  Future<void> selectTier(SubscriptionTierConfig tier) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      AppSnackBar.error(
          context, AppLocalizations.of(context)!.userNotConnected);
      return;
    }

    if (tier.isFree) {
      await handleDowngradeToFree(userId);
      return;
    }

    if (Platform.isIOS) {
      await handleIOSPurchase(tier);
    } else {
      await handleStripePurchase(userId, tier);
    }
  }

  Future<void> handleDowngradeToFree(String userId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.downgradeToFreeTitle),
        content: Text(
          Platform.isIOS ? l10n.cancelViaAppStore : l10n.downgradeWarning,
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
                openSubscriptionSettings();
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
      setLoading(true);
      final result = await stripeService.cancelSubscription(userId: userId);

      if (mounted) {
        setLoading(false);
        if (result.success) {
          final expiresAt = result.expiresAt;
          final message = expiresAt != null
              ? l10n.subscriptionCancelledOn(
                  '${expiresAt.day}/${expiresAt.month}/${expiresAt.year}')
              : l10n.subscriptionCancelledEndPeriod;
          AppSnackBar.success(context, message);
        } else {
          AppSnackBar.error(
              context, result.error ?? l10n.cancellationError);
        }
      }
    }
  }

  Future<void> handleIOSPurchase(SubscriptionTierConfig tier) async {
    final productId = showYearly
        ? 'com.smoothandesign.useme.${tier.id}.yearly'
        : 'com.smoothandesign.useme.${tier.id}.monthly';

    final product = iapProducts[productId];
    if (product == null) {
      AppSnackBar.error(
          context, AppLocalizations.of(context)!.productNotAvailable);
      return;
    }

    setLoading(true);
    try {
      final started = await iapService.buyProduct(product);
      if (!started && mounted) {
        setLoading(false);
        AppSnackBar.error(
            context, AppLocalizations.of(context)!.productNotAvailable);
      }
    } catch (e) {
      appLog('IAP purchase error: $e');
      if (mounted) {
        setLoading(false);
        AppSnackBar.error(
            context,
            AppLocalizations.of(context)!.purchaseError(e.toString()));
      }
    }
  }

  Future<void> handleStripePurchase(
      String userId, SubscriptionTierConfig tier) async {
    setLoading(true);
    final result = await stripeService.createSubscriptionCheckout(
      userId: userId,
      tierId: tier.id,
      isYearly: showYearly,
    );

    if (mounted) {
      setLoading(false);
      final l10n = AppLocalizations.of(context)!;
      if (result.success) {
        AppSnackBar.info(context, l10n.redirectingToPayment);
      } else {
        AppSnackBar.error(context, result.error ?? l10n.paymentCreationError);
      }
    }
  }

  Future<void> restorePurchases() async {
    if (!Platform.isIOS) return;
    setLoading(true);

    try {
      await iapService.restorePurchases();
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        setLoading(false);
        AppSnackBar.info(
            context, AppLocalizations.of(context)!.restoreCompleted);
      }
    } catch (e) {
      if (mounted) {
        setLoading(false);
        AppSnackBar.error(
            context, AppLocalizations.of(context)!.restoreError);
      }
    }
  }

  Future<void> openSubscriptionSettings() async {
    final userId = getCurrentUserId();

    if (Platform.isIOS) {
      final url = Uri.parse(UseMeIAPService.appleSubscriptionUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else {
      if (userId == null) return;
      setLoading(true);
      final success =
          await stripeService.openCustomerPortal(userId: userId);

      if (mounted) {
        setLoading(false);
        if (!success) {
          AppSnackBar.error(
              context, AppLocalizations.of(context)!.cannotOpenPortal);
        }
      }
    }
  }
}
