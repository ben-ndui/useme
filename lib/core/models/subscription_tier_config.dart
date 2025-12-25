import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Configuration d'un tier d'abonnement (géré par SuperAdmin)
/// Stocké dans Firestore: collection 'subscription_tiers'
class SubscriptionTierConfig extends Equatable {
  final String id; // 'free', 'pro', 'enterprise'
  final String name;
  final String description;
  final double priceMonthly;
  final double priceYearly;

  // Limites (-1 = illimité)
  final int maxSessions;
  final int maxRooms;
  final int maxServices;
  final int maxEngineers;

  // Fonctionnalités
  final bool hasDiscoveryVisibility;
  final bool hasAnalytics;
  final bool hasAdvancedAnalytics;
  final bool hasMultiStudios;
  final bool hasApiAccess;
  final bool hasPrioritySupport;
  final bool hasVerifiedBadge;

  // Métadonnées
  final bool isActive;
  final int sortOrder;
  final DateTime? updatedAt;

  const SubscriptionTierConfig({
    required this.id,
    required this.name,
    this.description = '',
    this.priceMonthly = 0,
    this.priceYearly = 0,
    this.maxSessions = -1,
    this.maxRooms = -1,
    this.maxServices = -1,
    this.maxEngineers = -1,
    this.hasDiscoveryVisibility = false,
    this.hasAnalytics = false,
    this.hasAdvancedAnalytics = false,
    this.hasMultiStudios = false,
    this.hasApiAccess = false,
    this.hasPrioritySupport = false,
    this.hasVerifiedBadge = false,
    this.isActive = true,
    this.sortOrder = 0,
    this.updatedAt,
  });

  /// Vérifie si une limite est illimitée
  bool isUnlimited(int limit) => limit == -1;

  /// Vérifie si le tier est gratuit
  bool get isFree => priceMonthly == 0 && priceYearly == 0;

  /// Prix annuel avec réduction (si applicable)
  double get yearlyDiscount {
    if (priceMonthly == 0) return 0;
    final fullYearPrice = priceMonthly * 12;
    return fullYearPrice - priceYearly;
  }

  /// Nombre de mois gratuits avec l'abonnement annuel
  int get freeMonthsWithYearly {
    if (priceMonthly == 0) return 0;
    return ((yearlyDiscount / priceMonthly)).round();
  }

  /// Configurations par défaut des tiers
  static SubscriptionTierConfig get defaultFree => const SubscriptionTierConfig(
        id: 'free',
        name: 'Free',
        description: 'Pour démarrer',
        priceMonthly: 0,
        priceYearly: 0,
        maxSessions: 20,
        maxRooms: 3,
        maxServices: 5,
        maxEngineers: 3,
        hasDiscoveryVisibility: false,
        hasAnalytics: false,
        hasAdvancedAnalytics: false,
        hasMultiStudios: false,
        hasApiAccess: false,
        hasPrioritySupport: false,
        hasVerifiedBadge: false,
        isActive: true,
        sortOrder: 0,
      );

  static SubscriptionTierConfig get defaultPro => const SubscriptionTierConfig(
        id: 'pro',
        name: 'Pro',
        description: 'Pour les studios actifs',
        priceMonthly: 19,
        priceYearly: 190,
        maxSessions: -1,
        maxRooms: 10,
        maxServices: -1,
        maxEngineers: 10,
        hasDiscoveryVisibility: true,
        hasAnalytics: true,
        hasAdvancedAnalytics: false,
        hasMultiStudios: false,
        hasApiAccess: false,
        hasPrioritySupport: false,
        hasVerifiedBadge: true,
        isActive: true,
        sortOrder: 1,
      );

  static SubscriptionTierConfig get defaultEnterprise =>
      const SubscriptionTierConfig(
        id: 'enterprise',
        name: 'Enterprise',
        description: 'Pour les grands studios',
        priceMonthly: 79,
        priceYearly: 790,
        maxSessions: -1,
        maxRooms: -1,
        maxServices: -1,
        maxEngineers: -1,
        hasDiscoveryVisibility: true,
        hasAnalytics: true,
        hasAdvancedAnalytics: true,
        hasMultiStudios: true,
        hasApiAccess: true,
        hasPrioritySupport: true,
        hasVerifiedBadge: true,
        isActive: true,
        sortOrder: 2,
      );

  static List<SubscriptionTierConfig> get defaultTiers => [
        defaultFree,
        defaultPro,
        defaultEnterprise,
      ];

  factory SubscriptionTierConfig.fromMap(Map<String, dynamic> map,
      {String? id}) {
    return SubscriptionTierConfig(
      id: id ?? map['id'] ?? 'unknown',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      priceMonthly: (map['priceMonthly'] as num?)?.toDouble() ?? 0,
      priceYearly: (map['priceYearly'] as num?)?.toDouble() ?? 0,
      maxSessions: map['maxSessions'] ?? -1,
      maxRooms: map['maxRooms'] ?? -1,
      maxServices: map['maxServices'] ?? -1,
      maxEngineers: map['maxEngineers'] ?? -1,
      hasDiscoveryVisibility: map['hasDiscoveryVisibility'] ?? false,
      hasAnalytics: map['hasAnalytics'] ?? false,
      hasAdvancedAnalytics: map['hasAdvancedAnalytics'] ?? false,
      hasMultiStudios: map['hasMultiStudios'] ?? false,
      hasApiAccess: map['hasApiAccess'] ?? false,
      hasPrioritySupport: map['hasPrioritySupport'] ?? false,
      hasVerifiedBadge: map['hasVerifiedBadge'] ?? false,
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'priceMonthly': priceMonthly,
        'priceYearly': priceYearly,
        'maxSessions': maxSessions,
        'maxRooms': maxRooms,
        'maxServices': maxServices,
        'maxEngineers': maxEngineers,
        'hasDiscoveryVisibility': hasDiscoveryVisibility,
        'hasAnalytics': hasAnalytics,
        'hasAdvancedAnalytics': hasAdvancedAnalytics,
        'hasMultiStudios': hasMultiStudios,
        'hasApiAccess': hasApiAccess,
        'hasPrioritySupport': hasPrioritySupport,
        'hasVerifiedBadge': hasVerifiedBadge,
        'isActive': isActive,
        'sortOrder': sortOrder,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  SubscriptionTierConfig copyWith({
    String? id,
    String? name,
    String? description,
    double? priceMonthly,
    double? priceYearly,
    int? maxSessions,
    int? maxRooms,
    int? maxServices,
    int? maxEngineers,
    bool? hasDiscoveryVisibility,
    bool? hasAnalytics,
    bool? hasAdvancedAnalytics,
    bool? hasMultiStudios,
    bool? hasApiAccess,
    bool? hasPrioritySupport,
    bool? hasVerifiedBadge,
    bool? isActive,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return SubscriptionTierConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceMonthly: priceMonthly ?? this.priceMonthly,
      priceYearly: priceYearly ?? this.priceYearly,
      maxSessions: maxSessions ?? this.maxSessions,
      maxRooms: maxRooms ?? this.maxRooms,
      maxServices: maxServices ?? this.maxServices,
      maxEngineers: maxEngineers ?? this.maxEngineers,
      hasDiscoveryVisibility:
          hasDiscoveryVisibility ?? this.hasDiscoveryVisibility,
      hasAnalytics: hasAnalytics ?? this.hasAnalytics,
      hasAdvancedAnalytics: hasAdvancedAnalytics ?? this.hasAdvancedAnalytics,
      hasMultiStudios: hasMultiStudios ?? this.hasMultiStudios,
      hasApiAccess: hasApiAccess ?? this.hasApiAccess,
      hasPrioritySupport: hasPrioritySupport ?? this.hasPrioritySupport,
      hasVerifiedBadge: hasVerifiedBadge ?? this.hasVerifiedBadge,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        priceMonthly,
        priceYearly,
        maxSessions,
        maxRooms,
        maxServices,
        maxEngineers,
        hasDiscoveryVisibility,
        hasAnalytics,
        hasAdvancedAnalytics,
        hasMultiStudios,
        hasApiAccess,
        hasPrioritySupport,
        hasVerifiedBadge,
        isActive,
        sortOrder,
        updatedAt,
      ];
}
