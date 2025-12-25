import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Abonnement d'un studio spécifique
/// Stocké dans users/{userId}.subscription
class StudioSubscription extends Equatable {
  final String tierId; // 'free', 'pro', 'enterprise'
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final String? stripeSubscriptionId;
  final String? stripeCustomerId;
  final int sessionsThisMonth;
  final DateTime? sessionsResetAt;

  const StudioSubscription({
    this.tierId = 'free',
    this.startedAt,
    this.expiresAt,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
    this.sessionsThisMonth = 0,
    this.sessionsResetAt,
  });

  /// Vérifie si l'abonnement est actif
  bool get isActive {
    if (tierId == 'free') return true;
    if (expiresAt == null) return true;
    return expiresAt!.isAfter(DateTime.now());
  }

  /// Vérifie si l'abonnement est expiré
  bool get isExpired => !isActive;

  /// Vérifie si c'est un abonnement gratuit
  bool get isFree => tierId == 'free';

  /// Vérifie si c'est un abonnement Pro
  bool get isPro => tierId == 'pro';

  /// Vérifie si c'est un abonnement Enterprise
  bool get isEnterprise => tierId == 'enterprise';

  /// Vérifie si c'est un abonnement payant
  bool get isPaid => isPro || isEnterprise;

  /// Jours restants avant expiration
  int get daysUntilExpiration {
    if (expiresAt == null) return -1; // Pas d'expiration
    final now = DateTime.now();
    if (expiresAt!.isBefore(now)) return 0;
    return expiresAt!.difference(now).inDays;
  }

  /// Vérifie si le compteur de sessions doit être réinitialisé
  bool get shouldResetSessions {
    if (sessionsResetAt == null) return true;
    final now = DateTime.now();
    return now.year > sessionsResetAt!.year ||
        now.month > sessionsResetAt!.month;
  }

  /// Crée un abonnement avec le compteur de sessions réinitialisé
  StudioSubscription resetSessionsIfNeeded() {
    if (!shouldResetSessions) return this;
    return copyWith(
      sessionsThisMonth: 0,
      sessionsResetAt: DateTime.now(),
    );
  }

  /// Incrémente le compteur de sessions
  StudioSubscription incrementSessions() {
    final updated = resetSessionsIfNeeded();
    return updated.copyWith(
      sessionsThisMonth: updated.sessionsThisMonth + 1,
    );
  }

  factory StudioSubscription.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StudioSubscription();
    return StudioSubscription(
      tierId: map['tierId'] ?? 'free',
      startedAt: map['startedAt'] != null
          ? (map['startedAt'] as Timestamp).toDate()
          : null,
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] as Timestamp).toDate()
          : null,
      stripeSubscriptionId: map['stripeSubscriptionId'],
      stripeCustomerId: map['stripeCustomerId'],
      sessionsThisMonth: map['sessionsThisMonth'] ?? 0,
      sessionsResetAt: map['sessionsResetAt'] != null
          ? (map['sessionsResetAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'tierId': tierId,
        'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
        'stripeSubscriptionId': stripeSubscriptionId,
        'stripeCustomerId': stripeCustomerId,
        'sessionsThisMonth': sessionsThisMonth,
        'sessionsResetAt': sessionsResetAt != null
            ? Timestamp.fromDate(sessionsResetAt!)
            : null,
      };

  StudioSubscription copyWith({
    String? tierId,
    DateTime? startedAt,
    DateTime? expiresAt,
    String? stripeSubscriptionId,
    String? stripeCustomerId,
    int? sessionsThisMonth,
    DateTime? sessionsResetAt,
  }) {
    return StudioSubscription(
      tierId: tierId ?? this.tierId,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      sessionsThisMonth: sessionsThisMonth ?? this.sessionsThisMonth,
      sessionsResetAt: sessionsResetAt ?? this.sessionsResetAt,
    );
  }

  @override
  List<Object?> get props => [
        tierId,
        startedAt,
        expiresAt,
        stripeSubscriptionId,
        stripeCustomerId,
        sessionsThisMonth,
        sessionsResetAt,
      ];
}
