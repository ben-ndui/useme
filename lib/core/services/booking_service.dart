import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/models/models_exports.dart';

/// Booking Service - CRUD operations for session bookings
class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'useme_bookings';

  /// Get a new booking ID
  String getNewBookingId() => _firestore.collection(_collection).doc().id;

  /// Create a new booking
  Future<SmoothResponse<Booking>> createBooking(Booking booking) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final newBooking = booking.copyWith(id: docRef.id);
      await docRef.set(newBooking.toMap());
      return SmoothResponse(code: 200, message: 'Réservation créée', data: newBooking);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: null);
    }
  }

  /// Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookingId).get();
      if (doc.exists && doc.data() != null) {
        return Booking.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all bookings for a studio
  Future<List<Booking>> getBookingsByStudioId(String studioId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studioId', isEqualTo: studioId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Booking.fromMap(doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  /// Stream bookings for real-time updates
  Stream<List<Booking>> streamBookingsByStudioId(String studioId) {
    return _firestore
        .collection(_collection)
        .where('studioId', isEqualTo: studioId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromMap(d.data())).toList());
  }

  /// Stream bookings for an artist
  Stream<List<Booking>> streamBookingsByArtistId(String artistId) {
    return _firestore
        .collection(_collection)
        .where('artistId', isEqualTo: artistId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromMap(d.data())).toList());
  }

  /// Update booking
  Future<SmoothResponse<bool>> updateBooking(
    String bookingId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update(updates);
      return SmoothResponse(code: 200, message: 'Réservation mise à jour', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Delete booking
  Future<SmoothResponse<bool>> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).delete();
      return SmoothResponse(code: 200, message: 'Réservation supprimée', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Confirm a booking
  Future<SmoothResponse<bool>> confirmBooking(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': BookingStatus.confirmed.name,
        'confirmedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Réservation confirmée', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Complete a booking
  Future<SmoothResponse<bool>> completeBooking(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': BookingStatus.completed.name,
        'completedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Réservation terminée', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Cancel a booking
  Future<SmoothResponse<bool>> cancelBooking(String bookingId, String? reason) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': BookingStatus.cancelled.name,
        'cancelledAt': DateTime.now().millisecondsSinceEpoch,
        'cancellationReason': reason,
      });
      return SmoothResponse(code: 200, message: 'Réservation annulée', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Get booking count for a studio
  Future<int> getBookingCount(String studioId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studioId', isEqualTo: studioId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get confirmed bookings count for a studio
  Future<int> getConfirmedBookingCount(String studioId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studioId', isEqualTo: studioId)
          .where('status', isEqualTo: BookingStatus.confirmed.name)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
