import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/models/models_exports.dart';

/// Session Service - CRUD operations for studio sessions
class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'useme_sessions';

  /// Get all sessions for a studio
  Future<List<Session>> getSessions(String studioId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studioId', isEqualTo: studioId)
          .orderBy('scheduledStart', descending: true)
          .get();
      return snapshot.docs.map((doc) => Session.fromMap(doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  /// Stream sessions for real-time updates
  Stream<List<Session>> streamSessions(String studioId) {
    return _firestore
        .collection(_collection)
        .where('studioId', isEqualTo: studioId)
        .orderBy('scheduledStart', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Session.fromMap(d.data())).toList());
  }

  /// Stream sessions for an engineer
  Stream<List<Session>> streamEngineerSessions(String engineerId) {
    return _firestore
        .collection(_collection)
        .where('engineerId', isEqualTo: engineerId)
        .orderBy('scheduledStart', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Session.fromMap(d.data())).toList());
  }

  /// Stream sessions for an artist (cherche dans le tableau artistIds)
  Stream<List<Session>> streamArtistSessions(String artistId) {
    return _firestore
        .collection(_collection)
        .where('artistIds', arrayContains: artistId)
        .orderBy('scheduledStart', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Session.fromMap(d.data())).toList());
  }

  /// Get sessions by date range
  Stream<List<Session>> streamSessionsByDateRange(
    String studioId,
    DateTime start,
    DateTime end,
  ) {
    return _firestore
        .collection(_collection)
        .where('studioId', isEqualTo: studioId)
        .where('scheduledStart', isGreaterThanOrEqualTo: start.millisecondsSinceEpoch)
        .where('scheduledStart', isLessThanOrEqualTo: end.millisecondsSinceEpoch)
        .orderBy('scheduledStart')
        .snapshots()
        .map((s) => s.docs.map((d) => Session.fromMap(d.data())).toList());
  }

  /// Get a single session by ID
  Future<Session?> getSession(String sessionId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(sessionId).get();
      if (!doc.exists) return null;
      return Session.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Create a new session
  Future<SmoothResponse<Session>> createSession(Session session) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final newSession = session.copyWith(id: docRef.id);
      await docRef.set(newSession.toMap());
      return SmoothResponse(code: 200, message: 'Session créée', data: newSession);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: null);
    }
  }

  /// Update an existing session
  Future<SmoothResponse<bool>> updateSession(Session session) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(session.id)
          .update(session.toMap());
      return SmoothResponse(code: 200, message: 'Session mise à jour', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Delete a session
  Future<SmoothResponse<bool>> deleteSession(String sessionId) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).delete();
      return SmoothResponse(code: 200, message: 'Session supprimée', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Update session status
  Future<SmoothResponse<bool>> updateStatus(String sessionId, SessionStatus status) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'status': status.name,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Statut mis à jour', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Assign an engineer to a session
  Future<SmoothResponse<bool>> assignEngineer(
    String sessionId,
    String engineerId,
    String engineerName,
  ) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'engineerId': engineerId,
        'engineerName': engineerName,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Ingénieur assigné', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Add an artist to a session
  Future<SmoothResponse<bool>> addArtist(
    String sessionId,
    String artistId,
    String artistName,
  ) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'artistIds': FieldValue.arrayUnion([artistId]),
        'artistNames': FieldValue.arrayUnion([artistName]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Artiste ajouté', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Remove an artist from a session
  Future<SmoothResponse<bool>> removeArtist(
    String sessionId,
    String artistId,
    String artistName,
  ) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'artistIds': FieldValue.arrayRemove([artistId]),
        'artistNames': FieldValue.arrayRemove([artistName]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Artiste retiré', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Update all artists on a session
  Future<SmoothResponse<bool>> updateArtists(
    String sessionId,
    List<String> artistIds,
    List<String> artistNames,
  ) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'artistIds': artistIds,
        'artistNames': artistNames,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Artistes mis à jour', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Check-in to a session
  Future<SmoothResponse<bool>> checkin(String sessionId) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'status': SessionStatus.inProgress.name,
        'intervention.checkinTime': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Check-in effectué', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Check-out from a session
  Future<SmoothResponse<bool>> checkout(String sessionId) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'status': SessionStatus.completed.name,
        'intervention.checkoutTime': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Check-out effectué', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Add a photo to the session
  Future<SmoothResponse<bool>> addPhoto(String sessionId, String photoUrl) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'intervention.photos': FieldValue.arrayUnion([photoUrl]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Photo ajoutée', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Update session notes
  Future<SmoothResponse<bool>> updateNotes(String sessionId, String notes) async {
    try {
      await _firestore.collection(_collection).doc(sessionId).update({
        'intervention.notes': notes,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Notes mises à jour', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }
}
