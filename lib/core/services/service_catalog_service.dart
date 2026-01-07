import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:useme/core/models/models_exports.dart';
import 'package:uuid/uuid.dart' show Uuid;

/// Service Catalog Service - CRUD operations for studio services
class ServiceCatalogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'useme_studio_services';
  final Uuid _uuid = const Uuid();

  /// Generate new service ID
  String getNewServiceId() => _uuid.v4();

  /// Create a new studio service
  Future<SmoothResponse<bool>> createService(
    String studioId,
    StudioService service,
  ) async {
    try {
      final data = service.toMap();
      data['studioId'] = studioId;
      await _firestore.collection(_collection).doc(service.id).set(data);
      return SmoothResponse(code: 200, message: 'Service créé', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Get all services for a studio
  Future<List<StudioService>> getServicesByStudioId(String studioId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studioId', isEqualTo: studioId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout: Firestore index may be missing'),
          );
      return snapshot.docs.map((doc) => StudioService.fromMap({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      debugPrint('❌ ServiceCatalogService.getServicesByStudioId error: $e');
      return [];
    }
  }

  /// Get only active services for a studio
  Future<List<StudioService>> getActiveServicesByStudioId(String studioId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studioId', isEqualTo: studioId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout: Firestore index may be missing'),
          );
      return snapshot.docs.map((doc) => StudioService.fromMap({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      debugPrint('❌ ServiceCatalogService.getActiveServicesByStudioId error: $e');
      return [];
    }
  }

  /// Stream services for real-time updates
  Stream<List<StudioService>> streamServicesByStudioId(String studioId) {
    return _firestore
        .collection(_collection)
        .where('studioId', isEqualTo: studioId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => StudioService.fromMap({...d.data(), 'id': d.id})).toList());
  }

  /// Get single service by ID
  Future<StudioService?> getServiceById(String serviceId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(serviceId).get();
      if (!doc.exists) return null;
      return StudioService.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  /// Search services by name or description
  Future<List<StudioService>> searchServices(String studioId, String query) async {
    try {
      final services = await getServicesByStudioId(studioId);
      final lowercaseQuery = query.toLowerCase();
      return services.where((service) {
        final nameMatch = service.name.toLowerCase().contains(lowercaseQuery);
        final descMatch =
            service.description?.toLowerCase().contains(lowercaseQuery) ?? false;
        return nameMatch || descMatch;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update service
  Future<SmoothResponse<bool>> updateService(
    String serviceId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
      await _firestore.collection(_collection).doc(serviceId).update(updates);
      return SmoothResponse(code: 200, message: 'Service mis à jour', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Soft delete service (set isActive to false)
  Future<SmoothResponse<bool>> deactivateService(String serviceId) async {
    try {
      await _firestore.collection(_collection).doc(serviceId).update({
        'isActive': false,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Service désactivé', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Reactivate service
  Future<SmoothResponse<bool>> reactivateService(String serviceId) async {
    try {
      await _firestore.collection(_collection).doc(serviceId).update({
        'isActive': true,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return SmoothResponse(code: 200, message: 'Service réactivé', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Hard delete service
  Future<SmoothResponse<bool>> deleteService(String serviceId) async {
    try {
      await _firestore.collection(_collection).doc(serviceId).delete();
      return SmoothResponse(code: 200, message: 'Service supprimé', data: true);
    } catch (e) {
      return SmoothResponse(code: 500, message: 'Erreur: $e', data: false);
    }
  }

  /// Get services count for a studio
  Future<int> getServicesCount(String studioId) async {
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
}
