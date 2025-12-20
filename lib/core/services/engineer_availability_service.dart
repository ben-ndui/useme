import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/models/models_exports.dart';
import 'package:useme/core/services/session_service.dart';
import 'package:useme/core/services/team_service.dart';

/// Service de gestion des disponibilités des ingénieurs
class EngineerAvailabilityService {
  final FirebaseFirestore _firestore;
  final SessionService _sessionService;
  final TeamService _teamService;

  static const String _usersCollection = 'users';
  static const String _timeOffsCollection = 'engineer_time_offs';

  EngineerAvailabilityService({
    FirebaseFirestore? firestore,
    SessionService? sessionService,
    TeamService? teamService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _sessionService = sessionService ?? SessionService(),
        _teamService = teamService ?? TeamService();

  // ========== WORKING HOURS ==========

  /// Récupère les horaires de travail d'un ingénieur
  Future<WorkingHours> getWorkingHours(String engineerId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(engineerId).get();
      if (!doc.exists || doc.data() == null) {
        return WorkingHours.defaultSchedule();
      }
      final data = doc.data()!;
      return WorkingHours.fromMap(data['workingHours'] as Map<String, dynamic>?);
    } catch (e) {
      debugPrint('Erreur getWorkingHours: $e');
      return WorkingHours.defaultSchedule();
    }
  }

  /// Stream des horaires de travail (temps réel)
  Stream<WorkingHours> streamWorkingHours(String engineerId) {
    return _firestore.collection(_usersCollection).doc(engineerId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return WorkingHours.defaultSchedule();
      }
      return WorkingHours.fromMap(doc.data()!['workingHours'] as Map<String, dynamic>?);
    });
  }

  /// Met à jour les horaires de travail
  Future<SmoothResponse<bool>> setWorkingHours(
    String engineerId,
    WorkingHours hours,
  ) async {
    try {
      await _firestore.collection(_usersCollection).doc(engineerId).update({
        'workingHours': hours.toMap(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Horaires mis à jour', data: true);
    } catch (e) {
      debugPrint('Erreur setWorkingHours: $e');
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  // ========== TIME OFFS ==========

  /// Stream des indisponibilités d'un ingénieur
  Stream<List<TimeOff>> streamTimeOffs(String engineerId) {
    return _firestore
        .collection(_timeOffsCollection)
        .where('engineerId', isEqualTo: engineerId)
        .orderBy('start', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimeOff.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Récupère les time-offs futurs
  Stream<List<TimeOff>> streamFutureTimeOffs(String engineerId) {
    final now = DateTime.now();
    return _firestore
        .collection(_timeOffsCollection)
        .where('engineerId', isEqualTo: engineerId)
        .where('end', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('end')
        .orderBy('start')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimeOff.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Récupère les time-offs pour une période
  Future<List<TimeOff>> getTimeOffsByDateRange(
    String engineerId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Firestore ne permet pas de requêter avec des overlaps complexes,
      // on récupère tous les time-offs et on filtre côté client
      final snapshot = await _firestore
          .collection(_timeOffsCollection)
          .where('engineerId', isEqualTo: engineerId)
          .get();

      return snapshot.docs
          .map((doc) => TimeOff.fromMap(doc.data(), doc.id))
          .where((timeOff) => timeOff.overlapsWith(start, end))
          .toList();
    } catch (e) {
      debugPrint('Erreur getTimeOffsByDateRange: $e');
      return [];
    }
  }

  /// Ajoute une indisponibilité
  Future<SmoothResponse<TimeOff>> addTimeOff(TimeOff timeOff) async {
    try {
      final docRef = _firestore.collection(_timeOffsCollection).doc();
      final newTimeOff = timeOff.copyWith(id: docRef.id);
      await docRef.set(newTimeOff.toMap());
      return SmoothResponse(
        code: 201,
        message: 'Indisponibilité ajoutée',
        data: newTimeOff,
      );
    } catch (e) {
      debugPrint('Erreur addTimeOff: $e');
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: null);
    }
  }

  /// Supprime une indisponibilité
  Future<SmoothResponse<bool>> deleteTimeOff(String timeOffId) async {
    try {
      await _firestore.collection(_timeOffsCollection).doc(timeOffId).delete();
      return SmoothResponse(code: 200, message: 'Indisponibilité supprimée', data: true);
    } catch (e) {
      debugPrint('Erreur deleteTimeOff: $e');
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  // ========== AVAILABILITY CHECK ==========

  /// Vérifie si un ingénieur est disponible pour un créneau
  Future<bool> isAvailable({
    required String engineerId,
    required DateTime start,
    required DateTime end,
  }) async {
    // 1. Vérifier les horaires de travail
    final workingHours = await getWorkingHours(engineerId);
    if (!workingHours.isWorkingDuring(start, end)) {
      return false;
    }

    // 2. Vérifier les time-offs
    final timeOffs = await getTimeOffsByDateRange(engineerId, start, end);
    for (final timeOff in timeOffs) {
      if (timeOff.overlapsWith(start, end)) {
        return false;
      }
    }

    // 3. Vérifier les sessions déjà assignées
    final sessions = await _sessionService.getSessions(engineerId);
    for (final session in sessions) {
      // Session confirmée ou en cours qui chevauche
      if (session.status == SessionStatus.confirmed ||
          session.status == SessionStatus.inProgress) {
        if (_overlaps(start, end, session.scheduledStart, session.scheduledEnd)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Récupère tous les ingénieurs disponibles d'un studio pour un créneau
  Future<List<AvailableEngineer>> getAvailableEngineers({
    required String studioId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // 1. Récupérer tous les ingénieurs du studio
      final engineers = await _teamService.getTeamMembers(studioId);

      // 2. Vérifier la disponibilité de chacun
      final results = <AvailableEngineer>[];

      for (final engineer in engineers) {
        final availabilityInfo = await _checkEngineerAvailability(
          engineerId: engineer.uid,
          start: start,
          end: end,
        );

        results.add(AvailableEngineer(
          user: engineer,
          isAvailable: availabilityInfo.isAvailable,
          unavailabilityReason: availabilityInfo.reason,
        ));
      }

      // Trier: disponibles en premier, puis par nom
      results.sort((a, b) {
        if (a.isAvailable && !b.isAvailable) return -1;
        if (!a.isAvailable && b.isAvailable) return 1;
        return (a.user.name ?? '').compareTo(b.user.name ?? '');
      });

      return results;
    } catch (e) {
      debugPrint('Erreur getAvailableEngineers: $e');
      return [];
    }
  }

  /// Vérifie la disponibilité avec la raison
  Future<_AvailabilityInfo> _checkEngineerAvailability({
    required String engineerId,
    required DateTime start,
    required DateTime end,
  }) async {
    // 1. Horaires de travail
    final workingHours = await getWorkingHours(engineerId);
    if (!workingHours.isWorkingDuring(start, end)) {
      return _AvailabilityInfo(false, 'Hors horaires de travail');
    }

    // 2. Time-offs
    final timeOffs = await getTimeOffsByDateRange(engineerId, start, end);
    for (final timeOff in timeOffs) {
      if (timeOff.overlapsWith(start, end)) {
        return _AvailabilityInfo(false, timeOff.reason ?? 'Indisponible');
      }
    }

    // 3. Sessions
    final sessions = await _sessionService.getSessions(engineerId);
    for (final session in sessions) {
      if (session.status == SessionStatus.confirmed ||
          session.status == SessionStatus.inProgress) {
        if (_overlaps(start, end, session.scheduledStart, session.scheduledEnd)) {
          return _AvailabilityInfo(false, 'Déjà en session');
        }
      }
    }

    return _AvailabilityInfo(true, null);
  }

  bool _overlaps(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
    return s1.isBefore(e2) && e1.isAfter(s2);
  }
}

/// Info de disponibilité interne
class _AvailabilityInfo {
  final bool isAvailable;
  final String? reason;
  _AvailabilityInfo(this.isAvailable, this.reason);
}

/// Ingénieur avec son statut de disponibilité
class AvailableEngineer {
  final AppUser user;
  final bool isAvailable;
  final String? unavailabilityReason;

  const AvailableEngineer({
    required this.user,
    required this.isAvailable,
    this.unavailabilityReason,
  });
}
