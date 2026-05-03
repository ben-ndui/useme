import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uzme/core/models/app_user.dart';
import 'package:uzme/core/models/discovered_studio.dart';
import 'package:uzme/core/services/env_service.dart';
import 'package:uzme/core/services/location_service.dart';
import 'package:uzme/core/utils/app_logger.dart';

/// Service for discovering studios nearby using Google Places API + Firestore partners
class StudioDiscoveryService {
  static final StudioDiscoveryService _instance =
      StudioDiscoveryService._internal();
  factory StudioDiscoveryService({
    FirebaseFirestore? firestore,
    LocationService? locationService,
    http.Client? httpClient,
  }) {
    if (firestore != null || locationService != null || httpClient != null) {
      return StudioDiscoveryService._di(
        firestore: firestore ?? FirebaseFirestore.instance,
        locationService: locationService ?? LocationService(),
        httpClient: httpClient ?? http.Client(),
      );
    }
    return _instance;
  }
  StudioDiscoveryService._internal()
      : _firestore = FirebaseFirestore.instance,
        _locationService = LocationService(),
        _httpClient = http.Client();
  StudioDiscoveryService._di({
    required FirebaseFirestore firestore,
    required LocationService locationService,
    required http.Client httpClient,
  })  : _firestore = firestore,
        _locationService = locationService,
        _httpClient = httpClient;

  /// Google Maps API Key from environment
  String get _apiKey => EnvService.googleMapsApiKey;
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  final LocationService _locationService;
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

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
      List<DiscoveredStudio> mergedStudios;
      try {
        mergedStudios = await _mergeStudiosWithClaims(
          googleStudios,
          position,
          radius,
        );
      } catch (e) {
        appLog('⚠️ StudioDiscoveryService: merge failed, using Google Places only: $e');
        mergedStudios = googleStudios;
      }

      _cachedStudios = mergedStudios;
      _cacheTime = DateTime.now();
      _cachedPosition = position;
      return _updateDistances(mergedStudios, position);
    } catch (e, stackTrace) {
      appLog('⚠️ StudioDiscoveryService: findNearbyStudios error: $e');
      appLog('⚠️ StackTrace: $stackTrace');
      // Return cached if available, otherwise empty list
      if (_cachedStudios != null) {
        return _updateDistances(_cachedStudios!, position);
      }
      return [];
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
    if (FirebaseAuth.instance.currentUser == null) return googleStudios;

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
            appLog('⚠️ StudioDiscoveryService: Timeout fetching partners');
            throw Exception('Timeout');
          },
        );

    final partnerStudios = <DiscoveredStudio>[];
    final claimedGooglePlaceIds = <String>{};

    for (final doc in query.docs) {
      try {
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
      } catch (e) {
        appLog('⚠️ StudioDiscoveryService: Error parsing partner ${doc.id}: $e');
      }
    }

    // Fetch pro profiles with location
    final proStudios = await _fetchNearbyPros(position, radius);

    // Filter out Google studios that are claimed
    final filteredGoogle = googleStudios
        .where((s) => !claimedGooglePlaceIds.contains(s.id))
        .toList();

    // Partner studios first, then pros, then remaining Google studios
    return [...partnerStudios, ...proStudios, ...filteredGoogle];
  }

  /// Fetch available pro profiles with a location within radius.
  Future<List<DiscoveredStudio>> _fetchNearbyPros(
    LatLng position,
    int radius,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('proProfile.isAvailable', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 10));

      final pros = <DiscoveredStudio>[];
      for (final doc in query.docs) {
        try {
          final user = AppUser.fromMap(doc.data(), doc.id);
          if (!user.hasProProfile || !user.proProfile!.hasLocation) continue;

          final studio = DiscoveredStudio.fromProUser(user);
          final distance = _locationService.distanceBetween(position, studio.position);
          if (distance <= radius) {
            pros.add(studio);
          }
        } catch (e) {
          appLog('⚠️ StudioDiscoveryService: Error parsing pro ${doc.id}: $e');
        }
      }
      return pros;
    } catch (e) {
      appLog('⚠️ StudioDiscoveryService: Error fetching pros: $e');
      return [];
    }
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

    final response = await _httpClient.get(url).timeout(const Duration(seconds: 15));

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
        // Pioneers en premier
        if (a.isPioneer && !b.isPioneer) return -1;
        if (!a.isPioneer && b.isPioneer) return 1;
        // Puis partenaires
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
      final response = await _httpClient.get(url);
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
      final response = await _httpClient.get(url).timeout(const Duration(seconds: 10));

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
      appLog('⚠️ Geocoding error: $e');
    }

    return null;
  }

}
