import 'package:equatable/equatable.dart';
import 'package:useme/core/models/models_exports.dart';

/// Base session event
abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

/// Load all sessions for a studio
class LoadSessionsEvent extends SessionEvent {
  final String studioId;

  const LoadSessionsEvent({required this.studioId});

  @override
  List<Object?> get props => [studioId];
}

/// Load sessions for an engineer
class LoadEngineerSessionsEvent extends SessionEvent {
  final String engineerId;

  const LoadEngineerSessionsEvent({required this.engineerId});

  @override
  List<Object?> get props => [engineerId];
}

/// Load sessions for an artist
class LoadArtistSessionsEvent extends SessionEvent {
  final String artistId;

  const LoadArtistSessionsEvent({required this.artistId});

  @override
  List<Object?> get props => [artistId];
}

/// Create new session (with subscription limit check)
class CreateSessionEvent extends SessionEvent {
  final Session session;
  final String? subscriptionTierId;
  final int? currentSessionCount;

  const CreateSessionEvent({
    required this.session,
    this.subscriptionTierId,
    this.currentSessionCount,
  });

  @override
  List<Object?> get props => [session, subscriptionTierId, currentSessionCount];
}

/// Update existing session
class UpdateSessionEvent extends SessionEvent {
  final Session session;

  const UpdateSessionEvent({required this.session});

  @override
  List<Object?> get props => [session];
}

/// Delete session
class DeleteSessionEvent extends SessionEvent {
  final String sessionId;

  const DeleteSessionEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Update session status
class UpdateSessionStatusEvent extends SessionEvent {
  final String sessionId;
  final SessionStatus status;

  const UpdateSessionStatusEvent({required this.sessionId, required this.status});

  @override
  List<Object?> get props => [sessionId, status];
}

/// Assign engineer to session
class AssignEngineerEvent extends SessionEvent {
  final String sessionId;
  final String engineerId;
  final String engineerName;

  const AssignEngineerEvent({
    required this.sessionId,
    required this.engineerId,
    required this.engineerName,
  });

  @override
  List<Object?> get props => [sessionId, engineerId, engineerName];
}

/// Check-in to session
class CheckinSessionEvent extends SessionEvent {
  final String sessionId;

  const CheckinSessionEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Check-out from session
class CheckoutSessionEvent extends SessionEvent {
  final String sessionId;

  const CheckoutSessionEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Load single session by ID
class LoadSessionByIdEvent extends SessionEvent {
  final String sessionId;

  const LoadSessionByIdEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Clear all sessions (used on logout)
class ClearSessionsEvent extends SessionEvent {
  const ClearSessionsEvent();
}
