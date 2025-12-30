import 'package:equatable/equatable.dart';
import '../../models/calendar_connection.dart';
import '../../models/google_calendar_event.dart';
import '../../models/unavailability.dart';

/// Base calendar state
abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CalendarInitialState extends CalendarState {
  const CalendarInitialState();
}

/// Loading state
class CalendarLoadingState extends CalendarState {
  const CalendarLoadingState();
}

/// Calendar connected state
class CalendarConnectedState extends CalendarState {
  final CalendarConnection connection;
  final List<Unavailability> unavailabilities;
  final bool isSyncing;

  const CalendarConnectedState({
    required this.connection,
    this.unavailabilities = const [],
    this.isSyncing = false,
  });

  CalendarConnectedState copyWith({
    CalendarConnection? connection,
    List<Unavailability>? unavailabilities,
    bool? isSyncing,
  }) {
    return CalendarConnectedState(
      connection: connection ?? this.connection,
      unavailabilities: unavailabilities ?? this.unavailabilities,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [connection, unavailabilities, isSyncing];
}

/// Calendar disconnected state
class CalendarDisconnectedState extends CalendarState {
  final List<Unavailability> manualUnavailabilities;

  const CalendarDisconnectedState({
    this.manualUnavailabilities = const [],
  });

  @override
  List<Object?> get props => [manualUnavailabilities];
}

/// Syncing state
class CalendarSyncingState extends CalendarState {
  final CalendarConnection connection;

  const CalendarSyncingState({required this.connection});

  @override
  List<Object?> get props => [connection];
}

/// Error state
class CalendarErrorState extends CalendarState {
  final String message;

  const CalendarErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// OAuth URL ready state (for connecting)
class CalendarAuthUrlReadyState extends CalendarState {
  final String authUrl;

  const CalendarAuthUrlReadyState({required this.authUrl});

  @override
  List<Object?> get props => [authUrl];
}

/// Unavailability added state
class UnavailabilityAddedState extends CalendarState {
  final Unavailability unavailability;

  const UnavailabilityAddedState({required this.unavailability});

  @override
  List<Object?> get props => [unavailability];
}

/// Unavailability deleted state
class UnavailabilityDeletedState extends CalendarState {
  final String unavailabilityId;

  const UnavailabilityDeletedState({required this.unavailabilityId});

  @override
  List<Object?> get props => [unavailabilityId];
}

// =============================================================================
// IMPORT PREVIEW STATES
// =============================================================================

/// Loading preview events state
class CalendarPreviewLoadingState extends CalendarState {
  const CalendarPreviewLoadingState();
}

/// Preview events loaded state
class CalendarPreviewLoadedState extends CalendarState {
  final List<GoogleCalendarEvent> events;

  const CalendarPreviewLoadedState({required this.events});

  @override
  List<Object?> get props => [events];
}

/// Importing events state
class CalendarImportingState extends CalendarState {
  const CalendarImportingState();
}

/// Import success state
class CalendarImportSuccessState extends CalendarState {
  final int sessionsCreated;
  final int unavailabilitiesCreated;

  const CalendarImportSuccessState({
    required this.sessionsCreated,
    required this.unavailabilitiesCreated,
  });

  @override
  List<Object?> get props => [sessionsCreated, unavailabilitiesCreated];
}
