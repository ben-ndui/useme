import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Configuration Stripe de l'application (DevMaster only)
/// Stocké dans Firestore: collection 'app_config' doc 'stripe'
/// Les clés sensibles sont cryptées AES-256 avant stockage
class StripeConfig extends Equatable {
  /// Clé publique Stripe (pk_live_xxx ou pk_test_xxx)
  /// Non cryptée car c'est une clé publique
  final String publishableKey;

  /// Clé secrète Stripe (sk_live_xxx ou sk_test_xxx)
  /// CRYPTÉE AES-256 avant stockage
  final String encryptedSecretKey;

  /// Secret du webhook Stripe (whsec_xxx)
  /// CRYPTÉ AES-256 avant stockage
  final String encryptedWebhookSecret;

  /// Mode live (production) ou test
  final bool isLiveMode;

  /// IDs des prix Stripe pour chaque tier
  /// Ex: { 'pro_monthly': 'price_xxx', 'pro_yearly': 'price_xxx', ... }
  final Map<String, String> priceIds;

  /// Date de dernière mise à jour
  final DateTime? updatedAt;

  /// ID de l'utilisateur DevMaster qui a fait la dernière mise à jour
  final String? updatedBy;

  const StripeConfig({
    this.publishableKey = '',
    this.encryptedSecretKey = '',
    this.encryptedWebhookSecret = '',
    this.isLiveMode = false,
    this.priceIds = const {},
    this.updatedAt,
    this.updatedBy,
  });

  /// Vérifie si la configuration est complète
  bool get isConfigured =>
      publishableKey.isNotEmpty && encryptedSecretKey.isNotEmpty;

  /// Vérifie si les webhooks sont configurés
  bool get hasWebhook => encryptedWebhookSecret.isNotEmpty;

  /// Vérifie si tous les prix sont configurés
  bool get hasAllPrices =>
      priceIds.containsKey('pro_monthly') &&
      priceIds.containsKey('pro_yearly') &&
      priceIds.containsKey('enterprise_monthly') &&
      priceIds.containsKey('enterprise_yearly');

  /// Récupère l'ID du prix pour un tier et une période
  String? getPriceId(String tierId, {bool yearly = false}) {
    final key = '${tierId}_${yearly ? 'yearly' : 'monthly'}';
    return priceIds[key];
  }

  /// Vérifie si c'est une clé de test
  bool get isTestKey => publishableKey.startsWith('pk_test_');

  /// Vérifie si c'est une clé live
  bool get isLiveKey => publishableKey.startsWith('pk_live_');

  /// Vérifie la cohérence entre le mode et la clé
  bool get isKeyModeConsistent {
    if (publishableKey.isEmpty) return true;
    if (isLiveMode) return isLiveKey;
    return isTestKey;
  }

  factory StripeConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StripeConfig();
    return StripeConfig(
      publishableKey: map['publishableKey'] ?? '',
      encryptedSecretKey: map['encryptedSecretKey'] ?? '',
      encryptedWebhookSecret: map['encryptedWebhookSecret'] ?? '',
      isLiveMode: map['isLiveMode'] ?? false,
      priceIds: Map<String, String>.from(map['priceIds'] ?? {}),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      updatedBy: map['updatedBy'],
    );
  }

  Map<String, dynamic> toMap() => {
        'publishableKey': publishableKey,
        'encryptedSecretKey': encryptedSecretKey,
        'encryptedWebhookSecret': encryptedWebhookSecret,
        'isLiveMode': isLiveMode,
        'priceIds': priceIds,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': updatedBy,
      };

  StripeConfig copyWith({
    String? publishableKey,
    String? encryptedSecretKey,
    String? encryptedWebhookSecret,
    bool? isLiveMode,
    Map<String, String>? priceIds,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return StripeConfig(
      publishableKey: publishableKey ?? this.publishableKey,
      encryptedSecretKey: encryptedSecretKey ?? this.encryptedSecretKey,
      encryptedWebhookSecret:
          encryptedWebhookSecret ?? this.encryptedWebhookSecret,
      isLiveMode: isLiveMode ?? this.isLiveMode,
      priceIds: priceIds ?? this.priceIds,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
        publishableKey,
        encryptedSecretKey,
        encryptedWebhookSecret,
        isLiveMode,
        priceIds,
        updatedAt,
        updatedBy,
      ];
}
