import 'package:cloud_firestore/cloud_firestore.dart';

/// Session type enum (types de sessions studio)
enum SessionType {
  mix,
  mastering,
  recording,
  mixing,
  editing,
  other,
}

extension SessionTypeExtension on SessionType {
  String get label {
    switch (this) {
      case SessionType.mix:
        return 'Mix';
      case SessionType.mastering:
        return 'Mastering';
      case SessionType.recording:
        return 'Enregistrement';
      case SessionType.mixing:
        return 'Mixage';
      case SessionType.editing:
        return 'Montage';
      case SessionType.other:
        return 'Autre';
    }
  }

  static SessionType fromString(String? value) {
    switch (value) {
      case 'mix':
        return SessionType.mix;
      case 'mastering':
        return SessionType.mastering;
      case 'recording':
        return SessionType.recording;
      case 'mixing':
        return SessionType.mixing;
      case 'editing':
        return SessionType.editing;
      default:
        return SessionType.other;
    }
  }
}

/// Session status enum
enum SessionStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
}

extension SessionStatusExtension on SessionStatus {
  String get label {
    switch (this) {
      case SessionStatus.pending:
        return 'En attente';
      case SessionStatus.confirmed:
        return 'Confirmée';
      case SessionStatus.inProgress:
        return 'En cours';
      case SessionStatus.completed:
        return 'Terminée';
      case SessionStatus.cancelled:
        return 'Annulée';
      case SessionStatus.noShow:
        return 'Absent';
    }
  }

  static SessionStatus fromString(String? value) {
    switch (value) {
      case 'confirmed':
        return SessionStatus.confirmed;
      case 'inProgress':
        return SessionStatus.inProgress;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'noShow':
        return SessionStatus.noShow;
      default:
        return SessionStatus.pending;
    }
  }
}

/// Session intervention data (check-in, photos, notes)
class SessionIntervention {
  final DateTime? checkinTime;
  final DateTime? checkoutTime;
  final List<String> photos;
  final String? notes;

  const SessionIntervention({
    this.checkinTime,
    this.checkoutTime,
    this.photos = const [],
    this.notes,
  });

  factory SessionIntervention.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const SessionIntervention();
    return SessionIntervention(
      checkinTime: _parseDateTime(map['checkinTime']),
      checkoutTime: _parseDateTime(map['checkoutTime']),
      photos: List<String>.from(map['photos'] ?? []),
      notes: map['notes']?.toString(),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  Map<String, dynamic> toMap() => {
        'checkinTime': checkinTime?.millisecondsSinceEpoch,
        'checkoutTime': checkoutTime?.millisecondsSinceEpoch,
        'photos': photos,
        'notes': notes,
      };

  SessionIntervention copyWith({
    DateTime? checkinTime,
    DateTime? checkoutTime,
    List<String>? photos,
    String? notes,
  }) =>
      SessionIntervention(
        checkinTime: checkinTime ?? this.checkinTime,
        checkoutTime: checkoutTime ?? this.checkoutTime,
        photos: photos ?? this.photos,
        notes: notes ?? this.notes,
      );

  bool get hasCheckedIn => checkinTime != null;
  bool get hasCheckedOut => checkoutTime != null;
}

/// Session model for studio bookings
class Session {
  final String id;
  final String studioId;
  final String? engineerId;
  final String? engineerName;

  /// Liste des IDs d'artistes participant à la session.
  final List<String> artistIds;

  /// Liste des noms d'artistes (pour affichage sans fetch).
  final List<String> artistNames;

  final SessionType type;
  final SessionStatus status;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final int durationMinutes;
  final String? notes;
  final SessionIntervention intervention;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Session({
    required this.id,
    required this.studioId,
    this.engineerId,
    this.engineerName,
    required this.artistIds,
    required this.artistNames,
    required this.type,
    this.status = SessionStatus.pending,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.durationMinutes,
    this.notes,
    SessionIntervention? intervention,
    required this.createdAt,
    this.updatedAt,
  }) : intervention = intervention ?? const SessionIntervention();

  /// Constructeur pratique pour un seul artiste.
  factory Session.single({
    required String id,
    required String studioId,
    String? engineerId,
    String? engineerName,
    required String artistId,
    required String artistName,
    required SessionType type,
    SessionStatus status = SessionStatus.pending,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    required int durationMinutes,
    String? notes,
    SessionIntervention? intervention,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id,
      studioId: studioId,
      engineerId: engineerId,
      engineerName: engineerName,
      artistIds: [artistId],
      artistNames: [artistName],
      type: type,
      status: status,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      durationMinutes: durationMinutes,
      notes: notes,
      intervention: intervention,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    // Rétro-compatibilité : si artistId/artistName existent (ancien format)
    List<String> artistIds;
    List<String> artistNames;

    if (map['artistIds'] != null) {
      artistIds = List<String>.from(map['artistIds']);
      artistNames = List<String>.from(map['artistNames'] ?? []);
    } else if (map['artistId'] != null) {
      // Ancien format single artist
      artistIds = [map['artistId']?.toString() ?? ''];
      artistNames = [map['artistName']?.toString() ?? ''];
    } else {
      artistIds = [];
      artistNames = [];
    }

    return Session(
      id: map['id']?.toString() ?? '',
      studioId: map['studioId']?.toString() ?? '',
      engineerId: map['engineerId']?.toString(),
      engineerName: map['engineerName']?.toString(),
      artistIds: artistIds,
      artistNames: artistNames,
      type: SessionTypeExtension.fromString(map['type']?.toString()),
      status: SessionStatusExtension.fromString(map['status']?.toString()),
      scheduledStart: _parseDateTime(map['scheduledStart']) ?? DateTime.now(),
      scheduledEnd: _parseDateTime(map['scheduledEnd']) ?? DateTime.now(),
      durationMinutes: map['durationMinutes'] as int? ?? 60,
      notes: map['notes']?.toString(),
      intervention: SessionIntervention.fromMap(
          map['intervention'] as Map<String, dynamic>?),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'studioId': studioId,
        'engineerId': engineerId,
        'engineerName': engineerName,
        'artistIds': artistIds,
        'artistNames': artistNames,
        'type': type.name,
        'status': status.name,
        'scheduledStart': scheduledStart.millisecondsSinceEpoch,
        'scheduledEnd': scheduledEnd.millisecondsSinceEpoch,
        'durationMinutes': durationMinutes,
        'notes': notes,
        'intervention': intervention.toMap(),
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
      };

  Session copyWith({
    String? id,
    String? studioId,
    String? engineerId,
    String? engineerName,
    List<String>? artistIds,
    List<String>? artistNames,
    SessionType? type,
    SessionStatus? status,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    int? durationMinutes,
    String? notes,
    SessionIntervention? intervention,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Session(
        id: id ?? this.id,
        studioId: studioId ?? this.studioId,
        engineerId: engineerId ?? this.engineerId,
        engineerName: engineerName ?? this.engineerName,
        artistIds: artistIds ?? this.artistIds,
        artistNames: artistNames ?? this.artistNames,
        type: type ?? this.type,
        status: status ?? this.status,
        scheduledStart: scheduledStart ?? this.scheduledStart,
        scheduledEnd: scheduledEnd ?? this.scheduledEnd,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        notes: notes ?? this.notes,
        intervention: intervention ?? this.intervention,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  // Helper getters
  bool get hasEngineer => engineerId != null;
  bool get hasArtists => artistIds.isNotEmpty;
  bool get hasMultipleArtists => artistIds.length > 1;
  int get artistCount => artistIds.length;

  bool get isPending => status == SessionStatus.pending;
  bool get isConfirmed => status == SessionStatus.confirmed;
  bool get isInProgress => status == SessionStatus.inProgress;
  bool get isCompleted => status == SessionStatus.completed;
  bool get isCancelled => status == SessionStatus.cancelled;

  double get durationHours => durationMinutes / 60.0;

  /// Nom d'affichage des artistes (séparés par ", " ou "& " pour le dernier).
  String get artistName {
    if (artistNames.isEmpty) return 'Artiste inconnu';
    if (artistNames.length == 1) return artistNames.first;
    if (artistNames.length == 2) return '${artistNames[0]} & ${artistNames[1]}';
    return '${artistNames.sublist(0, artistNames.length - 1).join(', ')} & ${artistNames.last}';
  }

  /// Premier ID artiste (pour rétro-compatibilité).
  String get artistId => artistIds.isNotEmpty ? artistIds.first : '';

  /// Vérifie si un artiste participe à cette session.
  bool hasArtist(String artistId) => artistIds.contains(artistId);

  bool isOnDate(DateTime date) =>
      scheduledStart.year == date.year &&
      scheduledStart.month == date.month &&
      scheduledStart.day == date.day;
}
