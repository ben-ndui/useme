import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Représente une indisponibilité ponctuelle d'un ingénieur
/// (vacances, maladie, RDV, etc.)
class TimeOff extends Equatable {
  final String id;
  final String engineerId;
  final DateTime start;
  final DateTime end;
  final String? reason;
  final DateTime createdAt;

  const TimeOff({
    required this.id,
    required this.engineerId,
    required this.start,
    required this.end,
    this.reason,
    required this.createdAt,
  });

  /// Vérifie si ce time-off chevauche une période donnée
  bool overlapsWith(DateTime periodStart, DateTime periodEnd) {
    // Deux périodes se chevauchent si l'une commence avant que l'autre finisse
    return start.isBefore(periodEnd) && end.isAfter(periodStart);
  }

  /// Vérifie si une date est dans cette période d'indisponibilité
  bool containsDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);

    return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
  }

  /// Durée en jours (inclus)
  int get durationDays {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays + 1;
  }

  /// Vérifie si le time-off est actuellement en cours
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  /// Vérifie si le time-off est dans le futur
  bool get isFuture => start.isAfter(DateTime.now());

  /// Vérifie si le time-off est passé
  bool get isPast => end.isBefore(DateTime.now());

  /// Suggestions de raisons courantes
  static const List<String> commonReasons = [
    'Vacances',
    'Maladie',
    'RDV médical',
    'Personnel',
    'Formation',
    'Congé familial',
  ];

  Map<String, dynamic> toMap() {
    return {
      'engineerId': engineerId,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TimeOff.fromMap(Map<String, dynamic> map, String documentId) {
    return TimeOff(
      id: documentId,
      engineerId: map['engineerId'] as String,
      start: (map['start'] as Timestamp).toDate(),
      end: (map['end'] as Timestamp).toDate(),
      reason: map['reason'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  TimeOff copyWith({
    String? id,
    String? engineerId,
    DateTime? start,
    DateTime? end,
    String? reason,
    DateTime? createdAt,
  }) {
    return TimeOff(
      id: id ?? this.id,
      engineerId: engineerId ?? this.engineerId,
      start: start ?? this.start,
      end: end ?? this.end,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, engineerId, start, end, reason, createdAt];
}
