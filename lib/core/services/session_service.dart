import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout: Firestore index may be missing'),
          );
      return snapshot.docs.map((doc) => Session.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('❌ SessionService.getSessions error: $e');
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

  /// Stream sessions for an engineer (assigned + proposed)
  Stream<List<Session>> streamEngineerSessions(String engineerId) {
    // Query 1: Sessions where engineer is the main engineer
    final mainEngineerStream = _firestore
        .collection(_collection)
        .where('engineerId', isEqualTo: engineerId)
        .snapshots();

    // Query 2: Sessions where engineer is in engineerIds array (multi-engineer)
    final multiEngineerStream = _firestore
        .collection(_collection)
        .where('engineerIds', arrayContains: engineerId)
        .snapshots();

    // Query 3: Sessions where engineer has been proposed (pending response)
    final proposedStream = _firestore
        .collection(_collection)
        .where('proposedEngineerIds', arrayContains: engineerId)
        .snapshots();

    // Combine all three streams and merge unique sessions
    return mainEngineerStream.asyncExpand((mainSnap) {
      return multiEngineerStream.asyncExpand((multiSnap) {
        return proposedStream.map((proposedSnap) {
          final sessionsMap = <String, Session>{};

          for (final doc in mainSnap.docs) {
            final session = Session.fromMap(doc.data());
            sessionsMap[session.id] = session;
          }
          for (final doc in multiSnap.docs) {
            final session = Session.fromMap(doc.data());
            sessionsMap[session.id] = session;
          }
          for (final doc in proposedSnap.docs) {
            final session = Session.fromMap(doc.data());
            sessionsMap[session.id] = session;
          }

          final sessions = sessionsMap.values.toList()
            ..sort((a, b) => b.scheduledStart.compareTo(a.scheduledStart));
          return sessions;
        });
      });
    });
  }

  /// Stream only proposed sessions for an engineer (not yet accepted)
  Stream<List<Session>> streamProposedSessions(String engineerId) {
    return _firestore
        .collection(_collection)
        .where('proposedEngineerIds', arrayContains: engineerId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((s) => s.docs.map((d) => Session.fromMap(d.data())).toList()
          ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart)));
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

      // Si c'est une demande (pending), notifier le studio
      if (session.status == SessionStatus.pending) {
        await _createSessionRequestNotification(newSession);
      }

      return SmoothResponse(code: 200, message: 'Session créée', data: newSession);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: null);
    }
  }

  /// Crée une notification pour le studio quand un artiste envoie une demande
  Future<void> _createSessionRequestNotification(Session session) async {
    try {
      final notifRef = _firestore.collection('user_notifications').doc();
      await notifRef.set({
        'id': notifRef.id,
        'userId': session.studioId,
        'type': 'session_request',
        'title': 'Nouvelle demande de session',
        'body': '${session.artistName} souhaite réserver une session ${session.typeLabel}',
        'data': {
          'sessionId': session.id,
          'artistName': session.artistName,
          'sessionType': session.type.name,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Notification créée pour le studio ${session.studioId}');
    } catch (e) {
      debugPrint('❌ Erreur création notification: $e');
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
      // Récupérer la session pour les infos de notification
      final session = await getSession(sessionId);

      await _firestore.collection(_collection).doc(sessionId).update({
        'status': status.name,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Notifier l'artiste du changement de statut
      if (session != null) {
        await _createStatusChangeNotification(session, status);
      }

      return SmoothResponse(code: 200, message: 'Statut mis à jour', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Notifie les artistes et l'ingénieur quand le statut de leur session change
  Future<void> _createStatusChangeNotification(Session session, SessionStatus newStatus) async {
    try {
      String artistTitle;
      String artistBody;
      String type;

      switch (newStatus) {
        case SessionStatus.confirmed:
          artistTitle = 'Session confirmée !';
          artistBody = 'Votre session ${session.typeLabel} a été acceptée';
          type = 'session_confirmed';
          break;
        case SessionStatus.cancelled:
          artistTitle = 'Session refusée';
          artistBody = 'Votre demande de session ${session.typeLabel} a été refusée';
          type = 'session_cancelled';
          break;
        default:
          return; // Pas de notif pour les autres statuts
      }

      // Notifier chaque artiste de la session
      for (final artistId in session.artistIds) {
        final notifRef = _firestore.collection('user_notifications').doc();
        await notifRef.set({
          'id': notifRef.id,
          'userId': artistId,
          'type': type,
          'title': artistTitle,
          'body': artistBody,
          'data': {
            'sessionId': session.id,
            'studioId': session.studioId,
            'sessionType': session.type.name,
          },
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      debugPrint('✅ Notifications envoyées aux artistes');

      // Notifier l'ingénieur si session confirmée et ingénieur assigné
      if (newStatus == SessionStatus.confirmed && session.hasEngineer) {
        await _notifyEngineerAssignment(session);
      }
    } catch (e) {
      debugPrint('❌ Erreur notification statut: $e');
    }
  }

  /// Notifie l'ingénieur qu'il a été assigné à une session confirmée
  Future<void> _notifyEngineerAssignment(Session session) async {
    try {
      final notifRef = _firestore.collection('user_notifications').doc();
      await notifRef.set({
        'id': notifRef.id,
        'userId': session.engineerId,
        'type': 'session_assigned',
        'title': 'Nouvelle session assignée',
        'body': 'Session ${session.type.label} avec ${session.artistName}',
        'data': {
          'sessionId': session.id,
          'studioId': session.studioId,
          'artistName': session.artistName,
          'sessionType': session.type.name,
        },
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Notification envoyée à l\'ingénieur ${session.engineerId}');
    } catch (e) {
      debugPrint('❌ Erreur notification ingénieur: $e');
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
