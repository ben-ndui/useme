import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:useme/core/models/app_user.dart';
import 'package:useme/core/models/discovered_studio.dart';
import 'package:useme/core/services/location_service.dart';

/// Service for discovering studios nearby using Google Places API + Firestore partners
class StudioDiscoveryService {
  static final StudioDiscoveryService _instance =
      StudioDiscoveryService._internal();
  factory StudioDiscoveryService() => _instance;
  StudioDiscoveryService._internal();

  static const String _apiKey = 'AIzaSyBQFkJ6oG4RTRRb6RbJ3Tk0MfrA1seHTqM';
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  final LocationService _locationService = LocationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache studios for 25 minutes per position
  List<DiscoveredStudio>? _cachedStudios;
  DateTime? _cacheTime;
  LatLng? _cachedPosition;
  static const Duration _cacheDuration = Duration(minutes: 25);
  static const double _cacheDistanceThreshold = 2000; // 2km

  /// Search for recording studios nearby (Google Places + Firestore partners)
  Future<List<DiscoveredStudio>> findNearbyStudios(
    LatLng position, {
    int radius = 5000,
    bool forceRefresh = false,
  }) async {
    // Check cache - invalidate if position changed significantly
    final isCacheValid = !forceRefresh &&
        _cachedStudios != null &&
        _cacheTime != null &&
        _cachedPosition != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration &&
        _locationService.distanceBetween(_cachedPosition!, position) < _cacheDistanceThreshold;

    if (isCacheValid) {
      return _updateDistances(_cachedStudios!, position);
    }

    try {
      // Fetch Google Places
      final googleStudios = await _searchGooglePlaces(position, radius);

      // Merge with partner studios (filters out claimed Google Places)
      final mergedStudios = await _mergeStudiosWithClaims(
        googleStudios,
        position,
        radius,
      );

      _cachedStudios = mergedStudios;
      _cacheTime = DateTime.now();
      _cachedPosition = position;
      return _updateDistances(mergedStudios, position);
    } catch (e) {
      // Return cached if available, otherwise return mock data
      if (_cachedStudios != null) {
        return _updateDistances(_cachedStudios!, position);
      }
      return _getMockStudios(position);
    }
  }

  /// Convert AppUser (partner) to DiscoveredStudio
  DiscoveredStudio _partnerToDiscoveredStudio(AppUser user) {
    final profile = user.studioProfile!;
    return DiscoveredStudio(
      id: user.uid, // Use user ID as studio ID for booking
      name: profile.name,
      address: profile.fullAddress.isNotEmpty ? profile.fullAddress : profile.address,
      position: LatLng(
        profile.location!.latitude,
        profile.location!.longitude,
      ),
      rating: profile.rating,
      reviewCount: profile.reviewCount,
      photoUrl: profile.photos.isNotEmpty ? profile.photos.first : user.photoURL,
      phoneNumber: profile.phone ?? user.phoneNumber,
      website: profile.website,
      isPartner: true,
      services: profile.services,
    );
  }

  /// Merge with claimed Google Place IDs filtering
  Future<List<DiscoveredStudio>> _mergeStudiosWithClaims(
    List<DiscoveredStudio> googleStudios,
    LatLng position,
    int radius,
  ) async {
    // Fetch partner studios (admin or superAdmin with isPartner)
    // Note: Firestore doesn't support OR in where, so we query isPartner only
    // and filter by role in Dart
    final query = await _firestore
        .collection('users')
        .where('isPartner', isEqualTo: true)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⚠️ StudioDiscoveryService: Timeout fetching partners');
            throw Exception('Timeout');
          },
        );

    final partnerStudios = <DiscoveredStudio>[];
    final claimedGooglePlaceIds = <String>{};

    for (final doc in query.docs) {
      final user = AppUser.fromMap(doc.data(), doc.id);
      // Only include admin or superAdmin roles
      if (!user.isStudio && !user.isSuperAdmin) continue;

      if (user.studioProfile != null) {
        // Track claimed Google Place ID
        if (user.studioProfile!.googlePlaceId != null) {
          claimedGooglePlaceIds.add(user.studioProfile!.googlePlaceId!);
        }
        // Add partner if has location and is within radius
        if (user.studioProfile!.location != null) {
          final studio = _partnerToDiscoveredStudio(user);
          final distance = _locationService.distanceBetween(position, studio.position);
          if (distance <= radius) {
            partnerStudios.add(studio);
          }
        }
      }
    }

    // Filter out Google studios that are claimed
    final filteredGoogle = googleStudios
        .where((s) => !claimedGooglePlaceIds.contains(s.id))
        .toList();

    // Partner studios first, then remaining Google studios
    return [...partnerStudios, ...filteredGoogle];
  }

  Future<List<DiscoveredStudio>> _searchGooglePlaces(
    LatLng position,
    int radius,
  ) async {
    final url = Uri.parse(
      '$_baseUrl?location=${position.latitude},${position.longitude}'
      '&radius=$radius'
      '&keyword=recording+studio+music+studio'
      '&type=establishment'
      '&key=$_apiKey',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List? ?? [];

      return results
          .map((place) => DiscoveredStudio.fromGooglePlace(place))
          .where((s) => s.position.latitude != 0)
          .toList();
    }

    throw Exception('Failed to fetch studios: ${response.statusCode}');
  }

  List<DiscoveredStudio> _updateDistances(
    List<DiscoveredStudio> studios,
    LatLng userPosition,
  ) {
    return studios.map((studio) {
      final distance = _locationService.distanceBetween(
        userPosition,
        studio.position,
      );
      return studio.copyWithDistance(distance);
    }).toList()
      ..sort((a, b) {
        // Partenaires en premier
        if (a.isPartner && !b.isPartner) return -1;
        if (!a.isPartner && b.isPartner) return 1;
        // Puis tri par distance croissante
        return (a.distanceMeters ?? double.infinity)
            .compareTo(b.distanceMeters ?? double.infinity);
      });
  }

  /// Get studio details by place ID
  Future<DiscoveredStudio?> getStudioDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=name,formatted_address,geometry,rating,user_ratings_total,'
      'formatted_phone_number,website,photos'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];
        if (result != null) {
          return DiscoveredStudio.fromGooglePlace(result);
        }
      }
    } catch (e) {
      // Ignore errors
    }
    return null;
  }

  /// Clear cache
  void clearCache() {
    _cachedStudios = null;
    _cacheTime = null;
    _cachedPosition = null;
  }

  /// Geocode an address to coordinates
  Future<LatLng?> geocodeAddress(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=${Uri.encodeComponent(address)}'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;

        if (results != null && results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          return LatLng(
            location['lat'] as double,
            location['lng'] as double,
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Geocoding error: $e');
    }

    return null;
  }

  /// Mock studios for testing / demo
  List<DiscoveredStudio> _getMockStudios(LatLng userPosition) {
    return [
      DiscoveredStudio(
        id: 'mock_1',
        name: 'Studio Bleu',
        address: '12 Rue de la Musique, Paris',
        position: LatLng(
          userPosition.latitude + 0.005,
          userPosition.longitude + 0.003,
        ),
        rating: 4.8,
        reviewCount: 42,
        isPartner: true,
        services: ['Enregistrement', 'Mixage', 'Mastering'],
      ),
      DiscoveredStudio(
        id: 'mock_2',
        name: 'Sound Factory',
        address: '45 Avenue du Son, Paris',
        position: LatLng(
          userPosition.latitude - 0.008,
          userPosition.longitude + 0.002,
        ),
        rating: 4.5,
        reviewCount: 28,
        isPartner: true,
        services: ['Enregistrement', 'Production'],
      ),
      DiscoveredStudio(
        id: 'mock_3',
        name: 'Le Labo Musical',
        address: '8 Rue des Artistes, Paris',
        position: LatLng(
          userPosition.latitude + 0.002,
          userPosition.longitude - 0.006,
        ),
        rating: 4.2,
        reviewCount: 15,
        isPartner: false,
        services: ['Enregistrement'],
      ),
    ].map((s) {
      final distance = _locationService.distanceBetween(userPosition, s.position);
      return s.copyWithDistance(distance);
    }).toList();
  }
}
