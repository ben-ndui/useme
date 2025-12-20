import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/discovered_studio.dart';
import 'package:useme/core/models/studio_profile.dart';
import 'studio_discovery_service.dart';

/// Service pour revendiquer/lier un studio Google à un compte admin
class StudioClaimService {
  static final StudioClaimService _instance = StudioClaimService._internal();
  factory StudioClaimService() => _instance;
  StudioClaimService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StudioDiscoveryService _discoveryService = StudioDiscoveryService();

  /// Recherche des studios à proximité pour revendication
  Future<List<DiscoveredStudio>> searchStudiosForClaim({
    required LatLng position,
    int radius = 10000,
  }) async {
    return _discoveryService.findNearbyStudios(
      position,
      radius: radius,
      forceRefresh: true,
    );
  }

  /// Vérifie si un studio Google est déjà revendiqué
  Future<bool> isStudioClaimed(String googlePlaceId) async {
    final query = await _firestore
        .collection('users')
        .where('studioProfile.googlePlaceId', isEqualTo: googlePlaceId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Récupère l'ID du propriétaire si le studio est revendiqué
  Future<String?> getStudioOwnerId(String googlePlaceId) async {
    final query = await _firestore
        .collection('users')
        .where('studioProfile.googlePlaceId', isEqualTo: googlePlaceId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    return null;
  }

  /// Revendique un studio Google pour un admin
  Future<void> claimStudio({
    required String userId,
    required DiscoveredStudio studio,
  }) async {
    // Vérifier si déjà revendiqué
    final existingOwner = await getStudioOwnerId(studio.id);
    if (existingOwner != null && existingOwner != userId) {
      throw Exception('Ce studio est déjà revendiqué par un autre utilisateur');
    }

    // Récupérer les détails complets du studio
    final details = await _discoveryService.getStudioDetails(studio.id);
    final studioData = details ?? studio;

    // Créer le profil studio
    final studioProfile = StudioProfile(
      name: studioData.name,
      address: studioData.address,
      location: GeoPoint(
        studioData.position.latitude,
        studioData.position.longitude,
      ),
      photos: studioData.photoUrl != null ? [studioData.photoUrl!] : [],
      googlePlaceId: studio.id,
      googlePlaceName: studioData.name,
      rating: studioData.rating,
      reviewCount: studioData.reviewCount,
      website: studioData.website,
      phone: studioData.phoneNumber,
      services: studioData.services,
      claimedAt: DateTime.now(),
    );

    // Mettre à jour l'utilisateur
    await _firestore.collection('users').doc(userId).update({
      'isPartner': true,
      'studioProfile': studioProfile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Crée un studio manuellement (sans lien Google)
  Future<void> createManualStudio({
    required String userId,
    required StudioProfile profile,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'isPartner': true,
      'studioProfile': profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Met à jour le profil studio
  Future<void> updateStudioProfile({
    required String userId,
    required StudioProfile profile,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'studioProfile': profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Retire le statut partenaire (déclaime)
  Future<void> unclaimStudio(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'isPartner': false,
      'studioProfile': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Récupère tous les studios partenaires
  Future<List<AppUser>> getPartnerStudios() async {
    final query = await _firestore
        .collection('users')
        .where('isPartner', isEqualTo: true)
        .where('role', isEqualTo: 'admin')
        .get();

    return query.docs.map((doc) => AppUser.fromMap(doc.data(), doc.id)).toList();
  }

  /// Stream des studios partenaires proches d'une position
  Stream<List<AppUser>> streamPartnerStudiosNear(
    LatLng position, {
    double radiusKm = 50,
  }) {
    // Calcul approximatif des bornes géographiques
    // 1 degré ≈ 111km
    final latDelta = radiusKm / 111.0;
    final lngDelta = radiusKm / (111.0 * _cos(position.latitude));

    final minLat = position.latitude - latDelta;
    final maxLat = position.latitude + latDelta;
    final minLng = position.longitude - lngDelta;
    final maxLng = position.longitude + lngDelta;

    return _firestore
        .collection('users')
        .where('isPartner', isEqualTo: true)
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .where((user) {
        final loc = user.studioProfile?.location;
        if (loc == null) return false;
        return loc.latitude >= minLat &&
            loc.latitude <= maxLat &&
            loc.longitude >= minLng &&
            loc.longitude <= maxLng;
      }).toList();
    });
  }

  double _cos(double degrees) {
    return _cosTable[(degrees.abs().toInt() % 90)];
  }

  static const List<double> _cosTable = [
    1.0, 0.9998, 0.9994, 0.9986, 0.9976, 0.9962, 0.9945, 0.9925,
    0.9903, 0.9877, 0.9848, 0.9816, 0.9781, 0.9744, 0.9703, 0.9659,
    0.9613, 0.9563, 0.9511, 0.9455, 0.9397, 0.9336, 0.9272, 0.9205,
    0.9135, 0.9063, 0.8988, 0.8910, 0.8829, 0.8746, 0.8660, 0.8572,
    0.8480, 0.8387, 0.8290, 0.8192, 0.8090, 0.7986, 0.7880, 0.7771,
    0.7660, 0.7547, 0.7431, 0.7314, 0.7193, 0.7071, 0.6947, 0.6820,
    0.6691, 0.6561, 0.6428, 0.6293, 0.6157, 0.6018, 0.5878, 0.5736,
    0.5592, 0.5446, 0.5299, 0.5150, 0.5000, 0.4848, 0.4695, 0.4540,
    0.4384, 0.4226, 0.4067, 0.3907, 0.3746, 0.3584, 0.3420, 0.3256,
    0.3090, 0.2924, 0.2756, 0.2588, 0.2419, 0.2250, 0.2079, 0.1908,
    0.1736, 0.1564, 0.1392, 0.1219, 0.1045, 0.0872, 0.0698, 0.0523,
    0.0349, 0.0175,
  ];
}
