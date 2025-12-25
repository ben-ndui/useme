import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smoothandesign_package/smoothandesign.dart';
import 'calendar_connection.dart';
import 'studio_profile.dart';
import 'studio_subscription.dart';

/// Extension des rôles Use Me sur BaseUserRole.
///
/// Mapping:
/// - Studio (admin) → Propriétaire du studio
/// - Engineer (worker) → Ingénieur son
/// - Artist (client) → Artiste/musicien
extension UseMeRoleExtension on BaseUserRole {
  /// Label Use Me pour le rôle.
  String get useMeLabel {
    switch (this) {
      case BaseUserRole.admin:
        return 'Studio';
      case BaseUserRole.worker:
        return 'Ingénieur';
      case BaseUserRole.client:
        return 'Artiste';
      case BaseUserRole.superAdmin:
        return 'Super Admin';
      default:
        return 'Utilisateur';
    }
  }

  /// Description Use Me du rôle.
  String get useMeDescription {
    switch (this) {
      case BaseUserRole.admin:
        return 'Propriétaire du studio - gestion complète';
      case BaseUserRole.worker:
        return 'Ingénieur son - sessions assignées';
      case BaseUserRole.client:
        return 'Artiste - réservation de sessions';
      case BaseUserRole.superAdmin:
        return 'Administration système globale';
      default:
        return 'Accès de base';
    }
  }

  /// Vérifie si c'est un propriétaire de studio.
  bool get isStudio => this == BaseUserRole.admin;

  /// Vérifie si c'est un ingénieur.
  bool get isEngineer => this == BaseUserRole.worker;

  /// Vérifie si c'est un artiste.
  bool get isArtist => this == BaseUserRole.client;

  /// Vérifie si c'est un super admin.
  bool get isSuperAdmin => this == BaseUserRole.superAdmin;
}

/// Modèle utilisateur Use Me.
///
/// Étend BaseUser avec les champs spécifiques à l'app de réservation studio.
class AppUser extends BaseUser {
  /// ID du studio (pour les ingénieurs).
  final String? studioId;

  /// Liste des studios liés (pour les artistes).
  final List<String> studioIds;

  /// Nom de scène (pour les artistes).
  final String? stageName;

  /// Genres musicaux (pour les artistes).
  final List<String> genres;

  /// Biographie.
  final String? bio;

  /// Ville.
  final String? city;

  /// Connexion calendrier (Google/Apple).
  final CalendarConnection? calendarConnection;

  /// Studio visible sur la map/feed artistes (pour admins).
  final bool isPartner;

  /// Profil studio complet (pour admins partenaires).
  final StudioProfile? studioProfile;

  /// Abonnement du studio (pour admins).
  final StudioSubscription? subscription;

  /// DevMaster a accès à la config Stripe et système.
  final bool isDevMaster;

  const AppUser({
    required super.uid,
    required super.email,
    super.name,
    super.displayName,
    super.photoURL,
    super.phoneNumber,
    super.role = BaseUserRole.client,
    super.fcmToken,
    super.isFirstTime = true,
    super.isOnline = false,
    super.isBlocked = false,
    super.createdAt,
    super.updatedAt,
    this.studioId,
    this.studioIds = const [],
    this.stageName,
    this.genres = const [],
    this.bio,
    this.city,
    this.calendarConnection,
    this.isPartner = false,
    this.studioProfile,
    this.subscription,
    this.isDevMaster = false,
  });

  /// Crée depuis une Map Firestore.
  factory AppUser.fromMap(Map<String, dynamic> map, [String? id]) {
    return AppUser(
      uid: id ?? map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      displayName: map['displayName'],
      photoURL: map['photoUrl'] ?? map['photo_Url'],
      phoneNumber: map['phoneNumber'] ?? map['phone'],
      role: BaseUserRoleExtension.fromString(map['role']),
      fcmToken: map['fcmToken'],
      isFirstTime: map['isFirstTime'] ?? true,
      isOnline: map['isOnline'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
      createdAt: FirestoreModel.dateTimeFromFirestore(map['createdAt']),
      updatedAt: FirestoreModel.dateTimeFromFirestore(map['updatedAt']),
      studioId: map['studioId'],
      studioIds: List<String>.from(map['studioIds'] ?? []),
      stageName: map['stageName'],
      genres: List<String>.from(map['genres'] ?? []),
      bio: map['bio'],
      city: map['city'],
      calendarConnection: map['calendarConnection'] != null
          ? CalendarConnection.fromMap(map['calendarConnection'] as Map<String, dynamic>)
          : null,
      isPartner: map['isPartner'] ?? false,
      studioProfile: map['studioProfile'] != null
          ? StudioProfile.fromMap(map['studioProfile'] as Map<String, dynamic>)
          : null,
      subscription: map['subscription'] != null
          ? StudioSubscription.fromMap(map['subscription'] as Map<String, dynamic>)
          : null,
      isDevMaster: map['isDevMaster'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'studioId': studioId,
      'studioIds': studioIds,
      'stageName': stageName,
      'genres': genres,
      'bio': bio,
      'city': city,
      'calendarConnection': calendarConnection?.toMap(),
      'isPartner': isPartner,
      'studioProfile': studioProfile?.toMap(),
      'subscription': subscription?.toMap(),
      'isDevMaster': isDevMaster,
    };
  }

  @override
  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    BaseUserRole? role,
    String? fcmToken,
    bool? isFirstTime,
    bool? isOnline,
    bool? isBlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? studioId,
    List<String>? studioIds,
    String? stageName,
    List<String>? genres,
    String? bio,
    String? city,
    CalendarConnection? calendarConnection,
    bool? isPartner,
    StudioProfile? studioProfile,
    StudioSubscription? subscription,
    bool? isDevMaster,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      isOnline: isOnline ?? this.isOnline,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studioId: studioId ?? this.studioId,
      studioIds: studioIds ?? this.studioIds,
      stageName: stageName ?? this.stageName,
      genres: genres ?? this.genres,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      calendarConnection: calendarConnection ?? this.calendarConnection,
      isPartner: isPartner ?? this.isPartner,
      studioProfile: studioProfile ?? this.studioProfile,
      subscription: subscription ?? this.subscription,
      isDevMaster: isDevMaster ?? this.isDevMaster,
    );
  }

  /// Vérifie si le calendrier est connecté.
  bool get hasCalendarConnected => calendarConnection?.connected == true;

  /// Vérifie si c'est un propriétaire de studio.
  bool get isStudio => role.isStudio;

  /// Vérifie si c'est un ingénieur.
  bool get isEngineer => role.isEngineer;

  /// Vérifie si c'est un artiste.
  bool get isArtist => role.isArtist;

  /// Vérifie si c'est un super admin.
  bool get isSuperAdmin => role.isSuperAdmin;

  /// Vérifie si le studio est partenaire et a un profil
  bool get hasStudioProfile => isPartner && studioProfile != null;

  /// Nom du studio pour affichage
  String get studioDisplayName =>
      studioProfile?.name ?? displayName ?? name ?? 'Studio';

  /// ID du DevMaster principal (depuis .env pour la sécurité)
  static String get _devMasterUserId =>
      dotenv.env['DEV_MASTER_USER_ID'] ?? '';

  /// Vérifie si l'utilisateur a accès aux configurations système (DevMaster)
  /// Retourne true si:
  /// - L'utilisateur est le DevMaster principal (ID depuis .env)
  /// - OU l'utilisateur est SuperAdmin avec isDevMaster=true dans Firestore
  bool get hasDevMasterAccess =>
      uid == _devMasterUserId || (isSuperAdmin && isDevMaster);

  /// ID du tier d'abonnement actuel (par défaut 'free')
  String get subscriptionTierId => subscription?.tierId ?? 'free';

  /// Vérifie si l'abonnement est actif
  bool get hasActiveSubscription => subscription?.isActive ?? true;

  /// Vérifie si c'est un abonnement payant
  bool get hasPaidSubscription => subscription?.isPaid ?? false;

  /// Nombre de sessions ce mois
  int get sessionsThisMonth => subscription?.sessionsThisMonth ?? 0;

  @override
  List<Object?> get props => [
        ...super.props,
        studioId,
        studioIds,
        stageName,
        genres,
        calendarConnection,
        isPartner,
        studioProfile,
        subscription,
        isDevMaster,
      ];
}
