import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:useme/core/models/subscription_tier_config.dart';

/// Service de gestion de la configuration des tiers d'abonnement (SuperAdmin)
/// Collection Firestore: 'subscription_tiers'
class SubscriptionConfigService {
  static const String _collection = 'subscription_tiers';

  final FirebaseFirestore _firestore;

  // Cache local pour éviter les lectures répétées
  List<SubscriptionTierConfig>? _cachedTiers;
  DateTime? _lastFetch;
  static const Duration _cacheDuration = Duration(minutes: 5);

  SubscriptionConfigService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Référence à la collection des tiers
  CollectionReference<Map<String, dynamic>> get _tiersRef =>
      _firestore.collection(_collection);

  /// Stream de tous les tiers actifs triés par ordre
  Stream<List<SubscriptionTierConfig>> streamTiers() {
    return _tiersRef
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubscriptionTierConfig.fromMap(doc.data(), id: doc.id))
            .toList());
  }

  /// Récupère tous les tiers (avec cache)
  Future<List<SubscriptionTierConfig>> getTiers({bool forceRefresh = false}) async {
    // Vérifier le cache
    if (!forceRefresh && _cachedTiers != null && _lastFetch != null) {
      final elapsed = DateTime.now().difference(_lastFetch!);
      if (elapsed < _cacheDuration) {
        return _cachedTiers!;
      }
    }

    try {
      final snapshot = await _tiersRef.orderBy('sortOrder').get();

      if (snapshot.docs.isEmpty) {
        // Initialiser avec les tiers par défaut
        await _initializeDefaultTiers();
        return SubscriptionTierConfig.defaultTiers;
      }

      _cachedTiers = snapshot.docs
          .map((doc) => SubscriptionTierConfig.fromMap(doc.data(), id: doc.id))
          .toList();
      _lastFetch = DateTime.now();

      return _cachedTiers!;
    } catch (e) {
      debugPrint('Erreur récupération tiers: $e');
      return _cachedTiers ?? SubscriptionTierConfig.defaultTiers;
    }
  }

  /// Récupère un tier spécifique
  Future<SubscriptionTierConfig?> getTier(String tierId) async {
    // Chercher dans le cache d'abord
    if (_cachedTiers != null) {
      final cached = _cachedTiers!.where((t) => t.id == tierId).firstOrNull;
      if (cached != null) return cached;
    }

    try {
      final doc = await _tiersRef.doc(tierId).get();
      if (!doc.exists) return null;

      return SubscriptionTierConfig.fromMap(doc.data()!, id: doc.id);
    } catch (e) {
      debugPrint('Erreur récupération tier $tierId: $e');
      // Fallback vers les défauts
      return SubscriptionTierConfig.defaultTiers
          .where((t) => t.id == tierId)
          .firstOrNull;
    }
  }

  /// Met à jour un tier (SuperAdmin only)
  Future<void> updateTier(SubscriptionTierConfig tier) async {
    try {
      await _tiersRef.doc(tier.id).set(tier.toMap(), SetOptions(merge: true));

      // Invalider le cache
      _cachedTiers = null;
      _lastFetch = null;
    } catch (e) {
      debugPrint('Erreur mise à jour tier ${tier.id}: $e');
      rethrow;
    }
  }

  /// Crée un nouveau tier (SuperAdmin only)
  Future<void> createTier(SubscriptionTierConfig tier) async {
    try {
      await _tiersRef.doc(tier.id).set(tier.toMap());

      // Invalider le cache
      _cachedTiers = null;
      _lastFetch = null;
    } catch (e) {
      debugPrint('Erreur création tier ${tier.id}: $e');
      rethrow;
    }
  }

  /// Supprime un tier (SuperAdmin only)
  /// Attention: vérifier qu'aucun studio n'utilise ce tier avant suppression
  Future<void> deleteTier(String tierId) async {
    if (tierId == 'free') {
      throw Exception('Le tier Free ne peut pas être supprimé');
    }

    try {
      await _tiersRef.doc(tierId).delete();

      // Invalider le cache
      _cachedTiers = null;
      _lastFetch = null;
    } catch (e) {
      debugPrint('Erreur suppression tier $tierId: $e');
      rethrow;
    }
  }

  /// Initialise les tiers par défaut (première utilisation)
  Future<void> _initializeDefaultTiers() async {
    final batch = _firestore.batch();

    for (final tier in SubscriptionTierConfig.defaultTiers) {
      batch.set(_tiersRef.doc(tier.id), tier.toMap());
    }

    await batch.commit();
    debugPrint('Tiers par défaut initialisés');
  }

  /// Vérifie si un studio peut créer une session selon son tier
  Future<bool> canCreateSession({
    required String tierId,
    required int currentSessionsThisMonth,
  }) async {
    final tier = await getTier(tierId);
    if (tier == null) return false;

    // -1 = illimité
    if (tier.maxSessions == -1) return true;

    return currentSessionsThisMonth < tier.maxSessions;
  }

  /// Vérifie si un studio peut créer une salle selon son tier
  Future<bool> canCreateRoom({
    required String tierId,
    required int currentRoomsCount,
  }) async {
    final tier = await getTier(tierId);
    if (tier == null) return false;

    if (tier.maxRooms == -1) return true;

    return currentRoomsCount < tier.maxRooms;
  }

  /// Vérifie si un studio peut créer un service selon son tier
  Future<bool> canCreateService({
    required String tierId,
    required int currentServicesCount,
  }) async {
    final tier = await getTier(tierId);
    if (tier == null) return false;

    if (tier.maxServices == -1) return true;

    return currentServicesCount < tier.maxServices;
  }

  /// Vérifie si un studio peut ajouter un engineer selon son tier
  Future<bool> canAddEngineer({
    required String tierId,
    required int currentEngineersCount,
  }) async {
    final tier = await getTier(tierId);
    if (tier == null) return false;

    if (tier.maxEngineers == -1) return true;

    return currentEngineersCount < tier.maxEngineers;
  }

  /// Invalide le cache manuellement
  void invalidateCache() {
    _cachedTiers = null;
    _lastFetch = null;
  }
}
