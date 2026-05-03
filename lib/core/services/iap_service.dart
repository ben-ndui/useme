import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'package:uzme/core/utils/app_logger.dart';

// Re-export les types du package pour simplifier les imports
export 'package:smoothandesign_package/smoothandesign.dart'
    show
        IAPServiceConfig,
        IAPPurchaseResult,
        BaseIAPService,
        ProductDetails,
        PurchaseDetails,
        PurchaseStatus;

/// Configuration IAP pour Use Me
const _useMeIAPConfig = IAPServiceConfig(
  appBundleId: 'com.smoothandesign.useme',
  subscriptionProductIds: [
    'com.smoothandesign.useme.pro.monthly',
    'com.smoothandesign.useme.pro.yearly',
    'com.smoothandesign.useme.enterprise.monthly',
    'com.smoothandesign.useme.enterprise.yearly',
  ],
  consumableProductIds: [],
);

/// Service IAP spécifique à Use Me
/// Gère les abonnements via Apple In-App Purchase (iOS uniquement)
class UseMeIAPService extends BaseIAPService {
  static final UseMeIAPService _instance = UseMeIAPService._internal();

  factory UseMeIAPService() => _instance;

  UseMeIAPService._internal() : super(config: _useMeIAPConfig);

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Product IDs par tier
  static const Map<String, List<String>> tierProductIds = {
    'pro': [
      'com.smoothandesign.useme.pro.monthly',
      'com.smoothandesign.useme.pro.yearly',
    ],
    'enterprise': [
      'com.smoothandesign.useme.enterprise.monthly',
      'com.smoothandesign.useme.enterprise.yearly',
    ],
  };

  /// Récupère le tier ID depuis un product ID
  static String? getTierIdFromProduct(String productId) {
    if (productId.contains('.pro.')) return 'pro';
    if (productId.contains('.enterprise.')) return 'enterprise';
    return null;
  }

  /// Vérifie si c'est un abonnement annuel
  static bool isYearlyProduct(String productId) {
    return productId.endsWith('.yearly');
  }

  /// Récupère les produits pour un tier spécifique
  Future<List<ProductDetails>> getProductsForTier(String tierId) async {
    final productIds = tierProductIds[tierId];
    if (productIds == null) return [];
    return await getProducts(productIds);
  }

  @override
  Future<bool> verifyPurchase(PurchaseDetails purchase) async {
    if (_currentUserId == null) return false;

    try {
      final callable = _functions.httpsCallable('verifyAppleReceipt');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': _currentUserId,
        'productId': purchase.productID,
        'transactionId': purchase.purchaseID,
        'receiptData': purchase.verificationData.serverVerificationData,
      });

      final success = result.data['success'] == true;
      if (success) {
        appLog('IAP receipt verified for $_currentUserId');
      }
      return success;
    } catch (e) {
      appLog('IAP receipt verification error: $e');
      // Cloud Function handled the Firestore update — if it fails,
      // don't deliver locally to avoid double-write
      return false;
    }
  }

  @override
  Future<void> deliverProduct(PurchaseDetails purchase) async {
    // The Cloud Function in verifyPurchase already wrote the subscription
    // to Firestore. This method is called after verify returns true.
    // We only log here — no duplicate Firestore write needed.
    final tierId = getTierIdFromProduct(purchase.productID);
    appLog('IAP product delivered: $tierId for $_currentUserId');
  }

  /// UserId courant (à définir avant les achats)
  String? _currentUserId;

  /// Définit l'utilisateur courant pour les achats
  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  /// Vérifie si l'utilisateur a un abonnement actif via Apple
  Future<bool> hasActiveAppleSubscription(String userId) async {
    final db = FirebaseFirestore.instance;
    final userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;

    final data = userDoc.data();
    final subscription = data?['subscription'] as Map<String, dynamic>?;
    if (subscription == null) return false;

    return subscription['purchaseSource'] == 'apple_iap' &&
        subscription['tierId'] != 'free';
  }

  /// URL pour gérer les abonnements Apple
  static const appleSubscriptionUrl =
      'https://apps.apple.com/account/subscriptions';
}

/// Extension pour faciliter l'accès au service
extension IAPServiceExtension on BaseIAPService {
  /// Cast vers UseMeIAPService
  UseMeIAPService get asUseMe => this as UseMeIAPService;
}
