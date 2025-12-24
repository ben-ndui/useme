import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/models/favorite.dart';

/// Service pour gérer les favoris dans Firestore.
class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'useme_favorites';

  /// Stream des favoris d'un utilisateur.
  /// Note: On évite orderBy pour ne pas nécessiter d'index composite.
  /// Le tri est fait côté client.
  Stream<List<Favorite>> streamFavorites(String userId) {
    debugPrint('❤️ FavoriteService.streamFavorites called for userId: $userId');
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((s) {
          debugPrint('❤️ streamFavorites received ${s.docs.length} docs');
          final favorites = s.docs.map((d) => Favorite.fromMap(d.data(), d.id)).toList();
          // Tri côté client (plus récent en premier)
          favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return favorites;
        });
  }

  /// Stream des favoris par type.
  /// Note: On évite orderBy pour ne pas nécessiter d'index composite.
  Stream<List<Favorite>> streamFavoritesByType(String userId, FavoriteType type) {
    debugPrint('❤️ FavoriteService.streamFavoritesByType called for userId: $userId, type: $type');
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.name)
        .snapshots()
        .map((s) {
          debugPrint('❤️ streamFavoritesByType received ${s.docs.length} docs');
          final favorites = s.docs.map((d) => Favorite.fromMap(d.data(), d.id)).toList();
          favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return favorites;
        });
  }

  /// Vérifie si un élément est en favori.
  Future<bool> isFavorite(String userId, String targetId) async {
    final query = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('targetId', isEqualTo: targetId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Stream pour vérifier si un élément est en favori (temps réel).
  Stream<bool> streamIsFavorite(String userId, String targetId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('targetId', isEqualTo: targetId)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isNotEmpty);
  }

  /// Ajoute un favori.
  Future<SmoothResponse<Favorite>> addFavorite({
    required String userId,
    required String targetId,
    required FavoriteType type,
    String? targetName,
    String? targetPhotoUrl,
    String? targetAddress,
  }) async {
    try {
      // Vérifier si déjà en favori
      final existing = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('targetId', isEqualTo: targetId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return SmoothResponse.error(message: 'Déjà en favoris');
      }

      final data = {
        'userId': userId,
        'targetId': targetId,
        'type': type.name,
        'createdAt': DateTime.now().toIso8601String(),
        if (targetName != null) 'targetName': targetName,
        if (targetPhotoUrl != null) 'targetPhotoUrl': targetPhotoUrl,
        if (targetAddress != null) 'targetAddress': targetAddress,
      };

      final docRef = await _firestore.collection(_collection).add(data);
      final favorite = Favorite.fromMap(data, docRef.id);

      return SmoothResponse.success(data: favorite);
    } catch (e) {
      return SmoothResponse.error(message: 'Erreur ajout favori: $e');
    }
  }

  /// Supprime un favori.
  Future<SmoothResponse<void>> removeFavorite(String favoriteId) async {
    try {
      await _firestore.collection(_collection).doc(favoriteId).delete();
      return SmoothResponse.success();
    } catch (e) {
      return SmoothResponse.error(message: 'Erreur suppression favori: $e');
    }
  }

  /// Supprime un favori par userId et targetId.
  Future<SmoothResponse<void>> removeFavoriteByTarget({
    required String userId,
    required String targetId,
  }) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('targetId', isEqualTo: targetId)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }

      return SmoothResponse.success();
    } catch (e) {
      return SmoothResponse.error(message: 'Erreur suppression favori: $e');
    }
  }

  /// Toggle favori (ajoute si pas présent, supprime si présent).
  Future<SmoothResponse<bool>> toggleFavorite({
    required String userId,
    required String targetId,
    required FavoriteType type,
    String? targetName,
    String? targetPhotoUrl,
    String? targetAddress,
  }) async {
    debugPrint('❤️ FavoriteService.toggleFavorite called');
    debugPrint('❤️ userId: $userId, targetId: $targetId, type: $type');

    try {
      final query = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('targetId', isEqualTo: targetId)
          .limit(1)
          .get();

      debugPrint('❤️ Query returned ${query.docs.length} docs');

      if (query.docs.isNotEmpty) {
        // Supprimer
        debugPrint('❤️ Removing favorite...');
        await query.docs.first.reference.delete();
        debugPrint('❤️ Favorite removed successfully');
        return SmoothResponse.success(data: false);
      } else {
        // Ajouter
        debugPrint('❤️ Adding favorite...');
        final result = await addFavorite(
          userId: userId,
          targetId: targetId,
          type: type,
          targetName: targetName,
          targetPhotoUrl: targetPhotoUrl,
          targetAddress: targetAddress,
        );
        debugPrint('❤️ Add result: ${result.isSuccess}, ${result.message}');
        return SmoothResponse.success(data: true);
      }
    } catch (e) {
      debugPrint('❤️ Error in toggleFavorite: $e');
      return SmoothResponse.error(message: 'Erreur toggle favori: $e');
    }
  }

  /// Récupère le nombre de favoris d'un utilisateur.
  Future<int> getFavoriteCount(String userId) async {
    final query = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    return query.count ?? 0;
  }
}
