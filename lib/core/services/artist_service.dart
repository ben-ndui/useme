import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/models/models_exports.dart';

/// Artist Service - CRUD operations for artists
class ArtistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'useme_artists';

  /// Get a new artist ID
  String getNewArtistId() => _firestore.collection(_collection).doc().id;

  /// Create a new artist
  Future<SmoothResponse<bool>> createArtist(String studioId, Artist artist) async {
    try {
      final artistData = artist.toMap();
      artistData['studioIds'] = [studioId];
      artistData['createdAt'] = FieldValue.serverTimestamp();
      artistData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(_collection).doc(artist.id).set(artistData);
      return SmoothResponse(code: 200, message: 'Artiste créé', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Get artist by ID
  Future<Artist?> getArtistById(String artistId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(artistId).get();
      if (doc.exists && doc.data() != null) {
        return Artist.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all artists for a studio
  Future<List<Artist>> getArtistsByStudioId(String studioId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studioIds', arrayContains: studioId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Artist.fromMap(doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  /// Stream artists for real-time updates
  Stream<List<Artist>> streamArtistsByStudioId(String studioId) {
    return _firestore
        .collection(_collection)
        .where('studioIds', arrayContains: studioId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Artist.fromMap(d.data())).toList());
  }

  /// Stream a single artist by ID
  Stream<Artist?> streamArtistById(String artistId) {
    return _firestore
        .collection(_collection)
        .doc(artistId)
        .snapshots()
        .map((s) => s.exists && s.data() != null ? Artist.fromMap(s.data()!) : null);
  }

  /// Update artist
  Future<SmoothResponse<bool>> updateArtist(
    String artistId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collection).doc(artistId).update(updates);
      return SmoothResponse(code: 200, message: 'Artiste mis à jour', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Delete artist
  Future<SmoothResponse<bool>> deleteArtist(String artistId) async {
    try {
      await _firestore.collection(_collection).doc(artistId).delete();
      return SmoothResponse(code: 200, message: 'Artiste supprimé', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Search artists by name or stage name
  Future<List<Artist>> searchArtists(String studioId, String query) async {
    try {
      if (query.isEmpty) return getArtistsByStudioId(studioId);
      final allArtists = await getArtistsByStudioId(studioId);
      final searchLower = query.toLowerCase();
      return allArtists.where((artist) {
        return artist.name.toLowerCase().contains(searchLower) ||
            (artist.stageName?.toLowerCase().contains(searchLower) ?? false) ||
            (artist.email?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get artist by linked user ID (for artist portal)
  Future<Artist?> getArtistByLinkedUserId(String linkedUserId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('linkedUserId', isEqualTo: linkedUserId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return Artist.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Link a user to an artist (for artist portal access)
  Future<SmoothResponse<bool>> linkUserToArtist(
    String artistId,
    String userId,
    String studioId,
  ) async {
    try {
      final batch = _firestore.batch();

      batch.update(_firestore.collection(_collection).doc(artistId), {
        'linkedUserId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(_firestore.collection('users').doc(userId), {
        'linkedArtistId': artistId,
        'role': 'client',
        'invitedByStudioId': studioId,
        'roleChangedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return SmoothResponse(code: 200, message: 'Utilisateur lié', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Get artist count for a studio
  Future<int> getArtistCount(String studioId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studioIds', arrayContains: studioId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
