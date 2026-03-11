import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:smoothandesign_package/core/models/working_hours.dart';
import 'package:useme/core/models/payment_method.dart';

/// Types de professionnels pouvant proposer leurs services
enum ProType {
  soundEngineer,
  musician,
  artisticDirector,
  producer,
  vocalist,
  composer;

  static ProType fromString(String? value) {
    return ProType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProType.soundEngineer,
    );
  }

  String get label {
    switch (this) {
      case ProType.soundEngineer:
        return 'Ingenieur son';
      case ProType.musician:
        return 'Musicien';
      case ProType.artisticDirector:
        return 'Directeur artistique';
      case ProType.producer:
        return 'Realisateur / Beatmaker';
      case ProType.vocalist:
        return 'Chanteur / Choriste';
      case ProType.composer:
        return 'Compositeur / Arrangeur';
    }
  }
}

/// Profil professionnel activable par n'importe quel utilisateur
/// pour proposer ses services sur la marketplace.
class ProProfile extends Equatable {
  /// Types de services proposés (un pro peut cumuler)
  final List<ProType> proTypes;

  /// Nom professionnel / nom de scène
  final String displayName;

  /// Bio / description des services
  final String? bio;

  /// Spécialités (ex: "Mix voix", "Mastering analog", "Beatmaking trap")
  final List<String> specialties;

  /// Instruments joués (pour musiciens/compositeurs)
  final List<String> instruments;

  /// Genres musicaux
  final List<String> genres;

  /// DAWs maîtrisés (pour ingés/producteurs)
  final List<String> daws;

  /// Tarif horaire de base
  final double? hourlyRate;

  /// Devise
  final String currency;

  /// Propose des services à distance
  final bool remote;

  /// Ville
  final String? city;

  /// Position GPS
  final GeoPoint? location;

  /// Photo de profil choisie (parmi portfolio ou photo de compte)
  final String? profilePhotoUrl;

  /// Photos / portfolio
  final List<String> portfolioUrls;

  /// Lien site web
  final String? website;

  /// Téléphone
  final String? phone;

  /// Horaires de disponibilité
  final WorkingHours? workingHours;

  /// Note moyenne (0-5)
  final double? rating;

  /// Nombre d'avis
  final int? reviewCount;

  /// Profil vérifié par l'équipe
  final bool isVerified;

  /// Profil actuellement disponible pour des missions
  final bool isAvailable;

  /// Date d'activation du profil pro
  final DateTime? activatedAt;

  /// Moyens de paiement acceptés par le pro
  final List<PaymentMethod> paymentMethods;

  const ProProfile({
    required this.displayName,
    this.proTypes = const [],
    this.bio,
    this.specialties = const [],
    this.instruments = const [],
    this.genres = const [],
    this.daws = const [],
    this.hourlyRate,
    this.currency = 'EUR',
    this.remote = false,
    this.city,
    this.location,
    this.profilePhotoUrl,
    this.portfolioUrls = const [],
    this.website,
    this.phone,
    this.workingHours,
    this.rating,
    this.reviewCount,
    this.isVerified = false,
    this.isAvailable = true,
    this.activatedAt,
    this.paymentMethods = const [],
  });

  factory ProProfile.fromMap(Map<String, dynamic> map) {
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

    return ProProfile(
      displayName: map['displayName'] ?? '',
      proTypes: (map['proTypes'] as List<dynamic>?)
              ?.map((e) => ProType.fromString(e as String?))
              .toList() ??
          [],
      bio: map['bio'],
      specialties: List<String>.from(map['specialties'] ?? []),
      instruments: List<String>.from(map['instruments'] ?? []),
      genres: List<String>.from(map['genres'] ?? []),
      daws: List<String>.from(map['daws'] ?? []),
      hourlyRate: (map['hourlyRate'] as num?)?.toDouble(),
      currency: map['currency'] ?? 'EUR',
      remote: map['remote'] ?? false,
      city: map['city'],
      location: loc,
      profilePhotoUrl: map['profilePhotoUrl'],
      portfolioUrls: List<String>.from(map['portfolioUrls'] ?? []),
      website: map['website'],
      phone: map['phone'],
      workingHours: map['workingHours'] != null
          ? WorkingHours.fromMap(map['workingHours'] as Map<String, dynamic>)
          : null,
      rating: (map['rating'] as num?)?.toDouble(),
      reviewCount: map['reviewCount'] as int?,
      isVerified: map['isVerified'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      activatedAt: map['activatedAt'] != null
          ? (map['activatedAt'] is Timestamp
              ? (map['activatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['activatedAt'].toString()))
          : null,
      paymentMethods: (map['paymentMethods'] as List<dynamic>?)
              ?.map((m) => PaymentMethod.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'proTypes': proTypes.map((e) => e.name).toList(),
      'bio': bio,
      'specialties': specialties,
      'instruments': instruments,
      'genres': genres,
      'daws': daws,
      'hourlyRate': hourlyRate,
      'currency': currency,
      'remote': remote,
      'city': city,
      'location': location,
      'profilePhotoUrl': profilePhotoUrl,
      'portfolioUrls': portfolioUrls,
      'website': website,
      'phone': phone,
      'workingHours': workingHours?.toMap(),
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'activatedAt':
          activatedAt != null ? Timestamp.fromDate(activatedAt!) : null,
      'paymentMethods': paymentMethods.map((m) => m.toMap()).toList(),
    };
  }

  ProProfile copyWith({
    String? displayName,
    List<ProType>? proTypes,
    String? bio,
    List<String>? specialties,
    List<String>? instruments,
    List<String>? genres,
    List<String>? daws,
    double? hourlyRate,
    String? currency,
    bool? remote,
    String? city,
    GeoPoint? location,
    String? profilePhotoUrl,
    List<String>? portfolioUrls,
    String? website,
    String? phone,
    WorkingHours? workingHours,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    bool? isAvailable,
    DateTime? activatedAt,
    List<PaymentMethod>? paymentMethods,
  }) {
    return ProProfile(
      displayName: displayName ?? this.displayName,
      proTypes: proTypes ?? this.proTypes,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      instruments: instruments ?? this.instruments,
      genres: genres ?? this.genres,
      daws: daws ?? this.daws,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      remote: remote ?? this.remote,
      city: city ?? this.city,
      location: location ?? this.location,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      workingHours: workingHours ?? this.workingHours,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      activatedAt: activatedAt ?? this.activatedAt,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }

  /// Adresse formatée
  String get formattedLocation {
    if (city != null && city!.isNotEmpty) return city!;
    if (remote) return 'A distance';
    return '';
  }

  /// Vérifie si le pro a une position GPS
  bool get hasLocation => location != null;

  /// Vérifie si le pro est musicien
  bool get isMusician => proTypes.contains(ProType.musician);

  /// Vérifie si le pro est ingé son
  bool get isSoundEngineer => proTypes.contains(ProType.soundEngineer);

  /// Vérifie si le pro est producteur
  bool get isProducer => proTypes.contains(ProType.producer);

  /// Vérifie si le pro a configuré ses horaires
  bool get hasWorkingHours => workingHours != null;

  /// Vérifie si le pro a un tarif défini
  bool get hasRate => hourlyRate != null && hourlyRate! > 0;

  /// Moyens de paiement activés
  List<PaymentMethod> get enabledPaymentMethods =>
      paymentMethods.where((m) => m.isEnabled).toList();

  /// Vérifie si le pro a configuré des moyens de paiement
  bool get hasPaymentMethods => enabledPaymentMethods.isNotEmpty;

  /// Label combiné des types (ex: "Musicien, Ingenieur son")
  String get proTypesLabel => proTypes.map((t) => t.label).join(', ');

  /// Tarif formaté pour affichage
  String get formattedRate {
    if (!hasRate) return 'Sur devis';
    return '${hourlyRate!.toStringAsFixed(0)} $currency/h';
  }

  @override
  List<Object?> get props => [
        displayName,
        proTypes,
        bio,
        specialties,
        instruments,
        genres,
        daws,
        hourlyRate,
        remote,
        city,
        location,
        profilePhotoUrl,
        portfolioUrls,
        rating,
        isVerified,
        isAvailable,
        paymentMethods,
      ];
}
