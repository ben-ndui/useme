import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoothandesign_package/smoothandesign.dart';

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
  consumableProductIds: [], // Pas de consommables pour Use Me
);

/// Service IAP spécifique à Use Me
/// Gère les abonnements via Apple In-App Purchase (iOS uniquement)
class UseMeIAPService extends BaseIAPService {
  static final UseMeIAPService _instance = UseMeIAPService._internal();

  factory UseMeIAPService() => _instance;

  UseMeIAPService._internal() : super(config: _useMeIAPConfig);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  Future<void> deliverProduct(PurchaseDetails purchase) async {
    final tierId = getTierIdFromProduct(purchase.productID);
    if (tierId == null) {
      throw Exception('Tier inconnu pour le produit: ${purchase.productID}');
    }

    // Récupérer l'utilisateur courant
    // Note: L'userId doit être passé au service ou récupéré autrement
    // Pour l'instant on utilise les metadata du purchase si disponibles
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    // Mettre à jour l'abonnement dans Firestore
    await _firestore.collection('users').doc(userId).update({
      'subscription': {
        'tierId': tierId,
        'startedAt': FieldValue.serverTimestamp(),
        'expiresAt': null, // Géré par Apple
        'appleProductId': purchase.productID,
        'appleTransactionId': purchase.purchaseID,
        'purchaseSource': 'apple_iap',
        'sessionsThisMonth': 0,
        'sessionsResetAt': FieldValue.serverTimestamp(),
      },
    });
  }

  /// UserId courant (à définir avant les achats)
  String? _currentUserId;

  /// Définit l'utilisateur courant pour les achats
  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  /// Vérifie si l'utilisateur a un abonnement actif via Apple
  Future<bool> hasActiveAppleSubscription(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
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
