import 'package:equatable/equatable.dart';
import '../../models/unavailability.dart';

/// Base calendar event
abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
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
