import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Source de l'indisponibilité
enum UnavailabilitySource {
  google,
  apple,
  manual,
}

extension UnavailabilitySourceExtension on UnavailabilitySource {
  String get label {
    switch (this) {
      case UnavailabilitySource.google:
        return 'Google Calendar';
      case UnavailabilitySource.apple:
        return 'Apple Calendar';
      case UnavailabilitySource.manual:
        return 'Manuel';
    }
  }

  String get value {
    switch (this) {
      case UnavailabilitySource.google:
        return 'google';
      case UnavailabilitySource.apple:
        return 'apple';
      case UnavailabilitySource.manual:
        return 'manual';
    }
  }

  static UnavailabilitySource fromString(String? value) {
    switch (value) {
      case 'google':
        return UnavailabilitySource.google;
      case 'apple':
        return UnavailabilitySource.apple;
      case 'manual':
        return UnavailabilitySource.manual;
      default:
        return UnavailabilitySource.manual;
    }
  }
}

/// Modèle d'indisponibilité
class Unavailability extends Equatable {
  final String id;
  final String studioId;
  final DateTime start;
  final DateTime end;
  final UnavailabilitySource source;
  final String? externalEventId;
  final String? title;
  final DateTime createdAt;

  const Unavailability({
    required this.id,
    required this.studioId,
    required this.start,
    required this.end,
    required this.source,
    this.externalEventId,
    this.title,
    required this.createdAt,
  });

  factory Unavailability.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Unavailability(
      id: doc.id,
      studioId: data['studioId'] as String,
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
      source: UnavailabilitySourceExtension.fromString(data['source'] as String?),
      externalEventId: data['externalEventId'] as String?,
      title: data['title'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studioId': studioId,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'source': source.value,
      'externalEventId': externalEventId,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Unavailability copyWith({
    String? id,
    String? studioId,
    DateTime? start,
    DateTime? end,
    UnavailabilitySource? source,
    String? externalEventId,
    String? title,
    DateTime? createdAt,
  }) {
    return Unavailability(
      id: id ?? this.id,
      studioId: studioId ?? this.studioId,
      start: start ?? this.start,
      end: end ?? this.end,
      source: source ?? this.source,
      externalEventId: externalEventId ?? this.externalEventId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Vérifie si l'indisponibilité chevauche une période donnée
  bool overlapsWith(DateTime otherStart, DateTime otherEnd) {
    return start.isBefore(otherEnd) && end.isAfter(otherStart);
  }

  /// Durée en minutes
  int get durationMinutes => end.difference(start).inMinutes;

  @override
  List<Object?> get props => [
        id,
        studioId,
        start,
        end,
        source,
        externalEventId,
        title,
        createdAt,
      ];
}
