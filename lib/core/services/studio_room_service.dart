import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:useme/core/models/studio_room.dart';

/// Service for managing studio rooms
class StudioRoomService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'useme_studio_rooms';

  StudioRoomService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _roomsRef =>
      _firestore.collection(_collection);

  /// Get all rooms for a studio
  Future<List<StudioRoom>> getRoomsByStudio(String studioId) async {
    try {
      final snapshot = await _roomsRef
          .where('studioId', isEqualTo: studioId)
          .orderBy('createdAt', descending: false)
          .get();
      return snapshot.docs.map((doc) => StudioRoom.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ StudioRoomService.getRoomsByStudio error: $e');
      return [];
    }
  }

  /// Get active rooms for a studio (for booking)
  Future<List<StudioRoom>> getActiveRoomsByStudio(String studioId) async {
    try {
      final snapshot = await _roomsRef
          .where('studioId', isEqualTo: studioId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: false)
          .get();
      return snapshot.docs.map((doc) => StudioRoom.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('❌ StudioRoomService.getActiveRoomsByStudio error: $e');
      return [];
    }
  }

  /// Get a single room by ID
  Future<StudioRoom?> getRoomById(String roomId) async {
    try {
      final doc = await _roomsRef.doc(roomId).get();
      if (!doc.exists) return null;
      return StudioRoom.fromFirestore(doc);
    } catch (e) {
      debugPrint('❌ StudioRoomService.getRoomById error: $e');
      return null;
    }
  }

  /// Create a new room
  Future<StudioRoom?> createRoom(StudioRoom room) async {
    try {
      final docRef = await _roomsRef.add(room.toFirestore());
      return room.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('❌ StudioRoomService.createRoom error: $e');
      return null;
    }
  }

  /// Update an existing room
  Future<bool> updateRoom(StudioRoom room) async {
    try {
      await _roomsRef.doc(room.id).update({
        ...room.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ StudioRoomService.updateRoom error: $e');
      return false;
    }
  }

  /// Delete a room
  Future<bool> deleteRoom(String roomId) async {
    try {
      await _roomsRef.doc(roomId).delete();
      return true;
    } catch (e) {
      debugPrint('❌ StudioRoomService.deleteRoom error: $e');
      return false;
    }
  }

  /// Toggle room active status
  Future<bool> toggleRoomStatus(String roomId, bool isActive) async {
    try {
      await _roomsRef.doc(roomId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ StudioRoomService.toggleRoomStatus error: $e');
      return false;
    }
  }

  /// Stream rooms for a studio (real-time)
  Stream<List<StudioRoom>> streamRoomsByStudio(String studioId) {
    return _roomsRef
        .where('studioId', isEqualTo: studioId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => StudioRoom.fromFirestore(doc)).toList());
  }
}
