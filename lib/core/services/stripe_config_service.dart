import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:useme/core/models/stripe_config.dart';
import 'package:useme/core/services/encryption_service.dart';

/// Service de gestion de la configuration Stripe (DevMaster only)
/// Collection Firestore: 'app_config' doc 'stripe'
/// Les clés sensibles sont cryptées AES-256 avant stockage
class StripeConfigService {
  static const String _collection = 'app_config';
  static const String _document = 'stripe';

  final FirebaseFirestore _firestore;
  final EncryptionService _encryption;

  // Cache local
  StripeConfig? _cachedConfig;
  DateTime? _lastFetch;
  static const Duration _cacheDuration = Duration(minutes: 10);

  StripeConfigService({
    required EncryptionService encryption,
    FirebaseFirestore? firestore,
  })  : _encryption = encryption,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Référence au document de configuration Stripe
  DocumentReference<Map<String, dynamic>> get _configRef =>
      _firestore.collection(_collection).doc(_document);

  /// Stream de la configuration Stripe
  Stream<StripeConfig?> streamConfig() {
    return _configRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return _decryptConfig(StripeConfig.fromMap(snapshot.data()));
    });
  }

  /// Récupère la configuration Stripe (avec cache)
  Future<StripeConfig?> getConfig({bool forceRefresh = false}) async {
    // Vérifier le cache
    if (!forceRefresh && _cachedConfig != null && _lastFetch != null) {
      final elapsed = DateTime.now().difference(_lastFetch!);
      if (elapsed < _cacheDuration) {
        return _cachedConfig;
      }
    }

    try {
      final doc = await _configRef.get();

      if (!doc.exists) {
        return null;
      }

      final config = StripeConfig.fromMap(doc.data());
      _cachedConfig = _decryptConfig(config);
      _lastFetch = DateTime.now();

      return _cachedConfig;
    } catch (e) {
      debugPrint('Erreur récupération config Stripe: $e');
      return _cachedConfig;
    }
  }

  /// Récupère uniquement la clé publique (pour les studios/artistes)
  /// Ne nécessite pas d'être DevMaster
  Future<String?> getPublishableKey() async {
    final config = await getConfig();
    return config?.publishableKey;
  }

  /// Sauvegarde la configuration Stripe (DevMaster only)
  /// Chiffre les clés sensibles avant stockage
  Future<void> saveConfig({
    required StripeConfig config,
    required String updatedBy,
    String? secretKey,
    String? webhookSecret,
  }) async {
    try {
      // Préparer la config avec les clés chiffrées
      var configToSave = config.copyWith(updatedBy: updatedBy);

      // Chiffrer la clé secrète si fournie
      if (secretKey != null && secretKey.isNotEmpty) {
        final encrypted = _encryption.encryptString(secretKey);
        if (encrypted != null) {
          configToSave = configToSave.copyWith(encryptedSecretKey: encrypted);
        }
      }

      // Chiffrer le webhook secret si fourni
      if (webhookSecret != null && webhookSecret.isNotEmpty) {
        final encrypted = _encryption.encryptString(webhookSecret);
        if (encrypted != null) {
          configToSave = configToSave.copyWith(encryptedWebhookSecret: encrypted);
        }
      }

      await _configRef.set(configToSave.toMap(), SetOptions(merge: true));

      // Invalider le cache
      _cachedConfig = null;
      _lastFetch = null;

      debugPrint('Config Stripe sauvegardée');
    } catch (e) {
      debugPrint('Erreur sauvegarde config Stripe: $e');
      rethrow;
    }
  }

  /// Met à jour uniquement la clé publique
  Future<void> updatePublishableKey({
    required String publishableKey,
    required String updatedBy,
  }) async {
    try {
      await _configRef.set({
        'publishableKey': publishableKey,
        'updatedBy': updatedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _cachedConfig = null;
      _lastFetch = null;
    } catch (e) {
      debugPrint('Erreur mise à jour clé publique: $e');
      rethrow;
    }
  }

  /// Met à jour le mode (test/live)
  Future<void> updateMode({
    required bool isLiveMode,
    required String updatedBy,
  }) async {
    try {
      await _configRef.set({
        'isLiveMode': isLiveMode,
        'updatedBy': updatedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _cachedConfig = null;
      _lastFetch = null;
    } catch (e) {
      debugPrint('Erreur mise à jour mode: $e');
      rethrow;
    }
  }

  /// Met à jour les IDs de prix Stripe
  Future<void> updatePriceIds({
    required Map<String, String> priceIds,
    required String updatedBy,
  }) async {
    try {
      await _configRef.set({
        'priceIds': priceIds,
        'updatedBy': updatedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _cachedConfig = null;
      _lastFetch = null;
    } catch (e) {
      debugPrint('Erreur mise à jour price IDs: $e');
      rethrow;
    }
  }

  /// Valide les clés Stripe (appel API de test)
  /// Retourne true si les clés sont valides
  Future<bool> validateKeys({
    required String publishableKey,
    required String secretKey,
  }) async {
    // Vérification du format des clés
    if (!publishableKey.startsWith('pk_')) {
      debugPrint('Format clé publique invalide');
      return false;
    }

    if (!secretKey.startsWith('sk_')) {
      debugPrint('Format clé secrète invalide');
      return false;
    }

    // Vérifier cohérence test/live
    final isTestPublishable = publishableKey.startsWith('pk_test_');
    final isTestSecret = secretKey.startsWith('sk_test_');

    if (isTestPublishable != isTestSecret) {
      debugPrint('Les clés doivent être toutes deux en mode test ou live');
      return false;
    }

    // TODO: Appeler l'API Stripe pour valider les clés
    // Pour l'instant, on considère que le format est suffisant
    return true;
  }

  /// Vérifie si Stripe est configuré
  Future<bool> isConfigured() async {
    final config = await getConfig();
    return config?.isConfigured ?? false;
  }

  /// Déchiffre les clés sensibles de la config
  StripeConfig _decryptConfig(StripeConfig config) {
    String? decryptedSecretKey;
    String? decryptedWebhookSecret;

    if (config.encryptedSecretKey.isNotEmpty) {
      decryptedSecretKey = _encryption.decryptString(config.encryptedSecretKey);
    }

    if (config.encryptedWebhookSecret.isNotEmpty) {
      decryptedWebhookSecret =
          _encryption.decryptString(config.encryptedWebhookSecret);
    }

    // Note: On retourne la config avec les clés déchiffrées en mémoire
    // mais on ne stocke jamais les clés déchiffrées
    return config.copyWith(
      encryptedSecretKey: decryptedSecretKey ?? config.encryptedSecretKey,
      encryptedWebhookSecret:
          decryptedWebhookSecret ?? config.encryptedWebhookSecret,
    );
  }

  /// Invalide le cache manuellement
  void invalidateCache() {
    _cachedConfig = null;
    _lastFetch = null;
  }
}
