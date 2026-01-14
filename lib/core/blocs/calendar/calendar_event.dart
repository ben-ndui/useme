import 'package:equatable/equatable.dart';
import '../../models/google_calendar_event.dart';
import 'package:smoothandesign_package/core/models/unavailability.dart';

/// Base calendar event
abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

/// Reset calendar state (on logout)
class ResetCalendarEvent extends CalendarEvent {
  const ResetCalendarEvent();
}

/// Load calendar connection status
class LoadCalendarStatusEvent extends CalendarEvent {
  final String userId;

  const LoadCalendarStatusEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Connect Google Calendar
class ConnectGoogleCalendarEvent extends CalendarEvent {
  final String userId;

  const ConnectGoogleCalendarEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Disconnect calendar
class DisconnectCalendarEvent extends CalendarEvent {
  final String userId;

  const DisconnectCalendarEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Sync calendar (manual)
class SyncCalendarEvent extends CalendarEvent {
  final String userId;

  const SyncCalendarEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Load unavailabilities for a studio
class LoadUnavailabilitiesEvent extends CalendarEvent {
  final String studioId;

  const LoadUnavailabilitiesEvent({required this.studioId});

  @override
  List<Object?> get props => [studioId];
}

/// Add manual unavailability
class AddUnavailabilityEvent extends CalendarEvent {
  final Unavailability unavailability;

  const AddUnavailabilityEvent({required this.unavailability});

  @override
  List<Object?> get props => [unavailability];
}

/// Delete unavailability
class DeleteUnavailabilityEvent extends CalendarEvent {
  final String unavailabilityId;

  const DeleteUnavailabilityEvent({required this.unavailabilityId});

  @override
  List<Object?> get props => [unavailabilityId];
}

/// Calendar connected callback (from OAuth redirect)
class CalendarConnectedEvent extends CalendarEvent {
  final String userId;
  final bool success;
  final String? error;

  const CalendarConnectedEvent({
    required this.userId,
    required this.success,
    this.error,
  });

  @override
  List<Object?> get props => [userId, success, error];
}

/// Internal event: unavailabilities updated from stream
class UnavailabilitiesUpdatedEvent extends CalendarEvent {
  final List<Unavailability> unavailabilities;

  const UnavailabilitiesUpdatedEvent({required this.unavailabilities});

  @override
  List<Object?> get props => [unavailabilities];
}

// =============================================================================
// IMPORT PREVIEW EVENTS
// =============================================================================

/// Fetch calendar events for preview/review
class FetchCalendarPreviewEvent extends CalendarEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const FetchCalendarPreviewEvent({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

/// Import categorized events (sessions or unavailabilities)
class ImportCategorizedEventsEvent extends CalendarEvent {
  final String userId;
  final List<GoogleCalendarEvent> events;

  const ImportCategorizedEventsEvent({
    required this.userId,
    required this.events,
  });

  @override
  List<Object?> get props => [userId, events];
}
