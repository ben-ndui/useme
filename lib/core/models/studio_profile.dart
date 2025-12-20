import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Profil studio pour les admins partenaires
class StudioProfile extends Equatable {
  /// Nom du studio (affiché aux artistes)
  final String name;

  /// Description / bio du studio
  final String? description;

  /// Adresse complète
  final String? address;

  /// Ville
  final String? city;

  /// Code postal
  final String? postalCode;

  /// Pays
  final String? country;

  /// Position GPS pour la map
  final GeoPoint? location;

  /// Photos du studio
  final List<String> photos;

  /// Genres musicaux spécialisés
  final List<String> genres;

  /// Services proposés (recording, mixing, mastering...)
  final List<String> services;

  /// Tarif horaire de base
  final double? hourlyRate;

  /// Devise
  final String currency;

  /// Horaires d'ouverture (ex: {"monday": {"open": "09:00", "close": "22:00"}})
  final Map<String, dynamic>? openingHours;

  /// ID Google Place (si lié à un lieu Google)
  final String? googlePlaceId;

  /// Nom du lieu Google (pour affichage)
  final String? googlePlaceName;

  /// Note moyenne (0-5)
  final double? rating;

  /// Nombre d'avis
  final int? reviewCount;

  /// Site web
  final String? website;

  /// Téléphone du studio
  final String? phone;

  /// Studio vérifié par l'équipe
  final bool isVerified;

  /// Date de revendication du studio
  final DateTime? claimedAt;

  const StudioProfile({
    required this.name,
    this.description,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.location,
    this.photos = const [],
    this.genres = const [],
    this.services = const [],
    this.hourlyRate,
    this.currency = 'EUR',
    this.openingHours,
    this.googlePlaceId,
    this.googlePlaceName,
    this.rating,
    this.reviewCount,
    this.website,
    this.phone,
    this.isVerified = false,
    this.claimedAt,
  });

  /// Crée depuis une Map Firestore
  factory StudioProfile.fromMap(Map<String, dynamic> map) {
    GeoPoint? loc;
    if (map['location'] != null) {
      if (map['location'] is GeoPoint) {
        loc = map['location'] as GeoPoint;
      } else if (map['location'] is Map) {
        final locMap = map['location'] as Map<String, dynamic>;
        loc = GeoPoint(
          (locMap['latitude'] ?? 0.0).toDouble(),
          (locMap['longitude'] ?? 0.0).toDouble(),
        );
      }
    }

    return StudioProfile(
      name: map['name'] ?? '',
      description: map['description'],
      address: map['address'],
      city: map['city'],
      postalCode: map['postalCode'],
      country: map['country'],
      location: loc,
      photos: List<String>.from(map['photos'] ?? []),
      genres: List<String>.from(map['genres'] ?? []),
      services: List<String>.from(map['services'] ?? []),
      hourlyRate: (map['hourlyRate'] as num?)?.toDouble(),
      currency: map['currency'] ?? 'EUR',
      openingHours: map['openingHours'] as Map<String, dynamic>?,
      googlePlaceId: map['googlePlaceId'],
      googlePlaceName: map['googlePlaceName'],
      rating: (map['rating'] as num?)?.toDouble(),
      reviewCount: map['reviewCount'] as int?,
      website: map['website'],
      phone: map['phone'],
      isVerified: map['isVerified'] ?? false,
      claimedAt: map['claimedAt'] != null
          ? (map['claimedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convertit en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'location': location,
      'photos': photos,
      'genres': genres,
      'services': services,
      'hourlyRate': hourlyRate,
      'currency': currency,
      'openingHours': openingHours,
      'googlePlaceId': googlePlaceId,
      'googlePlaceName': googlePlaceName,
      'rating': rating,
      'reviewCount': reviewCount,
      'website': website,
      'phone': phone,
      'isVerified': isVerified,
      'claimedAt': claimedAt != null ? Timestamp.fromDate(claimedAt!) : null,
    };
  }

  /// Copie avec modifications
  StudioProfile copyWith({
    String? name,
    String? description,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    GeoPoint? location,
    List<String>? photos,
    List<String>? genres,
    List<String>? services,
    double? hourlyRate,
    String? currency,
    Map<String, dynamic>? openingHours,
    String? googlePlaceId,
    String? googlePlaceName,
    double? rating,
    int? reviewCount,
    String? website,
    String? phone,
    bool? isVerified,
    DateTime? claimedAt,
  }) {
    return StudioProfile(
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      location: location ?? this.location,
      photos: photos ?? this.photos,
      genres: genres ?? this.genres,
      services: services ?? this.services,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      openingHours: openingHours ?? this.openingHours,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
      googlePlaceName: googlePlaceName ?? this.googlePlaceName,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  /// Adresse formatée complète
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Vérifie si le studio a une position GPS
  bool get hasLocation => location != null;

  /// Vérifie si le studio est lié à Google
  bool get isLinkedToGoogle => googlePlaceId != null;

  @override
  List<Object?> get props => [
        name,
        description,
        address,
        city,
        location,
        photos,
        genres,
        services,
        hourlyRate,
        googlePlaceId,
        rating,
        isVerified,
      ];
}
