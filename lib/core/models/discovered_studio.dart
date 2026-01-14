import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useme/core/models/studio_profile.dart';

/// Studio discovered via location-based search (Google Places or internal DB)
class DiscoveredStudio {
  final String id;
  final String name;
  final String? address;
  final LatLng position;
  final double? rating;
  final int? reviewCount;
  final String? photoUrl;
  final String? phoneNumber;
  final String? website;
  final bool isPartner; // Studio registered on Use Me
  final List<String> services;
  final double? distanceMeters;
  final StudioType studioType;

  const DiscoveredStudio({
    required this.id,
    required this.name,
    this.address,
    required this.position,
    this.rating,
    this.reviewCount,
    this.photoUrl,
    this.phoneNumber,
    this.website,
    this.isPartner = false,
    this.services = const [],
    this.distanceMeters,
    this.studioType = StudioType.independent,
  });

  /// Create from Google Places API response
  factory DiscoveredStudio.fromGooglePlace(Map<String, dynamic> json) {
    final location = json['geometry']?['location'];
    final photos = json['photos'] as List?;

    return DiscoveredStudio(
      id: json['place_id'] ?? '',
      name: json['name'] ?? 'Studio inconnu',
      address: json['vicinity'] ?? json['formatted_address'],
      position: LatLng(
        location?['lat']?.toDouble() ?? 0,
        location?['lng']?.toDouble() ?? 0,
      ),
      rating: json['rating']?.toDouble(),
      reviewCount: json['user_ratings_total'],
      photoUrl: photos != null && photos.isNotEmpty
          ? _buildPhotoUrl(photos[0]['photo_reference'])
          : null,
      isPartner: false,
    );
  }

  /// Create from internal Firestore document
  factory DiscoveredStudio.fromFirestore(
    Map<String, dynamic> json,
    String id,
  ) {
    return DiscoveredStudio(
      id: id,
      name: json['name'] ?? json['displayName'] ?? 'Studio',
      address: json['address'],
      position: LatLng(
        (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
        (json['longitude'] ?? json['lng'] ?? 0).toDouble(),
      ),
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      photoUrl: json['photoURL'] ?? json['photoUrl'],
      phoneNumber: json['phoneNumber'],
      website: json['website'],
      isPartner: true,
      services: List<String>.from(json['services'] ?? []),
      studioType: StudioType.fromString(json['studioType'] as String?),
    );
  }

  /// Copy with distance
  DiscoveredStudio copyWithDistance(double distance) {
    return DiscoveredStudio(
      id: id,
      name: name,
      address: address,
      position: position,
      rating: rating,
      reviewCount: reviewCount,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      website: website,
      isPartner: isPartner,
      services: services,
      distanceMeters: distance,
      studioType: studioType,
    );
  }

  /// Format distance for display
  String get formattedDistance {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.round()} m';
    }
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km';
  }

  static String _buildPhotoUrl(String photoReference) {
    const apiKey = 'AIzaSyBQFkJ6oG4RTRRb6RbJ3Tk0MfrA1seHTqM';
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=400&photo_reference=$photoReference&key=$apiKey';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredStudio &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
