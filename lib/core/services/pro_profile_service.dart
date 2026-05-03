import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smoothandesign_package/smoothandesign.dart' show SmoothResponse;
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/pro_profile.dart';
import 'package:uzme/core/services/studio_discovery_service.dart';
import 'package:uzme/core/utils/app_logger.dart';

/// Service pour gérer les profils professionnels (marketplace).
class ProProfileService {
  final FirebaseFirestore _firestore;
  final StudioDiscoveryService _discoveryService;

  ProProfileService({
    FirebaseFirestore? firestore,
    StudioDiscoveryService? discoveryService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _discoveryService = discoveryService ?? StudioDiscoveryService();

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Geocode la ville du profil pour obtenir les coordonnées GPS.
  Future<ProProfile> _geocodeCity(ProProfile profile) async {
    final city = profile.city;
    if (city == null || city.isEmpty) return profile;

    try {
      final latLng = await _discoveryService.geocodeAddress(city);
      if (latLng != null) {
        return profile.copyWith(
          location: GeoPoint(latLng.latitude, latLng.longitude),
        );
      }
    } catch (e) {
      appLog('ProProfileService: geocoding failed for "$city": $e');
    }
    return profile;
  }

  /// Active un profil pro pour un utilisateur.
  Future<SmoothResponse<ProProfile>> activateProProfile({
    required String userId,
    required ProProfile profile,
  }) async {
    try {
      var finalProfile = profile.activatedAt != null
          ? profile
          : profile.copyWith(activatedAt: DateTime.now());

      finalProfile = await _geocodeCity(finalProfile);

      await _users.doc(userId).update({
        'proProfile': finalProfile.toMap(),
      });

      appLog('ProProfileService: profil pro active pour $userId');
      return SmoothResponse(
        data: finalProfile,
        message: 'Profil pro active',
        code: 200,
      );
    } catch (e) {
      return SmoothResponse(
        data: profile,
        message: 'Erreur activation: $e',
        code: 500,
      );
    }
  }

  /// Met à jour le profil pro.
  Future<SmoothResponse<bool>> updateProProfile({
    required String userId,
    required ProProfile profile,
  }) async {
    try {
      final finalProfile = await _geocodeCity(profile);
      await _users.doc(userId).update({
        'proProfile': finalProfile.toMap(),
      });
      return SmoothResponse(data: true, message: 'Profil mis a jour', code: 200);
    } catch (e) {
      return SmoothResponse(data: false, message: 'Erreur: $e', code: 500);
    }
  }

  /// Met à jour la disponibilité du pro.
  Future<SmoothResponse<bool>> setAvailability({
    required String userId,
    required bool isAvailable,
  }) async {
    try {
      await _users.doc(userId).update({
        'proProfile.isAvailable': isAvailable,
      });
      return SmoothResponse(data: true, message: 'Disponibilite mise a jour', code: 200);
    } catch (e) {
      return SmoothResponse(data: false, message: 'Erreur: $e', code: 500);
    }
  }

  /// Désactive le profil pro (ne supprime pas les données).
  Future<SmoothResponse<bool>> deactivateProProfile(String userId) async {
    try {
      await _users.doc(userId).update({
        'proProfile.isAvailable': false,
      });
      return SmoothResponse(data: true, message: 'Profil desactive', code: 200);
    } catch (e) {
      return SmoothResponse(data: false, message: 'Erreur: $e', code: 500);
    }
  }

  /// Supprime complètement le profil pro.
  Future<SmoothResponse<bool>> deleteProProfile(String userId) async {
    try {
      await _users.doc(userId).update({
        'proProfile': FieldValue.delete(),
      });
      return SmoothResponse(data: true, message: 'Profil supprime', code: 200);
    } catch (e) {
      return SmoothResponse(data: false, message: 'Erreur: $e', code: 500);
    }
  }

  /// Récupère le profil pro d'un utilisateur.
  Future<ProProfile?> getProProfile(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null || data['proProfile'] == null) return null;

      return ProProfile.fromMap(data['proProfile'] as Map<String, dynamic>);
    } catch (e) {
      appLog('ProProfileService: erreur getProProfile: $e');
      return null;
    }
  }

  /// Récupère un utilisateur par son ID (pro ou non).
  Future<AppUser?> getUser(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data()!, doc.id);
    } catch (e) {
      appLog('ProProfileService: erreur getUser: $e');
      return null;
    }
  }

  /// Récupère un utilisateur pro complet par son ID.
  Future<AppUser?> getProUser(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;

      final user = AppUser.fromMap(doc.data()!, doc.id);
      if (!user.hasProProfile) return null;
      return user;
    } catch (e) {
      appLog('ProProfileService: erreur getProUser: $e');
      return null;
    }
  }

  /// Recherche des pros disponibles par type.
  Future<List<AppUser>> searchPros({
    List<ProType>? types,
    String? city,
    bool remoteOnly = false,
    int limit = 20,
  }) async {
    try {
      // Firestore ne permet pas de filter sur des champs nested avec arrayContains
      // On récupère tous les users avec un proProfile et on filtre côté client
      var query = _users
          .where('proProfile.isAvailable', isEqualTo: true)
          .limit(limit * 2); // Fetch extra to account for client-side filtering

      final snapshot = await query.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout recherche pros');
        },
      );

      var results = snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .where((user) => user.hasProProfile)
          .toList();

      // Filtrer par type côté client
      if (types != null && types.isNotEmpty) {
        results = results.where((user) {
          final userTypes = user.proProfile!.proTypes;
          return types.any((t) => userTypes.contains(t));
        }).toList();
      }

      // Filtrer par ville
      if (city != null && city.isNotEmpty) {
        final cityLower = city.toLowerCase();
        results = results.where((user) {
          final proCity = user.proProfile!.city?.toLowerCase() ?? '';
          return proCity.contains(cityLower);
        }).toList();
      }

      // Filtrer remote only
      if (remoteOnly) {
        results = results.where((user) => user.proProfile!.remote).toList();
      }

      // Trier : vérifiés en premier, puis par rating
      results.sort((a, b) {
        final aProfile = a.proProfile!;
        final bProfile = b.proProfile!;

        // Vérifiés en premier
        if (aProfile.isVerified && !bProfile.isVerified) return -1;
        if (!aProfile.isVerified && bProfile.isVerified) return 1;

        // Puis par rating décroissant
        final aRating = aProfile.rating ?? 0;
        final bRating = bProfile.rating ?? 0;
        return bRating.compareTo(aRating);
      });

      return results.take(limit).toList();
    } catch (e) {
      appLog('ProProfileService: erreur searchPros: $e');
      return [];
    }
  }

  /// Recherche de pros par texte (nom, spécialités, instruments).
  List<AppUser> filterProsByText(List<AppUser> pros, String query) {
    if (query.isEmpty) return pros;

    final queryLower = query.toLowerCase();
    return pros.where((user) {
      final profile = user.proProfile;
      if (profile == null) return false;

      return profile.displayName.toLowerCase().contains(queryLower) ||
          profile.specialties.any((s) => s.toLowerCase().contains(queryLower)) ||
          profile.instruments.any((i) => i.toLowerCase().contains(queryLower)) ||
          profile.genres.any((g) => g.toLowerCase().contains(queryLower)) ||
          profile.proTypesLabel.toLowerCase().contains(queryLower);
    }).toList();
  }
}
