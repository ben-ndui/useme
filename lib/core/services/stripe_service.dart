// Re-export les types du package pour simplifier les imports
export 'package:smoothandesign_package/smoothandesign.dart'
    show
        SubscriptionCheckoutResult,
        CancelSubscriptionResult,
        PaymentIntentResult,
        StripeServiceConfig,
        BaseStripeService;

import 'package:smoothandesign_package/smoothandesign.dart';

/// Configuration Stripe pour Use Me
const _useMeStripeConfig = StripeServiceConfig(
  apiBaseUrl: 'https://us-central1-smoothandesign.cloudfunctions.net/api',
  appName: 'useme',
  configDocPath: 'app_config/stripe',
);

/// Service Stripe spécifique à Use Me
/// Utilise BaseStripeService du package avec la config Use Me
class StripeSubscriptionService extends BaseStripeService {
  static final StripeSubscriptionService _instance =
      StripeSubscriptionService._internal();

  factory StripeSubscriptionService() => _instance;

  StripeSubscriptionService._internal() : super(config: _useMeStripeConfig);
}
