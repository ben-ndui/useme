import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoothandesign_package/core/models/unavailability.dart';

/// Service pour gérer les indisponibilités studio
class UnavailabilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'studio_unavailabilities';

  /// Stream des indisponibilités pour un studio
  Stream<List<Unavailability>> streamByStudioId(String studioId) {
    return _firestore
        .collection(_collection)
        .where('studioId', isEqualTo: studioId)
        .orderBy('start', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => Unavailability.fromFirestore(d)).toList());
  }

  /// Récupère les indisponibilités pour une plage de dates
  Future<List<Unavailability>> getByDateRange(
    String studioId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studioId', isEqualTo: studioId)
          .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('start', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      return snapshot.docs.map((d) => Unavailability.fromFirestore(d)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Récupère les indisponibilités pour un jour spécifique
  Future<List<Unavailability>> getByDate(String studioId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getByDateRange(studioId, startOfDay, endOfDay);
  }

  /// Crée une indisponibilité manuelle
  Future<String> create(Unavailability unavailability) async {
    final docRef = await _firestore.collection(_collection).add(unavailability.toMap());
    return docRef.id;
  }

  /// Met à jour une indisponibilité
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update(data);
  }

  /// Supprime une indisponibilité
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  /// Supprime toutes les indisponibilités d'une source pour un studio
  Future<void> deleteBySource(String studioId, UnavailabilitySource source) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('studioId', isEqualTo: studioId)
        .where('source', isEqualTo: source.value)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Vérifie si un créneau est en conflit avec des indisponibilités
  Future<bool> hasConflict(
    String studioId,
    DateTime start,
    DateTime end,
  ) async {
    final unavailabilities = await getByDateRange(
      studioId,
      start.subtract(const Duration(days: 1)),
      end.add(const Duration(days: 1)),
    );

    for (final u in unavailabilities) {
      if (u.overlapsWith(start, end)) {
        return true;
      }
    }
    return false;
  }
}
