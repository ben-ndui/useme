// ignore_for_file: deprecated_member_use_from_same_package
// The deprecated 'type' field is intentionally used for backward compatibility with Firestore

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

  /// Ordre logique pour l'affichage (enregistrement → mix → mastering)
  int get sortOrder {
    switch (this) {
      case SessionType.recording:
        return 0;
      case SessionType.mix:
      case SessionType.mixing:
        return 1;
      case SessionType.mastering:
        return 2;
      case SessionType.editing:
        return 3;
      case SessionType.other:
        return 4;
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

  /// Parse une liste de types depuis Firestore
  static List<SessionType> listFromStrings(List<dynamic>? values) {
    if (values == null || values.isEmpty) return [];
    return values.map((v) => fromString(v?.toString())).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Génère le label combiné pour plusieurs types
  /// Ex: "Enregistrement + Mix + Mastering"
  static String combinedLabel(List<SessionType> types) {
    if (types.isEmpty) return 'Autre';
    final sorted = types.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted.map((t) => t.label).join(' + ');
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
  final String? roomId;
  final String? roomName;

  /// Ingénieur principal (rétro-compatibilité single engineer)
  final String? engineerId;
  final String? engineerName;

  /// Multi-ingénieurs : liste des ingénieurs assignés à la session
  final List<String> engineerIds;
  final List<String> engineerNames;

  /// Ingénieurs à qui la session a été proposée (en attente de réponse)
  final List<String> proposedEngineerIds;

  /// Liste des IDs d'artistes participant à la session.
  final List<String> artistIds;

  /// Liste des noms d'artistes (pour affichage sans fetch).
  final List<String> artistNames;

  /// Types de session multiples (enregistrement, mix, mastering, etc.)
  /// Permet les combinaisons comme "Enregistrement + Mix + Mastering"
  final List<SessionType> types;

  /// Type principal (rétro-compatibilité avec l'ancien format single type)
  @Deprecated('Use types instead')
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
    this.roomId,
    this.roomName,
    this.engineerId,
    this.engineerName,
    this.engineerIds = const [],
    this.engineerNames = const [],
    this.proposedEngineerIds = const [],
    required this.artistIds,
    required this.artistNames,
    List<SessionType>? types,
    SessionType? type,
    this.status = SessionStatus.pending,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.durationMinutes,
    this.notes,
    SessionIntervention? intervention,
    required this.createdAt,
    this.updatedAt,
  })  : types = types ?? (type != null ? [type] : [SessionType.other]),
        type = type ?? (types?.isNotEmpty == true ? types!.first : SessionType.other),
        intervention = intervention ?? const SessionIntervention();

  /// Constructeur pratique pour un seul artiste.
  factory Session.single({
    required String id,
    required String studioId,
    String? roomId,
    String? roomName,
    String? engineerId,
    String? engineerName,
    List<String> engineerIds = const [],
    List<String> engineerNames = const [],
    List<String> proposedEngineerIds = const [],
    required String artistId,
    required String artistName,
    List<SessionType>? types,
    SessionType? type,
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
      roomId: roomId,
      roomName: roomName,
      engineerId: engineerId,
      engineerName: engineerName,
      engineerIds: engineerIds,
      engineerNames: engineerNames,
      proposedEngineerIds: proposedEngineerIds,
      artistIds: [artistId],
      artistNames: [artistName],
      types: types,
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

    // Multi-ingénieurs : support nouveau format + rétro-compat
    List<String> engineerIds = List<String>.from(map['engineerIds'] ?? []);
    List<String> engineerNames = List<String>.from(map['engineerNames'] ?? []);
    List<String> proposedEngineerIds = List<String>.from(map['proposedEngineerIds'] ?? []);

    // Multi-types : support nouveau format + rétro-compat avec 'type' single
    List<SessionType> types;
    if (map['types'] != null && (map['types'] as List).isNotEmpty) {
      types = SessionTypeExtension.listFromStrings(map['types'] as List);
    } else {
      // Fallback sur l'ancien format single type
      types = [SessionTypeExtension.fromString(map['type']?.toString())];
    }

    return Session(
      id: map['id']?.toString() ?? '',
      studioId: map['studioId']?.toString() ?? '',
      roomId: map['roomId']?.toString(),
      roomName: map['roomName']?.toString(),
      engineerId: map['engineerId']?.toString(),
      engineerName: map['engineerName']?.toString(),
      engineerIds: engineerIds,
      engineerNames: engineerNames,
      proposedEngineerIds: proposedEngineerIds,
      artistIds: artistIds,
      artistNames: artistNames,
      types: types,
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
        'roomId': roomId,
        'roomName': roomName,
        'engineerId': engineerId,
        'engineerName': engineerName,
        'engineerIds': engineerIds,
        'engineerNames': engineerNames,
        'proposedEngineerIds': proposedEngineerIds,
        'artistIds': artistIds,
        'artistNames': artistNames,
        'types': types.map((t) => t.name).toList(),
        'type': type.name, // Rétro-compatibilité
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
    String? roomId,
    String? roomName,
    String? engineerId,
    String? engineerName,
    List<String>? engineerIds,
    List<String>? engineerNames,
    List<String>? proposedEngineerIds,
    List<String>? artistIds,
    List<String>? artistNames,
    List<SessionType>? types,
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
        roomId: roomId ?? this.roomId,
        roomName: roomName ?? this.roomName,
        engineerId: engineerId ?? this.engineerId,
        engineerName: engineerName ?? this.engineerName,
        engineerIds: engineerIds ?? this.engineerIds,
        engineerNames: engineerNames ?? this.engineerNames,
        proposedEngineerIds: proposedEngineerIds ?? this.proposedEngineerIds,
        artistIds: artistIds ?? this.artistIds,
        artistNames: artistNames ?? this.artistNames,
        types: types ?? this.types,
        type: type,
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
  bool get hasRoom => roomId != null;

  /// Vérifie si au moins un ingénieur est assigné (single ou multi)
  bool get hasEngineer => engineerId != null || engineerIds.isNotEmpty;

  /// Vérifie si des ingénieurs ont été proposés mais pas encore assignés
  bool get hasPendingProposals => proposedEngineerIds.isNotEmpty;

  /// Vérifie si la session a plusieurs ingénieurs assignés
  bool get hasMultipleEngineers => engineerIds.length > 1;

  /// Nombre d'ingénieurs assignés
  int get engineerCount => engineerIds.isNotEmpty ? engineerIds.length : (engineerId != null ? 1 : 0);

  bool get hasArtists => artistIds.isNotEmpty;
  bool get hasMultipleArtists => artistIds.length > 1;
  int get artistCount => artistIds.length;

  bool get isPending => status == SessionStatus.pending;
  bool get isConfirmed => status == SessionStatus.confirmed;
  bool get isInProgress => status == SessionStatus.inProgress;
  bool get isCompleted => status == SessionStatus.completed;
  bool get isCancelled => status == SessionStatus.cancelled;

  /// Vérifie si la session est passée (date de fin < maintenant)
  bool get isPast => scheduledEnd.isBefore(DateTime.now());

  /// Vérifie si la session est en cours (entre début et fin)
  bool get isCurrentlyHappening {
    final now = DateTime.now();
    return now.isAfter(scheduledStart) && now.isBefore(scheduledEnd);
  }

  /// Statut d'affichage calculé basé sur l'heure actuelle
  /// Prend en compte les sessions confirmées qui sont en cours ou passées
  SessionStatus get displayStatus {
    // Si déjà terminée, annulée ou noShow, garder le statut
    if (status == SessionStatus.completed ||
        status == SessionStatus.cancelled ||
        status == SessionStatus.noShow) {
      return status;
    }

    // Si confirmée et actuellement en cours → afficher "en cours"
    if (status == SessionStatus.confirmed && isCurrentlyHappening) {
      return SessionStatus.inProgress;
    }

    // Si confirmée/pending et passée → afficher "terminée"
    if ((status == SessionStatus.confirmed || status == SessionStatus.pending) && isPast) {
      return SessionStatus.completed;
    }

    // Sinon, garder le statut original
    return status;
  }

  /// Vérifie si la session peut être annulée (pas passée et pas déjà terminée/annulée)
  bool get canBeCancelled =>
      !isPast &&
      !isCurrentlyHappening &&
      status != SessionStatus.completed &&
      status != SessionStatus.cancelled &&
      status != SessionStatus.noShow;

  double get durationHours => durationMinutes / 60.0;

  /// Label combiné des types de session
  /// Ex: "Enregistrement + Mix + Mastering"
  String get typeLabel => SessionTypeExtension.combinedLabel(types);

  /// Vérifie si la session inclut un type spécifique
  bool hasType(SessionType t) => types.contains(t);

  /// Vérifie si c'est une session avec plusieurs types
  bool get hasMultipleTypes => types.length > 1;

  /// Nom d'affichage des artistes (séparés par ", " ou "& " pour le dernier).
  String get artistName {
    if (artistNames.isEmpty) return 'Artiste inconnu';
    if (artistNames.length == 1) return artistNames.first;
    if (artistNames.length == 2) return '${artistNames[0]} & ${artistNames[1]}';
    return '${artistNames.sublist(0, artistNames.length - 1).join(', ')} & ${artistNames.last}';
  }

  /// Nom d'affichage des ingénieurs (single ou multi)
  String get allEngineerNames {
    if (engineerNames.isNotEmpty) {
      if (engineerNames.length == 1) return engineerNames.first;
      if (engineerNames.length == 2) return '${engineerNames[0]} & ${engineerNames[1]}';
      return '${engineerNames.sublist(0, engineerNames.length - 1).join(', ')} & ${engineerNames.last}';
    }
    return engineerName ?? '';
  }

  /// Premier ID artiste (pour rétro-compatibilité).
  String get artistId => artistIds.isNotEmpty ? artistIds.first : '';

  /// Vérifie si un artiste participe à cette session.
  bool hasArtist(String artistId) => artistIds.contains(artistId);

  /// Vérifie si un ingénieur est assigné à cette session
  bool isEngineerAssigned(String engId) =>
      engineerId == engId || engineerIds.contains(engId);

  /// Vérifie si un ingénieur a reçu une proposition pour cette session
  bool isEngineerProposed(String engId) => proposedEngineerIds.contains(engId);

  bool isOnDate(DateTime date) =>
      scheduledStart.year == date.year &&
      scheduledStart.month == date.month &&
      scheduledStart.day == date.day;
}
