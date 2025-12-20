import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Provider de calendrier supporté
enum CalendarProvider {
  google,
  apple,
}

extension CalendarProviderExtension on CalendarProvider {
  String get label {
    switch (this) {
      case CalendarProvider.google:
        return 'Google Calendar';
      case CalendarProvider.apple:
        return 'Apple Calendar';
    }
  }

  String get value {
    switch (this) {
      case CalendarProvider.google:
        return 'google';
      case CalendarProvider.apple:
        return 'apple';
    }
  }

  static CalendarProvider fromString(String? value) {
    switch (value) {
      case 'google':
        return CalendarProvider.google;
      case 'apple':
        return CalendarProvider.apple;
      default:
        return CalendarProvider.google;
    }
  }
}

/// Modèle de connexion calendrier
class CalendarConnection extends Equatable {
  final CalendarProvider provider;
  final bool connected;
  final String? email;
  final String calendarId;
  final DateTime? lastSync;
  final DateTime? connectedAt;

  const CalendarConnection({
    required this.provider,
    required this.connected,
    this.email,
    this.calendarId = 'primary',
    this.lastSync,
    this.connectedAt,
  });

  factory CalendarConnection.fromMap(Map<String, dynamic> map) {
    return CalendarConnection(
      provider: CalendarProviderExtension.fromString(map['provider'] as String?),
      connected: map['connected'] as bool? ?? false,
      email: map['email'] as String?,
      calendarId: map['calendarId'] as String? ?? 'primary',
      lastSync: (map['lastSync'] as Timestamp?)?.toDate(),
      connectedAt: (map['connectedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider': provider.value,
      'connected': connected,
      'email': email,
      'calendarId': calendarId,
      'lastSync': lastSync != null ? Timestamp.fromDate(lastSync!) : null,
      'connectedAt': connectedAt != null ? Timestamp.fromDate(connectedAt!) : null,
    };
  }

  CalendarConnection copyWith({
    CalendarProvider? provider,
    bool? connected,
    String? email,
    String? calendarId,
    DateTime? lastSync,
    DateTime? connectedAt,
  }) {
    return CalendarConnection(
      provider: provider ?? this.provider,
      connected: connected ?? this.connected,
      email: email ?? this.email,
      calendarId: calendarId ?? this.calendarId,
      lastSync: lastSync ?? this.lastSync,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }

  @override
  List<Object?> get props => [provider, connected, email, calendarId, lastSync, connectedAt];
}
