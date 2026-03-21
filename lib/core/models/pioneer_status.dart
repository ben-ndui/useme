import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Pioneer status for early adopters (first 5 studios + first 5 pros).
/// Stored as a nested map in `users/{userId}.pioneer`.
class PioneerStatus extends Equatable {
  final bool isPioneer;
  final int pioneerNumber; // 1-5
  final String pioneerType; // 'studio' | 'pro'
  final DateTime? pioneerSince;
  final DateTime? freeSubscriptionUntil;
  final DateTime? commissionExemptUntil;
  final String? grantedBy; // 'auto' | superAdmin userId

  const PioneerStatus({
    this.isPioneer = false,
    this.pioneerNumber = 0,
    this.pioneerType = '',
    this.pioneerSince,
    this.freeSubscriptionUntil,
    this.commissionExemptUntil,
    this.grantedBy,
  });

  /// Whether the free Pro subscription is still active.
  bool get isFreeSubscriptionActive {
    if (!isPioneer || freeSubscriptionUntil == null) return false;
    return freeSubscriptionUntil!.isAfter(DateTime.now());
  }

  /// Whether the 0% commission exemption is still active.
  bool get isCommissionExempt {
    if (!isPioneer || commissionExemptUntil == null) return false;
    return commissionExemptUntil!.isAfter(DateTime.now());
  }

  /// Days remaining until benefits expire.
  int get daysUntilBenefitsExpire {
    if (commissionExemptUntil == null) return 0;
    final remaining = commissionExemptUntil!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Display label for the badge.
  String get badgeLabel => 'Pioneer #$pioneerNumber';

  factory PioneerStatus.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PioneerStatus();
    return PioneerStatus(
      isPioneer: map['isPioneer'] ?? false,
      pioneerNumber: map['pioneerNumber'] ?? 0,
      pioneerType: map['pioneerType'] ?? '',
      pioneerSince: _parseDate(map['pioneerSince']),
      freeSubscriptionUntil: _parseDate(map['freeSubscriptionUntil']),
      commissionExemptUntil: _parseDate(map['commissionExemptUntil']),
      grantedBy: map['grantedBy'],
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Serializes to map. Note: `grantedBy` is omitted to avoid
  /// leaking admin UIDs — it's only written server-side.
  Map<String, dynamic> toMap() => {
        'isPioneer': isPioneer,
        'pioneerNumber': pioneerNumber,
        'pioneerType': pioneerType,
        'pioneerSince': pioneerSince,
        'freeSubscriptionUntil': freeSubscriptionUntil,
        'commissionExemptUntil': commissionExemptUntil,
      };

  PioneerStatus copyWith({
    bool? isPioneer,
    int? pioneerNumber,
    String? pioneerType,
    DateTime? pioneerSince,
    DateTime? freeSubscriptionUntil,
    DateTime? commissionExemptUntil,
    String? grantedBy,
  }) {
    return PioneerStatus(
      isPioneer: isPioneer ?? this.isPioneer,
      pioneerNumber: pioneerNumber ?? this.pioneerNumber,
      pioneerType: pioneerType ?? this.pioneerType,
      pioneerSince: pioneerSince ?? this.pioneerSince,
      freeSubscriptionUntil:
          freeSubscriptionUntil ?? this.freeSubscriptionUntil,
      commissionExemptUntil:
          commissionExemptUntil ?? this.commissionExemptUntil,
      grantedBy: grantedBy ?? this.grantedBy,
    );
  }

  @override
  List<Object?> get props => [
        isPioneer,
        pioneerNumber,
        pioneerType,
        pioneerSince,
        freeSubscriptionUntil,
        commissionExemptUntil,
        grantedBy,
      ];
}
