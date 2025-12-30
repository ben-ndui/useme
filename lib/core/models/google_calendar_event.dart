import 'package:equatable/equatable.dart';

/// Type d'import pour un événement Google Calendar
enum ImportType {
  session,
  unavailability,
  skip,
}

/// Représente un événement Google Calendar pour l'écran de review
class GoogleCalendarEvent extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;

  // Pour le review - sélection utilisateur
  final ImportType importType;
  final String? selectedArtistId;
  final String? selectedArtistName;
  final String? externalArtistName;

  const GoogleCalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.start,
    required this.end,
    this.isAllDay = false,
    this.importType = ImportType.skip,
    this.selectedArtistId,
    this.selectedArtistName,
    this.externalArtistName,
  });

  /// Crée depuis la réponse JSON du backend
  factory GoogleCalendarEvent.fromJson(Map<String, dynamic> json) {
    return GoogleCalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Sans titre',
      description: json['description'] as String?,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      isAllDay: json['isAllDay'] as bool? ?? false,
    );
  }

  /// Convertit en JSON pour l'import (envoi au backend)
  Map<String, dynamic> toImportJson() {
    return {
      'googleEventId': id,
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'type': importType == ImportType.session ? 'session' : 'unavailability',
      if (selectedArtistId != null) 'artistId': selectedArtistId,
      if (externalArtistName != null) 'artistName': externalArtistName,
      if (selectedArtistName != null && selectedArtistId != null)
        'artistName': selectedArtistName,
    };
  }

  /// Durée en minutes
  int get durationMinutes => end.difference(start).inMinutes;

  /// Copie avec modifications
  GoogleCalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    bool? isAllDay,
    ImportType? importType,
    String? selectedArtistId,
    String? selectedArtistName,
    String? externalArtistName,
  }) {
    return GoogleCalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      start: start ?? this.start,
      end: end ?? this.end,
      isAllDay: isAllDay ?? this.isAllDay,
      importType: importType ?? this.importType,
      selectedArtistId: selectedArtistId ?? this.selectedArtistId,
      selectedArtistName: selectedArtistName ?? this.selectedArtistName,
      externalArtistName: externalArtistName ?? this.externalArtistName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        start,
        end,
        isAllDay,
        importType,
        selectedArtistId,
        selectedArtistName,
        externalArtistName,
      ];
}
